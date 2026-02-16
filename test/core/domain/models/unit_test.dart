import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/services/unit_resolver.dart';

void main() {
  group('PrimitiveUnit', () {
    test('constructs with required fields', () {
      const unit = PrimitiveUnit(id: 'm');
      expect(unit.id, 'm');
      expect(unit.aliases, isEmpty);
      expect(unit.description, isNull);
    });

    test('constructs with all fields', () {
      const unit = PrimitiveUnit(
        id: 'm',
        aliases: ['meter', 'metre'],
        description: 'SI base unit of length',
      );
      expect(unit.id, 'm');
      expect(unit.aliases, ['meter', 'metre']);
      expect(unit.description, 'SI base unit of length');
    });

    test('allNames includes id and aliases', () {
      const unit = PrimitiveUnit(id: 'ft', aliases: ['foot', 'feet']);
      expect(unit.allNames, ['ft', 'foot', 'feet']);
    });

    test('allNames with no aliases is just id', () {
      const unit = PrimitiveUnit(id: 'kg');
      expect(unit.allNames, ['kg']);
    });

    test('default aliases is empty list', () {
      const unit = PrimitiveUnit(id: 'x');
      expect(unit.aliases, const <String>[]);
    });

    test('isPrimitive is true', () {
      expect(const PrimitiveUnit(id: 'm').isPrimitive, isTrue);
    });

    test('isAffine is false', () {
      expect(const PrimitiveUnit(id: 'm').isAffine, isFalse);
    });

    test('isDimensionless defaults to false', () {
      const unit = PrimitiveUnit(id: 'm');
      expect(unit.isDimensionless, isFalse);
    });

    test('isDimensionless can be set to true', () {
      const unit = PrimitiveUnit(id: 'rad', isDimensionless: true);
      expect(unit.isDimensionless, isTrue);
    });

    test('isDimensionless true still has isPrimitive true', () {
      const unit = PrimitiveUnit(id: 'rad', isDimensionless: true);
      expect(unit.isPrimitive, isTrue);
    });

    test('isDimensionless unit is const-constructible', () {
      const unit = PrimitiveUnit(
        id: 'rad',
        aliases: ['radian'],
        description: 'Plane angle',
        isDimensionless: true,
      );
      expect(unit.id, 'rad');
      expect(unit.isDimensionless, isTrue);
    });
  });

  group('AffineUnit', () {
    test('isAffine is true', () {
      const unit = AffineUnit(
        id: 'tempC',
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      expect(unit.isAffine, isTrue);
    });

    test('isPrimitive is false', () {
      const unit = AffineUnit(
        id: 'tempC',
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      expect(unit.isPrimitive, isFalse);
    });
  });

  group('DerivedUnit', () {
    test('stores expression string', () {
      const unit = DerivedUnit(id: 'N', expression: 'kg m / s^2');
      expect(unit.expression, 'kg m / s^2');
    });

    test('const construction', () {
      const unit = DerivedUnit(id: 'km', expression: '1000 m');
      expect(unit.expression, '1000 m');
    });

    test('isPrimitive is false', () {
      const unit = DerivedUnit(id: 'km', expression: '1000 m');
      expect(unit.isPrimitive, isFalse);
    });

    test('isAffine is false', () {
      const unit = DerivedUnit(id: 'km', expression: '1000 m');
      expect(unit.isAffine, isFalse);
    });
  });

  group('PrefixUnit', () {
    test('isPrefix is true', () {
      const unit = PrefixUnit(id: 'kilo', expression: '1000');
      expect(unit.isPrefix, isTrue);
    });

    test('isPrimitive is false', () {
      const unit = PrefixUnit(id: 'kilo', expression: '1000');
      expect(unit.isPrimitive, isFalse);
    });

    test('isAffine is false', () {
      const unit = PrefixUnit(id: 'kilo', expression: '1000');
      expect(unit.isAffine, isFalse);
    });

    test('is a DerivedUnit', () {
      const unit = PrefixUnit(id: 'kilo', expression: '1000');
      expect(unit, isA<DerivedUnit>());
    });

    test('stores expression string', () {
      const unit = PrefixUnit(id: 'milli', expression: '0.001');
      expect(unit.expression, '0.001');
    });

    test('const construction with all fields', () {
      const unit = PrefixUnit(
        id: 'kilo',
        aliases: ['k'],
        description: 'SI prefix for 10^3',
        expression: '1000',
      );
      expect(unit.id, 'kilo');
      expect(unit.aliases, ['k']);
      expect(unit.description, 'SI prefix for 10^3');
      expect(unit.expression, '1000');
    });

    test('resolves via resolveUnit', () {
      final repo = UnitRepository();
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.registerPrefix(
        const PrefixUnit(id: 'kilo', aliases: ['k'], expression: '1000'),
      );
      final prefix = repo.allPrefixes.first;
      final q = resolveUnit(prefix, repo);
      expect(q.value, closeTo(1000.0, 1e-10));
      expect(q.isDimensionless, isTrue);
    });
  });

  group('isPrefix on other unit types', () {
    test('PrimitiveUnit.isPrefix is false', () {
      expect(const PrimitiveUnit(id: 'm').isPrefix, isFalse);
    });

    test('DerivedUnit.isPrefix is false', () {
      expect(
        const DerivedUnit(id: 'km', expression: '1000 m').isPrefix,
        isFalse,
      );
    });

    test('AffineUnit.isPrefix is false', () {
      const unit = AffineUnit(
        id: 'tempC',
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      expect(unit.isPrefix, isFalse);
    });
  });

  group('PrimitiveUnit resolution', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      repo.register(
        const PrimitiveUnit(
          id: 'm',
          aliases: ['meter'],
          description: 'SI base unit of length',
        ),
      );
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
      repo2.register(const PrimitiveUnit(id: 'kg'));
      final unit = repo2.getUnit('kg');
      final q = resolveUnit(unit, repo2);
      expect(q.dimension, Dimension({'kg': 1}));
    });
  });
}
