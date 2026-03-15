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
        const FunctionDefinitionResult(
          label: 'tempF(x) =',
          expression: 'x * 9|5 + 32',
        ),
        const FunctionConversionResult(
          functionName: 'tempC',
          formattedValue: '20',
        ),
        const EvaluationError(message: 'error'),
      ];

      for (final state in states) {
        // Exhaustive switch — compilation fails if a variant is missing.
        final label = switch (state) {
          EvaluationIdle() => 'idle',
          EvaluationSuccess() => 'success',
          ConversionSuccess() => 'conversion',
          FunctionDefinitionResult() => 'function-definition',
          FunctionConversionResult() => 'function-conversion',
          EvaluationError() => 'error',
        };
        expect(label, isNotEmpty);
      }
    });
  });
}
