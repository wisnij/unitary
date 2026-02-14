import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/unit_definition.dart';

void main() {
  group('isAffine', () {
    test('PrimitiveUnitDefinition returns false', () {
      expect(const PrimitiveUnitDefinition().isAffine, isFalse);
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

  group('isPrimitive', () {
    test('PrimitiveUnitDefinition returns true', () {
      expect(const PrimitiveUnitDefinition().isPrimitive, isTrue);
    });

    test('AffineDefinition returns false', () {
      const def = AffineDefinition(
        factor: 1.0,
        offset: 273.15,
        baseUnitId: 'K',
      );
      expect(def.isPrimitive, isFalse);
    });

    test('CompoundDefinition returns false', () {
      const def = CompoundDefinition(expression: 'kg m / s^2');
      expect(def.isPrimitive, isFalse);
    });
  });

  group('CompoundDefinition', () {
    test('stores expression string', () {
      const def = CompoundDefinition(expression: 'kg m / s^2');
      expect(def.expression, 'kg m / s^2');
    });

    test('const construction', () {
      const def = CompoundDefinition(expression: '1000 m');
      expect(def.expression, '1000 m');
    });
  });
}
