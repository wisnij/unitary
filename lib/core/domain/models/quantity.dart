import 'dart:math' as math;

import '../errors.dart';
import 'dimension.dart';
import 'rational.dart';

/// Represents a physical quantity: a numeric value combined with dimensional
/// information.
///
/// All arithmetic operations maintain dimensional consistency.  The value is
/// stored as a [double]; NaN values are rejected at construction time
/// (fail-fast).
class Quantity {
  /// The numeric value of this quantity.
  final double value;

  /// The dimension of this quantity (a map of unit IDs to exponents).
  final Dimension dimension;

  /// Epsilon for floating-point comparisons.
  static const double epsilon = 1e-10;

  /// Creates a quantity with the given [value] and [dimension].
  ///
  /// Throws [EvalException] if [value] is NaN.
  Quantity(double value, this.dimension) : value = _validateValue(value);

  /// Creates a dimensionless quantity.
  Quantity.dimensionless(double value)
    : value = _validateValue(value),
      dimension = Dimension.dimensionless;

  static double _validateValue(double value) {
    if (value.isNaN) {
      throw EvalException(
        'Invalid computation resulted in undefined value (NaN)',
      );
    }
    return value;
  }

  static final Quantity unity = Quantity.dimensionless(1.0);

  // -- Query properties --

  /// Whether this quantity is dimensionless.
  bool get isDimensionless => dimension.isDimensionless;

  /// Whether the value is exactly zero.
  bool get isZero => value == 0.0;

  /// Whether the value is strictly positive.
  bool get isPositive => value > 0.0;

  /// Whether the value is strictly negative.
  bool get isNegative => value < 0.0;

  /// Whether this quantity has the same dimension as [other].
  bool isConformableWith(Quantity other) =>
      dimension.isConformableWith(other.dimension);

  // -- Arithmetic operations --

  /// Adds two conformable quantities.
  ///
  /// Throws [DimensionException] if the dimensions differ.
  Quantity add(Quantity other) {
    _requireConformable(other, 'add');
    return Quantity(value + other.value, dimension);
  }

  /// Subtracts two conformable quantities.
  ///
  /// Throws [DimensionException] if the dimensions differ.
  Quantity subtract(Quantity other) {
    _requireConformable(other, 'subtract');
    return Quantity(value - other.value, dimension);
  }

  /// Multiplies two quantities, combining their dimensions.
  Quantity multiply(Quantity other) {
    return Quantity(value * other.value, dimension.multiply(other.dimension));
  }

  /// Divides two quantities, combining their dimensions.
  ///
  /// Throws [EvalException] if dividing by zero.
  Quantity divide(Quantity other) {
    if (other.value == 0.0) {
      throw EvalException('Division by zero');
    }
    return Quantity(value / other.value, dimension.divide(other.dimension));
  }

  /// Returns this quantity with negated value.
  Quantity negate() => Quantity(-value, dimension);

  /// Returns this quantity with absolute value.
  Quantity abs() => Quantity(value.abs(), dimension);

  /// Raises this quantity to the given [exponent].
  ///
  /// For dimensioned quantities, the exponent must be rational and all
  /// dimension exponents must be evenly divisible.  Throws
  /// [DimensionException] if not.  Throws [EvalException] if the
  /// computation is invalid (e.g., negative base with fractional exponent).
  Quantity power(num exponent) {
    if (exponent == 0) return Quantity.unity;
    if (exponent == 1) return Quantity(value, dimension);

    if (isDimensionless) {
      _checkNegativeBaseFractional(exponent);
      return Quantity.dimensionless(math.pow(value, exponent).toDouble());
    }

    // Dimensioned quantity: recover rational exponent and validate.
    final Rational rational;
    if (exponent is int) {
      rational = Rational.fromInt(exponent);
    } else {
      rational = Rational.fromDouble(exponent.toDouble());

      // Verify the recovered rational is close enough.
      final recovered = rational.toDouble();
      if ((recovered - exponent).abs() > epsilon) {
        throw EvalException(
          'Cannot determine rational approximation for exponent: $exponent',
        );
      }
    }

    // Validate and compute new dimension.
    final newDimension = dimension.powerRational(rational);

    _checkNegativeBaseFractional(exponent);

    return Quantity(math.pow(value, exponent).toDouble(), newDimension);
  }

  void _checkNegativeBaseFractional(num exponent) {
    if (value < 0 &&
        exponent is double &&
        exponent != exponent.truncateToDouble()) {
      throw EvalException(
        'Cannot raise negative number to fractional power: '
        '$value ^ $exponent',
      );
    }
  }

  // -- Comparison --

  /// Returns `true` if this quantity approximately equals [other] within
  /// the given [tolerance].
  ///
  /// Uses relative tolerance for large values and absolute tolerance for
  /// small values.  Returns `false` if dimensions differ.
  bool approximatelyEquals(Quantity other, {double tolerance = epsilon}) {
    if (!dimension.isConformableWith(other.dimension)) return false;

    final maxVal = math.max(value.abs(), other.value.abs());
    final effectiveTolerance = maxVal > 1.0 ? tolerance * maxVal : tolerance;
    return (value - other.value).abs() <= effectiveTolerance;
  }

  // -- Operators --

  Quantity operator +(Quantity other) => add(other);
  Quantity operator -(Quantity other) => subtract(other);
  Quantity operator *(Quantity other) => multiply(other);
  Quantity operator /(Quantity other) => divide(other);
  Quantity operator -() => negate();

  // -- Internal --

  void _requireConformable(Quantity other, String operation) {
    if (!dimension.isConformableWith(other.dimension)) {
      throw DimensionException(
        'Cannot $operation quantities with different dimensions: '
        '${dimension.canonicalRepresentation()} and '
        '${other.dimension.canonicalRepresentation()}',
      );
    }
  }

  @override
  String toString() =>
      'Quantity($value, ${dimension.canonicalRepresentation()})';
}
