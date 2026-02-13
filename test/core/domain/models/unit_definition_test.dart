import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_definition.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

void main() {
  group('isAffine', () {
    test('PrimitiveUnitDefinition returns false', () {
      expect(PrimitiveUnitDefinition().isAffine, isFalse);
    });

    test('LinearDefinition returns false', () {
      const def = LinearDefinition(factor: 1.0, baseUnitId: 'K');
      expect(def.isAffine, isFalse);
    });

    test('AffineDefinition returns true', () {
      const def = AffineDefinition(
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      expect(def.isAffine, isTrue);
    });

    test('ConstantDefinition returns false', () {
      final def = ConstantDefinition(
        constantValue: 3.14159,
        dimension: Dimension.dimensionless,
      );
      expect(def.isAffine, isFalse);
    });

    test('CompoundDefinition returns false', () {
      final def = CompoundDefinition(expression: 'kg m / s^2');
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
      // tempF: factor=5/9, offset=-32.0, base=K
      // (212 + (-32)) * (5/9) = 180 * 5/9 = 100
      // Then 100 through K primitive = 100 K
      // Wait, that's wrong. The formula should give kelvin.
      // tempF(212): (212 - 32) * 5/9 + 273.15 = 373.15 K
      // But with our model: (value + offset) * factor through base K
      // We need (212 + (-32)) * (5/9) = 100 through base K = 100 K
      // That's only 100 K, not 373.15 K.
      // So tempF should be: offset such that (value + offset) * factor = kelvin
      // 212°F = 373.15 K → (212 + offset) * factor = 373.15
      // factor = 5/9, offset = 459.67 → (212 + 459.67) * 5/9 = 671.67 * 5/9 = 373.15
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

  group('ConstantDefinition', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
    });

    test('isPrimitive is false', () {
      final def = ConstantDefinition(
        constantValue: 3.14159,
        dimension: Dimension.dimensionless,
      );
      expect(def.isPrimitive, isFalse);
    });

    test('toQuantity scales by constantValue for dimensionless', () {
      final def = ConstantDefinition(
        constantValue: 3.14159265358979,
        dimension: Dimension.dimensionless,
      );
      final result = def.toQuantity(2.0, repo);
      expect(result.value, closeTo(6.28318530717958, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('toQuantity preserves dimension', () {
      final def = ConstantDefinition(
        constantValue: 299792458.0,
        dimension: Dimension({'m': 1, 's': -1}),
      );
      final result = def.toQuantity(1.0, repo);
      expect(result.value, closeTo(299792458.0, 1e-2));
      expect(result.dimension, Dimension({'m': 1, 's': -1}));
    });

    test('toQuantity with value=1 returns constantValue', () {
      final def = ConstantDefinition(
        constantValue: 9.80665,
        dimension: Dimension({'m': 1, 's': -2}),
      );
      final result = def.toQuantity(1.0, repo);
      expect(result.value, closeTo(9.80665, 1e-10));
    });
  });

  group('CompoundDefinition', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
    });

    test('isPrimitive is false', () {
      final def = CompoundDefinition(expression: 'kg m / s^2');
      expect(def.isPrimitive, isFalse);
    });

    test('isResolved is false before resolve', () {
      final def = CompoundDefinition(expression: 'kg m / s^2');
      expect(def.isResolved, isFalse);
    });

    test('toQuantity throws StateError before resolve', () {
      final def = CompoundDefinition(expression: 'kg m / s^2');
      expect(() => def.toQuantity(1.0, repo), throwsStateError);
    });

    test('isResolved is true after resolve', () {
      final def = CompoundDefinition(expression: 'kg m / s^2');
      final baseQuantity = Quantity(1.0, Dimension({'kg': 1, 'm': 1, 's': -2}));
      def.resolve(baseQuantity);
      expect(def.isResolved, isTrue);
    });

    test('toQuantity works after resolve', () {
      final def = CompoundDefinition(expression: 'kg m / s^2');
      final baseQuantity = Quantity(1.0, Dimension({'kg': 1, 'm': 1, 's': -2}));
      def.resolve(baseQuantity);
      final result = def.toQuantity(5.0, repo);
      expect(result.value, closeTo(5.0, 1e-10));
      expect(result.dimension, Dimension({'kg': 1, 'm': 1, 's': -2}));
    });

    test('toQuantity scales by base quantity value', () {
      final def = CompoundDefinition(expression: 'some expr');
      final baseQuantity = Quantity(2.5, Dimension({'m': 1}));
      def.resolve(baseQuantity);
      final result = def.toQuantity(3.0, repo);
      expect(result.value, closeTo(7.5, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('resolve throws if already resolved', () {
      final def = CompoundDefinition(expression: 'kg m / s^2');
      final baseQuantity = Quantity(1.0, Dimension({'kg': 1, 'm': 1, 's': -2}));
      def.resolve(baseQuantity);
      expect(() => def.resolve(baseQuantity), throwsStateError);
    });
  });
}
