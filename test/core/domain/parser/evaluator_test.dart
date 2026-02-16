import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/builtin_units.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/ast.dart';
import 'package:unitary/core/domain/parser/lexer.dart';
import 'package:unitary/core/domain/parser/parser.dart';

Quantity eval(String input) {
  final tokens = Lexer(input).scanTokens();
  final ast = Parser(tokens).parse();
  return ast.evaluate(const EvalContext());
}

Quantity evalWithRepo(String input, UnitRepository repo) {
  final tokens = Lexer(input).scanTokens();
  final ast = Parser(tokens, repo: repo).parse();
  return ast.evaluate(EvalContext(repo: repo));
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

  group('Evaluator: unit-aware evaluation', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      registerBuiltinUnits(repo);
    });

    test('5 ft resolves to meters', () {
      final result = evalWithRepo('5 ft', repo);
      expect(result.value, closeTo(1.524, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('5 feet resolves via alias', () {
      final result = evalWithRepo('5 feet', repo);
      expect(result.value, closeTo(1.524, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('5 ft + 3 m combines in base units', () {
      final result = evalWithRepo('5 ft + 3 m', repo);
      expect(result.value, closeTo(4.524, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('5 ft * 2 s gives m*s', () {
      final result = evalWithRepo('5 ft * 2 s', repo);
      expect(result.value, closeTo(3.048, 1e-10));
      expect(result.dimension, Dimension({'m': 1, 's': 1}));
    });

    test('5 ft / 2 s gives m/s', () {
      final result = evalWithRepo('5 ft / 2 s', repo);
      expect(result.value, closeTo(0.762, 1e-10));
      expect(result.dimension, Dimension({'m': 1, 's': -1}));
    });

    test('(3 ft)^2 gives m^2', () {
      final result = evalWithRepo('(3 ft)^2', repo);
      expect(result.value, closeTo(0.83612736, 1e-8));
      expect(result.dimension, Dimension({'m': 2}));
    });

    test('sqrt(9 ft^2) gives meters', () {
      final result = evalWithRepo('sqrt(9 ft^2)', repo);
      expect(result.value, closeTo(0.9144, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('1 km resolves to 1000 m', () {
      final result = evalWithRepo('1 km', repo);
      expect(result.value, closeTo(1000.0, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('2 lb resolves to kg', () {
      final result = evalWithRepo('2 lb', repo);
      expect(result.value, closeTo(0.90718474, 1e-8));
      expect(result.dimension, Dimension({'kg': 1}));
    });

    test('1 hr resolves to 3600 s', () {
      final result = evalWithRepo('1 hr', repo);
      expect(result.value, closeTo(3600.0, 1e-10));
      expect(result.dimension, Dimension({'s': 1}));
    });

    test('unknown unit with repo falls back to raw dimension', () {
      final result = evalWithRepo('5 zorblax', repo);
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'zorblax': 1}));
    });

    test('null repo preserves Phase 1 behavior', () {
      // Verify a few existing-style evaluations still work with no repo.
      final result = eval('5 m');
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('pure arithmetic with repo is unaffected', () {
      final result = evalWithRepo('2 + 3', repo);
      expect(result.value, 5.0);
      expect(result.isDimensionless, isTrue);
    });

    test('60 mi / hr gives velocity in m/s', () {
      final result = evalWithRepo('60 mi / hr', repo);
      // 60 * 1609.344 / 3600 = 26.8224 m/s
      expect(result.value, closeTo(26.8224, 1e-4));
      expect(result.dimension, Dimension({'m': 1, 's': -1}));
    });
  });

  group('Evaluator: affine unit evaluation', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      registerBuiltinUnits(repo);
    });

    test('tempF(212) = 373.15 K', () {
      final result = evalWithRepo('tempF(212)', repo);
      expect(result.value, closeTo(373.15, 1e-2));
      expect(result.dimension, Dimension({'K': 1}));
    });

    test('tempC(100) = 373.15 K', () {
      final result = evalWithRepo('tempC(100)', repo);
      expect(result.value, closeTo(373.15, 1e-10));
      expect(result.dimension, Dimension({'K': 1}));
    });

    test('tempK(373.15) = 373.15 K', () {
      final result = evalWithRepo('tempK(373.15)', repo);
      expect(result.value, closeTo(373.15, 1e-10));
      expect(result.dimension, Dimension({'K': 1}));
    });

    test('tempR(671.67) ≈ 373.15 K', () {
      final result = evalWithRepo('tempR(671.67)', repo);
      expect(result.value, closeTo(373.15, 1e-2));
      expect(result.dimension, Dimension({'K': 1}));
    });

    test('tempR(0) = 0 K', () {
      final result = evalWithRepo('tempR(0)', repo);
      expect(result.value, closeTo(0.0, 1e-10));
      expect(result.dimension, Dimension({'K': 1}));
    });

    test('tempF(32) + 10 degC = 283.15 K', () {
      final result = evalWithRepo('tempF(32) + 10 degC', repo);
      expect(result.value, closeTo(283.15, 1e-2));
      expect(result.dimension, Dimension({'K': 1}));
    });

    test('tempF(5 m) → DimensionException', () {
      expect(
        () => evalWithRepo('tempF(5 m)', repo),
        throwsA(isA<DimensionException>()),
      );
    });

    test('tempF(32 + 180) = 373.15 K (expression as argument)', () {
      final result = evalWithRepo('tempF(32 + 180)', repo);
      expect(result.value, closeTo(373.15, 1e-2));
      expect(result.dimension, Dimension({'K': 1}));
    });
  });

  group('Evaluator: constants', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      registerBuiltinUnits(repo);
    });

    test('pi ≈ 3.14159', () {
      final result = evalWithRepo('pi', repo);
      expect(result.value, closeTo(math.pi, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('2 pi ≈ 6.28318', () {
      final result = evalWithRepo('2 pi', repo);
      expect(result.value, closeTo(2 * math.pi, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('sin(pi) ≈ 0', () {
      final result = evalWithRepo('sin(pi)', repo);
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('ln(euler) = 1', () {
      final result = evalWithRepo('ln(euler)', repo);
      expect(result.value, closeTo(1.0, 1e-10));
    });

    test('c = 299792458 m/s', () {
      final result = evalWithRepo('c', repo);
      expect(result.value, closeTo(299792458.0, 1e-2));
      expect(result.dimension, Dimension({'m': 1, 's': -1}));
    });

    test('5e3 still parses as 5000.0 (not 5 * elementary_charge * 1000)', () {
      final result = evalWithRepo('5e3', repo);
      expect(result.value, closeTo(5000.0, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('5 e = 5 * elementary_charge', () {
      final result = evalWithRepo('5 e', repo);
      expect(result.value, closeTo(5 * 1.602176634e-19, 1e-29));
      expect(result.dimension, Dimension({'A': 1, 's': 1}));
    });
  });

  group('Evaluator: derived units', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      registerBuiltinUnits(repo);
    });

    test('5 N = Quantity(5, {kg:1, m:1, s:-2})', () {
      final result = evalWithRepo('5 N', repo);
      expect(result.value, closeTo(5.0, 1e-10));
      expect(result.dimension, Dimension({'kg': 1, 'm': 1, 's': -2}));
    });

    test('5 N + 3 kg*m/s^2 = 8 {kg:1, m:1, s:-2}', () {
      final result = evalWithRepo('5 N + 3 kg*m/s^2', repo);
      expect(result.value, closeTo(8.0, 1e-10));
      expect(result.dimension, Dimension({'kg': 1, 'm': 1, 's': -2}));
    });

    test('1 J = 1 N m (same dimension and value)', () {
      final j = evalWithRepo('1 J', repo);
      final nm = evalWithRepo('1 N m', repo);
      expect(j.value, closeTo(nm.value, 1e-10));
      expect(j.dimension, nm.dimension);
    });

    test('alias resolution: "newton" → N', () {
      final result = evalWithRepo('5 newton', repo);
      expect(result.value, closeTo(5.0, 1e-10));
      expect(result.dimension, Dimension({'kg': 1, 'm': 1, 's': -2}));
    });

    test('alias resolution: "joule" → J', () {
      final result = evalWithRepo('1 joule', repo);
      expect(result.value, closeTo(1.0, 1e-10));
      expect(result.dimension, Dimension({'kg': 1, 'm': 2, 's': -2}));
    });
  });

  group('Evaluator: Phase 3 deliverables', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      registerBuiltinUnits(repo);
    });

    test('tempF(212) evaluates to 373.15 K', () {
      final result = evalWithRepo('tempF(212)', repo);
      expect(result.value, closeTo(373.15, 1e-2));
      expect(result.dimension, Dimension({'K': 1}));
    });

    test('5 N + 3 kg*m/s^2 evaluates to 8 kg*m/s^2', () {
      final result = evalWithRepo('5 N + 3 kg*m/s^2', repo);
      expect(result.value, closeTo(8.0, 1e-10));
      expect(result.dimension, Dimension({'kg': 1, 'm': 1, 's': -2}));
    });
  });
}
