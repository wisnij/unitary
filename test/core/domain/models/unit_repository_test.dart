import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/services/unit_resolver.dart';

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository();
  });

  group('UnitRepository.register', () {
    test('registers a unit and looks up by id', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      final unit = repo.findUnit('m');
      expect(unit, isNotNull);
      expect(unit!.id, 'm');
    });

    test('looks up by alias', () {
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter', 'metre']));
      expect(repo.findUnit('meter')?.id, 'm');
      expect(repo.findUnit('metre')?.id, 'm');
    });

    test('throws on name collision with existing id', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      expect(
        () => repo.register(const PrimitiveUnit(id: 'm')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on alias collision with existing name', () {
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter']));
      expect(
        () => repo.register(const PrimitiveUnit(id: 'x', aliases: ['meter'])),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('collision error message includes conflicting unit id', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      expect(
        () => repo.register(const PrimitiveUnit(id: 'x', aliases: ['m'])),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains("'m'"),
          ),
        ),
      );
    });

    test(
      'primitive unit resolves with correct dimension after registration',
      () {
        repo.register(const PrimitiveUnit(id: 'kg'));
        expect(
          resolveUnit(repo.getUnit('kg'), repo).dimension,
          Dimension({'kg': 1}),
        );
      },
    );
  });

  group('UnitRepository.findUnit', () {
    test('returns null for unknown names', () {
      expect(repo.findUnit('unknown'), isNull);
    });

    test('returns null for empty string', () {
      expect(repo.findUnit(''), isNull);
    });

    test('plural stripping: removes trailing s', () {
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter']));
      // "meters" → strip 's' → "meter" → found
      expect(repo.findUnit('meters')?.id, 'm');
    });

    test('plural stripping: removes trailing es', () {
      repo.register(
        const CompoundUnit(id: 'in', aliases: ['inch'], expression: '0.0254 m'),
      );
      repo.register(const PrimitiveUnit(id: 'm'));
      // "inches" → strip 'es' → "inch" → found
      expect(repo.findUnit('inches')?.id, 'in');
    });

    test('plural stripping: tries es before s', () {
      // Register a unit with alias "inch" — "inches" should find it via
      // stripping 'es' → "inch", not via stripping 's' → "inche"
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(
        const CompoundUnit(id: 'in', aliases: ['inch'], expression: '0.0254 m'),
      );
      expect(repo.findUnit('inches')?.id, 'in');
    });

    test('plural stripping: hours → hour', () {
      repo.register(const PrimitiveUnit(id: 's'));
      repo.register(
        const CompoundUnit(id: 'hr', aliases: ['hour'], expression: '3600 s'),
      );
      expect(repo.findUnit('hours')?.id, 'hr');
    });

    test('irregular plural via explicit alias: feet', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(
        const CompoundUnit(
          id: 'ft',
          aliases: ['foot', 'feet'],
          expression: '0.3048 m',
        ),
      );
      // "feet" is an explicit alias, not found via stripping
      expect(repo.findUnit('feet')?.id, 'ft');
    });

    test('plural stripping does not match too-short strings', () {
      repo.register(const PrimitiveUnit(id: 's'));
      // "s" should not be stripped further (length 1)
      expect(repo.findUnit('s')?.id, 's');
      // "es" has length 2, stripping 'es' gives empty string — should not crash
      expect(repo.findUnit('es'), isNull);
    });

    test('exact match takes priority over plural stripping', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      // Register a unit whose id ends with 's'
      repo.register(const CompoundUnit(id: 'gas', expression: '1 m'));
      // "gas" should find 'gas' unit exactly, not strip 's' → "ga"
      expect(repo.findUnit('gas')?.id, 'gas');
    });
  });

  group('UnitRepository.getUnit', () {
    test('returns unit for known name', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      expect(repo.getUnit('m').id, 'm');
    });

    test('throws ArgumentError for unknown name', () {
      expect(() => repo.getUnit('unknown'), throwsA(isA<ArgumentError>()));
    });

    test('error message includes the unknown name', () {
      expect(
        () => repo.getUnit('xyz'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains("'xyz'"),
          ),
        ),
      );
    });
  });

  group('UnitRepository.dimensionlessIds', () {
    test('empty repo has no dimensionless ids', () {
      expect(repo.dimensionlessIds, isEmpty);
    });

    test('non-dimensionless primitive units are not tracked', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      expect(repo.dimensionlessIds, isEmpty);
    });

    test('dimensionless primitive units are tracked', () {
      repo.register(const PrimitiveUnit(id: 'rad', isDimensionless: true));
      expect(repo.dimensionlessIds, {'rad'});
    });

    test('tracks multiple dimensionless units', () {
      repo.register(const PrimitiveUnit(id: 'rad', isDimensionless: true));
      repo.register(const PrimitiveUnit(id: 'sr', isDimensionless: true));
      expect(repo.dimensionlessIds, {'rad', 'sr'});
    });

    test('mixes dimensionless and non-dimensionless primitives', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(const PrimitiveUnit(id: 'rad', isDimensionless: true));
      repo.register(const PrimitiveUnit(id: 'kg'));
      expect(repo.dimensionlessIds, {'rad'});
    });

    test('non-primitive units are not tracked', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(const CompoundUnit(id: 'km', expression: '1000 m'));
      expect(repo.dimensionlessIds, isEmpty);
    });

    test('returned set is unmodifiable', () {
      repo.register(const PrimitiveUnit(id: 'rad', isDimensionless: true));
      expect(() => repo.dimensionlessIds.add('x'), throwsUnsupportedError);
    });
  });

  group('UnitRepository.allUnits', () {
    test('empty repo has no units', () {
      expect(repo.allUnits, isEmpty);
    });

    test('returns all registered units', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(const PrimitiveUnit(id: 'kg'));
      final ids = repo.allUnits.map((u) => u.id).toSet();
      expect(ids, {'m', 'kg'});
    });

    test('does not include duplicate entries for aliases', () {
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter', 'metre']));
      expect(repo.allUnits.length, 1);
    });
  });
}
