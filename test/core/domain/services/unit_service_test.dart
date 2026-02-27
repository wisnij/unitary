import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/builtin_units.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/services/unit_service.dart';

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository();
    registerBuiltinUnits(repo);
  });

  group('reduce()', () {
    test('quantity already in primitives is unchanged', () {
      final q = Quantity(5.0, Dimension({'m': 1}));
      final result = reduce(q, repo);
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('dimensionless quantity is unchanged', () {
      final q = Quantity.dimensionless(42.0);
      final result = reduce(q, repo);
      expect(result.value, 42.0);
      expect(result.isDimensionless, isTrue);
    });

    test('single non-primitive: 5 ft → 1.524 m', () {
      final q = Quantity(5.0, Dimension({'ft': 1}));
      final result = reduce(q, repo);
      expect(result.value, closeTo(1.524, 1e-10));
      expect(result.dimension, Dimension({'m': 1}));
    });

    test('compound dimension: 60 mi/hr → m/s', () {
      final q = Quantity(60.0, Dimension({'mi': 1, 'hr': -1}));
      final result = reduce(q, repo);
      expect(result.value, closeTo(26.8224, 1e-4));
      expect(result.dimension, Dimension({'m': 1, 's': -1}));
    });

    test('with exponents: 1 ft^2 → m^2', () {
      final q = Quantity(1.0, Dimension({'ft': 2}));
      final result = reduce(q, repo);
      expect(result.value, closeTo(math.pow(0.3048, 2), 1e-10));
      expect(result.dimension, Dimension({'m': 2}));
    });

    test('negative exponents: 1 ft^-1 → m^-1', () {
      final q = Quantity(1.0, Dimension({'ft': -1}));
      final result = reduce(q, repo);
      expect(result.value, closeTo(1.0 / 0.3048, 1e-6));
      expect(result.dimension, Dimension({'m': -1}));
    });

    test('mixed primitive/non-primitive: 5 ft kg → m kg', () {
      final q = Quantity(5.0, Dimension({'ft': 1, 'kg': 1}));
      final result = reduce(q, repo);
      expect(result.value, closeTo(1.524, 1e-10));
      expect(result.dimension, Dimension({'m': 1, 'kg': 1}));
    });

    test('unknown unit name is kept as-is', () {
      final q = Quantity(5.0, Dimension({'wakalixes': 1}));
      final result = reduce(q, repo);
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'wakalixes': 1}));
    });

    test('multiple non-primitives: lb ft → kg m', () {
      final q = Quantity(1.0, Dimension({'lb': 1, 'ft': 1}));
      final result = reduce(q, repo);
      expect(result.value, closeTo(0.45359237 * 0.3048, 1e-10));
      expect(result.dimension, Dimension({'kg': 1, 'm': 1}));
    });
  });
}
