import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/models/unit_repository_provider.dart';
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
    test('initial state has no active worksheet and no active row', () {
      final state = container.read(worksheetProvider);
      expect(state.worksheetId, isNull);
      expect(state.activeRowIndex, isNull);
    });

    test('selectWorksheet changes the active template', () {
      container.read(worksheetProvider.notifier).selectWorksheet('mass');
      expect(container.read(worksheetProvider).worksheetId, 'mass');
    });

    test('selectWorksheet from no selection sets the active template', () {
      expect(container.read(worksheetProvider).worksheetId, isNull);
      container.read(worksheetProvider.notifier).selectWorksheet('length');
      expect(container.read(worksheetProvider).worksheetId, 'length');
    });

    test('selectWorksheet with same id is a no-op', () {
      container.read(worksheetProvider.notifier).selectWorksheet('mass');
      container.read(worksheetProvider.notifier).selectWorksheet('mass');
      expect(container.read(worksheetProvider).worksheetId, 'mass');
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
      'build initialises from empty persist state with no active template',
      () {
        final state = container.read(worksheetProvider);
        expect(state.worksheetId, isNull);
        expect(state.worksheetValues, isEmpty);
      },
    );

    test(
      'build leaves no active template when persisted ID is unrecognised',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          WorksheetRepository.prefsKey,
          '{"activeWorksheetId":"no_such_template","sources":{}}',
        );
        final worksheetRepo = WorksheetRepository(prefs);
        final settingsRepo = SettingsRepository(prefs);
        final c = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
          ],
        );
        addTearDown(c.dispose);
        expect(c.read(worksheetProvider).worksheetId, isNull);
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

  group('WorksheetNotifier shared unit repository', () {
    test(
      'worksheet computations use the shared unitRepositoryProvider repo',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final settingsRepo = SettingsRepository(prefs);
        final worksheetRepo = WorksheetRepository(prefs);

        final repo = UnitRepository.withPredefinedUnits();
        // Override the compiled euro rate with a synthetic test-only rate
        // (1 euro = 0.5 USD, i.e. 1 USD = 2 EUR), as a currency rate
        // refresh would via registerDynamic.
        repo.registerDynamic(
          const DerivedUnit(
            id: 'euro',
            aliases: ['EUR'],
            expression: '1|2 USD',
          ),
        );

        final c = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
            unitRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(c.dispose);

        final template = predefinedWorksheets.firstWhere(
          (t) => t.id == 'currency',
        );
        final usdIndex = template.rows.indexWhere(
          (r) => r.expression == 'USD',
        );
        final eurIndex = template.rows.indexWhere(
          (r) => r.expression == 'EUR',
        );

        c
            .read(worksheetProvider.notifier)
            .onRowChanged('currency', usdIndex, '1');

        final values = c
            .read(worksheetProvider)
            .valuesFor('currency', template.rows.length);
        expect(double.parse(values[eurIndex].text), closeTo(2.0, 1e-9));
      },
    );

    test(
      'recomputes display values for persisted sources when '
      'unitRepositoryVersionProvider increments',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final settingsRepo = SettingsRepository(prefs);
        final worksheetRepo = WorksheetRepository(prefs);

        final template = predefinedWorksheets.firstWhere(
          (t) => t.id == 'currency',
        );
        final usdIndex = template.rows.indexWhere(
          (r) => r.expression == 'USD',
        );
        final eurIndex = template.rows.indexWhere(
          (r) => r.expression == 'EUR',
        );

        await worksheetRepo.save(
          WorksheetPersistState(
            activeWorksheetId: 'currency',
            sources: {
              'currency': WorksheetSourceEntry(rowIndex: usdIndex, text: '1'),
            },
          ),
        );

        final c = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
          ],
        );
        addTearDown(c.dispose);

        // Initial value uses the compiled fallback rate
        // (1 euro = 1|0.861567 USD, so 1 USD ~= 0.861567 EUR).
        final before = c
            .read(worksheetProvider)
            .valuesFor('currency', template.rows.length);
        expect(double.parse(before[eurIndex].text), closeTo(0.861567, 1e-4));

        // Simulate a currency rate refresh (synthetic test-only rate:
        // 1 euro = 0.5 USD, i.e. 1 USD = 2 EUR) and notify via the version
        // counter.
        final repo = c.read(unitRepositoryProvider);
        repo.registerDynamic(
          const DerivedUnit(
            id: 'euro',
            aliases: ['EUR'],
            expression: '1|2 USD',
          ),
        );
        c.read(unitRepositoryVersionProvider.notifier).increment();

        final after = c
            .read(worksheetProvider)
            .valuesFor('currency', template.rows.length);
        expect(double.parse(after[eurIndex].text), closeTo(2.0, 1e-9));
      },
    );

    test(
      'templates with no persisted source remain blank after '
      'unitRepositoryVersionProvider increments',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final settingsRepo = SettingsRepository(prefs);
        final worksheetRepo = WorksheetRepository(prefs);

        final c = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
          ],
        );
        addTearDown(c.dispose);

        // No persisted sources at all.
        c.read(worksheetProvider);
        c.read(unitRepositoryVersionProvider.notifier).increment();

        final massTemplate = predefinedWorksheets.firstWhere(
          (t) => t.id == 'mass',
        );
        final values = c
            .read(worksheetProvider)
            .valuesFor('mass', massTemplate.rows.length);
        expect(values.every((v) => v.text == ''), isTrue);
      },
    );

    test(
      'recompute after unitRepositoryVersionProvider increment is isolated '
      'to affected templates',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final settingsRepo = SettingsRepository(prefs);
        final worksheetRepo = WorksheetRepository(prefs);

        final currencyTemplate = predefinedWorksheets.firstWhere(
          (t) => t.id == 'currency',
        );
        final usdIndex = currencyTemplate.rows.indexWhere(
          (r) => r.expression == 'USD',
        );
        final eurIndex = currencyTemplate.rows.indexWhere(
          (r) => r.expression == 'EUR',
        );

        await worksheetRepo.save(
          WorksheetPersistState(
            activeWorksheetId: 'currency',
            sources: {
              'currency': WorksheetSourceEntry(rowIndex: usdIndex, text: '1'),
              // Out-of-range row index simulates a template whose row count
              // shrank since this source was persisted.
              'mass': const WorksheetSourceEntry(rowIndex: 99, text: '1'),
            },
          ),
        );

        final c = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
          ],
        );
        addTearDown(c.dispose);

        final repo = c.read(unitRepositoryProvider);
        repo.registerDynamic(
          const DerivedUnit(
            id: 'euro',
            aliases: ['EUR'],
            expression: '1|2 USD',
          ),
        );

        expect(
          () => c.read(unitRepositoryVersionProvider.notifier).increment(),
          returnsNormally,
        );

        final currencyValues = c
            .read(worksheetProvider)
            .valuesFor('currency', currencyTemplate.rows.length);
        expect(
          double.parse(currencyValues[eurIndex].text),
          closeTo(2.0, 1e-9),
        );

        final massTemplate = predefinedWorksheets.firstWhere(
          (t) => t.id == 'mass',
        );
        final massValues = c
            .read(worksheetProvider)
            .valuesFor('mass', massTemplate.rows.length);
        expect(massValues.every((v) => v.text == ''), isTrue);
      },
    );
  });
}
