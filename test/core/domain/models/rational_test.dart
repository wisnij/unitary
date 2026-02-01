import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/rational.dart';

void main() {
  group('Rational constructor', () {
    test('stores numerator and denominator', () {
      final r = Rational(3, 4);
      expect(r.numerator, 3);
      expect(r.denominator, 4);
    });

    test('normalizes by GCD', () {
      final r = Rational(6, 8);
      expect(r.numerator, 3);
      expect(r.denominator, 4);
    });

    test('normalizes large GCD', () {
      final r = Rational(100, 250);
      expect(r.numerator, 2);
      expect(r.denominator, 5);
    });

    test('normalizes sign to numerator', () {
      final r = Rational(3, -4);
      expect(r.numerator, -3);
      expect(r.denominator, 4);
    });

    test('double negative normalizes to positive', () {
      final r = Rational(-3, -6);
      expect(r.numerator, 1);
      expect(r.denominator, 2);
    });

    test('zero numerator', () {
      final r = Rational(0, 5);
      expect(r.numerator, 0);
      expect(r.denominator, 1);
    });

    test('throws on zero denominator', () {
      expect(() => Rational(1, 0), throwsArgumentError);
    });
  });

  group('Rational.fromInt', () {
    test('creates integer rational', () {
      final r = Rational.fromInt(5);
      expect(r.numerator, 5);
      expect(r.denominator, 1);
    });

    test('negative integer', () {
      final r = Rational.fromInt(-3);
      expect(r.numerator, -3);
      expect(r.denominator, 1);
    });

    test('zero', () {
      final r = Rational.fromInt(0);
      expect(r.numerator, 0);
      expect(r.denominator, 1);
    });
  });

  group('Rational.fromDouble', () {
    test('recovers 1/2 from 0.5', () {
      final r = Rational.fromDouble(0.5);
      expect(r.numerator, 1);
      expect(r.denominator, 2);
    });

    test('recovers 1/3 from 0.333...', () {
      final r = Rational.fromDouble(1.0 / 3.0);
      expect(r.numerator, 1);
      expect(r.denominator, 3);
    });

    test('recovers 1/4 from 0.25', () {
      final r = Rational.fromDouble(0.25);
      expect(r.numerator, 1);
      expect(r.denominator, 4);
    });

    test('recovers 2/3 from 0.666...', () {
      final r = Rational.fromDouble(2.0 / 3.0);
      expect(r.numerator, 2);
      expect(r.denominator, 3);
    });

    test('recovers 1/5 from 0.2', () {
      final r = Rational.fromDouble(0.2);
      expect(r.numerator, 1);
      expect(r.denominator, 5);
    });

    test('recovers 3/7 from double', () {
      final r = Rational.fromDouble(3.0 / 7.0);
      expect(r.numerator, 3);
      expect(r.denominator, 7);
    });

    test('recovers integer 3 from 3.0', () {
      final r = Rational.fromDouble(3.0);
      expect(r.numerator, 3);
      expect(r.denominator, 1);
    });

    test('recovers 0 from 0.0', () {
      final r = Rational.fromDouble(0.0);
      expect(r.numerator, 0);
      expect(r.denominator, 1);
    });

    test('recovers negative -1/2 from -0.5', () {
      final r = Rational.fromDouble(-0.5);
      expect(r.numerator, -1);
      expect(r.denominator, 2);
    });

    test('recovers -1/3 from negative', () {
      final r = Rational.fromDouble(-1.0 / 3.0);
      expect(r.numerator, -1);
      expect(r.denominator, 3);
    });

    test('respects maxDenominator', () {
      // Pi ≈ 355/113 with maxDenominator=1000
      // but with maxDenominator=10, should get 22/7
      final r = Rational.fromDouble(3.14159265, maxDenominator: 10);
      expect(r.denominator, lessThanOrEqualTo(10));
    });

    test('throws on NaN', () {
      expect(() => Rational.fromDouble(double.nan), throwsArgumentError);
    });

    test('throws on positive infinity', () {
      expect(() => Rational.fromDouble(double.infinity), throwsArgumentError);
    });

    test('throws on negative infinity', () {
      expect(
        () => Rational.fromDouble(double.negativeInfinity),
        throwsArgumentError,
      );
    });
  });

  group('Rational.toDouble', () {
    test('1/2 converts to 0.5', () {
      expect(Rational(1, 2).toDouble(), 0.5);
    });

    test('3/4 converts to 0.75', () {
      expect(Rational(3, 4).toDouble(), 0.75);
    });

    test('round-trip: fromDouble then toDouble', () {
      const values = [0.5, 0.25, 0.2, 0.125, 0.1];
      for (final v in values) {
        final r = Rational.fromDouble(v);
        expect(r.toDouble(), closeTo(v, 1e-10));
      }
    });
  });

  group('Rational.toString', () {
    test('shows fraction', () {
      expect(Rational(3, 4).toString(), '3/4');
    });

    test('integer omits denominator', () {
      expect(Rational(5, 1).toString(), '5');
    });

    test('zero shows as 0', () {
      expect(Rational(0, 1).toString(), '0');
    });

    test('negative fraction', () {
      expect(Rational(-1, 2).toString(), '-1/2');
    });
  });

  group('Rational equality', () {
    test('equal rationals', () {
      expect(Rational(1, 2), equals(Rational(1, 2)));
    });

    test('equal after normalization', () {
      expect(Rational(2, 4), equals(Rational(1, 2)));
    });

    test('unequal rationals', () {
      expect(Rational(1, 2), isNot(equals(Rational(1, 3))));
    });

    test('consistent hashCode for equal values', () {
      expect(Rational(2, 4).hashCode, equals(Rational(1, 2).hashCode));
    });
  });
}
