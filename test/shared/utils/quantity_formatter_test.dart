import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/features/settings/models/user_settings.dart';
import 'package:unitary/shared/utils/quantity_formatter.dart';

void main() {
  group('formatValue', () {
    group('decimal notation', () {
      test('formats integer value', () {
        expect(formatValue(42, precision: 6), '42');
      });

      test('formats value with fewer decimals than precision', () {
        expect(formatValue(1609.344, precision: 6), '1609.344');
      });

      test('formats value truncated to precision', () {
        expect(formatValue(1.23456789, precision: 4), '1.2346');
      });

      test('formats value at precision 2', () {
        expect(formatValue(3.14159, precision: 2), '3.14');
      });

      test('formats value at precision 10', () {
        expect(formatValue(3.14159265358979, precision: 10), '3.1415926536');
      });

      test('formats small value with leading zeros', () {
        expect(formatValue(0.000123, precision: 4), '0.0001');
      });

      test('formats small value with higher precision', () {
        expect(formatValue(0.000123, precision: 6), '0.000123');
      });

      test('formats negative value', () {
        expect(formatValue(-42.5, precision: 6), '-42.5');
      });

      test('strips trailing zeros', () {
        expect(formatValue(1.5000, precision: 6), '1.5');
      });
    });

    group('scientific notation', () {
      test('formats large value', () {
        expect(
          formatValue(1609.344, precision: 6, notation: Notation.scientific),
          '1.609344e+3',
        );
      });

      test('formats small value', () {
        expect(
          formatValue(0.000123, precision: 4, notation: Notation.scientific),
          '1.2300e-4',
        );
      });

      test('formats value between 1 and 10', () {
        expect(
          formatValue(5.5, precision: 4, notation: Notation.scientific),
          '5.5000e+0',
        );
      });

      test('formats negative value', () {
        expect(
          formatValue(-1609.344, precision: 6, notation: Notation.scientific),
          '-1.609344e+3',
        );
      });

      test('formats value of exactly 1', () {
        expect(
          formatValue(1.0, precision: 4, notation: Notation.scientific),
          '1.0000e+0',
        );
      });

      test('formats very large value', () {
        expect(
          formatValue(6.022e23, precision: 4, notation: Notation.scientific),
          '6.0220e+23',
        );
      });

      test('formats very small value', () {
        expect(
          formatValue(1.6e-19, precision: 4, notation: Notation.scientific),
          '1.6000e-19',
        );
      });
    });

    group('engineering notation', () {
      test('exponent is multiple of 3 for large value', () {
        expect(
          formatValue(1609.344, precision: 6, notation: Notation.engineering),
          '1.609344e+3',
        );
      });

      test('exponent is multiple of 3 for small value', () {
        expect(
          formatValue(0.000123, precision: 4, notation: Notation.engineering),
          '123.0000e-6',
        );
      });

      test('value between 1 and 999 has exponent 0', () {
        expect(
          formatValue(42.0, precision: 4, notation: Notation.engineering),
          '42.0000e+0',
        );
      });

      test('value of 1000 has exponent 3', () {
        expect(
          formatValue(1000.0, precision: 4, notation: Notation.engineering),
          '1.0000e+3',
        );
      });

      test('value of 999999 has exponent 3', () {
        expect(
          formatValue(999999.0, precision: 4, notation: Notation.engineering),
          '999.9990e+3',
        );
      });

      test('value between 0.001 and 1 has exponent -3', () {
        expect(
          formatValue(0.05, precision: 4, notation: Notation.engineering),
          '50.0000e-3',
        );
      });

      test('negative value', () {
        expect(
          formatValue(-4200.0, precision: 4, notation: Notation.engineering),
          '-4.2000e+3',
        );
      });
    });

    group('special cases', () {
      test('zero returns 0 for decimal', () {
        expect(formatValue(0.0, precision: 6), '0');
      });

      test('zero returns 0 for scientific', () {
        expect(
          formatValue(0.0, precision: 6, notation: Notation.scientific),
          '0',
        );
      });

      test('zero returns 0 for engineering', () {
        expect(
          formatValue(0.0, precision: 6, notation: Notation.engineering),
          '0',
        );
      });

      test('positive infinity', () {
        expect(formatValue(double.infinity, precision: 6), 'Infinity');
      });

      test('negative infinity', () {
        expect(formatValue(double.negativeInfinity, precision: 6), '-Infinity');
      });

      test('infinity in scientific notation', () {
        expect(
          formatValue(
            double.infinity,
            precision: 6,
            notation: Notation.scientific,
          ),
          'Infinity',
        );
      });
    });
  });

  group('formatQuantity', () {
    test('formats dimensionless quantity with value only', () {
      final q = Quantity.dimensionless(42.0);
      expect(formatQuantity(q, precision: 6), '42');
    });

    test('formats quantity with single unit', () {
      final q = Quantity(1609.344, Dimension({'m': 1}));
      expect(formatQuantity(q, precision: 6), '1609.344 m');
    });

    test('formats quantity with compound dimension', () {
      final q = Quantity(8.0, Dimension({'kg': 1, 'm': 1, 's': -2}));
      expect(formatQuantity(q, precision: 6), '8 kg m / s^2');
    });

    test('respects notation setting', () {
      final q = Quantity(1609.344, Dimension({'m': 1}));
      expect(
        formatQuantity(q, precision: 6, notation: Notation.scientific),
        '1.609344e+3 m',
      );
    });

    test('respects precision setting', () {
      final q = Quantity(3.14159, Dimension({'m': 1}));
      expect(formatQuantity(q, precision: 2), '3.14 m');
    });

    test('zero with dimension', () {
      final q = Quantity(0.0, Dimension({'m': 1}));
      expect(formatQuantity(q, precision: 6), '0 m');
    });

    test('infinity with dimension', () {
      final q = Quantity(double.infinity, Dimension({'m': 1}));
      expect(formatQuantity(q, precision: 6), 'Infinity m');
    });
  });
}
