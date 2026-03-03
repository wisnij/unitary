import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/builtin_functions.dart';
import 'package:unitary/core/domain/data/predefined_units.dart';
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
    repo = UnitRepository();
    registerPredefinedUnits(repo);
    registerBuiltinFunctions(repo);
  });

  group('Registration', () {
    test('registers a nonzero number of units', () {
      expect(repo.allUnits.length, greaterThan(0));
    });

    test('registers a nonzero number of prefixes', () {
      expect(repo.allPrefixes.length, greaterThan(0));
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
