import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/features/freeform/data/idle_examples.dart';
import 'package:unitary/features/freeform/presentation/widgets/result_display.dart';
import 'package:unitary/features/freeform/state/freeform_state.dart';

void main() {
  group('resultSpeechLabel', () {
    test('every EvaluationResult variant produces a non-empty label', () {
      final variants = <EvaluationResult>[
        const EvaluationIdle(),
        EvaluationSuccess(
          result: Quantity(1609.344, Dimension({'m': 1})),
          formattedResult: '1609.344 m',
        ),
        const ConversionSuccess(
          convertedValue: 8.04672,
          formattedResult: '= 8.04672 km',
          formattedReciprocal: '= (1 / 0.12427424) km',
          outputUnit: 'km',
        ),
        const UnitDefinitionResult(
          aliasLine: '= calorie_th',
          definitionLine: '= 4.184 J',
          formattedResult: '= 4.184 kg m^2 / s^2',
        ),
        const FunctionDefinitionResult(
          label: 'tempF(x) =',
          expression: 'x * 9|5 + 32',
        ),
        const FunctionConversionResult(
          functionName: 'tempC',
          formattedValue: '20',
        ),
        const ReciprocalConversionSuccess(
          reciprocalInputLabel: '1 / mph',
          formattedResult: '= 2.2369363 s/m',
          formattedReciprocal: '= (1 / 0.44704) s/m',
          outputUnit: 's/m',
        ),
        const EvaluationError(message: 'bad'),
      ];
      for (final variant in variants) {
        expect(
          resultSpeechLabel(variant),
          isNotEmpty,
          reason: '${variant.runtimeType} must have a spoken form',
        );
      }
    });

    test('idle without example speaks the instruction', () {
      expect(
        resultSpeechLabel(const EvaluationIdle()),
        'Enter an expression above.',
      );
    });

    test('idle with example speaks instruction and example', () {
      const state = EvaluationIdle(
        example: FreeformExample(inputExpression: '60 mph'),
      );
      expect(
        resultSpeechLabel(state),
        'Enter an expression above. Try: 60 mph',
      );
    });

    test('idle example with output expression speaks the arrow as "to"', () {
      const state = EvaluationIdle(
        example: FreeformExample(
          inputExpression: '1|2 gallon',
          outputExpression: 'ml',
        ),
      );
      expect(
        resultSpeechLabel(state),
        'Enter an expression above. Try: 1 over 2 gallon to ml',
      );
    });

    test('success speaks the formatted result with symbols worded', () {
      final state = EvaluationSuccess(
        result: Quantity(8, Dimension({'kg': 1, 'm': 1, 's': -2})),
        formattedResult: '8 kg m / s^2',
      );
      expect(resultSpeechLabel(state), '8 kg m per s to the power 2');
    });

    test('conversion speaks result then reciprocal line', () {
      const state = ConversionSuccess(
        convertedValue: 8.04672,
        formattedResult: '= 8.04672 km',
        formattedReciprocal: '= (1 / 0.12427424) km',
        outputUnit: 'km',
      );
      expect(
        resultSpeechLabel(state),
        'equals 8.04672 km. equals (1 per 0.12427424) km',
      );
    });

    test('unit definition speaks all present lines in order', () {
      const state = UnitDefinitionResult(
        aliasLine: '= calorie_th',
        definitionLine: '= 4.184 J',
        formattedResult: '= 4.184 kg m^2 / s^2',
      );
      expect(
        resultSpeechLabel(state),
        'equals calorie_th. equals 4.184 J. '
        'equals 4.184 kg m to the power 2 per s to the power 2',
      );
    });

    test('unit definition skips null lines', () {
      const state = UnitDefinitionResult(
        aliasLine: null,
        definitionLine: null,
        formattedResult: '= 1 m',
      );
      expect(resultSpeechLabel(state), 'equals 1 m');
    });

    test('function definition speaks label and expression', () {
      const state = FunctionDefinitionResult(
        label: 'tempF(x) =',
        expression: 'x * 9|5 + 32',
      );
      expect(
        resultSpeechLabel(state),
        'tempF(x) equals x times 9 over 5 + 32',
      );
    });

    test('function definition with null expression speaks not available', () {
      const state = FunctionDefinitionResult(
        label: 'unknown(x) =',
        expression: null,
      );
      expect(resultSpeechLabel(state), 'unknown(x) equals not available');
    });

    test('function conversion speaks the composed call', () {
      const state = FunctionConversionResult(
        functionName: 'tempC',
        formattedValue: '20',
      );
      expect(resultSpeechLabel(state), 'tempC(20)');
    });

    test('reciprocal conversion speaks notice, label, result, reciprocal', () {
      const state = ReciprocalConversionSuccess(
        reciprocalInputLabel: '1 / mph',
        formattedResult: '= 2.2369363 s/m',
        formattedReciprocal: '= (1 / 0.44704) s/m',
        outputUnit: 's/m',
      );
      expect(
        resultSpeechLabel(state),
        'Reciprocal conversion. 1 per mph. '
        'equals 2.2369363 s per m. equals (1 per 0.44704) s per m',
      );
    });

    test('error is prefixed with Error: and message is spoken verbatim', () {
      const state = EvaluationError(message: 'Unknown unit: "xyzzy"');
      expect(resultSpeechLabel(state), 'Error: Unknown unit: "xyzzy"');
    });
  });
}
