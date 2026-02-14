import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_definition.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

void main() {
  group('isAffine', () {
    test('PrimitiveUnitDefinition returns false', () {
      expect(PrimitiveUnitDefinition().isAffine, isFalse);
    });

    test('AffineDefinition returns true', () {
      const def = AffineDefinition(
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      expect(def.isAffine, isTrue);
    });

    test('CompoundDefinition returns false', () {
      const def = CompoundDefinition(expression: 'kg m / s^2');
      expect(def.isAffine, isFalse);
    });
  });

  group('AffineDefinition', () {
    late UnitRepository repo;

    setUp(() {
      // Set up a minimal repo with K as a primitive.
      repo = UnitRepository();
      repo.register(
        Unit(
          id: 'K',
          aliases: ['kelvin'],
          definition: PrimitiveUnitDefinition(),
        ),
      );
    });

    test('isPrimitive is false', () {
      const def = AffineDefinition(
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      expect(def.isPrimitive, isFalse);
    });

    test('toQuantity computes (value + offset) * factor', () {
      // tempC: factor=1.0, offset=273.15, base=K
      // tempC(100) = (100 + 273.15) * 1.0 = 373.15 K
      const def = AffineDefinition(
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      final result = def.toQuantity(100.0, repo);
      expect(result.value, closeTo(373.15, 1e-10));
      expect(result.dimension, Dimension({'K': 1}));
    });

    test('tempF(212) = 373.15 K', () {
      const def = AffineDefinition(
        factor: 5 / 9,
        offset: 459.67,
        baseUnitId: 'K',
      );
      final result = def.toQuantity(212.0, repo);
      expect(result.value, closeTo(373.15, 1e-2));
      expect(result.dimension, Dimension({'K': 1}));
    });

    test('tempF(32) = 273.15 K', () {
      const def = AffineDefinition(
        factor: 5 / 9,
        offset: 459.67,
        baseUnitId: 'K',
      );
      final result = def.toQuantity(32.0, repo);
      expect(result.value, closeTo(273.15, 1e-2));
    });

    test('tempF(-40) = 233.15 K', () {
      const def = AffineDefinition(
        factor: 5 / 9,
        offset: 459.67,
        baseUnitId: 'K',
      );
      final result = def.toQuantity(-40.0, repo);
      expect(result.value, closeTo(233.15, 1e-2));
    });

    test('tempC(100) = 373.15 K', () {
      const def = AffineDefinition(
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      final result = def.toQuantity(100.0, repo);
      expect(result.value, closeTo(373.15, 1e-10));
    });

    test('tempC(0) = 273.15 K', () {
      const def = AffineDefinition(
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      final result = def.toQuantity(0.0, repo);
      expect(result.value, closeTo(273.15, 1e-10));
    });

    test('tempK(373.15) = 373.15 K', () {
      const def = AffineDefinition(factor: 1.0, offset: 0.0, baseUnitId: 'K');
      final result = def.toQuantity(373.15, repo);
      expect(result.value, closeTo(373.15, 1e-10));
    });

    test('tempR(671.67) ≈ 373.15 K', () {
      const def = AffineDefinition(factor: 5 / 9, offset: 0.0, baseUnitId: 'K');
      final result = def.toQuantity(671.67, repo);
      expect(result.value, closeTo(373.15, 1e-2));
    });

    test('tempR(0) = 0 K', () {
      const def = AffineDefinition(factor: 5 / 9, offset: 0.0, baseUnitId: 'K');
      final result = def.toQuantity(0.0, repo);
      expect(result.value, closeTo(0.0, 1e-10));
    });
  });

  group('CompoundDefinition', () {
    test('isPrimitive is false', () {
      const def = CompoundDefinition(expression: 'kg m / s^2');
      expect(def.isPrimitive, isFalse);
    });

    test('stores expression string', () {
      const def = CompoundDefinition(expression: 'kg m / s^2');
      expect(def.expression, 'kg m / s^2');
    });

    test('toQuantity throws UnsupportedError', () {
      const def = CompoundDefinition(expression: 'kg m / s^2');
      final repo = UnitRepository();
      expect(() => def.toQuantity(1.0, repo), throwsUnsupportedError);
    });

    test('const construction', () {
      const def = CompoundDefinition(expression: '1000 m');
      expect(def.expression, '1000 m');
    });
  });
}
