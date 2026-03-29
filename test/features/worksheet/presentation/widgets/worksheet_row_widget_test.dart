import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/worksheet/presentation/widgets/worksheet_row_widget.dart';

void main() {
  Widget buildRow({
    required bool isError,
    String label = 'meters',
    String expression = 'm',
  }) {
    final controller = TextEditingController();
    return MaterialApp(
      home: Scaffold(
        body: WorksheetRowWidget(
          label: label,
          expression: expression,
          controller: controller,
          isActive: false,
          isError: isError,
          onChanged: (_) {},
          onFocused: () {},
        ),
      ),
    );
  }

  group('WorksheetRowWidget error styling', () {
    testWidgets('normal row does not apply error color', (tester) async {
      await tester.pumpWidget(buildRow(isError: false));

      final textField = tester.widget<TextField>(find.byType(TextField));
      // style is null when not an error — the TextField inherits theme defaults.
      expect(textField.style, isNull);
    });

    testWidgets('error row applies colorScheme.error to text', (tester) async {
      await tester.pumpWidget(buildRow(isError: true));

      final context = tester.element(find.byType(TextField));
      final errorColor = Theme.of(context).colorScheme.error;

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style, isNotNull);
      expect(textField.style!.color, errorColor);
    });
  });
}
