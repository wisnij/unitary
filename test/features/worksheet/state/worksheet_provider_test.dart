import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';
import 'package:unitary/features/worksheet/state/worksheet_state.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = SettingsRepository(prefs);
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WorksheetNotifier', () {
    test('initial state uses first template and no active row', () {
      final state = container.read(worksheetProvider);
      expect(state.worksheetId, predefinedWorksheets.first.id);
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
}
