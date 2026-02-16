/// A rational number represented as a numerator/denominator pair.
///
/// Used primarily for recovering rational approximations from `double`
/// exponents during dimensional analysis.  Always stored in lowest terms
/// with a positive denominator.
class Rational {
  /// The numerator, in lowest terms.
  final int numerator;

  /// The denominator, always positive and in lowest terms.
  final int denominator;

  /// Creates a rational number, normalizing sign and reducing by GCD.
  ///
  /// Throws [ArgumentError] if [denominator] is zero.
  factory Rational(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError('Denominator must not be zero');
    }

    // Normalize: GCD reduction and positive denominator.
    final g = numerator.gcd(denominator).abs();
    var n = numerator ~/ g;
    var d = denominator ~/ g;
    if (d < 0) {
      n = -n;
      d = -d;
    }

    return Rational._(n, d);
  }

  const Rational._(this.numerator, this.denominator);

  /// Creates a rational from an integer (denominator = 1).
  Rational.fromInt(int value) : numerator = value, denominator = 1;

  /// Recovers a rational approximation from a [double] using continued
  /// fractions.
  ///
  /// The [maxDenominator] parameter limits the complexity of the recovered
  /// fraction (default: 100).
  ///
  /// Throws [ArgumentError] if [value] is NaN or infinite.
  factory Rational.fromDouble(double value, {int maxDenominator = 100}) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError('Cannot convert $value to rational');
    }

    final sign = value < 0 ? -1 : 1;
    final x = value.abs();

    // Handle integers directly.
    if (x == x.truncateToDouble()) {
      return Rational.fromInt((x * sign).toInt());
    }

    // Continued fraction algorithm.
    var n0 = 0, d0 = 1; // Previous convergent.
    var n1 = 1, d1 = 0; // Current convergent.

    var remainder = x;

    for (var i = 0; i < 100; i++) {
      final a = remainder.floor();

      final n2 = a * n1 + n0;
      final d2 = a * d1 + d0;

      if (d2 > maxDenominator) {
        return Rational(n1 * sign, d1);
      }

      if ((n2 / d2 - x).abs() < 1e-10) {
        return Rational(n2 * sign, d2);
      }

      remainder = 1.0 / (remainder - a);
      n0 = n1;
      n1 = n2;
      d0 = d1;
      d1 = d2;

      if (remainder.isInfinite || remainder.isNaN) {
        break;
      }
    }

    return Rational(n1 * sign, d1);
  }

  /// Converts this rational to a [double].
  double toDouble() => numerator / denominator;

  @override
  String toString() {
    if (denominator == 1) {
      return '$numerator';
    }
    return '$numerator/$denominator';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Rational) {
      return false;
    }
    return numerator == other.numerator && denominator == other.denominator;
  }

  @override
  int get hashCode => Object.hash(numerator, denominator);
}
