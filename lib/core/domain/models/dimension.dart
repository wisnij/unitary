import 'dart:collection';

import '../errors.dart';
import 'rational.dart';

/// Represents a physical dimension as a product of units with integer
/// exponents.
///
/// For example, velocity is `{m: 1, s: -1}` and force is
/// `{kg: 1, m: 1, s: -2}`.  A dimensionless quantity has an empty map.
class Dimension {
  /// Map from unit ID to its integer exponent.
  ///
  /// Zero exponents are stripped on construction; this map is never modified
  /// after creation.
  final Map<String, int> units;

  /// Creates a dimension from a map of unit IDs to exponents.
  ///
  /// Zero exponents are automatically removed.
  Dimension(Map<String, int> unitExponents)
    : units = UnmodifiableMapView(
        Map.fromEntries(unitExponents.entries.where((e) => e.value != 0)),
      );

  /// Creates a dimensionless dimension (empty units map).
  static final Dimension dimensionless = Dimension({});

  /// Whether this dimension is dimensionless (empty units map).
  bool get isDimensionless => units.isEmpty;

  /// Returns the dimension that results from multiplying this dimension by
  /// [other] (adds exponents for each unit).
  Dimension multiply(Dimension other) {
    final result = Map<String, int>.from(units);
    for (final entry in other.units.entries) {
      result[entry.key] = (result[entry.key] ?? 0) + entry.value;
    }
    return Dimension(result);
  }

  /// Returns the dimension that results from dividing this dimension by
  /// [other] (subtracts exponents for each unit).
  Dimension divide(Dimension other) {
    final result = Map<String, int>.from(units);
    for (final entry in other.units.entries) {
      result[entry.key] = (result[entry.key] ?? 0) - entry.value;
    }
    return Dimension(result);
  }

  /// Returns this dimension raised to an integer [exponent] (multiplies all
  /// exponents by the scalar).
  Dimension power(int exponent) {
    if (exponent == 0) return Dimension.dimensionless;
    final result = <String, int>{};
    for (final entry in units.entries) {
      result[entry.key] = entry.value * exponent;
    }
    return Dimension(result);
  }

  /// Returns this dimension raised to a rational [exponent].
  ///
  /// Each unit exponent is multiplied by the rational's numerator, then divided
  /// by its denominator.  Throws [DimensionException] if any result is not
  /// evenly divisible.
  Dimension powerRational(Rational exponent) {
    if (isDimensionless) return Dimension.dimensionless;

    final result = <String, int>{};
    for (final entry in units.entries) {
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

  /// Whether this dimension is the same as [other] (same units with same
  /// exponents), meaning quantities with these dimensions are conformable.
  bool isConformableWith(Dimension other) => this == other;

  /// Returns a human-readable string like `kg m / s^2`.
  ///
  /// Units are sorted alphabetically.  Positive exponents appear in
  /// the numerator, negative in the denominator.  Returns `'1'` for
  /// dimensionless.
  String canonicalRepresentation() {
    if (isDimensionless) return '1';

    final positive = <String>[];
    final negative = <String>[];

    final sorted = units.entries.toList()
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
    if (units.length != other.units.length) {
      return false;
    }
    for (final entry in units.entries) {
      if (other.units[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    // Sort entries for order-independent hashing.
    final sorted = units.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Object.hashAll(sorted.map((e) => Object.hash(e.key, e.value)));
  }

  @override
  String toString() => 'Dimension(${canonicalRepresentation()})';
}
