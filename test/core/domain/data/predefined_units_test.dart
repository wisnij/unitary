import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/ast.dart';
import 'package:unitary/core/domain/services/unit_resolver.dart';

/// Units whose expressions use language features the evaluator does not yet
/// support.  When support is added, remove the affected IDs and the test will
/// confirm they now resolve correctly.
const _knownEvalFailures = <String>{};

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository.withPredefinedUnits();
  });

  group('Registration', () {
    test('registers a nonzero number of units', () {
      expect(repo.allUnits.length, greaterThan(0));
    });

    test('registers a nonzero number of prefixes', () {
      expect(repo.allPrefixes.length, greaterThan(0));
    });
  });

  group('Defined functions', () {
    late EvalContext ctx;

    setUp(() {
      ctx = EvalContext(repo: repo);
    });

    test('circlearea is registered as a DefinedFunction', () {
      expect(repo.findFunction('circlearea'), isA<DefinedFunction>());
    });

    test('circlearea has arity 1 and an inverse', () {
      final f = repo.findFunction('circlearea') as DefinedFunction;
      expect(f.arity, 1);
      expect(f.hasInverse, isTrue);
    });

    test('circlearea(3 m) returns pi*9 m^2', () {
      final f = repo.findFunction('circlearea') as DefinedFunction;
      final r = Quantity(3.0, Dimension({'m': 1}));
      final result = f.call([r], ctx);
      expect(result.value, closeTo(math.pi * 9.0, 1e-6));
      expect(result.dimension, equals(Dimension({'m': 2})));
    });

    test('tempC is registered as a DefinedFunction', () {
      expect(repo.findFunction('tempC'), isA<DefinedFunction>());
    });

    test('tempC has arity 1 and an inverse', () {
      final f = repo.findFunction('tempC') as DefinedFunction;
      expect(f.arity, 1);
      expect(f.hasInverse, isTrue);
    });

    test('tempC(0) returns 273.15 K', () {
      final f = repo.findFunction('tempC') as DefinedFunction;
      final result = f.call([Quantity.dimensionless(0.0)], ctx);
      expect(result.value, closeTo(273.15, 1e-6));
      expect(result.dimension, equals(Dimension({'K': 1})));
    });

    test('windchill is registered as a DefinedFunction', () {
      expect(repo.findFunction('windchill'), isA<DefinedFunction>());
    });

    test('windchill has arity 2 and no inverse', () {
      final f = repo.findFunction('windchill') as DefinedFunction;
      expect(f.arity, 2);
      expect(f.hasInverse, isFalse);
    });
  });

  group('Piecewise functions', () {
    test('gasmark is registered as a PiecewiseFunction', () {
      final f = repo.findFunction('gasmark');
      expect(f, isA<PiecewiseFunction>());
    });

    test('gasmark(5) returns correct value in kelvin', () {
      // From the GNU Units table: gasmark 5 -> 834.67 degR
      // degR = 5/9 K, so 834.67 * 5/9 ≈ 463.7055... K
      final f = repo.findFunction('gasmark') as PiecewiseFunction;
      final result = f.call([Quantity.dimensionless(5.0)]);
      expect(result.value, closeTo(834.67 * 5.0 / 9.0, 1e-3));
    });

    test('gasmark inverse of gasmark(5) returns 5', () {
      final f = repo.findFunction('gasmark') as PiecewiseFunction;
      final forward = f.call([Quantity.dimensionless(5.0)]);
      final inverse = f.callInverse([forward]);
      expect(inverse.value, closeTo(5.0, 1e-6));
      expect(inverse.dimension.isDimensionless, isTrue);
    });

    test('gasmark range quantity has degR dimension and SI factor', () {
      // degR = 5/9 K exactly
      final f = repo.findFunction('gasmark') as PiecewiseFunction;
      expect(
        f.range!.quantity!.dimension,
        equals(Dimension({'K': 1})),
      );
      expect(f.range!.quantity!.value, closeTo(5.0 / 9.0, 1e-10));
    });
  });

  group('Evaluation', () {
    test('all units evaluate without errors or circular definitions', () {
      final unexpectedFailures = <String>[];
      final unexpectedPasses = <String>[];

      for (final unit in repo.allUnits) {
        try {
          resolveUnit(unit, repo);
          if (_knownEvalFailures.contains(unit.id)) {
            unexpectedPasses.add(unit.id);
          }
        } catch (_) {
          if (!_knownEvalFailures.contains(unit.id)) {
            unexpectedFailures.add(unit.id);
          }
        }
      }

      expect(
        unexpectedFailures,
        isEmpty,
        reason:
            'Unexpected resolution failures — add to _knownEvalFailures '
            'or fix the unit definition',
      );
      expect(
        unexpectedPasses,
        isEmpty,
        reason: 'These units now resolve — remove them from _knownEvalFailures',
      );
    });
  });
}
