import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/models/unit_repository.dart';
import '../../../core/domain/parser/expression_parser.dart';
import '../../settings/state/settings_provider.dart';
import '../data/predefined_worksheets.dart';
import '../models/worksheet.dart';
import '../services/worksheet_engine.dart';
import 'worksheet_state.dart';

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
    return WorksheetState(
      worksheetId: predefinedWorksheets.first.id,
      activeRowIndex: null,
      worksheetValues: {},
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
    final updated = List<String>.from(current);
    updated[rowIndex] = text;

    state = state.copyWith(
      activeRowIndex: rowIndex,
      worksheetValues: {
        ...state.worksheetValues,
        worksheetId: updated,
      },
    );

    _runEngine(worksheetId, template, rowIndex, text);
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
    final updated = List<String>.from(current);

    for (var i = 0; i < result.values.length; i++) {
      if (i == sourceIndex) {
        continue; // preserve raw text
      }
      updated[i] = result.values[i] ?? '';
    }

    state = state.copyWith(
      worksheetValues: {
        ...state.worksheetValues,
        worksheetId: updated,
      },
    );
  }
}
