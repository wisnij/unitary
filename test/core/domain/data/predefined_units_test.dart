import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/services/unit_resolver.dart';

/// Units whose expressions use language features the evaluator does not yet
/// support.  When support is added, remove the affected IDs and the test will
/// confirm they now resolve correctly.
const _knownEvalFailures = {
  // Affine unit function-call syntax using units not registered in the repo.
  // 'normaltemp' uses 'tempF(70)' but 'tempF' is not in units.json.
  // 'S10' uses 'SB_degree(10)' but 'SB_degree' is not in units.json.
  // 'ipv4classA/B/C' use 'ipv4subnetsize(N)' but 'ipv4subnetsize' is not in
  // units.json.
  // Fix: register these functions/units or inline their definitions.
  'normaltemp',
  'S10',
  'ipv4classA',
  'ipv4classB',
  'ipv4classC',
};

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
