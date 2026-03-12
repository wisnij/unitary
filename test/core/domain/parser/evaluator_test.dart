import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/builtin_functions.dart';
import 'package:unitary/core/domain/data/predefined_units.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/ast.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
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

// Repo with all predefined units and builtin functions.
// Initialized lazily and reused across tests.
UnitRepository? _fnRepoInstance;
Quantity evalFn(String input) {
  _fnRepoInstance ??= UnitRepository.withPredefinedUnits();
  return evalWithRepo(input, _fnRepoInstance!);
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
      final result = evalFn('sqrt(9 m^2)');
      expect(result.value, 3.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('sqrt(9 m^3) throws DimensionException', () {
      expect(() => evalFn('sqrt(9 m^3)'), throwsA(isA<DimensionException>()));
    });

    test('cbrt(8 m^3) → Quantity(2, {m: 1})', () {
      final result = evalFn('cbrt(8 m^3)');
      expect(result.value, closeTo(2.0, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });
  });

  group('Evaluator: trig functions', () {
    test('sin(0) = 0', () {
      final result = evalFn('sin(0)');
      expect(result.value, closeTo(0.0, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('cos(0) = 1', () {
      final result = evalFn('cos(0)');
      expect(result.value, closeTo(1.0, 1e-10));
    });

    test('tan(0) = 0', () {
      final result = evalFn('tan(0)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('asin(0) = 0', () {
      final result = evalFn('asin(0)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('acos(1) = 0', () {
      final result = evalFn('acos(1)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('atan(0) = 0', () {
      final result = evalFn('atan(0)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('asin(2) throws EvalException', () {
      expect(() => evalFn('asin(2)'), throwsA(isA<EvalException>()));
    });

    test('acos(2) throws EvalException', () {
      expect(() => evalFn('acos(2)'), throwsA(isA<EvalException>()));
    });

    test('sin(5 m) throws DimensionException', () {
      expect(() => evalFn('sin(5 m)'), throwsA(isA<DimensionException>()));
    });
  });

  group('Evaluator: ln/log/exp', () {
    test('ln(1) = 0', () {
      final result = evalFn('ln(1)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    // log is base-10 (log10): log10(1) = 0.
    test('log(1) = 0', () {
      final result = evalFn('log(1)');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('exp(0) = 1', () {
      final result = evalFn('exp(0)');
      expect(result.value, closeTo(1.0, 1e-10));
    });

    test('exp(1) = e', () {
      final result = evalFn('exp(1)');
      expect(result.value, closeTo(math.e, 1e-10));
    });

    test('ln(0) throws EvalException', () {
      expect(() => evalFn('ln(0)'), throwsA(isA<EvalException>()));
    });

    test('ln(-1) throws EvalException', () {
      expect(() => evalFn('ln(-1)'), throwsA(isA<EvalException>()));
    });

    test('ln(5 m) throws DimensionException', () {
      expect(() => evalFn('ln(5 m)'), throwsA(isA<DimensionException>()));
    });
  });

  group('Evaluator: logB(x) arbitrary-base logarithms', () {
    test('log2(8) = 3', () {
      expect(evalFn('log2(8)').value, closeTo(3.0, 1e-10));
    });

    test('log10(1000) = 3', () {
      expect(evalFn('log10(1000)').value, closeTo(3.0, 1e-10));
    });

    test('log16(256) = 2', () {
      expect(evalFn('log16(256)').value, closeTo(2.0, 1e-10));
    });

    test('log256(65536) = 2', () {
      expect(evalFn('log256(65536)').value, closeTo(2.0, 1e-10));
    });

    test('log(100) = 2 (plain log unchanged)', () {
      expect(evalFn('log(100)').value, closeTo(2.0, 1e-10));
    });

    test('log(x) and log10(x) produce equal results', () {
      final a = evalFn('log(500)').value;
      final b = evalFn('log10(500)').value;
      expect(a, closeTo(b, 1e-10));
    });

    test('logB result is dimensionless', () {
      expect(evalFn('log2(8)').isDimensionless, isTrue);
    });

    test('log2(0) throws EvalException (ln domain violation)', () {
      expect(() => evalFn('log2(0)'), throwsA(isA<EvalException>()));
    });

    test('log2(-1) throws EvalException (ln domain violation)', () {
      expect(() => evalFn('log2(-1)'), throwsA(isA<EvalException>()));
    });
  });

  group('Evaluator: abs', () {
    test('abs(-5) = 5', () {
      final result = evalFn('abs(-5)');
      expect(result.value, 5.0);
    });

    test('abs(5) = 5', () {
      final result = evalFn('abs(5)');
      expect(result.value, 5.0);
    });

    test('abs(-3 m) preserves dimension', () {
      final result = evalFn('abs(-3 m)');
      expect(result.value, 3.0);
      expect(result.dimension, Dimension({'m': 1}));
    });
  });

  group('Evaluator: FunctionNode.evaluate() AST-level', () {
    test('dispatches through repo and returns correct result', () {
      final repo = UnitRepository();
      registerBuiltinFunctions(repo);
      const node = FunctionNode('sin', [NumberNode(0.0)]);
      final result = node.evaluate(EvalContext(repo: repo));
      expect(result.value, closeTo(0.0, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('throws EvalException when context.repo is null', () {
      const node = FunctionNode('sin', [NumberNode(0.0)]);
      expect(
        () => node.evaluate(const EvalContext()),
        throwsA(isA<EvalException>()),
      );
    });

    test('throws EvalException for unknown function name in repo', () {
      final repo = UnitRepository();
      const node = FunctionNode('notafunction', [NumberNode(0.0)]);
      expect(
        () => node.evaluate(EvalContext(repo: repo)),
        throwsA(isA<EvalException>()),
      );
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
      final result = evalFn('abs(sin(0))');
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('unit(expr) = unit * expr (no repo)', () {
      // Without a repo, 'foo' is not a function, so foo(1) parses as foo * 1
      // which evaluates to Quantity(1, {foo: 1}), not an error.
      final result = eval('foo(1)');
      expect(result.value, 1.0);
      expect(result.dimension, Dimension({'foo': 1}));
    });

    test('wrong arg count throws EvalException', () {
      expect(() => evalFn('sin(1, 2)'), throwsA(isA<EvalException>()));
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
      registerPredefinedUnits(repo);
      registerBuiltinFunctions(repo);
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

    test('unknown unit with repo throws EvalException', () {
      expect(
        () => evalWithRepo('5 wakalixes', repo),
        throwsA(
          isA<EvalException>().having(
            (e) => e.message,
            'message',
            contains('wakalixes'),
          ),
        ),
      );
    });

    test('unknown unit mid-expression throws EvalException', () {
      expect(
        () => evalWithRepo('5 m + 3 wakalixes', repo),
        throwsA(isA<EvalException>()),
      );
    });

    test('null repo preserves Phase 1 behavior', () {
      // Verify a few existing-style evaluations still work with no repo.
      final result = eval('5 m');
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test(
      'null repo falls back to raw dimension for unrecognized identifiers',
      () {
        // With no repo, unknown names produce raw dimensions (Phase 1 behavior).
        final result = eval('5 wakalixes');
        expect(result.value, 5.0);
        expect(result.dimension, Dimension({'wakalixes': 1}));
      },
    );

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

  group(
    'Evaluator: affine unit evaluation',
    skip: 'affine units not yet registered',
    () {
      late UnitRepository repo;

      setUp(() {
        repo = UnitRepository();
        registerPredefinedUnits(repo);
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
    },
  );

  group('Evaluator: constants', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      registerPredefinedUnits(repo);
      registerBuiltinFunctions(repo);
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
      registerPredefinedUnits(repo);
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
      registerPredefinedUnits(repo);
    });

    test(
      'tempF(212) evaluates to 373.15 K',
      skip: 'affine units not yet registered',
      () {
        final result = evalWithRepo('tempF(212)', repo);
        expect(result.value, closeTo(373.15, 1e-2));
        expect(result.dimension, Dimension({'K': 1}));
      },
    );

    test('5 N + 3 kg*m/s^2 evaluates to 8 kg*m/s^2', () {
      final result = evalWithRepo('5 N + 3 kg*m/s^2', repo);
      expect(result.value, closeTo(8.0, 1e-10));
      expect(result.dimension, Dimension({'kg': 1, 'm': 1, 's': -2}));
    });
  });

  group('Evaluator: trailing-digit exponent shorthand', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      registerPredefinedUnits(repo);
    });

    test('5 m2 evaluates the same as 5 m^2', () {
      final shorthand = evalWithRepo('5 m2', repo);
      final explicit = evalWithRepo('5 m^2', repo);
      expect(shorthand.value, closeTo(explicit.value, 1e-10));
      expect(shorthand.dimension, explicit.dimension);
    });

    test('centimeters3 evaluates the same as cm^3', () {
      final shorthand = evalWithRepo('centimeters3', repo);
      final explicit = evalWithRepo('cm^3', repo);
      expect(shorthand.value, closeTo(explicit.value, 1e-10));
      expect(shorthand.dimension, explicit.dimension);
    });
  });

  group('Evaluator: inverse function operator (~)', () {
    // A simple invertible function: f(x) = 2x, f⁻¹(y) = y/2.
    // Implemented as a PiecewiseFunction (the only built-in invertible type).
    UnitRepository makeInvertibleRepo() {
      final repo = UnitRepository();
      registerBuiltinFunctions(repo);
      repo.registerFunction(
        PiecewiseFunction(
          id: 'double',
          points: [(0.0, 0.0), (100.0, 200.0)],
          noerror: false,
          outputUnit: Quantity.unity,
        ),
      );
      return repo;
    }

    test('FunctionNode with inverse == false dispatches to call', () {
      final repo = UnitRepository();
      registerBuiltinFunctions(repo);
      // sin(0) = 0 via call()
      const node = FunctionNode('sin', [NumberNode(0.0)]);
      final result = node.evaluate(EvalContext(repo: repo));
      expect(result.value, closeTo(0.0, 1e-10));
    });

    test('FunctionNode with inverse == true dispatches to callInverse', () {
      final repo = makeInvertibleRepo();
      // double(x) = 2x; ~double(10) = 5
      const node = FunctionNode(
        'double',
        [NumberNode(10.0)],
        inverse: true,
      );
      final result = node.evaluate(EvalContext(repo: repo));
      expect(result.value, closeTo(5.0, 1e-10));
    });

    test('~name(args) on non-invertible function throws EvalException', () {
      // sin has hasInverse == false
      expect(() => evalFn('~sin(1)'), throwsA(isA<EvalException>()));
    });

    test('end-to-end: ~double(10) evaluates to 5', () {
      final repo = makeInvertibleRepo();
      expect(evalWithRepo('~double(10)', repo).value, closeTo(5.0, 1e-10));
    });

    test('end-to-end: ~double(~double(x)) roundtrips correctly', () {
      final repo = makeInvertibleRepo();
      // ~double(~double(40)) = ~double(20) = 10
      expect(
        evalWithRepo('~double(~double(40))', repo).value,
        closeTo(10.0, 1e-10),
      );
    });
  });

  group('EvalContext.variables', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository.withPredefinedUnits();
    });

    Quantity evalWithVars(
      String expr,
      UnitRepository r,
      Map<String, Quantity> vars,
    ) {
      final tokens = Lexer(expr).scanTokens();
      final ast = Parser(tokens, repo: r).parse();
      return ast.evaluate(EvalContext(repo: r, variables: vars));
    }

    test('variable name shadows a real unit', () {
      // 'm' normally resolves as meter; bind it to a dimensionless 5 instead.
      final vars = {'m': Quantity.dimensionless(5.0)};
      final result = evalWithVars('m', repo, vars);
      expect(result.value, closeTo(5.0, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('name not in variables falls through to repo lookup', () {
      final vars = {'x': Quantity.dimensionless(99.0)};
      // 'm' is not in vars, so it should resolve to meter.
      final result = evalWithVars('m', repo, vars);
      expect(result.value, closeTo(1.0, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('null variables is transparent (no change in behavior)', () {
      final tokens = Lexer('m').scanTokens();
      final ast = Parser(tokens, repo: repo).parse();
      // variables: null — should behave like a plain EvalContext.
      final result = ast.evaluate(EvalContext(repo: repo));
      expect(result.value, closeTo(1.0, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });
  });

  group('ExpressionParser with variables', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository.withPredefinedUnits();
    });

    test('bound name resolves to bound Quantity', () {
      final vars = {'x': Quantity.dimensionless(7.0)};
      final parser = ExpressionParser(repo: repo, variables: vars);
      final result = parser.evaluate('x');
      expect(result.value, closeTo(7.0, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('expression using bound name evaluates correctly', () {
      final vars = {'x': Quantity.dimensionless(3.0)};
      final parser = ExpressionParser(repo: repo, variables: vars);
      final result = parser.evaluate('2 x');
      expect(result.value, closeTo(6.0, 1e-10));
    });
  });
}
