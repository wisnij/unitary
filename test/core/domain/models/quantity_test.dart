import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';

void main() {
  group('Quantity construction', () {
    test('stores value and dimension', () {
      final q = Quantity(5.0, Dimension({'m': 1}));
      expect(q.value, 5.0);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('dimensionless constructor', () {
      final q = Quantity.dimensionless(3.14);
      expect(q.value, 3.14);
      expect(q.isDimensionless, isTrue);
    });

    test('NaN value throws EvalException', () {
      expect(
        () => Quantity(double.nan, Dimension.dimensionless()),
        throwsA(isA<EvalException>()),
      );
    });

    test('infinity is allowed', () {
      final q = Quantity(double.infinity, Dimension.dimensionless());
      expect(q.value, double.infinity);
    });

    test('negative infinity is allowed', () {
      final q = Quantity(double.negativeInfinity, Dimension({'m': 1}));
      expect(q.value, double.negativeInfinity);
    });

    test('zero value is allowed', () {
      final q = Quantity(0.0, Dimension({'m': 1}));
      expect(q.value, 0.0);
    });
  });

  group('Quantity query properties', () {
    test('isDimensionless', () {
      expect(Quantity.dimensionless(1.0).isDimensionless, isTrue);
      expect(Quantity(1.0, Dimension({'m': 1})).isDimensionless, isFalse);
    });

    test('isZero', () {
      expect(Quantity.dimensionless(0.0).isZero, isTrue);
      expect(Quantity.dimensionless(1.0).isZero, isFalse);
    });

    test('isPositive', () {
      expect(Quantity.dimensionless(1.0).isPositive, isTrue);
      expect(Quantity.dimensionless(0.0).isPositive, isFalse);
      expect(Quantity.dimensionless(-1.0).isPositive, isFalse);
    });

    test('isNegative', () {
      expect(Quantity.dimensionless(-1.0).isNegative, isTrue);
      expect(Quantity.dimensionless(0.0).isNegative, isFalse);
      expect(Quantity.dimensionless(1.0).isNegative, isFalse);
    });
  });

  group('Quantity.add', () {
    test('adds conformable quantities', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(3.0, Dimension({'m': 1}));
      final result = a + b;
      expect(result.value, 8.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('adds dimensionless quantities', () {
      final a = Quantity.dimensionless(2.0);
      final b = Quantity.dimensionless(3.0);
      expect((a + b).value, 5.0);
    });

    test('throws on non-conformable dimensions', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(3.0, Dimension({'s': 1}));
      expect(() => a + b, throwsA(isA<DimensionException>()));
    });

    test('adding zero preserves value', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(0.0, Dimension({'m': 1}));
      expect((a + b).value, 5.0);
    });
  });

  group('Quantity.subtract', () {
    test('subtracts conformable quantities', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(3.0, Dimension({'m': 1}));
      final result = a - b;
      expect(result.value, 2.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('throws on non-conformable dimensions', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(3.0, Dimension({'s': 1}));
      expect(() => a - b, throwsA(isA<DimensionException>()));
    });
  });

  group('Quantity.multiply', () {
    test('multiplies values and combines dimensions', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(3.0, Dimension({'m': 1}));
      final result = a * b;
      expect(result.value, 15.0);
      expect(result.dimension, Dimension({'m': 2}));
    });

    test('different dimensions', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(2.0, Dimension({'s': 1}));
      final result = a * b;
      expect(result.value, 10.0);
      expect(result.dimension, Dimension({'m': 1, 's': 1}));
    });

    test('multiply by dimensionless', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity.dimensionless(3.0);
      final result = a * b;
      expect(result.value, 15.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('multiply producing dimensionless', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(2.0, Dimension({'m': -1}));
      final result = a * b;
      expect(result.value, 10.0);
      expect(result.isDimensionless, isTrue);
    });
  });

  group('Quantity.divide', () {
    test('divides values and combines dimensions', () {
      final a = Quantity(10.0, Dimension({'m': 1}));
      final b = Quantity(2.0, Dimension({'s': 1}));
      final result = a / b;
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'m': 1, 's': -1}));
    });

    test('same dimension produces dimensionless', () {
      final a = Quantity(10.0, Dimension({'m': 1}));
      final b = Quantity(2.0, Dimension({'m': 1}));
      final result = a / b;
      expect(result.value, 5.0);
      expect(result.isDimensionless, isTrue);
    });

    test('division by zero throws EvalException', () {
      final a = Quantity(10.0, Dimension({'m': 1}));
      final b = Quantity(0.0, Dimension({'s': 1}));
      expect(() => a / b, throwsA(isA<EvalException>()));
    });
  });

  group('Quantity.negate', () {
    test('negates value', () {
      final q = Quantity(5.0, Dimension({'m': 1}));
      final result = -q;
      expect(result.value, -5.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('double negate restores value', () {
      final q = Quantity(5.0, Dimension({'m': 1}));
      expect((-(-q)).value, 5.0);
    });
  });

  group('Quantity.abs', () {
    test('positive value unchanged', () {
      final q = Quantity(5.0, Dimension({'m': 1}));
      expect(q.abs().value, 5.0);
    });

    test('negative value becomes positive', () {
      final q = Quantity(-5.0, Dimension({'m': 1}));
      expect(q.abs().value, 5.0);
    });

    test('preserves dimension', () {
      final q = Quantity(-5.0, Dimension({'m': 1, 's': -1}));
      expect(q.abs().dimension, Dimension({'m': 1, 's': -1}));
    });
  });

  group('Quantity.power', () {
    test('integer exponent on dimensioned quantity', () {
      final q = Quantity(3.0, Dimension({'m': 1}));
      final result = q.power(2);
      expect(result.value, 9.0);
      expect(result.dimension, Dimension({'m': 2}));
    });

    test('exponent 0 gives dimensionless 1', () {
      final q = Quantity(5.0, Dimension({'m': 1}));
      final result = q.power(0);
      expect(result.value, 1.0);
      expect(result.isDimensionless, isTrue);
    });

    test('exponent 1 returns equivalent quantity', () {
      final q = Quantity(5.0, Dimension({'m': 1}));
      final result = q.power(1);
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('fractional exponent on even-powered dimension', () {
      // (4 m^2)^0.5 = 2 m
      final q = Quantity(4.0, Dimension({'m': 2}));
      final result = q.power(0.5);
      expect(result.value, closeTo(2.0, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('cube root of m^3', () {
      // (8 m^3)^(1/3) = 2 m
      final q = Quantity(8.0, Dimension({'m': 3}));
      final result = q.power(1.0 / 3.0);
      expect(result.value, closeTo(2.0, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('invalid fractional exponent on odd dimension', () {
      // (5 m^3)^0.5 is invalid: 3 * 1/2 = 1.5 is not integer
      final q = Quantity(5.0, Dimension({'m': 3}));
      expect(() => q.power(0.5), throwsA(isA<DimensionException>()));
    });

    test('negative base with integer exponent', () {
      final q = Quantity(-2.0, Dimension({'m': 1}));
      final result = q.power(3);
      expect(result.value, -8.0);
      expect(result.dimension, Dimension({'m': 3}));
    });

    test('negative base with fractional exponent throws', () {
      final q = Quantity(-4.0, Dimension({'m': 2}));
      expect(() => q.power(0.5), throwsA(isA<EvalException>()));
    });

    test('dimensionless with fractional exponent', () {
      final q = Quantity.dimensionless(4.0);
      final result = q.power(0.5);
      expect(result.value, closeTo(2.0, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('dimensionless negative base with fractional exponent throws', () {
      final q = Quantity.dimensionless(-4.0);
      expect(() => q.power(0.5), throwsA(isA<EvalException>()));
    });

    test('compound dimension: (m/s)^3', () {
      final q = Quantity(5.0, Dimension({'m': 1, 's': -1}));
      final result = q.power(3);
      expect(result.value, closeTo(125.0, 1e-10));
      expect(result.dimension, Dimension({'m': 3, 's': -3}));
    });

    test('negative integer exponent', () {
      final q = Quantity(2.0, Dimension({'m': 1}));
      final result = q.power(-2);
      expect(result.value, closeTo(0.25, 1e-10));
      expect(result.dimension, Dimension({'m': -2}));
    });
  });

  group('Quantity.isConformableWith', () {
    test('same dimension is conformable', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(3.0, Dimension({'m': 1}));
      expect(a.isConformableWith(b), isTrue);
    });

    test('different dimension is not conformable', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(3.0, Dimension({'s': 1}));
      expect(a.isConformableWith(b), isFalse);
    });
  });

  group('Quantity.approximatelyEquals', () {
    test('exact match', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(5.0, Dimension({'m': 1}));
      expect(a.approximatelyEquals(b), isTrue);
    });

    test('within tolerance', () {
      final a = Quantity(1.0, Dimension.dimensionless());
      final b = Quantity(1.0 + 1e-12, Dimension.dimensionless());
      expect(a.approximatelyEquals(b), isTrue);
    });

    test('outside tolerance', () {
      final a = Quantity(1.0, Dimension.dimensionless());
      final b = Quantity(1.1, Dimension.dimensionless());
      expect(a.approximatelyEquals(b), isFalse);
    });

    test('different dimensions returns false', () {
      final a = Quantity(5.0, Dimension({'m': 1}));
      final b = Quantity(5.0, Dimension({'s': 1}));
      expect(a.approximatelyEquals(b), isFalse);
    });

    test('relative tolerance for large values', () {
      final a = Quantity(1e10, Dimension.dimensionless());
      final b = Quantity(1e10 + 0.5, Dimension.dimensionless());
      expect(a.approximatelyEquals(b), isTrue);
    });

    test('small values use absolute tolerance', () {
      final a = Quantity(1e-15, Dimension.dimensionless());
      final b = Quantity(2e-15, Dimension.dimensionless());
      expect(a.approximatelyEquals(b), isTrue);
    });

    test('1/3 round-trip precision', () {
      final x = Quantity.dimensionless(1.0 / 3.0);
      final y = x * Quantity.dimensionless(3.0);
      expect(y.approximatelyEquals(Quantity.dimensionless(1.0)), isTrue);
    });
  });

  group('Quantity overflow', () {
    test('very large multiplication produces infinity', () {
      final big = Quantity(1e308, Dimension.dimensionless());
      final result = big * big;
      expect(result.value.isInfinite, isTrue);
    });

    test('infinity preserves dimension', () {
      final big = Quantity(1e308, Dimension({'m': 1}));
      final result = big * Quantity(1e308, Dimension.dimensionless());
      expect(result.value, double.infinity);
      expect(result.dimension, Dimension({'m': 1}));
    });
  });

  group('Quantity operator overloads', () {
    test('+ operator', () {
      final a = Quantity.dimensionless(2.0);
      final b = Quantity.dimensionless(3.0);
      expect((a + b).value, 5.0);
    });

    test('- operator (binary)', () {
      final a = Quantity.dimensionless(5.0);
      final b = Quantity.dimensionless(3.0);
      expect((a - b).value, 2.0);
    });

    test('* operator', () {
      final a = Quantity.dimensionless(2.0);
      final b = Quantity.dimensionless(3.0);
      expect((a * b).value, 6.0);
    });

    test('/ operator', () {
      final a = Quantity.dimensionless(6.0);
      final b = Quantity.dimensionless(3.0);
      expect((a / b).value, 2.0);
    });

    test('unary - operator', () {
      final a = Quantity.dimensionless(5.0);
      expect((-a).value, -5.0);
    });
  });

  group('Quantity edge cases', () {
    test('0^0 is 1 dimensionless', () {
      final q = Quantity.dimensionless(0.0);
      final result = q.power(0);
      expect(result.value, 1.0);
      expect(result.isDimensionless, isTrue);
    });

    test('0 * infinity produces NaN and throws', () {
      final a = Quantity(0.0, Dimension.dimensionless());
      final b = Quantity(double.infinity, Dimension.dimensionless());
      expect(() => a * b, throwsA(isA<EvalException>()));
    });

    test('infinity - infinity produces NaN and throws', () {
      final a = Quantity(double.infinity, Dimension.dimensionless());
      expect(() => a - a, throwsA(isA<EvalException>()));
    });

    test('power with large integer exponent', () {
      final q = Quantity(2.0, Dimension.dimensionless());
      final result = q.power(10);
      expect(result.value, closeTo(1024.0, 1e-10));
    });

    test('dimensionless power of pi', () {
      final q = Quantity.dimensionless(math.e);
      final result = q.power(1);
      expect(result.value, closeTo(math.e, 1e-10));
    });
  });
}
