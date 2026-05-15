import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/freeform/data/freeform_history_repository.dart';

void main() {
  group('FreeformHistoryRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<FreeformHistoryRepository> makeRepo() async {
      final prefs = await SharedPreferences.getInstance();
      return FreeformHistoryRepository(prefs);
    }

    group('load', () {
      test('returns empty list when prefs are empty', () async {
        final repo = await makeRepo();
        expect(repo.load(), isEmpty);
      });

      test('returns empty list for malformed JSON', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(FreeformHistoryRepository.prefsKey, 'not json');
        final repo = FreeformHistoryRepository(prefs);
        expect(repo.load(), isEmpty);
      });

      test('returns empty list for JSON that is not a list', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          FreeformHistoryRepository.prefsKey,
          '{"from":"5 km","to":"mi"}',
        );
        final repo = FreeformHistoryRepository(prefs);
        expect(repo.load(), isEmpty);
      });

      test('silently drops malformed individual entries', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          FreeformHistoryRepository.prefsKey,
          '[{"from":"5 km","to":"mi"},{"bad":true},{"from":"100 ft","to":"m"}]',
        );
        final repo = FreeformHistoryRepository(prefs);
        final entries = repo.load();
        expect(entries.length, 2);
        expect(entries[0].from, '5 km');
        expect(entries[1].from, '100 ft');
      });
    });

    group('save and load round-trip', () {
      test('preserves order and values', () async {
        final repo = await makeRepo();
        final entries = [
          const FreeformHistoryEntry(from: '5 km', to: 'mi'),
          const FreeformHistoryEntry(from: '100 degF', to: 'tempC'),
          const FreeformHistoryEntry(from: '9.8 m/s^2', to: ''),
        ];
        await repo.save(entries);
        final loaded = repo.load();
        expect(loaded.length, 3);
        expect(loaded[0], entries[0]);
        expect(loaded[1], entries[1]);
        expect(loaded[2], entries[2]);
      });

      test('saves empty list', () async {
        final repo = await makeRepo();
        await repo.save([]);
        expect(repo.load(), isEmpty);
      });

      test('overwrites previous data', () async {
        final repo = await makeRepo();
        await repo.save([const FreeformHistoryEntry(from: '5 km', to: 'mi')]);
        await repo.save([const FreeformHistoryEntry(from: '1 kg', to: 'lb')]);
        final loaded = repo.load();
        expect(loaded.length, 1);
        expect(loaded[0].from, '1 kg');
      });
    });

    group('cap enforcement', () {
      test('truncates list to maxEntries on save', () async {
        final repo = await makeRepo();
        final entries = List.generate(
          FreeformHistoryRepository.maxEntries + 10,
          (i) => FreeformHistoryEntry(from: '$i km', to: 'mi'),
        );
        await repo.save(entries);
        final loaded = repo.load();
        expect(loaded.length, FreeformHistoryRepository.maxEntries);
        expect(loaded.first.from, '0 km');
        expect(
          loaded.last.from,
          '${FreeformHistoryRepository.maxEntries - 1} km',
        );
      });

      test('does not truncate when at or below maxEntries', () async {
        final repo = await makeRepo();
        final entries = List.generate(
          FreeformHistoryRepository.maxEntries,
          (i) => FreeformHistoryEntry(from: '$i km', to: 'mi'),
        );
        await repo.save(entries);
        expect(repo.load().length, FreeformHistoryRepository.maxEntries);
      });
    });
  });
}
