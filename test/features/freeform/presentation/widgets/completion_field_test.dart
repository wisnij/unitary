import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/freeform/presentation/widgets/completion_field.dart';

/// Wraps [child] in a minimal app with Riverpod and Overlay support.
Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

/// Builds a [CompletionField] bound to [controller] and [focusNode].
Widget _buildField({
  required TextEditingController controller,
  required FocusNode focusNode,
  ValueChanged<String>? onChanged,
}) {
  return CompletionField(
    controller: controller,
    focusNode: focusNode,
    decoration: const InputDecoration(labelText: 'Test'),
    onChanged: onChanged,
  );
}

void main() {
  group('CompletionField', () {
    late TextEditingController controller;
    late FocusNode focusNode;

    setUp(() {
      controller = TextEditingController();
      focusNode = FocusNode();
    });

    tearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('renders a TextField', (tester) async {
      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('overlay not shown initially (no text)', (tester) async {
      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );
      await tester.pump();
      // No suggestion text visible when field is empty.
      expect(find.text('kg'), findsNothing);
    });

    testWidgets('overlay appears when focused field has matching token', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Set text with cursor at end of a known registered ID prefix.
      controller.value = const TextEditingValue(
        text: 'kg',
        selection: TextSelection.collapsed(offset: 2),
      );
      await tester.pump(); // controller listener fires
      await tester.pump(); // post-frame callback fires
      await tester.pump(); // overlay renders

      // "kg" is a unit primary ID — it should appear in the suggestion list.
      expect(find.text('kg'), findsWidgets);
    });

    testWidgets('overlay not shown when no matches', (tester) async {
      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      controller.value = const TextEditingValue(
        text: 'zzz',
        selection: TextSelection.collapsed(offset: 3),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // No suggestion items expected.
      expect(find.text('zzz'), findsOneWidget); // only in the TextField itself
    });

    testWidgets('overlay hidden when field loses focus', (tester) async {
      final otherFocus = FocusNode();
      addTearDown(otherFocus.dispose);

      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              _buildField(controller: controller, focusNode: focusNode),
              Focus(focusNode: otherFocus, child: const SizedBox()),
            ],
          ),
        ),
      );

      // Focus the completion field and set a matching token.
      await tester.tap(find.byType(TextField));
      await tester.pump();
      controller.value = const TextEditingValue(
        text: 'kg',
        selection: TextSelection.collapsed(offset: 2),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // Overlay visible.
      expect(find.text('kg'), findsWidgets);

      // Move focus away.
      otherFocus.requestFocus();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Overlay should be gone: "kg" text only in the TextField.
      expect(find.text('kg'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Display labels
    // -------------------------------------------------------------------------
    //
    // Note: the "overlay appears above the field when near the bottom of the
    // viewport" behaviour (_showAbove) reads RenderBox.localToGlobal at
    // post-frame time and compares it against MediaQuery screen height.
    // Standard widget tests run in a fixed 800×600 viewport where the field
    // is always in the upper half, so this code path is exercised only by
    // manual device testing or a golden/integration test with a constrained
    // viewport.  The positioning logic lives in _CompletionFieldState._updateAbove.

    testWidgets('unit suggestions are displayed without a suffix', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      // 'kg' is a unit primary ID.
      controller.value = const TextEditingValue(
        text: 'kg',
        selection: TextSelection.collapsed(offset: 2),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Overlay row shows the plain name — no trailing character.
      expect(find.text('kg'), findsWidgets);
      expect(find.text('kg '), findsNothing);
    });

    testWidgets('prefix suggestions are displayed with a trailing dash', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      // 'kilo' is a registered SI prefix primary ID.
      controller.value = const TextEditingValue(
        text: 'kilo',
        selection: TextSelection.collapsed(offset: 4),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // The overlay row shows 'kilo-', not bare 'kilo'.
      expect(find.text('kilo-'), findsOneWidget);
    });

    testWidgets(
      'function suggestions are displayed with a trailing parenthesis',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(_buildField(controller: controller, focusNode: focusNode)),
        );

        await tester.tap(find.byType(TextField));
        await tester.pump();

        // 'tempC' is a registered function — 'temp' should surface it.
        controller.value = const TextEditingValue(
          text: 'temp',
          selection: TextSelection.collapsed(offset: 4),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump();

        // The overlay row should show the name followed by '('.
        expect(find.text('tempC('), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // Insertion behaviour
    // -------------------------------------------------------------------------

    testWidgets('tapping a unit suggestion inserts name with trailing space', (
      tester,
    ) async {
      String? changedText;
      await tester.pumpWidget(
        _wrap(
          _buildField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (v) => changedText = v,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      // 'kg' is a unit primary ID.
      controller.value = const TextEditingValue(
        text: 'kg',
        selection: TextSelection.collapsed(offset: 2),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Tap the 'kg' unit suggestion row.
      await tester.tap(find.text('kg').last);
      await tester.pump();

      // A trailing space is appended so the user can continue typing.
      expect(controller.text, equals('kg '));
      expect(changedText, equals('kg '));
    });

    testWidgets('tapping a prefix suggestion inserts name without dash', (
      tester,
    ) async {
      String? changedText;
      await tester.pumpWidget(
        _wrap(
          _buildField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (v) => changedText = v,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      // 'kilo' is a SI prefix — its overlay entry is labelled 'kilo-'.
      controller.value = const TextEditingValue(
        text: 'kilo',
        selection: TextSelection.collapsed(offset: 4),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Tap the 'kilo-' overlay row.
      await tester.tap(find.text('kilo-'));
      await tester.pump();

      // Prefix: dash is not inserted into the field.
      expect(controller.text, equals('kilo'));
      expect(changedText, equals('kilo'));
    });

    testWidgets('tapping a function suggestion inserts name with parenthesis', (
      tester,
    ) async {
      String? changedText;
      await tester.pumpWidget(
        _wrap(
          _buildField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (v) => changedText = v,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      controller.value = const TextEditingValue(
        text: 'tempC',
        selection: TextSelection.collapsed(offset: 5),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Tap the 'tempC(' suggestion row.
      await tester.tap(find.text('tempC(').first);
      await tester.pump();

      // The inserted text includes the open parenthesis.
      expect(controller.text, equals('tempC('));
      expect(changedText, equals('tempC('));
    });

    testWidgets('overlay dismissed when token is deleted', (tester) async {
      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Set a matching token so the overlay appears.
      controller.value = const TextEditingValue(
        text: 'kg',
        selection: TextSelection.collapsed(offset: 2),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // Overlay visible — 'kg' appears at least twice (field + suggestion row).
      expect(find.text('kg'), findsWidgets);

      // Clear the field (delete all characters).
      controller.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // Overlay dismissed — no suggestion text visible.
      expect(find.text('kg'), findsNothing);
    });

    testWidgets('at most 8 suggestion rows are visible without scrolling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      // 'me' matches a large number of entries (meter, mega, mebibyte, …).
      controller.value = const TextEditingValue(
        text: 'me',
        selection: TextSelection.collapsed(offset: 2),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // The overlay must be scrollable (more than 8 matches exist).
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // The visible height must be exactly 8 rows tall.
      final scrollBox = tester.renderObject<RenderBox>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollBox.size.height, equals(8 * 48.0)); // 8 × _kRowHeight
    });

    testWidgets('overlay dismissed after suggestion tap', (tester) async {
      // Use a function token: 'tempC(' inserts to 'tempC(', leaving the cursor
      // after the '(' which is not an identifier character, so no suggestions
      // are produced after insertion and the overlay stays closed.
      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      controller.value = const TextEditingValue(
        text: 'tempC',
        selection: TextSelection.collapsed(offset: 5),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Overlay visible with 'tempC(' entry.
      expect(find.text('tempC('), findsWidgets);

      // Tap the 'tempC(' suggestion.
      await tester.tap(find.text('tempC(').first);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // After tap the overlay is gone; 'tempC(' appears exactly once (text field).
      expect(find.text('tempC('), findsOneWidget);
    });
  });
}
