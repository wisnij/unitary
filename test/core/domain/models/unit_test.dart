import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_definition.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

void main() {
  group('Unit', () {
    test('constructs with required fields', () {
      final def = PrimitiveUnitDefinition();
      final unit = Unit(id: 'm', definition: def);
      expect(unit.id, 'm');
      expect(unit.aliases, isEmpty);
      expect(unit.description, isNull);
      expect(unit.definition, def);
    });

    test('constructs with all fields', () {
      final def = PrimitiveUnitDefinition();
      final unit = Unit(
        id: 'm',
        aliases: ['meter', 'metre'],
        description: 'SI base unit of length',
        definition: def,
      );
      expect(unit.id, 'm');
      expect(unit.aliases, ['meter', 'metre']);
      expect(unit.description, 'SI base unit of length');
    });

    test('allNames includes id and aliases', () {
      final def = PrimitiveUnitDefinition();
      final unit = Unit(id: 'ft', aliases: ['foot', 'feet'], definition: def);
      expect(unit.allNames, ['ft', 'foot', 'feet']);
    });

    test('allNames with no aliases is just id', () {
      final def = PrimitiveUnitDefinition();
      final unit = Unit(id: 'kg', definition: def);
      expect(unit.allNames, ['kg']);
    });

    test('const construction works', () {
      const def = LinearDefinition(factor: 0.3048, baseUnitId: 'm');
      const unit = Unit(id: 'ft', definition: def);
      expect(unit.id, 'ft');
    });

    test('default aliases is empty list', () {
      final def = PrimitiveUnitDefinition();
      final unit = Unit(id: 'x', definition: def);
      expect(unit.aliases, const <String>[]);
    });
  });

  group('PrimitiveUnitDefinition', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      repo.register(
        Unit(
          id: 'm',
          aliases: ['meter'],
          definition: PrimitiveUnitDefinition(),
        ),
      );
    });

    test('isPrimitive is true', () {
      expect(PrimitiveUnitDefinition().isPrimitive, isTrue);
    });

    test('getQuantity returns value with self-dimension', () {
      final def = repo.getUnit('m').definition;
      final q = def.getQuantity(5.0, repo);
      expect(q.value, 5.0);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('getQuantity with zero', () {
      final def = repo.getUnit('m').definition;
      final q = def.getQuantity(0.0, repo);
      expect(q.value, 0.0);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('getQuantity with negative value', () {
      final def = repo.getUnit('m').definition;
      final q = def.getQuantity(-3.14, repo);
      expect(q.value, -3.14);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('getQuantity uses bound id', () {
      final repo2 = UnitRepository();
      repo2.register(Unit(id: 'kg', definition: PrimitiveUnitDefinition()));
      final def = repo2.getUnit('kg').definition;
      final q = def.getQuantity(1.0, repo2);
      expect(q.dimension, Dimension({'kg': 1}));
    });
  });

  group('LinearDefinition', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      repo.register(
        Unit(
          id: 'm',
          aliases: ['meter'],
          definition: PrimitiveUnitDefinition(),
        ),
      );
      repo.register(
        const Unit(
          id: 'ft',
          aliases: ['foot', 'feet'],
          definition: LinearDefinition(factor: 0.3048, baseUnitId: 'm'),
        ),
      );
    });

    test('isPrimitive is false', () {
      expect(
        const LinearDefinition(factor: 0.3048, baseUnitId: 'm').isPrimitive,
        isFalse,
      );
    });

    test('getQuantity converts value and returns primitive dimension', () {
      final def = repo.getUnit('ft').definition;
      final q = def.getQuantity(1.0, repo);
      expect(q.value, closeTo(0.3048, 1e-10));
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('getQuantity with multiple units', () {
      final def = repo.getUnit('ft').definition;
      final q = def.getQuantity(5.0, repo);
      expect(q.value, closeTo(1.524, 1e-10));
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('getQuantity with zero', () {
      final def = repo.getUnit('ft').definition;
      final q = def.getQuantity(0.0, repo);
      expect(q.value, 0.0);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('chain resolution: yard → ft → m', () {
      repo.register(
        const Unit(
          id: 'yd',
          aliases: ['yard'],
          definition: LinearDefinition(factor: 3.0, baseUnitId: 'ft'),
        ),
      );
      final def = repo.getUnit('yd').definition;

      // 1 yard = 3 feet = 3 * 0.3048 m = 0.9144 m
      final q = def.getQuantity(1.0, repo);
      expect(q.value, closeTo(0.9144, 1e-10));
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('chain getQuantity returns primitive dimension', () {
      repo.register(
        const Unit(
          id: 'yd',
          aliases: ['yard'],
          definition: LinearDefinition(factor: 3.0, baseUnitId: 'ft'),
        ),
      );
      final def = repo.getUnit('yd').definition;
      final q = def.getQuantity(1.0, repo);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('getQuantity value matches reduce for derived units', () {
      repo.register(
        const Unit(
          id: 'yd',
          aliases: ['yard'],
          definition: LinearDefinition(factor: 3.0, baseUnitId: 'ft'),
        ),
      );
      final def = repo.getUnit('yd').definition;
      for (final x in [0.0, 1.0, 5.0, -2.5, 100.0]) {
        final q = def.getQuantity(x, repo);
        expect(
          q.value,
          closeTo(x * 0.9144, 1e-10),
          reason: 'getQuantity for $x yd',
        );
      }
    });

    test('const construction', () {
      const def = LinearDefinition(factor: 1000.0, baseUnitId: 'm');
      expect(def.factor, 1000.0);
      expect(def.baseUnitId, 'm');
    });
  });
}
