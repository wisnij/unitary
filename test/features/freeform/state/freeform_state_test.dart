import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/features/freeform/state/freeform_state.dart';

void main() {
  group('EvaluationResult', () {
    test('EvaluationIdle is a valid state', () {
      const state = EvaluationIdle();
      expect(state, isA<EvaluationResult>());
    });

    test('EvaluationSuccess holds result and formatted string', () {
      final result = Quantity(1.524, Dimension({'m': 1}));
      final state = EvaluationSuccess(
        result: result,
        formattedResult: '1.524 m',
      );
      expect(state.result, same(result));
      expect(state.formattedResult, '1.524 m');
    });

    test('ConversionSuccess holds converted value and output unit', () {
      const state = ConversionSuccess(
        convertedValue: 8.04672,
        formattedResult: '= 8.04672 km',
        formattedReciprocal: '= (1 / 0.12427424) km',
        outputUnit: 'km',
      );
      expect(state.convertedValue, 8.04672);
      expect(state.formattedResult, '= 8.04672 km');
      expect(state.formattedReciprocal, '= (1 / 0.12427424) km');
      expect(state.outputUnit, 'km');
    });

    test('UnitDefinitionResult holds all three fields', () {
      const state = UnitDefinitionResult(
        aliasLine: '= calorie_th',
        definitionLine: '= 4.184 J',
        formattedResult: '= 4.184 kg m^2 / s^2',
      );
      expect(state.aliasLine, '= calorie_th');
      expect(state.definitionLine, '= 4.184 J');
      expect(state.formattedResult, '= 4.184 kg m^2 / s^2');
    });

    test('UnitDefinitionResult accepts null header fields', () {
      const state = UnitDefinitionResult(
        aliasLine: null,
        definitionLine: null,
        formattedResult: '= 1 m',
      );
      expect(state.aliasLine, isNull);
      expect(state.definitionLine, isNull);
      expect(state.formattedResult, '= 1 m');
    });

    test('FunctionDefinitionResult holds label and expression', () {
      const state = FunctionDefinitionResult(
        label: 'tempF(x) =',
        expression: 'x * 9|5 + 32',
      );
      expect(state.label, 'tempF(x) =');
      expect(state.expression, 'x * 9|5 + 32');
    });

    test('FunctionDefinitionResult accepts null expression', () {
      const state = FunctionDefinitionResult(
        label: '~sin =',
        expression: null,
      );
      expect(state.label, '~sin =');
      expect(state.expression, isNull);
    });

    test('FunctionConversionResult holds functionName and formattedValue', () {
      const state = FunctionConversionResult(
        functionName: 'tempC',
        formattedValue: '20',
      );
      expect(state, isA<EvaluationResult>());
      expect(state.functionName, 'tempC');
      expect(state.formattedValue, '20');
    });

    test('ReciprocalConversionSuccess holds all fields', () {
      const state = ReciprocalConversionSuccess(
        reciprocalInputLabel: '1 / mph',
        formattedResult: '= 2.2369363 s/m',
        formattedReciprocal: '= (1 / 0.44704) s/m',
        outputUnit: 's/m',
      );
      expect(state, isA<EvaluationResult>());
      expect(state.reciprocalInputLabel, '1 / mph');
      expect(state.formattedResult, '= 2.2369363 s/m');
      expect(state.formattedReciprocal, '= (1 / 0.44704) s/m');
      expect(state.outputUnit, 's/m');
    });

    test('EvaluationError holds error message', () {
      const state = EvaluationError(message: 'Parse error at 1:5');
      expect(state.message, 'Parse error at 1:5');
    });

    test('sealed class covers all variants in switch', () {
      final states = <EvaluationResult>[
        const EvaluationIdle(),
        EvaluationSuccess(
          result: Quantity.dimensionless(1),
          formattedResult: '1',
        ),
        const ConversionSuccess(
          convertedValue: 1,
          formattedResult: '= 1 m',
          formattedReciprocal: '= (1 / 1) m',
          outputUnit: 'm',
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
        const EvaluationError(message: 'error'),
      ];

      for (final state in states) {
        // Exhaustive switch — compilation fails if a variant is missing.
        final label = switch (state) {
          EvaluationIdle() => 'idle',
          EvaluationSuccess() => 'success',
          ConversionSuccess() => 'conversion',
          UnitDefinitionResult() => 'unit-definition',
          FunctionDefinitionResult() => 'function-definition',
          FunctionConversionResult() => 'function-conversion',
          ReciprocalConversionSuccess() => 'reciprocal-conversion',
          EvaluationError() => 'error',
        };
        expect(label, isNotEmpty);
      }
    });
  });
}
