import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/utils.dart';

void main() {
  group('stripTrailingZeros', () {
    test('integer string unchanged', () {
      expect(stripTrailingZeros('42'), '42');
    });

    test('trailing zeros removed', () {
      expect(stripTrailingZeros('1.500'), '1.5');
    });

    test('decimal point removed when no fractional digits remain', () {
      expect(stripTrailingZeros('1.0'), '1');
    });

    test('zero with decimal point', () {
      expect(stripTrailingZeros('0.0'), '0');
    });

    test('negative value', () {
      expect(stripTrailingZeros('-1.0'), '-1');
    });

    test('value with significant fractional digits preserved', () {
      expect(stripTrailingZeros('3.14'), '3.14');
    });

    test('mixed trailing zeros', () {
      expect(stripTrailingZeros('1.2300'), '1.23');
    });

    test('exponential notation: trailing zeros stripped from significand', () {
      expect(stripTrailingZeros('1.0e+20'), '1e+20');
    });

    test('exponential notation: significant digits preserved', () {
      expect(stripTrailingZeros('1.5e+20'), '1.5e+20');
    });

    test('exponential notation: exponent untouched', () {
      expect(stripTrailingZeros('1.50e+300'), '1.5e+300');
    });

    test('string with no decimal point unchanged', () {
      expect(stripTrailingZeros('100'), '100');
    });
  });
}
