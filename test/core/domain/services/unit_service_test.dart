import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/builtin_units.dart';
import 'package:unitary/core/domain/errors.dart';
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
      final q = Quantity(5.0, Dimension({'zorblax': 1}));
      final result = reduce(q, repo);
      expect(result.value, 5.0);
      expect(result.dimension, Dimension({'zorblax': 1}));
    });

    test('multiple non-primitives: lb ft → kg m', () {
      final q = Quantity(1.0, Dimension({'lb': 1, 'ft': 1}));
      final result = reduce(q, repo);
      expect(result.value, closeTo(0.45359237 * 0.3048, 1e-10));
      expect(result.dimension, Dimension({'kg': 1, 'm': 1}));
    });
  });

  group('convert()', () {
    test('convert 1.524 m to meters', () {
      final q = Quantity(1.524, Dimension({'m': 1}));
      final mUnit = repo.getUnit('m');
      final result = convert(q, mUnit, repo);
      expect(result.value, closeTo(1.524, 1e-10));
    });

    test('convert meters to feet', () {
      final q = Quantity(1.524, Dimension({'m': 1}));
      final ftUnit = repo.getUnit('ft');
      final result = convert(q, ftUnit, repo);
      expect(result.value, closeTo(5.0, 1e-10));
    });

    test('convert non-primitive quantity to non-primitive target', () {
      // 5 ft in non-primitive dimension → reduce → convert to miles
      final q = Quantity(5.0, Dimension({'ft': 1}));
      final miUnit = repo.getUnit('mi');
      final result = convert(q, miUnit, repo);
      expect(result.value, closeTo(5.0 * 0.3048 / 1609.344, 1e-10));
    });

    test('round-trip: meters → feet → meters', () {
      final q = Quantity(3.0, Dimension({'m': 1}));
      final ftUnit = repo.getUnit('ft');
      final mUnit = repo.getUnit('m');
      final inFeet = convert(q, ftUnit, repo);
      // convert() returns value in target unit with primitive dimension.
      // To round-trip, wrap in the target unit's dimension.
      final feetQuantity = Quantity(inFeet.value, Dimension({'ft': 1}));
      final backToMeters = convert(feetQuantity, mUnit, repo);
      expect(backToMeters.value, closeTo(3.0, 1e-10));
    });

    test('round-trip: kg → lb → kg', () {
      final q = Quantity(10.0, Dimension({'kg': 1}));
      final lbUnit = repo.getUnit('lb');
      final kgUnit = repo.getUnit('kg');
      final inLb = convert(q, lbUnit, repo);
      final lbQuantity = Quantity(inLb.value, Dimension({'lb': 1}));
      final backToKg = convert(lbQuantity, kgUnit, repo);
      expect(backToKg.value, closeTo(10.0, 1e-10));
    });

    test('non-conformable: meters to seconds throws DimensionException', () {
      final q = Quantity(5.0, Dimension({'m': 1}));
      final sUnit = repo.getUnit('s');
      expect(() => convert(q, sUnit, repo), throwsA(isA<DimensionException>()));
    });

    test('non-conformable error message is descriptive', () {
      final q = Quantity(5.0, Dimension({'m': 1}));
      final sUnit = repo.getUnit('s');
      expect(
        () => convert(q, sUnit, repo),
        throwsA(
          isA<DimensionException>().having(
            (e) => e.message,
            'message',
            allOf(contains('m'), contains('s')),
          ),
        ),
      );
    });

    test('convert with chained units: miles to feet', () {
      // 1 mile = 5280 feet
      final q = Quantity(1.0, Dimension({'mi': 1}));
      final ftUnit = repo.getUnit('ft');
      final result = convert(q, ftUnit, repo);
      expect(result.value, closeTo(5280.0, 1e-6));
    });

    test('convert preserves target dimension', () {
      final q = Quantity(5.0, Dimension({'ft': 1}));
      final mUnit = repo.getUnit('m');
      final result = convert(q, mUnit, repo);
      expect(result.dimension, Dimension({'m': 1}));
    });

    test(
      'convert dimensionless quantity to dimensionless unit fails gracefully',
      () {
        // Dimensionless quantity to a length unit → non-conformable
        final q = Quantity.dimensionless(5.0);
        final mUnit = repo.getUnit('m');
        expect(
          () => convert(q, mUnit, repo),
          throwsA(isA<DimensionException>()),
        );
      },
    );
  });
}
