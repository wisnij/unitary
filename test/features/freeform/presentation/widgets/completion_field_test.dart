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

    testWidgets('tapping suggestion updates controller text', (tester) async {
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

      // Type a prefix for 'kilogram' (registered alias).
      controller.value = const TextEditingValue(
        text: 'kilo',
        selection: TextSelection.collapsed(offset: 4),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Find and tap the "kilo" suggestion (the prefix entry).
      final kiloFinder = find.text('kilo').last;
      expect(kiloFinder, findsOneWidget);
      await tester.tap(kiloFinder);
      await tester.pump();

      // Controller text updated to the selected entry.
      expect(controller.text, equals('kilo'));
      expect(changedText, equals('kilo'));
    });

    testWidgets('overlay dismissed after suggestion tap', (tester) async {
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

      // Tap the "kilo" suggestion.
      await tester.tap(find.text('kilo').last);
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // After tap the overlay should be hidden; "kilo" appears only once
      // (in the text field itself).
      expect(find.text('kilo'), findsOneWidget);
    });
  });
}
