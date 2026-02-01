import 'dart:collection';

import '../errors.dart';
import 'rational.dart';

/// Represents a physical dimension as a product of primitive units with
/// integer exponents.
///
/// For example, velocity is `{m: 1, s: -1}` and force is
/// `{kg: 1, m: 1, s: -2}`.  A dimensionless quantity has an empty map.
class Dimension {
  /// Map from primitive unit ID to its integer exponent.
  ///
  /// Zero exponents are stripped on construction; this map is never modified
  /// after creation.
  final Map<String, int> primitiveExponents;

  /// Creates a dimension from a map of primitive unit IDs to exponents.
  ///
  /// Zero exponents are automatically removed.
  Dimension(Map<String, int> exponents)
    : primitiveExponents = UnmodifiableMapView(
        Map.fromEntries(exponents.entries.where((e) => e.value != 0)),
      );

  /// Creates a dimensionless dimension (empty exponent map).
  Dimension.dimensionless() : primitiveExponents = const {};

  /// Whether this dimension is dimensionless (empty exponent map).
  bool get isDimensionless => primitiveExponents.isEmpty;

  /// Returns the dimension that results from multiplying this dimension by
  /// [other] (adds exponents for each primitive).
  Dimension multiply(Dimension other) {
    final result = Map<String, int>.from(primitiveExponents);
    for (final entry in other.primitiveExponents.entries) {
      result[entry.key] = (result[entry.key] ?? 0) + entry.value;
    }
    return Dimension(result);
  }

  /// Returns the dimension that results from dividing this dimension by
  /// [other] (subtracts exponents for each primitive).
  Dimension divide(Dimension other) {
    final result = Map<String, int>.from(primitiveExponents);
    for (final entry in other.primitiveExponents.entries) {
      result[entry.key] = (result[entry.key] ?? 0) - entry.value;
    }
    return Dimension(result);
  }

  /// Returns this dimension raised to an integer [exponent] (multiplies all
  /// exponents by the scalar).
  Dimension power(int exponent) {
    if (exponent == 0) return Dimension.dimensionless();
    final result = <String, int>{};
    for (final entry in primitiveExponents.entries) {
      result[entry.key] = entry.value * exponent;
    }
    return Dimension(result);
  }

  /// Returns this dimension raised to a rational [exponent].
  ///
  /// Each primitive exponent is multiplied by the rational's numerator, then
  /// divided by its denominator.  Throws [DimensionException] if any result
  /// is not evenly divisible.
  Dimension powerRational(Rational exponent) {
    if (isDimensionless) return Dimension.dimensionless();

    final result = <String, int>{};
    for (final entry in primitiveExponents.entries) {
      final product = entry.value * exponent.numerator;
      if (product % exponent.denominator != 0) {
        final resultExp =
            entry.value * exponent.numerator / exponent.denominator;
        throw DimensionException(
          'Cannot raise dimension ${entry.key}^${entry.value} to power '
          '$exponent: result would be ${entry.key}^$resultExp '
          'which is not an integer',
        );
      }
      result[entry.key] = product ~/ exponent.denominator;
    }
    return Dimension(result);
  }

  /// Whether this dimension is the same as [other] (same primitives with
  /// same exponents), meaning quantities with these dimensions are
  /// conformable.
  bool isCompatibleWith(Dimension other) => this == other;

  /// Returns a human-readable string like `kg m / s^2`.
  ///
  /// Primitives are sorted alphabetically.  Positive exponents appear in
  /// the numerator, negative in the denominator.  Returns `'1'` for
  /// dimensionless.
  String canonicalRepresentation() {
    if (isDimensionless) return '1';

    final positive = <String>[];
    final negative = <String>[];

    final sorted = primitiveExponents.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sorted) {
      if (entry.value > 0) {
        positive.add(
          entry.value == 1 ? entry.key : '${entry.key}^${entry.value}',
        );
      } else if (entry.value < 0) {
        final posExp = -entry.value;
        negative.add(posExp == 1 ? entry.key : '${entry.key}^$posExp');
      }
    }

    final numerator = positive.isEmpty ? '1' : positive.join(' ');
    if (negative.isEmpty) return numerator;
    return '$numerator / ${negative.join(' ')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Dimension) return false;
    if (primitiveExponents.length != other.primitiveExponents.length) {
      return false;
    }
    for (final entry in primitiveExponents.entries) {
      if (other.primitiveExponents[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    // Sort entries for order-independent hashing.
    final sorted = primitiveExponents.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Object.hashAll(sorted.map((e) => Object.hash(e.key, e.value)));
  }

  @override
  String toString() => 'Dimension(${canonicalRepresentation()})';
}
