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
      const def = CompoundDefinition(expression: '0.3048 m');
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

    test('toQuantity returns value with self-dimension', () {
      final def = repo.getUnit('m').definition;
      final q = def.toQuantity(5.0, repo);
      expect(q.value, 5.0);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('toQuantity with zero', () {
      final def = repo.getUnit('m').definition;
      final q = def.toQuantity(0.0, repo);
      expect(q.value, 0.0);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('toQuantity with negative value', () {
      final def = repo.getUnit('m').definition;
      final q = def.toQuantity(-3.14, repo);
      expect(q.value, -3.14);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('toQuantity uses bound id', () {
      final repo2 = UnitRepository();
      repo2.register(Unit(id: 'kg', definition: PrimitiveUnitDefinition()));
      final def = repo2.getUnit('kg').definition;
      final q = def.toQuantity(1.0, repo2);
      expect(q.dimension, Dimension({'kg': 1}));
    });
  });
}
