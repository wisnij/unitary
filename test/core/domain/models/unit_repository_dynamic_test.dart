import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository();
    repo.register(const PrimitiveUnit(id: 'kg'));
    repo.register(
      const DerivedUnit(
        id: 'lb',
        aliases: ['pound'],
        expression: '0.453592 kg',
      ),
    );
  });

  group('UnitRepository.registerDynamic', () {
    test('dynamic unit is found by its primary id', () {
      repo.registerDynamic(
        const DerivedUnit(id: 'tonne', expression: '1000 kg'),
      );
      expect(repo.findUnit('tonne')?.id, 'tonne');
    });

    test('dynamic unit is found by its alias', () {
      repo.registerDynamic(
        const DerivedUnit(id: 'tonne', aliases: ['t'], expression: '1000 kg'),
      );
      expect(repo.findUnit('t')?.id, 'tonne');
    });

    test('dynamic unit shadows a compiled unit with the same id', () {
      const updated = DerivedUnit(
        id: 'lb',
        aliases: ['pound'],
        expression: '0.5 kg',
      );
      repo.registerDynamic(updated);
      expect(repo.findUnit('lb'), same(updated));
      expect(repo.findUnit('pound'), same(updated));
    });

    test('dynamic unit shadows compiled unit via alias lookup', () {
      const updated = DerivedUnit(
        id: 'lb',
        aliases: ['pound'],
        expression: '0.5 kg',
      );
      repo.registerDynamic(updated);
      expect(repo.findUnit('pound'), same(updated));
    });

    test('duplicate dynamic registration replaces silently', () {
      repo.registerDynamic(
        const DerivedUnit(id: 'tonne', expression: '900 kg'),
      );
      const second = DerivedUnit(id: 'tonne', expression: '1000 kg');
      repo.registerDynamic(second);
      expect(repo.findUnit('tonne'), same(second));
    });

    test('findUnitWithPrefix returns dynamic unit for exact match', () {
      repo.registerDynamic(
        const DerivedUnit(id: 'tonne', expression: '1000 kg'),
      );
      final match = repo.findUnitWithPrefix('tonne');
      expect(match.unit?.id, 'tonne');
    });
  });

  group('UnitRepository.unregisterDynamic', () {
    test('removing dynamic unit restores compiled fallback', () {
      final original = repo.findUnit('lb');
      repo.registerDynamic(
        const DerivedUnit(id: 'lb', aliases: ['pound'], expression: '0.5 kg'),
      );
      repo.unregisterDynamic('lb');
      expect(repo.findUnit('lb'), same(original));
      expect(repo.findUnit('pound'), same(original));
    });

    test('removing dynamic-only unit makes id unknown', () {
      repo.registerDynamic(
        const DerivedUnit(id: 'tonne', expression: '1000 kg'),
      );
      repo.unregisterDynamic('tonne');
      expect(repo.findUnit('tonne'), isNull);
    });

    test('removing a non-existent dynamic id is a no-op', () {
      expect(() => repo.unregisterDynamic('nosuchunit'), returnsNormally);
      expect(repo.findUnit('kg')?.id, 'kg');
    });
  });

  group('UnitRepository.allDynamicUnits', () {
    test('empty before any dynamic registrations', () {
      expect(repo.allDynamicUnits, isEmpty);
    });

    test('reflects units after registration', () {
      const u1 = DerivedUnit(id: 'tonne', expression: '1000 kg');
      const u2 = DerivedUnit(id: 'stone', expression: '6.35 kg');
      repo.registerDynamic(u1);
      repo.registerDynamic(u2);
      expect(repo.allDynamicUnits, containsAll([u1, u2]));
    });

    test('does not include removed units', () {
      const u = DerivedUnit(id: 'tonne', expression: '1000 kg');
      repo.registerDynamic(u);
      repo.unregisterDynamic('tonne');
      expect(repo.allDynamicUnits, isEmpty);
    });

    test('reflects latest registration when id registered twice', () {
      repo.registerDynamic(
        const DerivedUnit(id: 'tonne', expression: '900 kg'),
      );
      const second = DerivedUnit(id: 'tonne', expression: '1000 kg');
      repo.registerDynamic(second);
      expect(repo.allDynamicUnits.toList(), [second]);
    });
  });

  group('cache invalidation on registerDynamic', () {
    test('stale cached resolution is discarded after registerDynamic', () {
      // Resolve and cache lb → 0.453592 kg
      final before = repo.resolveUnit(repo.getUnit('lb'));
      expect(before.value, closeTo(0.453592, 1e-6));

      // Update lb to a new rate
      repo.registerDynamic(
        const DerivedUnit(id: 'lb', aliases: ['pound'], expression: '0.5 kg'),
      );

      // Next resolution must reflect the new value, not the cached one
      final after = repo.resolveUnit(repo.getUnit('lb'));
      expect(after.value, closeTo(0.5, 1e-9));
      expect(after.dimension, Dimension({'kg': 1}));
    });

    test('units depending on updated unit also reflect new value', () {
      // Register a chain: stone = 14 lb
      repo.register(const DerivedUnit(id: 'stone', expression: '14 lb'));

      // Prime the cache for stone
      final before = repo.resolveUnit(repo.getUnit('stone'));
      expect(before.value, closeTo(14 * 0.453592, 1e-4));

      // Update lb
      repo.registerDynamic(
        const DerivedUnit(id: 'lb', aliases: ['pound'], expression: '0.5 kg'),
      );

      // stone must re-evaluate through new lb
      final after = repo.resolveUnit(repo.getUnit('stone'));
      expect(after.value, closeTo(7.0, 1e-9));
    });
  });
}
