import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
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

    test('toBase is identity', () {
      final def = repo.getUnit('m').definition;
      expect(def.toBase(5.0, repo), 5.0);
      expect(def.toBase(0.0, repo), 0.0);
      expect(def.toBase(-3.14, repo), -3.14);
    });

    test('fromBase is identity', () {
      final def = repo.getUnit('m').definition;
      expect(def.fromBase(5.0, repo), 5.0);
      expect(def.fromBase(0.0, repo), 0.0);
      expect(def.fromBase(-3.14, repo), -3.14);
    });

    test('getDimension returns {unitId: 1} after bind', () {
      final def = repo.getUnit('m').definition;
      expect(def.getDimension(repo), Dimension({'m': 1}));
    });

    test('getDimension uses bound id', () {
      final repo2 = UnitRepository();
      repo2.register(Unit(id: 'kg', definition: PrimitiveUnitDefinition()));
      final def = repo2.getUnit('kg').definition;
      expect(def.getDimension(repo2), Dimension({'kg': 1}));
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

    test('toBase multiplies by factor', () {
      final def = repo.getUnit('ft').definition;
      expect(def.toBase(1.0, repo), closeTo(0.3048, 1e-10));
      expect(def.toBase(5.0, repo), closeTo(1.524, 1e-10));
      expect(def.toBase(0.0, repo), 0.0);
    });

    test('fromBase divides by factor', () {
      final def = repo.getUnit('ft').definition;
      expect(def.fromBase(0.3048, repo), closeTo(1.0, 1e-10));
      expect(def.fromBase(1.524, repo), closeTo(5.0, 1e-10));
      expect(def.fromBase(0.0, repo), 0.0);
    });

    test('getDimension returns primitive dimension', () {
      final def = repo.getUnit('ft').definition;
      expect(def.getDimension(repo), Dimension({'m': 1}));
    });

    test('round-trip: fromBase(toBase(x)) equals x', () {
      final def = repo.getUnit('ft').definition;
      for (final x in [0.0, 1.0, 5.0, -3.14, 100.0, 0.001]) {
        final roundTripped = def.fromBase(def.toBase(x, repo), repo);
        expect(roundTripped, closeTo(x, 1e-10), reason: 'round-trip for $x');
      }
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
      expect(def.toBase(1.0, repo), closeTo(0.9144, 1e-10));
      expect(def.fromBase(0.9144, repo), closeTo(1.0, 1e-10));
    });

    test('chain getDimension returns primitive dimension', () {
      repo.register(
        const Unit(
          id: 'yd',
          aliases: ['yard'],
          definition: LinearDefinition(factor: 3.0, baseUnitId: 'ft'),
        ),
      );
      final def = repo.getUnit('yd').definition;
      expect(def.getDimension(repo), Dimension({'m': 1}));
    });

    test('chain round-trip: fromBase(toBase(x)) equals x', () {
      repo.register(
        const Unit(
          id: 'yd',
          aliases: ['yard'],
          definition: LinearDefinition(factor: 3.0, baseUnitId: 'ft'),
        ),
      );
      final def = repo.getUnit('yd').definition;
      for (final x in [0.0, 1.0, 5.0, -2.5, 100.0]) {
        final roundTripped = def.fromBase(def.toBase(x, repo), repo);
        expect(roundTripped, closeTo(x, 1e-10), reason: 'round-trip for $x');
      }
    });

    test('const construction', () {
      const def = LinearDefinition(factor: 1000.0, baseUnitId: 'm');
      expect(def.factor, 1000.0);
      expect(def.baseUnitId, 'm');
    });
  });
}
