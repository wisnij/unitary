import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/models/unit_repository.dart';
import '../../../core/domain/parser/expression_parser.dart';
import '../../settings/state/settings_provider.dart';
import '../data/predefined_worksheets.dart';
import '../data/worksheet_repository.dart';
import '../models/worksheet.dart';
import '../services/worksheet_engine.dart';
import 'worksheet_state.dart';

/// Provides the [WorksheetRepository] instance.
///
/// Must be overridden in [ProviderScope] with an initialized repository.
final worksheetRepositoryProvider = Provider<WorksheetRepository>(
  (ref) => throw UnimplementedError(
    'worksheetRepositoryProvider must be overridden',
  ),
);

/// Singleton parser shared by the worksheet feature.
final _worksheetParserProvider = Provider<ExpressionParser>((ref) {
  return ExpressionParser(repo: UnitRepository.withPredefinedUnits());
});

/// Non-autoDispose provider: worksheet values persist across navigation.
final worksheetProvider = NotifierProvider<WorksheetNotifier, WorksheetState>(
  WorksheetNotifier.new,
);

/// Manages worksheet evaluation state.
class WorksheetNotifier extends Notifier<WorksheetState> {
  @override
  WorksheetState build() {
    final persist = ref.watch(worksheetRepositoryProvider).load();
    final parser = ref.read(_worksheetParserProvider);
    final settings = ref.read(settingsProvider);

    // Seed worksheet values from each persisted source entry.
    final seededValues = <String, List<WorksheetCellResult>>{};
    for (final entry in persist.sources.entries) {
      final templateId = entry.key;
      final source = entry.value;
      final template = predefinedWorksheets
          .where((t) => t.id == templateId)
          .firstOrNull;
      if (template == null) {
        continue;
      }

      try {
        final result = computeWorksheet(
          rows: template.rows,
          sourceIndex: source.rowIndex,
          sourceText: source.text,
          parser: parser,
          settings: settings,
        );

        final cells = List<WorksheetCellResult>.filled(
          template.rows.length,
          const WorksheetCellResult.value(''),
        );
        cells[source.rowIndex] = WorksheetCellResult.value(source.text);
        for (var i = 0; i < result.values.length; i++) {
          if (i == source.rowIndex) {
            continue;
          }
          cells[i] = result.values[i] ?? const WorksheetCellResult.value('');
        }
        seededValues[templateId] = cells;
      } catch (_) {
        // Leave this template blank rather than crashing on restore.
      }
    }

    return WorksheetState(
      worksheetId: persist.activeWorksheetId,
      activeRowIndex: null,
      worksheetValues: seededValues,
    );
  }

  /// Switches to a different worksheet template.
  ///
  /// Preserves display values for all worksheets; each template has its own
  /// independent set of values.  Does not trigger recalculation.
  void selectWorksheet(String id) {
    if (id == state.worksheetId) {
      return;
    }
    state = state.copyWith(worksheetId: id, clearActiveRow: true);
    _persist();
  }

  /// Records that the user focused [rowIndex] in [worksheetId].
  ///
  /// Mere focus does NOT transfer source ownership or trigger recalculation.
  /// Only a keystroke (via [onRowChanged]) does that.
  void onRowFocused(String worksheetId, int rowIndex) {
    // Intentionally a no-op for recalculation purposes.
    // Retained as an explicit hook in case the UI needs focus tracking later.
  }

  /// Called when the user types in [rowIndex] of [worksheetId].
  ///
  /// Immediately updates the active row's raw text, then runs the engine
  /// synchronously to recompute all other rows.
  void onRowChanged(String worksheetId, int rowIndex, String text) {
    final template = predefinedWorksheets.firstWhere(
      (t) => t.id == worksheetId,
    );
    final current = state.valuesFor(worksheetId, template.rows.length);

    // Update source row immediately with raw text; mark it active.
    final updated = List<WorksheetCellResult>.from(current);
    updated[rowIndex] = WorksheetCellResult.value(text);

    state = state.copyWith(
      activeRowIndex: rowIndex,
      worksheetValues: {
        ...state.worksheetValues,
        worksheetId: updated,
      },
    );

    _runEngine(worksheetId, template, rowIndex, text);
    _persist(
      sourceWorksheetId: worksheetId,
      sourceRowIndex: rowIndex,
      sourceText: text,
    );
  }

  void _runEngine(
    String worksheetId,
    WorksheetTemplate template,
    int sourceIndex,
    String sourceText,
  ) {
    final parser = ref.read(_worksheetParserProvider);
    final settings = ref.read(settingsProvider);

    final result = computeWorksheet(
      rows: template.rows,
      sourceIndex: sourceIndex,
      sourceText: sourceText,
      parser: parser,
      settings: settings,
    );

    final current = state.valuesFor(worksheetId, template.rows.length);
    final updated = List<WorksheetCellResult>.from(current);

    for (var i = 0; i < result.values.length; i++) {
      if (i == sourceIndex) {
        continue; // preserve raw text
      }
      updated[i] = result.values[i] ?? const WorksheetCellResult.value('');
    }

    state = state.copyWith(
      worksheetValues: {
        ...state.worksheetValues,
        worksheetId: updated,
      },
    );
  }

  /// Persists the current active worksheet ID and optionally updates the
  /// sources map with a new source entry.
  void _persist({
    String? sourceWorksheetId,
    int? sourceRowIndex,
    String? sourceText,
  }) {
    final repo = ref.read(worksheetRepositoryProvider);
    final current = repo.load();

    final sources = Map<String, WorksheetSourceEntry>.from(current.sources);
    if (sourceWorksheetId != null &&
        sourceRowIndex != null &&
        sourceText != null) {
      sources[sourceWorksheetId] = WorksheetSourceEntry(
        rowIndex: sourceRowIndex,
        text: sourceText,
      );
    }

    repo.save(
      WorksheetPersistState(
        activeWorksheetId: state.worksheetId,
        sources: sources,
      ),
    );
  }
}
