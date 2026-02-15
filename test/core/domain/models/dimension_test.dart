import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/rational.dart';

void main() {
  group('Dimension construction', () {
    test('creates from exponent map', () {
      final d = Dimension({'m': 1, 's': -2});
      expect(d.units, {'m': 1, 's': -2});
    });

    test('strips zero exponents', () {
      final d = Dimension({'m': 1, 's': 0, 'kg': 0});
      expect(d.units, {'m': 1});
    });

    test('dimensionless from empty map', () {
      final d = Dimension({});
      expect(d.isDimensionless, isTrue);
    });

    test('dimensionless constructor', () {
      final d = Dimension.dimensionless;
      expect(d.isDimensionless, isTrue);
      expect(d.units, isEmpty);
    });

    test('all-zero exponents becomes dimensionless', () {
      final d = Dimension({'m': 0, 's': 0});
      expect(d.isDimensionless, isTrue);
    });

    test('exponent map is unmodifiable', () {
      final d = Dimension({'m': 1});
      expect(() => (d.units as Map)['m'] = 2, throwsUnsupportedError);
    });
  });

  group('Dimension.isDimensionless', () {
    test('true for empty map', () {
      expect(Dimension.dimensionless.isDimensionless, isTrue);
    });

    test('false for non-empty map', () {
      expect(Dimension({'m': 1}).isDimensionless, isFalse);
    });
  });

  group('Dimension.multiply', () {
    test('adds exponents for same primitive', () {
      final a = Dimension({'m': 1});
      final b = Dimension({'m': 2});
      expect(a.multiply(b), equals(Dimension({'m': 3})));
    });

    test('combines different primitives', () {
      final a = Dimension({'m': 1});
      final b = Dimension({'s': -1});
      expect(a.multiply(b), equals(Dimension({'m': 1, 's': -1})));
    });

    test('canceling exponents become dimensionless', () {
      final a = Dimension({'m': 1});
      final b = Dimension({'m': -1});
      expect(a.multiply(b).isDimensionless, isTrue);
    });

    test('multiply by dimensionless returns same', () {
      final a = Dimension({'m': 1, 's': -2});
      final b = Dimension.dimensionless;
      expect(a.multiply(b), equals(a));
    });

    test('velocity times time gives length', () {
      final velocity = Dimension({'m': 1, 's': -1});
      final time = Dimension({'s': 1});
      expect(velocity.multiply(time), equals(Dimension({'m': 1})));
    });
  });

  group('Dimension.divide', () {
    test('subtracts exponents', () {
      final a = Dimension({'m': 2});
      final b = Dimension({'m': 1});
      expect(a.divide(b), equals(Dimension({'m': 1})));
    });

    test('length divided by time gives velocity', () {
      final length = Dimension({'m': 1});
      final time = Dimension({'s': 1});
      expect(length.divide(time), equals(Dimension({'m': 1, 's': -1})));
    });

    test('same dimension divided gives dimensionless', () {
      final a = Dimension({'m': 1});
      expect(a.divide(a).isDimensionless, isTrue);
    });

    test('divide by dimensionless returns same', () {
      final a = Dimension({'m': 1});
      expect(a.divide(Dimension.dimensionless), equals(a));
    });
  });

  group('Dimension.power', () {
    test('multiplies all exponents by integer', () {
      final d = Dimension({'m': 1, 's': -1});
      expect(d.power(2), equals(Dimension({'m': 2, 's': -2})));
    });

    test('power of zero gives dimensionless', () {
      final d = Dimension({'m': 1, 's': -2});
      expect(d.power(0).isDimensionless, isTrue);
    });

    test('power of one returns same', () {
      final d = Dimension({'m': 1, 's': -2});
      expect(d.power(1), equals(d));
    });

    test('negative power inverts exponents', () {
      final d = Dimension({'m': 1, 's': -1});
      expect(d.power(-1), equals(Dimension({'m': -1, 's': 1})));
    });

    test('dimensionless raised to any power is dimensionless', () {
      final d = Dimension.dimensionless;
      expect(d.power(5).isDimensionless, isTrue);
    });
  });

  group('Dimension.powerRational', () {
    test('m^2 raised to 1/2 gives m', () {
      final d = Dimension({'m': 2});
      final result = d.powerRational(Rational(1, 2));
      expect(result, equals(Dimension({'m': 1})));
    });

    test('m^3 raised to 1/3 gives m', () {
      final d = Dimension({'m': 3});
      final result = d.powerRational(Rational(1, 3));
      expect(result, equals(Dimension({'m': 1})));
    });

    test('m^2 s^-2 raised to 1/2 gives m s^-1', () {
      final d = Dimension({'m': 2, 's': -2});
      final result = d.powerRational(Rational(1, 2));
      expect(result, equals(Dimension({'m': 1, 's': -1})));
    });

    test('integer rational works like power', () {
      final d = Dimension({'m': 1});
      final result = d.powerRational(Rational(3, 1));
      expect(result, equals(Dimension({'m': 3})));
    });

    test('m^3 raised to 1/2 throws DimensionException', () {
      final d = Dimension({'m': 3});
      expect(
        () => d.powerRational(Rational(1, 2)),
        throwsA(isA<DimensionException>()),
      );
    });

    test('m^1 raised to 1/3 throws DimensionException', () {
      final d = Dimension({'m': 1});
      expect(
        () => d.powerRational(Rational(1, 3)),
        throwsA(isA<DimensionException>()),
      );
    });

    test('mixed valid/invalid throws on first invalid', () {
      // m^2 s^3 raised to 1/2: m^2 is ok, s^3 is not.
      final d = Dimension({'m': 2, 's': 3});
      expect(
        () => d.powerRational(Rational(1, 2)),
        throwsA(isA<DimensionException>()),
      );
    });

    test('dimensionless raised to any rational is dimensionless', () {
      final d = Dimension.dimensionless;
      expect(d.powerRational(Rational(3, 7)).isDimensionless, isTrue);
    });

    test('2/3 power of m^3 gives m^2', () {
      final d = Dimension({'m': 3});
      final result = d.powerRational(Rational(2, 3));
      expect(result, equals(Dimension({'m': 2})));
    });
  });

  group('Dimension.removeDimensions', () {
    test('removes specified dimensions', () {
      final d = Dimension({'m': 1, 'rad': 1, 's': -1});
      final result = d.removeDimensions({'rad'});
      expect(result, equals(Dimension({'m': 1, 's': -1})));
    });

    test('removes multiple specified dimensions', () {
      final d = Dimension({'m': 1, 'rad': 1, 'sr': 2, 's': -1});
      final result = d.removeDimensions({'rad', 'sr'});
      expect(result, equals(Dimension({'m': 1, 's': -1})));
    });

    test('removes regardless of exponent value', () {
      final d = Dimension({'rad': 2, 's': -1});
      final result = d.removeDimensions({'rad'});
      expect(result, equals(Dimension({'s': -1})));
    });

    test('removes negative exponent entries', () {
      final d = Dimension({'rad': -1, 's': 1});
      final result = d.removeDimensions({'rad'});
      expect(result, equals(Dimension({'s': 1})));
    });

    test('returns dimensionless when all dimensions removed', () {
      final d = Dimension({'rad': 1});
      final result = d.removeDimensions({'rad'});
      expect(result.isDimensionless, isTrue);
    });

    test('no-op when ids not present', () {
      final d = Dimension({'m': 1, 's': -1});
      final result = d.removeDimensions({'rad'});
      expect(result, equals(d));
    });

    test('no-op with empty id set', () {
      final d = Dimension({'m': 1, 'rad': 1});
      final result = d.removeDimensions({});
      expect(result, equals(d));
    });

    test('dimensionless input returns dimensionless', () {
      final result = Dimension.dimensionless.removeDimensions({'rad'});
      expect(result.isDimensionless, isTrue);
    });
  });

  group('Dimension.isConformableWith', () {
    test('same dimensions are conformable', () {
      final a = Dimension({'m': 1, 's': -2});
      final b = Dimension({'m': 1, 's': -2});
      expect(a.isConformableWith(b), isTrue);
    });

    test('different dimensions are not conformable', () {
      final a = Dimension({'m': 1});
      final b = Dimension({'s': 1});
      expect(a.isConformableWith(b), isFalse);
    });

    test('different exponents are not conformable', () {
      final a = Dimension({'m': 1});
      final b = Dimension({'m': 2});
      expect(a.isConformableWith(b), isFalse);
    });

    test('dimensionless is conformable with dimensionless', () {
      expect(
        Dimension.dimensionless.isConformableWith(Dimension.dimensionless),
        isTrue,
      );
    });

    test('dimensionless is not conformable with dimensioned', () {
      expect(
        Dimension.dimensionless.isConformableWith(Dimension({'m': 1})),
        isFalse,
      );
    });
  });

  group('Dimension.canonicalRepresentation', () {
    test('dimensionless shows as 1', () {
      expect(Dimension.dimensionless.canonicalRepresentation(), '1');
    });

    test('single positive exponent', () {
      expect(Dimension({'m': 1}).canonicalRepresentation(), 'm');
    });

    test('single positive exponent > 1', () {
      expect(Dimension({'m': 2}).canonicalRepresentation(), 'm^2');
    });

    test('single negative exponent', () {
      expect(Dimension({'s': -1}).canonicalRepresentation(), '1 / s');
    });

    test('single negative exponent with magnitude > 1', () {
      expect(Dimension({'s': -2}).canonicalRepresentation(), '1 / s^2');
    });

    test('velocity dimension', () {
      expect(Dimension({'m': 1, 's': -1}).canonicalRepresentation(), 'm / s');
    });

    test('force dimension (sorted alphabetically)', () {
      final force = Dimension({'kg': 1, 'm': 1, 's': -2});
      expect(force.canonicalRepresentation(), 'kg m / s^2');
    });

    test('multiple negative exponents', () {
      final d = Dimension({'m': 1, 'kg': -1, 's': -2});
      expect(d.canonicalRepresentation(), 'm / kg s^2');
    });
  });

  group('Dimension equality', () {
    test('equal dimensions', () {
      expect(
        Dimension({'m': 1, 's': -2}),
        equals(Dimension({'m': 1, 's': -2})),
      );
    });

    test('order of map entries does not matter', () {
      expect(
        Dimension({'s': -2, 'm': 1}),
        equals(Dimension({'m': 1, 's': -2})),
      );
    });

    test('unequal dimensions', () {
      expect(Dimension({'m': 1}), isNot(equals(Dimension({'m': 2}))));
    });

    test('consistent hashCode for equal values', () {
      expect(
        Dimension({'m': 1, 's': -2}).hashCode,
        equals(Dimension({'m': 1, 's': -2}).hashCode),
      );
    });

    test('order-independent hashCode', () {
      expect(
        Dimension({'s': -2, 'm': 1}).hashCode,
        equals(Dimension({'m': 1, 's': -2}).hashCode),
      );
    });
  });
}
