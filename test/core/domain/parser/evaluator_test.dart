import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/parser/ast.dart';
import 'package:unitary/core/domain/parser/lexer.dart';
import 'package:unitary/core/domain/parser/parser.dart';

Quantity eval(String input) {
  final tokens = Lexer(input).scanTokens();
  final ast = Parser(tokens).parse();
  return ast.evaluate(const EvalContext());
}

void main() {
  group('Evaluator: pure arithmetic', () {
    test('5 * 3 + 2 = 17', () {
      final result = eval('5 * 3 + 2');
      expect(result.value, 17.0);
      expect(result.isDimensionless, isTrue);
    });

    test('10 / 4 = 2.5', () {
      final result = eval('10 / 4');
      expect(result.value, 2.5);
    });

    test('2^10 = 1024', () {
      final result = eval('2^10');
      expect(result.value, 1024.0);
    });

    test('2**10 = 1024', () {
      final result = eval('2**10');
      expect(result.value, 1024.0);
    });
  });

  group('Evaluator: unary operators', () {
    test('-5 + 3 = -2', () {
      final result = eval('-5 + 3');
      expect(result.value, -2.0);
    });

    test('1--2 = 1 - (-2) = 3', () {
      final result = eval('1--2');
      expect(result.value, 3.0);
    });

    test('+5 = 5', () {
      final result = eval('+5');
      expect(result.value, 5.0);
    });
  });

  group('Evaluator: precedence', () {
    test('2 + 3 * 4 = 14', () {
      final result = eval('2 + 3 * 4');
      expect(result.value, 14.0);
    });

    test('-2^3 = -(2^3) = -8', () {
      final result = eval('-2^3');
      expect(result.value, -8.0);
    });

    test('2^-3 = 0.125', () {
      final result = eval('2^-3');
      expect(result.value, 0.125);
    });

    test('-2^2 = -(2^2) = -4', () {
      final result = eval('-2^2');
      expect(result.value, -4.0);
    });

    test('(2 + 3) * 4 = 20', () {
      final result = eval('(2 + 3) * 4');
      expect(result.value, 20.0);
    });

    test('right-associative exponent: 2^3^2 = 2^9 = 512', () {
      final result = eval('2^3^2');
      expect(result.value, 512.0);
    });
  });

  group('Evaluator: high-precedence division', () {
    test('1|2 = 0.5', () {
      final result = eval('1|2');
      expect(result.value, 0.5);
    });

    test('1|3 ≈ 0.333...', () {
      final result = eval('1|3');
      expect(result.value, closeTo(1.0 / 3.0, 1e-10));
    });

    test('3|4|5 left-to-right: (3/4)/5 = 0.15', () {
      final result = eval('3|4|5');
      expect(result.value, closeTo(0.15, 1e-10));
    });
  });

  group('Evaluator: implicit multiplication', () {
    test('2 3 = 6', () {
      final result = eval('2 3');
      expect(result.value, 6.0);
    });

    test('2 3 4 = 24', () {
      final result = eval('2 3 4');
      expect(result.value, 24.0);
    });

    test('(2)(3) = 6', () {
      final result = eval('(2)(3)');
      expect(result.value, 6.0);
    });
  });

  group('Evaluator: unit identifiers', () {
    test('5 m → Quantity(5, {m: 1})', () {
      final result = eval('5 m');
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('m → Quantity(1, {m: 1})', () {
      final result = eval('m');
      expect(result.value, 1.0);
      expect(result.dimension, Dimension({'m': 1}));
    });
  });

  group('Evaluator: unit arithmetic', () {
    test('5 m * 3 = Quantity(15, {m: 1})', () {
      final result = eval('5 m * 3');
      expect(result.value, 15.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('5 m + 3 m = Quantity(8, {m: 1})', () {
      final result = eval('5 m + 3 m');
      expect(result.value, 8.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('5 m - 2 m = Quantity(3, {m: 1})', () {
      final result = eval('5 m - 2 m');
      expect(result.value, 3.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('5 m + 3 s throws DimensionException', () {
      expect(() => eval('5 m + 3 s'), throwsA(isA<DimensionException>()));
    });

    test('5 m * 3 s → Quantity(15, {m: 1, s: 1})', () {
      final result = eval('5 m * 3 s');
      expect(result.value, 15.0);
      expect(result.dimension, Dimension({'m': 1, 's': 1}));
    });

    test('10 m / 2 s → Quantity(5, {m: 1, s: -1})', () {
      // implicit multiply is higher precedence than /
      final result = eval('10 m / 2 s');
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'m': 1, 's': -1}));
    });

    test('(3 m)^2 → Quantity(9, {m: 2})', () {
      final result = eval('(3 m)^2');
      expect(result.value, 9.0);
      expect(result.dimension, Dimension({'m': 2}));
    });
  });

  group('Evaluator: sqrt and cbrt with units', () {
    test('sqrt(9 m^2) → Quantity(3, {m: 1})', () {
      final result = eval('sqrt(9 m^2)');
      expect(result.value, 3.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('sqrt(9 m^3) throws DimensionException', () {
      expect(() => eval('sqrt(9 m^3)'), throwsA(isA<DimensionException>()));
    });

    test('cbrt(8 m^3) → Quantity(2, {m: 1})', () {
      final result = eval('cbrt(8 m^3)');
      expect(result.value, closeTo(2.0, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });
  });

  group('Evaluator: trig functions', () {
    test('sin(0) = 0', () {
      final result = eval('sin(0)');
      expect(result.value, closeTo(0.0, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('cos(0) = 1', () {
      final result = eval('cos(0)');
      expect(result.value, closeTo(1.0, 1e-10));
    });

    test('tan(0) = 0', () {
      final result = eval('tan(0)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('asin(0) = 0', () {
      final result = eval('asin(0)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('acos(1) = 0', () {
      final result = eval('acos(1)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('atan(0) = 0', () {
      final result = eval('atan(0)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('asin(2) throws EvalException', () {
      expect(() => eval('asin(2)'), throwsA(isA<EvalException>()));
    });

    test('acos(2) throws EvalException', () {
      expect(() => eval('acos(2)'), throwsA(isA<EvalException>()));
    });

    test('sin(5 m) throws DimensionException', () {
      expect(() => eval('sin(5 m)'), throwsA(isA<DimensionException>()));
    });
  });

  group('Evaluator: ln/log/exp', () {
    test('ln(1) = 0', () {
      final result = eval('ln(1)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('log(1) = 0', () {
      final result = eval('log(1)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('exp(0) = 1', () {
      final result = eval('exp(0)');
      expect(result.value, closeTo(1.0, 1e-10));
    });

    test('exp(1) = e', () {
      final result = eval('exp(1)');
      expect(result.value, closeTo(math.e, 1e-10));
    });

    test('ln(0) throws EvalException', () {
      expect(() => eval('ln(0)'), throwsA(isA<EvalException>()));
    });

    test('ln(-1) throws EvalException', () {
      expect(() => eval('ln(-1)'), throwsA(isA<EvalException>()));
    });

    test('ln(5 m) throws DimensionException', () {
      expect(() => eval('ln(5 m)'), throwsA(isA<DimensionException>()));
    });
  });

  group('Evaluator: abs', () {
    test('abs(-5) = 5', () {
      final result = eval('abs(-5)');
      expect(result.value, 5.0);
    });

    test('abs(5) = 5', () {
      final result = eval('abs(5)');
      expect(result.value, 5.0);
    });

    test('abs(-3 m) preserves dimension', () {
      final result = eval('abs(-3 m)');
      expect(result.value, 3.0);
      expect(result.dimension, Dimension({'m': 1}));
    });
  });

  group('Evaluator: division by zero', () {
    test('1 / 0 throws EvalException', () {
      expect(() => eval('1 / 0'), throwsA(isA<EvalException>()));
    });
  });

  group('Evaluator: complex expressions', () {
    test('1|2 m → Quantity(0.5, {m: 1})', () {
      final result = eval('1|2 m');
      expect(result.value, 0.5);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('5 m / 2 s → Quantity(2.5, {m: 1, s: -1})', () {
      // implicit multiply is higher precedence than /
      final result = eval('5 m / 2 s');
      expect(result.value, 2.5);
      expect(result.dimension, Dimension({'m': 1, 's': -1}));
    });

    test('abs(sin(0)) = 0', () {
      final result = eval('abs(sin(0))');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('unit(expr) = unit * expr', () {
      // 'foo' is not a builtin, so foo(1) parses as foo * 1
      // which evaluates to Quantity(1, {foo: 1}), not an error.
      final result = eval('foo(1)');
      expect(result.value, 1.0);
      expect(result.dimension, Dimension({'foo': 1}));
    });

    test('wrong arg count throws EvalException', () {
      expect(() => eval('sin(1, 2)'), throwsA(isA<EvalException>()));
    });

    test('dimensioned exponent throws DimensionException', () {
      expect(() => eval('2^(3 m)'), throwsA(isA<DimensionException>()));
    });
  });

  group('Evaluator: reciprocal syntax', () {
    test('/2 = 0.5', () {
      final result = eval('/2');
      expect(result.value, 0.5);
      expect(result.isDimensionless, isTrue);
    });

    test('/m = 1/m', () {
      final result = eval('/m');
      expect(result.value, 1.0);
      expect(result.dimension, Dimension({'m': -1}));
    });
  });
}
