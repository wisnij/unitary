import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/features/freeform/presentation/widgets/result_display.dart';
import 'package:unitary/features/freeform/state/freeform_state.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ResultDisplay', () {
    testWidgets('renders idle placeholder text', (tester) async {
      await tester.pumpWidget(
        wrap(const ResultDisplay(result: EvaluationIdle())),
      );
      expect(find.text('Enter an expression'), findsOneWidget);
    });

    testWidgets('renders success result text', (tester) async {
      final state = EvaluationSuccess(
        result: Quantity(1609.344, Dimension({'m': 1})),
        formattedResult: '1609.344 m',
      );
      await tester.pumpWidget(wrap(ResultDisplay(result: state)));
      expect(find.text('1609.344 m'), findsOneWidget);
    });

    testWidgets('renders conversion result text', (tester) async {
      const state = ConversionSuccess(
        convertedValue: 8.04672,
        formattedResult: '8.04672 km',
        outputUnit: 'km',
      );
      await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
      expect(find.text('8.04672 km'), findsOneWidget);
    });

    testWidgets('renders error with icon', (tester) async {
      const state = EvaluationError(message: 'Cannot add m and kg');
      await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
      expect(find.text('Cannot add m and kg'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('idle state uses muted text color', (tester) async {
      await tester.pumpWidget(
        wrap(const ResultDisplay(result: EvaluationIdle())),
      );
      final text = tester.widget<Text>(find.text('Enter an expression'));
      expect(text.style?.color, isNotNull);
    });

    testWidgets('success state uses primary color', (tester) async {
      final state = EvaluationSuccess(
        result: Quantity.dimensionless(42),
        formattedResult: '42',
      );
      await tester.pumpWidget(wrap(ResultDisplay(result: state)));
      final text = tester.widget<Text>(find.text('42'));
      final context = tester.element(find.byType(ResultDisplay));
      final primaryColor = Theme.of(context).colorScheme.primary;
      expect(text.style?.color, primaryColor);
    });

    testWidgets('error state uses error color', (tester) async {
      const state = EvaluationError(message: 'bad');
      await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
      final text = tester.widget<Text>(find.text('bad'));
      final context = tester.element(find.byType(ResultDisplay));
      final errorColor = Theme.of(context).colorScheme.error;
      expect(text.style?.color, errorColor);
    });
  });
}
