import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/worksheet/data/worksheet_repository.dart';

void main() {
  group('WorksheetRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<WorksheetRepository> makeRepo() async {
      final prefs = await SharedPreferences.getInstance();
      return WorksheetRepository(prefs);
    }

    group('load', () {
      test(
        'returns null active ID and empty sources when prefs are empty',
        () async {
          final repo = await makeRepo();
          final state = repo.load();
          expect(state.activeWorksheetId, isNull);
          expect(state.sources, isEmpty);
        },
      );

      test('round-trips a null active worksheet ID', () async {
        final repo = await makeRepo();
        await repo.save(
          const WorksheetPersistState(
            activeWorksheetId: null,
            sources: {'mass': WorksheetSourceEntry(rowIndex: 0, text: '1 kg')},
          ),
        );
        final restored = repo.load();
        expect(restored.activeWorksheetId, isNull);
        expect(restored.sources['mass']!.text, '1 kg');
      });

      test('restores saved active worksheet ID', () async {
        final repo = await makeRepo();
        await repo.save(
          const WorksheetPersistState(
            activeWorksheetId: 'mass',
            sources: {},
          ),
        );
        final restored = repo.load();
        expect(restored.activeWorksheetId, 'mass');
      });

      test('restores saved sources map', () async {
        final repo = await makeRepo();
        await repo.save(
          const WorksheetPersistState(
            activeWorksheetId: 'length',
            sources: {
              'length': WorksheetSourceEntry(rowIndex: 2, text: '5 ft'),
              'mass': WorksheetSourceEntry(rowIndex: 0, text: '70 kg'),
            },
          ),
        );
        final restored = repo.load();
        expect(restored.sources['length']!.rowIndex, 2);
        expect(restored.sources['length']!.text, '5 ft');
        expect(restored.sources['mass']!.rowIndex, 0);
        expect(restored.sources['mass']!.text, '70 kg');
      });

      test('round-trips complete state correctly', () async {
        final repo = await makeRepo();
        const original = WorksheetPersistState(
          activeWorksheetId: 'temperature',
          sources: {
            'temperature': WorksheetSourceEntry(rowIndex: 1, text: '100'),
            'energy': WorksheetSourceEntry(rowIndex: 3, text: '1 kWh'),
          },
        );
        await repo.save(original);
        final restored = repo.load();
        expect(restored.activeWorksheetId, original.activeWorksheetId);
        expect(restored.sources.length, original.sources.length);
        for (final key in original.sources.keys) {
          expect(
            restored.sources[key]!.rowIndex,
            original.sources[key]!.rowIndex,
          );
          expect(restored.sources[key]!.text, original.sources[key]!.text);
        }
      });

      test(
        'returns null active ID when saved active ID is unrecognised',
        () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            WorksheetRepository.prefsKey,
            '{"activeWorksheetId":"no_such_template","sources":'
            '{"mass":{"rowIndex":0,"text":"1 kg"}}}',
          );
          final repo = WorksheetRepository(prefs);
          final state = repo.load();
          expect(state.activeWorksheetId, isNull);
          // Sources are still preserved even when the active ID is dropped.
          expect(state.sources['mass']!.text, '1 kg');
        },
      );

      test('handles malformed JSON gracefully and returns defaults', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(WorksheetRepository.prefsKey, 'not valid json');
        final repo = WorksheetRepository(prefs);
        final state = repo.load();
        expect(state.activeWorksheetId, isNull);
        expect(state.sources, isEmpty);
      });
    });

    group('save', () {
      test('overwrites previous data', () async {
        final repo = await makeRepo();
        await repo.save(
          const WorksheetPersistState(
            activeWorksheetId: 'mass',
            sources: {'mass': WorksheetSourceEntry(rowIndex: 0, text: '1 kg')},
          ),
        );
        await repo.save(
          const WorksheetPersistState(
            activeWorksheetId: 'length',
            sources: {},
          ),
        );
        final state = repo.load();
        expect(state.activeWorksheetId, 'length');
        expect(state.sources, isEmpty);
      });
    });
  });
}
