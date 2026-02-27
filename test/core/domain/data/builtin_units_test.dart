import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/builtin_units.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/services/unit_resolver.dart';

/// Units whose expressions use language features the evaluator does not yet
/// support.  When support is added, remove the affected IDs and the test will
/// confirm they now resolve correctly.
const _knownEvalFailures = {
  // tan/sin/cos called with an angle quantity (dimension: radian).
  // Fix: treat radian-dimensioned arguments as dimensionless in trig.
  'parsec',
  'hubble',

  // '$' dollar-sign identifier not recognised by the lexer.
  // Fix: add '$' as a valid unit-name character (or alias 'dollar').
  'fin',
  'sawbuck',
  'usgrand',
  'bitcoin',
  'silverprice',
  'goldprice',
  'platinumprice',
  'olddollargold',
  'newdollargold',
  'poundgold',
  'goldounce',
  'silverounce',
  'platinumounce',
  'USdimeweight',
  'USquarterweight',
  'UShalfdollarweight',
  'satoshi',
  'cent',

  // '%' percent-sign used as a unit symbol, not recognised by the lexer.
  // Fix: add '%' as a valid unit-name character (or rewrite expressions to
  // use 'percent').
  'basispoint',
  'uranium_natural',
  'air_1976',
  'air_1962',
  'air_2023',
  'air_2015',
  'polyndx_1976',
  'polyexpnt',

  // Unicode identifier characters (µ, Ω) not yet supported by the lexer.
  // Fix: extend the lexer to accept these characters in identifiers.
  '㎂',
  '㎌',
  '㎍',
  '㎕',
  '㎛',
  '㎲',
  '㎶',
  '㎼',
  '㏀',
  '㏁',

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

  // GNU Units uses numeric suffixes as exponent shorthand (e.g. 'm2' for m²,
  // 'ft3' for ft³).  These identifiers are not registered in our unit
  // database, which uses explicit exponent syntax ('m^2', 'ft^3').
  // Fix: register these aliases or rewrite the imported definitions to use
  // explicit exponent syntax.
  'naturalgas_HHV', // ft3
  'naturalgas_LHV', // ft3
  'k1250', // m2
  'k1400', // m2
  'K_apex1961', // m2
  'K_apex1971', // m2
  // 'log2' is not a built-in evaluator function (only log/ln/exp are).
  // Fix: add log2 as a built-in function in the evaluator.
  'hartley',
};

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository();
    registerBuiltinUnits(repo);
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
