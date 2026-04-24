import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/data/worksheet_repository.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';
import 'package:unitary/features/worksheet/state/worksheet_state.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsRepo = SettingsRepository(prefs);
    final worksheetRepo = WorksheetRepository(prefs);
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WorksheetNotifier', () {
    test('initial state uses length template and no active row', () {
      final state = container.read(worksheetProvider);
      expect(state.worksheetId, 'length');
      expect(state.activeRowIndex, isNull);
    });

    test('selectWorksheet changes the active template', () {
      container.read(worksheetProvider.notifier).selectWorksheet('mass');
      expect(container.read(worksheetProvider).worksheetId, 'mass');
    });

    test('selectWorksheet with same id is a no-op', () {
      final initial = container.read(worksheetProvider);
      container
          .read(worksheetProvider.notifier)
          .selectWorksheet(initial.worksheetId);
      expect(
        container.read(worksheetProvider).worksheetId,
        initial.worksheetId,
      );
    });

    test('selectWorksheet clears activeRowIndex', () {
      container.read(worksheetProvider.notifier).onRowChanged('length', 0, '1');
      expect(container.read(worksheetProvider).activeRowIndex, 0);
      container.read(worksheetProvider.notifier).selectWorksheet('mass');
      expect(container.read(worksheetProvider).activeRowIndex, isNull);
    });

    test('onRowFocused does not set activeRowIndex', () {
      container.read(worksheetProvider.notifier).onRowFocused('length', 2);
      // Focus alone must NOT transfer active row ownership.
      expect(container.read(worksheetProvider).activeRowIndex, isNull);
    });

    test('onRowChanged sets activeRowIndex', () {
      container.read(worksheetProvider.notifier).onRowChanged('length', 3, '5');
      expect(container.read(worksheetProvider).activeRowIndex, 3);
    });

    test('onRowChanged updates the source row display value immediately', () {
      container
          .read(worksheetProvider.notifier)
          .onRowChanged('length', 0, '42');
      final template = predefinedWorksheets.firstWhere((t) => t.id == 'length');
      final values = container
          .read(worksheetProvider)
          .valuesFor('length', template.rows.length);
      expect(values[0].text, '42');
    });

    test('empty input clears all other rows', () {
      final notifier = container.read(worksheetProvider.notifier);
      // First type a valid value so other rows have content.
      notifier.onRowChanged('length', 0, '1');
      // Now clear the source row.
      notifier.onRowChanged('length', 0, '');
      final template = predefinedWorksheets.firstWhere((t) => t.id == 'length');
      final values = container
          .read(worksheetProvider)
          .valuesFor('length', template.rows.length);
      // All non-source rows should be blank.
      for (var i = 1; i < values.length; i++) {
        expect(values[i].text, '', reason: 'row $i should be blank');
      }
    });

    test('switching worksheets preserves per-worksheet values', () {
      final notifier = container.read(worksheetProvider.notifier);
      notifier.onRowChanged('length', 0, '5');
      notifier.selectWorksheet('mass');
      notifier.onRowChanged('mass', 0, '10');
      notifier.selectWorksheet('length');

      final lengthTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'length',
      );
      final lengthValues = container
          .read(worksheetProvider)
          .valuesFor('length', lengthTemplate.rows.length);
      expect(lengthValues[0].text, '5');
    });

    test('other rows update immediately on change', () {
      container.read(worksheetProvider.notifier).onRowChanged('length', 0, '1');
      final template = predefinedWorksheets.firstWhere((t) => t.id == 'length');
      final values = container
          .read(worksheetProvider)
          .valuesFor('length', template.rows.length);
      // cm row should have a value (~100) immediately.
      expect(values[1].text, isNotEmpty);
      expect(double.tryParse(values[1].text), isNotNull);
    });

    test(
      'WorksheetState.valuesFor returns empty strings for unvisited worksheet',
      () {
        const state = WorksheetState(
          worksheetId: 'length',
          activeRowIndex: null,
          worksheetValues: {},
        );
        final values = state.valuesFor('length', 3);
        expect(
          values.map((v) => v.text).toList(),
          equals(['', '', '']),
        );
      },
    );
  });

  group('WorksheetNotifier persistence', () {
    test(
      'build initialises from empty persist state with default template',
      () {
        final state = container.read(worksheetProvider);
        expect(state.worksheetId, 'length');
        expect(state.worksheetValues, isEmpty);
      },
    );

    test('build restores active worksheet ID from persisted state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final worksheetRepo = WorksheetRepository(prefs);
      await worksheetRepo.save(
        const WorksheetPersistState(
          activeWorksheetId: 'mass',
          sources: {},
        ),
      );
      final settingsRepo = SettingsRepository(prefs);
      final c = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
        ],
      );
      addTearDown(c.dispose);
      expect(c.read(worksheetProvider).worksheetId, 'mass');
    });

    test(
      'build seeds worksheet values by running engine for persisted sources',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final worksheetRepo = WorksheetRepository(prefs);
        await worksheetRepo.save(
          const WorksheetPersistState(
            activeWorksheetId: 'length',
            sources: {
              'length': WorksheetSourceEntry(rowIndex: 0, text: '1'),
            },
          ),
        );
        final settingsRepo = SettingsRepository(prefs);
        final c = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
          ],
        );
        addTearDown(c.dispose);

        final template = predefinedWorksheets.firstWhere(
          (t) => t.id == 'length',
        );
        final values = c
            .read(worksheetProvider)
            .valuesFor('length', template.rows.length);
        // Source row preserved as raw text.
        expect(values[0].text, '1');
        // Other rows derived — should be non-empty numeric values.
        expect(values[1].text, isNotEmpty);
        expect(double.tryParse(values[1].text), isNotNull);
      },
    );

    test(
      'engine error on restore is isolated to the affected template',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final worksheetRepo = WorksheetRepository(prefs);
        await worksheetRepo.save(
          const WorksheetPersistState(
            activeWorksheetId: 'length',
            sources: {
              'length': WorksheetSourceEntry(
                rowIndex: 0,
                text: 'not_a_real_unit_xyz',
              ),
            },
          ),
        );
        final settingsRepo = SettingsRepository(prefs);
        final c = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
          ],
        );
        addTearDown(c.dispose);

        // Should not throw.
        expect(() => c.read(worksheetProvider), returnsNormally);
      },
    );

    test('onRowChanged writes through to the repository', () async {
      container
          .read(worksheetProvider.notifier)
          .onRowChanged('length', 0, '5 ft');

      final prefs = await SharedPreferences.getInstance();
      final persisted = WorksheetRepository(prefs).load();
      expect(persisted.sources['length']!.rowIndex, 0);
      expect(persisted.sources['length']!.text, '5 ft');
    });

    test('selectWorksheet writes through the updated active ID', () async {
      container.read(worksheetProvider.notifier).selectWorksheet('mass');

      final prefs = await SharedPreferences.getInstance();
      final persisted = WorksheetRepository(prefs).load();
      expect(persisted.activeWorksheetId, 'mass');
    });

    test('multiple templates are restored independently', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final worksheetRepo = WorksheetRepository(prefs);
      await worksheetRepo.save(
        const WorksheetPersistState(
          activeWorksheetId: 'length',
          sources: {
            'length': WorksheetSourceEntry(rowIndex: 0, text: '1'),
            'mass': WorksheetSourceEntry(rowIndex: 0, text: '2'),
          },
        ),
      );
      final settingsRepo = SettingsRepository(prefs);
      final c = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
        ],
      );
      addTearDown(c.dispose);

      final lengthTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'length',
      );
      final massTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'mass',
      );

      final lengthValues = c
          .read(worksheetProvider)
          .valuesFor('length', lengthTemplate.rows.length);
      final massValues = c
          .read(worksheetProvider)
          .valuesFor('mass', massTemplate.rows.length);

      // Each template's source row shows its own persisted value.
      expect(lengthValues[0].text, '1');
      expect(massValues[0].text, '2');

      // Each template's other rows are derived independently.
      expect(lengthValues[1].text, isNotEmpty);
      expect(massValues[1].text, isNotEmpty);
      expect(lengthValues[1].text, isNot(equals(massValues[1].text)));
    });
  });
}
