import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/completion_entry.dart';
import 'package:unitary/features/freeform/presentation/widgets/completion_field.dart';

/// Wraps [child] in a minimal app with Riverpod and Overlay support.
Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

/// Like [_wrap], but constrains the field to a narrow width so that long
/// expressions wrap onto multiple lines.
Widget _wrapNarrow(Widget child, {double width = 280}) {
  return _wrap(
    Align(
      alignment: Alignment.topCenter,
      child: SizedBox(width: width, child: child),
    ),
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

    testWidgets(
      'inner TextField uses a plain-text keyboard with no autocorrect or '
      'IME suggestions',
      (tester) async {
        await tester.pumpWidget(
          _wrap(_buildField(controller: controller, focusNode: focusNode)),
        );

        final field = tester.widget<TextField>(find.byType(TextField));
        // The explicit text keyboard type is load-bearing: with maxLines: null
        // and no explicit type, Flutter infers TextInputType.multiline, which
        // Android IMEs treat as prose input and auto-capitalize.
        expect(field.keyboardType, TextInputType.text);
        expect(field.autocorrect, isFalse);
        expect(field.enableSuggestions, isFalse);
        // Soft-wrap must survive the explicit keyboard type.
        expect(field.maxLines, isNull);
      },
    );

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
    // Semantic labels
    // -------------------------------------------------------------------------

    test('every completion kind yields a name+kind label (coverage)', () {
      // Coverage guard: iterate the whole enum so a new CompletionEntryKind
      // added without a label word fails here (in addition to the compile-time
      // guard from the exhaustive switch in completionSemanticLabel).
      for (final kind in CompletionEntryKind.values) {
        final label = completionSemanticLabel(
          CompletionEntry(name: 'foo', isPrimaryId: true, entryKind: kind),
        );
        expect(label, contains('foo'), reason: 'label "$label" missing name');
        expect(
          label,
          contains(kind.name),
          reason: 'label "$label" missing kind word "${kind.name}"',
        );
      }
    });

    test('completion labels use the "<name>, <kind>" form', () {
      expect(
        completionSemanticLabel(
          const CompletionEntry(
            name: 'meter',
            isPrimaryId: true,
            entryKind: CompletionEntryKind.unit,
          ),
        ),
        'meter, unit',
      );
      expect(
        completionSemanticLabel(
          const CompletionEntry(
            name: 'kilo',
            isPrimaryId: true,
            entryKind: CompletionEntryKind.prefix,
          ),
        ),
        'kilo, prefix',
      );
      expect(
        completionSemanticLabel(
          const CompletionEntry(
            name: 'tempC',
            isPrimaryId: true,
            entryKind: CompletionEntryKind.function,
          ),
        ),
        'tempC, function',
      );
    });

    testWidgets('prefix row exposes its label while keeping the visual dash', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrap(_buildField(controller: controller, focusNode: focusNode)),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      controller.value = const TextEditingValue(
        text: 'kilo',
        selection: TextSelection.collapsed(offset: 4),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Screen reader hears "kilo, prefix"...
      expect(find.bySemanticsLabel('kilo, prefix'), findsOneWidget);
      // ...while the visible display text still shows the trailing dash.
      expect(find.text('kilo-'), findsOneWidget);

      handle.dispose();
    });

    testWidgets(
      'every rendered suggestion row carries one name+kind label (coverage)',
      (tester) async {
        // Render-level count guard: a row that bypasses the Semantics wrapper
        // would make the label count differ from the row count.
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          _wrap(_buildField(controller: controller, focusNode: focusNode)),
        );
        await tester.tap(find.byType(TextField));
        await tester.pump();
        // 'me' matches many entries across kinds (meter, mega, mebibyte, …).
        controller.value = const TextEditingValue(
          text: 'me',
          selection: TextSelection.collapsed(offset: 2),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump();

        final rowCount = find.byType(InkWell).evaluate().length;
        expect(rowCount, greaterThan(0));
        expect(
          find.bySemanticsLabel(RegExp(r', (unit|prefix|function)$')),
          findsNWidgets(rowCount),
        );

        handle.dispose();
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

    // -------------------------------------------------------------------------
    // Wrapping (long expressions)
    // -------------------------------------------------------------------------

    testWidgets('long expression wraps and grows the field height', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapNarrow(_buildField(controller: controller, focusNode: focusNode)),
      );

      final singleLineHeight = tester.getSize(find.byType(TextField)).height;

      // Long enough to require multiple lines at 280 px width.
      final longText = '${'1 + ' * 10}2';
      controller.value = TextEditingValue(
        text: longText,
        selection: TextSelection.collapsed(offset: longText.length),
      );
      await tester.pump();

      final wrappedHeight = tester.getSize(find.byType(TextField)).height;
      expect(wrappedHeight, greaterThan(singleLineHeight));

      // Wrapping is purely visual: no newline characters in the text value.
      expect(controller.text, isNot(contains('\n')));

      // Shortening the text shrinks the field back to a single line.
      controller.value = const TextEditingValue(
        text: '1 + 2',
        selection: TextSelection.collapsed(offset: 5),
      );
      await tester.pump();
      expect(
        tester.getSize(find.byType(TextField)).height,
        equals(singleLineHeight),
      );
    });

    testWidgets('overlay appears below the bottom edge of a wrapped field', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapNarrow(_buildField(controller: controller, focusNode: focusNode)),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      final singleLineHeight = tester.getSize(find.byType(TextField)).height;

      // Wraps to multiple lines and ends in a completable identifier.
      final longText = '${'1 + ' * 10}kg';
      controller.value = TextEditingValue(
        text: longText,
        selection: TextSelection.collapsed(offset: longText.length),
      );
      await tester.pump(); // controller listener fires
      await tester.pump(); // post-frame callback fires
      await tester.pump(); // overlay renders

      final fieldRect = tester.getRect(find.byType(TextField));
      expect(fieldRect.height, greaterThan(singleLineHeight));

      // The first suggestion row starts at (or just below, allowing for the
      // overlay border) the field's current, taller bottom edge.
      final rowRect = tester.getRect(find.byType(InkWell).first);
      expect(rowRect.top, greaterThanOrEqualTo(fieldRect.bottom - 2));
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
