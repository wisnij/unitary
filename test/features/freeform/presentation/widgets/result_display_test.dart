import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/features/freeform/data/idle_examples.dart';
import 'package:unitary/features/freeform/presentation/widgets/result_display.dart';
import 'package:unitary/features/freeform/state/freeform_state.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ResultDisplay', () {
    testWidgets('renders idle instruction text without example', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const ResultDisplay(result: EvaluationIdle())),
      );
      expect(find.text('Enter an expression above.'), findsOneWidget);
      expect(find.textContaining('Try:'), findsNothing);
    });

    testWidgets('renders idle instruction and Try line when example given', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ResultDisplay(
            result: EvaluationIdle(
              example: FreeformExample(inputExpression: '60 mph'),
            ),
          ),
        ),
      );
      expect(find.text('Enter an expression above.'), findsOneWidget);
      expect(find.text('Try: 60 mph'), findsOneWidget);
    });

    testWidgets(
      'renders Try line with arrow when example has output expression',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const ResultDisplay(
              result: EvaluationIdle(
                example: FreeformExample(
                  inputExpression: '1|2 gallon',
                  outputExpression: 'ml',
                ),
              ),
            ),
          ),
        );
        expect(find.text('Enter an expression above.'), findsOneWidget);
        expect(find.text('Try: 1|2 gallon → ml'), findsOneWidget);
      },
    );

    testWidgets(
      'renders Try line without arrow when example has no output expression',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const ResultDisplay(
              result: EvaluationIdle(
                example: FreeformExample(inputExpression: '5 km'),
              ),
            ),
          ),
        );
        expect(find.text('Try: 5 km'), findsOneWidget);
        expect(find.textContaining('→'), findsNothing);
      },
    );

    testWidgets('invokes onTap when idle display is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          ResultDisplay(
            result: const EvaluationIdle(
              example: FreeformExample(inputExpression: '60 mph'),
            ),
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(ResultDisplay));
      expect(tapped, isTrue);
    });

    testWidgets('does not invoke onTap when null', (tester) async {
      // Should not throw when onTap is null.
      await tester.pumpWidget(
        wrap(
          const ResultDisplay(
            result: EvaluationIdle(
              example: FreeformExample(inputExpression: '60 mph'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ResultDisplay), warnIfMissed: false);
      // No assertion needed — the test passes if no exception is thrown.
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
      final text = tester.widget<Text>(find.text('Enter an expression above.'));
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

    testWidgets(
      'UnitDefinitionResult renders all three lines',
      (tester) async {
        const state = UnitDefinitionResult(
          aliasLine: '= calorie_th',
          definitionLine: '= 4.184 J',
          formattedResult: '= 4.184 kg m^2 / s^2',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('= calorie_th'), findsOneWidget);
        expect(find.text('= 4.184 J'), findsOneWidget);
        expect(find.text('= 4.184 kg m^2 / s^2'), findsOneWidget);
      },
    );

    testWidgets(
      'UnitDefinitionResult renders definition line and result when aliasLine is null',
      (tester) async {
        const state = UnitDefinitionResult(
          aliasLine: null,
          definitionLine: '= 4.184 J',
          formattedResult: '= 4.184 kg m^2 / s^2',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('= 4.184 J'), findsOneWidget);
        expect(find.text('= 4.184 kg m^2 / s^2'), findsOneWidget);
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        expect(texts.length, 2);
      },
    );

    testWidgets(
      'UnitDefinitionResult renders alias line and result when definitionLine is null',
      (tester) async {
        const state = UnitDefinitionResult(
          aliasLine: '= k m',
          definitionLine: null,
          formattedResult: '= 1000 m',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('= k m'), findsOneWidget);
        expect(find.text('= 1000 m'), findsOneWidget);
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        expect(texts.length, 2);
      },
    );

    testWidgets(
      'UnitDefinitionResult renders result only when both header lines are null',
      (tester) async {
        const state = UnitDefinitionResult(
          aliasLine: null,
          definitionLine: null,
          formattedResult: '= 1 m',
        );
        await tester.pumpWidget(wrap(const ResultDisplay(result: state)));
        expect(find.text('= 1 m'), findsOneWidget);
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        expect(texts.length, 1);
      },
    );
  });

  group('ResultDisplay live region semantics', () {
    // ResultDisplay carries no evaluation-mode dependency, so asserting the
    // live region per state covers both real-time and on-submit modes: the
    // screen renders the same widget unconditionally in either mode.

    testWidgets('success state is a live region with the spoken label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final state = EvaluationSuccess(
        result: Quantity(8, Dimension({'kg': 1, 'm': 1, 's': -2})),
        formattedResult: '8 kg m / s^2',
      );
      await tester.pumpWidget(wrap(ResultDisplay(result: state)));

      final expected = resultSpeechLabel(state);
      final node = tester.getSemantics(find.bySemanticsLabel(expected));
      expect(node.flagsCollection.isLiveRegion, isTrue);

      handle.dispose();
    });

    testWidgets('error state announces with Error prefix', (tester) async {
      final handle = tester.ensureSemantics();
      const state = EvaluationError(message: 'Cannot add m and kg');
      await tester.pumpWidget(wrap(const ResultDisplay(result: state)));

      final node = tester.getSemantics(
        find.bySemanticsLabel('Error: Cannot add m and kg'),
      );
      expect(node.flagsCollection.isLiveRegion, isTrue);

      handle.dispose();
    });

    testWidgets('idle state is a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(const ResultDisplay(result: EvaluationIdle())),
      );

      final node = tester.getSemantics(
        find.bySemanticsLabel('Enter an expression above.'),
      );
      expect(node.flagsCollection.isLiveRegion, isTrue);

      handle.dispose();
    });

    testWidgets('tappable idle example exposes button semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      const state = EvaluationIdle(
        example: FreeformExample(inputExpression: '60 mph'),
      );
      await tester.pumpWidget(
        wrap(ResultDisplay(result: state, onTap: () {})),
      );

      final node = tester.getSemantics(
        find.bySemanticsLabel(resultSpeechLabel(state)),
      );
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

      handle.dispose();
    });

    testWidgets('idle display without onTap is not a button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(const ResultDisplay(result: EvaluationIdle())),
      );

      final node = tester.getSemantics(
        find.bySemanticsLabel('Enter an expression above.'),
      );
      expect(node.flagsCollection.isButton, isFalse);

      handle.dispose();
    });

    testWidgets('non-idle result is not a button', (tester) async {
      final handle = tester.ensureSemantics();
      final state = EvaluationSuccess(
        result: Quantity.dimensionless(42),
        formattedResult: '42',
      );
      await tester.pumpWidget(wrap(ResultDisplay(result: state)));

      final node = tester.getSemantics(find.bySemanticsLabel('Result: 42'));
      expect(node.flagsCollection.isButton, isFalse);

      handle.dispose();
    });

    testWidgets('raw result text is excluded from semantics', (tester) async {
      final handle = tester.ensureSemantics();
      const state = ConversionSuccess(
        convertedValue: 8.04672,
        formattedResult: '= 8.04672 km',
        formattedReciprocal: '= (1 / 0.12427424) km',
        outputUnit: 'km',
      );
      await tester.pumpWidget(wrap(const ResultDisplay(result: state)));

      // The visible text widgets are still rendered...
      expect(find.text('= 8.04672 km'), findsOneWidget);
      expect(find.text('= (1 / 0.12427424) km'), findsOneWidget);
      // ...but contribute no semantics nodes of their own; only the composed
      // spoken label is exposed.
      expect(find.bySemanticsLabel('= 8.04672 km'), findsNothing);
      expect(find.bySemanticsLabel('= (1 / 0.12427424) km'), findsNothing);
      expect(
        find.bySemanticsLabel(resultSpeechLabel(state)),
        findsOneWidget,
      );

      handle.dispose();
    });
  });
}
