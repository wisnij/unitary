import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';

import '../../../helpers/pump_app.dart';
import '../../../shared/rebuild_counter.dart';

// Pins the worksheet rebuild bound observed in the July 13, 2026 DevTools
// rebuild-tracking pass (see openspec/changes/performance-measurement/
// measurements.md): a single cell edit triggers at most one rebuild of the
// WorksheetScreen subtree, in which the other rows show recomputed values.
// The recompute path is synchronous — onRowChanged runs the engine in the
// same turn; there is no worksheet-side debounce (the ~150 µs engine pass
// makes that sound).

void main() {
  void selectTemplate(WidgetTester tester, String id) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorksheetScreen)),
    );
    container.read(worksheetProvider.notifier).selectWorksheet(id);
  }

  testWidgets('a cell edit rebuilds the worksheet screen at most once '
      'and recomputes the other rows', (tester) async {
    await pumpApp(tester, WorksheetScreen(onNavigate: (_) {}));
    selectTemplate(tester, 'length');
    await tester.pumpAndSettle();

    // Focus the meter field first so focus changes are not part of the count.
    final meterField = find.byType(TextField).at(6);
    await tester.tap(meterField);
    await tester.pumpAndSettle();

    final counter = RebuildCounter()..install(tester);
    addTearDown(() => counter.uninstall(tester));

    await tester.enterText(meterField, '2');
    await tester.pumpAndSettle();

    expect(
      counter.of('WorksheetScreen'),
      lessThanOrEqualTo(1),
      reason: 'one cell edit produces at most one screen rebuild',
    );

    // 2 meters = 200 centimeters: the recompute reached the other rows.
    final centimeterField = tester.widget<TextField>(
      find.byType(TextField).at(2),
    );
    expect(centimeterField.controller?.text, '200');
  });

  testWidgets('a second edit in the same cell also rebuilds at most once', (
    tester,
  ) async {
    await pumpApp(tester, WorksheetScreen(onNavigate: (_) {}));
    selectTemplate(tester, 'length');
    await tester.pumpAndSettle();

    final meterField = find.byType(TextField).at(6);
    await tester.tap(meterField);
    await tester.pumpAndSettle();
    await tester.enterText(meterField, '2');
    await tester.pumpAndSettle();

    final counter = RebuildCounter()..install(tester);
    addTearDown(() => counter.uninstall(tester));

    // Steady-state keystroke: the source row is already active.
    await tester.enterText(meterField, '25');
    await tester.pumpAndSettle();

    expect(counter.of('WorksheetScreen'), lessThanOrEqualTo(1));

    final centimeterField = tester.widget<TextField>(
      find.byType(TextField).at(2),
    );
    expect(centimeterField.controller?.text, '2500');
  });
}
