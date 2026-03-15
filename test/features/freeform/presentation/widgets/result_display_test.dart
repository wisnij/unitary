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

    testWidgets('renders conversion result with forward and reciprocal', (
      tester,
    ) async {
      const state = ConversionSuccess(
        convertedValue: 8.04672,
        formattedResult: '= 8.04672 km',
        formattedReciprocal: '= (1 / 0.12427424) km',
        outputUnit: 'km',
      );
      await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
      expect(find.text('= 8.04672 km'), findsOneWidget);
      expect(find.text('= (1 / 0.12427424) km'), findsOneWidget);
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

    testWidgets(
      'FunctionDefinitionResult with non-null expression shows label and expression',
      (tester) async {
        const state = FunctionDefinitionResult(
          label: 'tempF(x) =',
          expression: 'x * 9|5 + 32',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('tempF(x) ='), findsOneWidget);
        expect(find.text('x * 9|5 + 32'), findsOneWidget);
      },
    );

    testWidgets(
      'FunctionDefinitionResult with null expression shows <not available>',
      (tester) async {
        const state = FunctionDefinitionResult(
          label: 'unknown(x) =',
          expression: null,
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('unknown(x) ='), findsOneWidget);
        expect(find.text('<not available>'), findsOneWidget);
      },
    );

    testWidgets(
      'FunctionDefinitionResult with inverse label shows inverse expression',
      (tester) async {
        const state = FunctionDefinitionResult(
          label: '~tempF =',
          expression: '(x - 32) * 5|9',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('~tempF ='), findsOneWidget);
        expect(find.text('(x - 32) * 5|9'), findsOneWidget);
      },
    );

    testWidgets(
      'FunctionDefinitionResult with inverse label and null expression shows <not available>',
      (tester) async {
        const state = FunctionDefinitionResult(
          label: '~sin =',
          expression: null,
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('~sin ='), findsOneWidget);
        expect(find.text('<not available>'), findsOneWidget);
      },
    );

    testWidgets(
      'FunctionConversionResult renders as functionName(formattedValue)',
      (tester) async {
        const state = FunctionConversionResult(
          functionName: 'tempC',
          formattedValue: '20',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('tempC(20)'), findsOneWidget);
      },
    );

    testWidgets(
      'FunctionConversionResult uses primary color',
      (tester) async {
        const state = FunctionConversionResult(
          functionName: 'tempC',
          formattedValue: '20',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        final text = tester.widget<Text>(find.text('tempC(20)'));
        final context = tester.element(find.byType(ResultDisplay));
        final primaryColor = Theme.of(context).colorScheme.primary;
        expect(text.style?.color, primaryColor);
      },
    );

    testWidgets(
      'FunctionConversionResult with dimensioned value renders full string',
      (tester) async {
        const state = FunctionConversionResult(
          functionName: 'stdatmT',
          formattedValue: '2.0000006 m',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('stdatmT(2.0000006 m)'), findsOneWidget);
      },
    );

    testWidgets(
      'FunctionConversionResult does not show a reciprocal row',
      (tester) async {
        const state = FunctionConversionResult(
          functionName: 'tempC',
          formattedValue: '20',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        // Only one Text widget: the composed function call string.
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        expect(texts.length, 1);
        expect(texts.first.data, 'tempC(20)');
      },
    );
  });
}
