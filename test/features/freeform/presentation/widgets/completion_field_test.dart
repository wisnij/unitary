import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/freeform/presentation/widgets/completion_field.dart';

/// Wraps [child] in a minimal app.
Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
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
  });
}
