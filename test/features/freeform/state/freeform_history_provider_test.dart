import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/freeform/data/freeform_history_repository.dart';
import 'package:unitary/features/freeform/state/freeform_history_provider.dart';

void main() {
  late ProviderContainer container;
  late FreeformHistoryRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = FreeformHistoryRepository(prefs);
    container = ProviderContainer(
      overrides: [
        freeformHistoryRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FreeformHistoryNotifier', () {
    test('build() returns empty list when storage is empty', () {
      final history = container.read(freeformHistoryProvider);
      expect(history, isEmpty);
    });

    test('build() restores persisted history', () async {
      final entries = [
        const FreeformHistoryEntry(from: '5 km', to: 'mi'),
        const FreeformHistoryEntry(from: '100 degF', to: 'tempC'),
      ];
      await repo.save(entries);

      // New container reads from the already-populated prefs.
      final freshContainer = ProviderContainer(
        overrides: [
          freeformHistoryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(freshContainer.dispose);

      final history = freshContainer.read(freeformHistoryProvider);
      expect(history.length, 2);
      expect(history[0], entries[0]);
      expect(history[1], entries[1]);
    });

    group('record()', () {
      test('prepends a new entry', () async {
        final notifier = container.read(freeformHistoryProvider.notifier);
        await notifier.record('5 km', 'mi');
        final history = container.read(freeformHistoryProvider);
        expect(history.length, 1);
        expect(history[0].from, '5 km');
        expect(history[0].to, 'mi');
      });

      test('trims whitespace from from and to values', () async {
        final notifier = container.read(freeformHistoryProvider.notifier);
        await notifier.record('  5 km  ', '  mi  ');
        final history = container.read(freeformHistoryProvider);
        expect(history[0].from, '5 km');
        expect(history[0].to, 'mi');
      });

      test('stores empty to field as empty string', () async {
        final notifier = container.read(freeformHistoryProvider.notifier);
        await notifier.record('5 km', '');
        expect(container.read(freeformHistoryProvider)[0].to, '');
      });

      test('new entries are prepended before older ones', () async {
        final notifier = container.read(freeformHistoryProvider.notifier);
        await notifier.record('5 km', 'mi');
        await notifier.record('100 degF', 'tempC');
        final history = container.read(freeformHistoryProvider);
        expect(history[0].from, '100 degF');
        expect(history[1].from, '5 km');
      });

      test('deduplicates: existing pair is removed and re-prepended', () async {
        final notifier = container.read(freeformHistoryProvider.notifier);
        await notifier.record('5 km', 'mi');
        await notifier.record('100 degF', 'tempC');
        await notifier.record('5 km', 'mi');
        final history = container.read(freeformHistoryProvider);
        expect(history.length, 2);
        expect(history[0].from, '5 km');
        expect(history[1].from, '100 degF');
      });

      test('dedup does not shrink a full list below maxEntries', () async {
        final notifier = container.read(freeformHistoryProvider.notifier);
        // Fill to cap.
        for (var i = 0; i < FreeformHistoryRepository.maxEntries; i++) {
          await notifier.record('$i km', 'mi');
        }
        expect(
          container.read(freeformHistoryProvider).length,
          FreeformHistoryRepository.maxEntries,
        );
        // Re-submit the oldest entry (now at the end).
        await notifier.record('0 km', 'mi');
        expect(
          container.read(freeformHistoryProvider).length,
          FreeformHistoryRepository.maxEntries,
        );
        expect(container.read(freeformHistoryProvider)[0].from, '0 km');
      });

      test('drops oldest entry when cap is exceeded', () async {
        final notifier = container.read(freeformHistoryProvider.notifier);
        for (var i = 0; i < FreeformHistoryRepository.maxEntries; i++) {
          await notifier.record('$i km', 'mi');
        }
        await notifier.record('new entry', '');
        final history = container.read(freeformHistoryProvider);
        expect(history.length, FreeformHistoryRepository.maxEntries);
        expect(history[0].from, 'new entry');
        expect(history.last.from, '1 km');
      });

      test('persists entries to repository', () async {
        final notifier = container.read(freeformHistoryProvider.notifier);
        await notifier.record('5 km', 'mi');
        final saved = repo.load();
        expect(saved.length, 1);
        expect(saved[0].from, '5 km');
      });
    });
  });
}
