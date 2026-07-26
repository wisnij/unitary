import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/freeform/presentation/freeform_screen.dart';

import '../../../helpers/pump_app.dart';
import '../../../shared/rebuild_counter.dart';

// Pins the scoped freeform rebuild behavior from the freeform-rebuild change:
// a keystroke (plus its debounced evaluation) rebuilds the FreeformScreen
// subtree root zero times — only the widgets that depend on the changed state
// rebuild (controller-listening buttons, scoped result/history consumers).
// Positive-effect assertions (result shown, buttons reacting) guard against
// the zero bound passing vacuously.

void main() {
  testWidgets(
    'a keystroke and its debounced evaluation do not rebuild the screen '
    'subtree, while the result and clear button still update',
    (
      tester,
    ) async {
      await pumpApp(tester, FreeformScreen(onNavigate: (_) {}));
      await tester.pumpAndSettle();

      // Focus the field first so focus changes are not part of the count.
      final inputField = find.widgetWithText(TextField, 'Convert from');
      await tester.tap(inputField);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.clear), findsNothing);

      final counter = RebuildCounter()..install(tester);
      addTearDown(() => counter.uninstall(tester));

      // One text-change event, then let the debounce fire and settle.
      await tester.enterText(inputField, '5 ft');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(
        counter.of('FreeformScreen'),
        0,
        reason:
            'keystroke and evaluation rebuild only scoped dependents, '
            'never the screen subtree root',
      );

      // Positive effects: the scoped rebuilds actually happened.  (The result
      // text can appear both in the result display and as the recorded entry
      // in the history pane.)
      expect(
        find.textContaining('1.524'),
        findsWidgets,
        reason: 'the evaluation result is displayed',
      );
      expect(
        find.byIcon(Icons.clear),
        findsOneWidget,
        reason: 'the clear button appears once the input is non-empty',
      );
    },
  );

  testWidgets('filling both fields enables the swap button without a screen '
      'subtree rebuild', (tester) async {
    await pumpApp(tester, FreeformScreen(onNavigate: (_) {}));
    await tester.pumpAndSettle();

    final inputField = find.widgetWithText(TextField, 'Convert from');
    final outputField = find.widgetWithText(TextField, 'Convert to (optional)');

    IconButton swapButton() => tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.swap_vert),
    );

    await tester.tap(inputField);
    await tester.pumpAndSettle();
    expect(
      swapButton().onPressed,
      isNull,
      reason: 'swap is disabled while a field is empty',
    );

    final counter = RebuildCounter()..install(tester);
    addTearDown(() => counter.uninstall(tester));

    await tester.enterText(inputField, '5 ft');
    await tester.pump();
    await tester.enterText(outputField, 'm');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(
      counter.of('FreeformScreen'),
      0,
      reason: 'button-state updates are scoped to the controller listeners',
    );
    expect(
      swapButton().onPressed,
      isNotNull,
      reason: 'swap enables once both fields are non-empty',
    );
  });
}
