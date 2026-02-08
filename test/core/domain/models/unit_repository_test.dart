import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_definition.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository();
  });

  group('UnitRepository.register', () {
    test('registers a unit and looks up by id', () {
      repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition()));
      final unit = repo.findUnit('m');
      expect(unit, isNotNull);
      expect(unit!.id, 'm');
    });

    test('looks up by alias', () {
      repo.register(
        Unit(
          id: 'm',
          aliases: ['meter', 'metre'],
          definition: PrimitiveUnitDefinition(),
        ),
      );
      expect(repo.findUnit('meter')?.id, 'm');
      expect(repo.findUnit('metre')?.id, 'm');
    });

    test('throws on name collision with existing id', () {
      repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition()));
      expect(
        () =>
            repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition())),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on alias collision with existing name', () {
      repo.register(
        Unit(
          id: 'm',
          aliases: ['meter'],
          definition: PrimitiveUnitDefinition(),
        ),
      );
      expect(
        () => repo.register(
          Unit(
            id: 'x',
            aliases: ['meter'],
            definition: PrimitiveUnitDefinition(),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('collision error message includes conflicting unit id', () {
      repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition()));
      expect(
        () => repo.register(
          Unit(id: 'x', aliases: ['m'], definition: PrimitiveUnitDefinition()),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains("'m'"),
          ),
        ),
      );
    });

    test('binds PrimitiveUnitDefinition on registration', () {
      final def = PrimitiveUnitDefinition();
      repo.register(Unit(id: 'kg', definition: def));
      expect(def.getDimension(repo), Dimension({'kg': 1}));
    });
  });

  group('UnitRepository.findUnit', () {
    test('returns null for unknown names', () {
      expect(repo.findUnit('unknown'), isNull);
    });

    test('returns null for empty string', () {
      expect(repo.findUnit(''), isNull);
    });

    test('plural stripping: removes trailing s', () {
      repo.register(
        Unit(
          id: 'm',
          aliases: ['meter'],
          definition: PrimitiveUnitDefinition(),
        ),
      );
      // "meters" → strip 's' → "meter" → found
      expect(repo.findUnit('meters')?.id, 'm');
    });

    test('plural stripping: removes trailing es', () {
      repo.register(
        const Unit(
          id: 'in',
          aliases: ['inch'],
          definition: LinearDefinition(factor: 0.0254, baseUnitId: 'm'),
        ),
      );
      repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition()));
      // "inches" → strip 'es' → "inch" → found
      expect(repo.findUnit('inches')?.id, 'in');
    });

    test('plural stripping: tries es before s', () {
      // Register a unit with alias "inch" — "inches" should find it via
      // stripping 'es' → "inch", not via stripping 's' → "inche"
      repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition()));
      repo.register(
        const Unit(
          id: 'in',
          aliases: ['inch'],
          definition: LinearDefinition(factor: 0.0254, baseUnitId: 'm'),
        ),
      );
      expect(repo.findUnit('inches')?.id, 'in');
    });

    test('plural stripping: hours → hour', () {
      repo.register(Unit(id: 's', definition: PrimitiveUnitDefinition()));
      repo.register(
        const Unit(
          id: 'hr',
          aliases: ['hour'],
          definition: LinearDefinition(factor: 3600, baseUnitId: 's'),
        ),
      );
      expect(repo.findUnit('hours')?.id, 'hr');
    });

    test('irregular plural via explicit alias: feet', () {
      repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition()));
      repo.register(
        const Unit(
          id: 'ft',
          aliases: ['foot', 'feet'],
          definition: LinearDefinition(factor: 0.3048, baseUnitId: 'm'),
        ),
      );
      // "feet" is an explicit alias, not found via stripping
      expect(repo.findUnit('feet')?.id, 'ft');
    });

    test('plural stripping does not match too-short strings', () {
      repo.register(Unit(id: 's', definition: PrimitiveUnitDefinition()));
      // "s" should not be stripped further (length 1)
      expect(repo.findUnit('s')?.id, 's');
      // "es" has length 2, stripping 'es' gives empty string — should not crash
      expect(repo.findUnit('es'), isNull);
    });

    test('exact match takes priority over plural stripping', () {
      repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition()));
      // Register a unit whose id ends with 's'
      repo.register(
        const Unit(
          id: 'gas',
          definition: LinearDefinition(factor: 1, baseUnitId: 'm'),
        ),
      );
      // "gas" should find 'gas' unit exactly, not strip 's' → "ga"
      expect(repo.findUnit('gas')?.id, 'gas');
    });
  });

  group('UnitRepository.getUnit', () {
    test('returns unit for known name', () {
      repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition()));
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

  group('UnitRepository.allUnits', () {
    test('empty repo has no units', () {
      expect(repo.allUnits, isEmpty);
    });

    test('returns all registered units', () {
      repo.register(Unit(id: 'm', definition: PrimitiveUnitDefinition()));
      repo.register(Unit(id: 'kg', definition: PrimitiveUnitDefinition()));
      final ids = repo.allUnits.map((u) => u.id).toSet();
      expect(ids, {'m', 'kg'});
    });

    test('does not include duplicate entries for aliases', () {
      repo.register(
        Unit(
          id: 'm',
          aliases: ['meter', 'metre'],
          definition: PrimitiveUnitDefinition(),
        ),
      );
      expect(repo.allUnits.length, 1);
    });
  });
}
