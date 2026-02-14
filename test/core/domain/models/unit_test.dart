import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_definition.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/services/unit_resolver.dart';

void main() {
  group('Unit', () {
    test('constructs with required fields', () {
      const def = PrimitiveUnitDefinition();
      const unit = Unit(id: 'm', definition: def);
      expect(unit.id, 'm');
      expect(unit.aliases, isEmpty);
      expect(unit.description, isNull);
      expect(unit.definition, def);
    });

    test('constructs with all fields', () {
      const def = PrimitiveUnitDefinition();
      const unit = Unit(
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
      const def = PrimitiveUnitDefinition();
      const unit = Unit(id: 'ft', aliases: ['foot', 'feet'], definition: def);
      expect(unit.allNames, ['ft', 'foot', 'feet']);
    });

    test('allNames with no aliases is just id', () {
      const def = PrimitiveUnitDefinition();
      const unit = Unit(id: 'kg', definition: def);
      expect(unit.allNames, ['kg']);
    });

    test('const construction works', () {
      const def = CompoundDefinition(expression: '0.3048 m');
      const unit = Unit(id: 'ft', definition: def);
      expect(unit.id, 'ft');
    });

    test('default aliases is empty list', () {
      const def = PrimitiveUnitDefinition();
      const unit = Unit(id: 'x', definition: def);
      expect(unit.aliases, const <String>[]);
    });
  });

  group('PrimitiveUnitDefinition', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      repo.register(
        const Unit(
          id: 'm',
          aliases: ['meter'],
          definition: PrimitiveUnitDefinition(),
        ),
      );
    });

    test('isPrimitive is true', () {
      expect(const PrimitiveUnitDefinition().isPrimitive, isTrue);
    });

    test('resolveUnit returns 1 with self-dimension', () {
      final unit = repo.getUnit('m');
      final q = resolveUnit(unit, repo);
      expect(q.value, 1.0);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('resolveUnit scaled by value', () {
      final unit = repo.getUnit('m');
      final q = resolveUnit(unit, repo).multiply(Quantity.dimensionless(5.0));
      expect(q.value, 5.0);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('resolveUnit scaled by zero', () {
      final unit = repo.getUnit('m');
      final q = resolveUnit(unit, repo).multiply(Quantity.dimensionless(0.0));
      expect(q.value, 0.0);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('resolveUnit scaled by negative value', () {
      final unit = repo.getUnit('m');
      final q = resolveUnit(unit, repo).multiply(Quantity.dimensionless(-3.14));
      expect(q.value, -3.14);
      expect(q.dimension, Dimension({'m': 1}));
    });

    test('resolveUnit uses unit id as dimension key', () {
      final repo2 = UnitRepository();
      repo2.register(
        const Unit(id: 'kg', definition: PrimitiveUnitDefinition()),
      );
      final unit = repo2.getUnit('kg');
      final q = resolveUnit(unit, repo2);
      expect(q.dimension, Dimension({'kg': 1}));
    });
  });
}
