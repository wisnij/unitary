import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/freeform/state/freeform_provider.dart';
import 'package:unitary/features/freeform/state/freeform_state.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

void main() {
  group('FreeformNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepository(prefs);
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is EvaluationIdle', () {
      expect(container.read(freeformProvider), isA<EvaluationIdle>());
    });

    test('evaluate succeeds for simple expression', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('2 + 3', '');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationSuccess>());
      final success = state as EvaluationSuccess;
      expect(success.result.value, 5.0);
      expect(success.formattedResult, '5');
    });

    test('evaluate succeeds for expression with units', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5 ft', '');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationSuccess>());
      final success = state as EvaluationSuccess;
      expect(success.result.value, closeTo(1.524, 1e-6));
      expect(success.formattedResult, contains('m'));
    });

    test('evaluate conversion succeeds for conformable expressions', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5 miles', 'km');
      final state = container.read(freeformProvider);
      expect(state, isA<ConversionSuccess>());
      final success = state as ConversionSuccess;
      expect(success.convertedValue, closeTo(8.04672, 1e-4));
      expect(success.formattedResult, startsWith('= '));
      expect(success.formattedResult, contains('km'));
      expect(success.outputUnit, 'km');
    });

    test('evaluate conversion includes reciprocal result', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5 miles', 'km');
      final state = container.read(freeformProvider);
      expect(state, isA<ConversionSuccess>());
      final success = state as ConversionSuccess;
      expect(success.formattedReciprocal, startsWith('= (1 / '));
      expect(success.formattedReciprocal, endsWith(') km'));
    });

    test('evaluate conversion fails for non-conformable expressions', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5 ft', '3 kg');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationError>());
    });

    test('evaluate returns error for parse error', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5 +', '');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationError>());
      expect((state as EvaluationError).message, isNotEmpty);
    });

    test('evaluate returns error for dimension mismatch', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5 ft + 3 kg', '');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationError>());
    });

    test('clear resets to EvaluationIdle', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5', '');
      expect(container.read(freeformProvider), isA<EvaluationSuccess>());
      notifier.clear();
      expect(container.read(freeformProvider), isA<EvaluationIdle>());
    });

    test('evaluate with empty input clears', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5', '');
      notifier.evaluate('', '');
      expect(container.read(freeformProvider), isA<EvaluationIdle>());
    });

    test('evaluate with whitespace-only input clears', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5', '');
      notifier.evaluate('   ', '');
      expect(container.read(freeformProvider), isA<EvaluationIdle>());
    });

    test(
      'evaluate conversion strips dimensionless units for conformability',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('1 radian', '1');
        final state = container.read(freeformProvider);
        expect(state, isA<ConversionSuccess>());
        final success = state as ConversionSuccess;
        expect(success.convertedValue, closeTo(1.0, 1e-10));
      },
    );

    test(
      'evaluate conversion strips dimensionless units from both sides',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('3 radian', 'radian');
        final state = container.read(freeformProvider);
        expect(state, isA<ConversionSuccess>());
        final success = state as ConversionSuccess;
        expect(success.convertedValue, closeTo(3.0, 1e-10));
      },
    );

    test(
      'evaluate conversion prefixes output unit with × when it starts with a digit',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('5000 m', '5 km');
        final state = container.read(freeformProvider);
        expect(state, isA<ConversionSuccess>());
        final success = state as ConversionSuccess;
        expect(success.formattedResult, contains('× 5 km'));
        expect(success.formattedReciprocal, contains('× 5 km'));
      },
    );

    // -- Function name in input field --

    test('bare function name input → FunctionDefinitionResult', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('tempF', '');
      final state = container.read(freeformProvider);
      expect(state, isA<FunctionDefinitionResult>());
      final result = state as FunctionDefinitionResult;
      expect(result.label, 'tempF(x) =');
      expect(result.expression, isNotNull);
    });

    test(
      'builtin function name input → FunctionDefinitionResult with built-in label',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('sin', '');
        final state = container.read(freeformProvider);
        expect(state, isA<FunctionDefinitionResult>());
        final result = state as FunctionDefinitionResult;
        expect(result.label, 'sin(x) =');
        expect(result.expression, '<built-in function sin>');
      },
    );

    // -- Bare inverse function name in input field --

    test('~funcName input → FunctionDefinitionResult with inverse label', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('~tempF', '');
      final state = container.read(freeformProvider);
      expect(state, isA<FunctionDefinitionResult>());
      final result = state as FunctionDefinitionResult;
      expect(result.label, '~tempF =');
      expect(result.expression, isNotNull);
    });

    test(
      '~funcName with no inverse → FunctionDefinitionResult with fallback expression',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('~sin', '');
        final state = container.read(freeformProvider);
        expect(state, isA<FunctionDefinitionResult>());
        final result = state as FunctionDefinitionResult;
        expect(result.label, '~sin =');
        expect(result.expression, 'no inverse defined');
      },
    );

    // -- Function name in output field --

    test(
      'expression input + function name output → FunctionConversionResult via callInverse',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // tempF(68) = 293.15 K; ~tempC(293.15 K) = 20 °C = 20.0
        notifier.evaluate('tempF(68)', 'tempC');
        final state = container.read(freeformProvider);
        expect(state, isA<FunctionConversionResult>());
        final result = state as FunctionConversionResult;
        expect(result.functionName, 'tempC');
        expect(double.parse(result.formattedValue), closeTo(20.0, 1e-4));
      },
    );

    test(
      'FunctionConversionResult uses the name as entered, not the canonical id',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // 'tempcelsius' is an alias for tempC; the display should reflect what the user typed
        notifier.evaluate('tempF(68)', 'tempcelsius');
        final state = container.read(freeformProvider);
        expect(state, isA<FunctionConversionResult>());
        final result = state as FunctionConversionResult;
        expect(result.functionName, 'tempcelsius');
        expect(double.parse(result.formattedValue), closeTo(20.0, 1e-4));
      },
    );

    test(
      'FunctionConversionResult includes dimension when inverse returns dimensioned quantity',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // stdatmTH(2 m) → temperature; ~stdatmT of that temperature ≈ 2 m
        notifier.evaluate('stdatmTH(2 m)', 'stdatmT');
        final state = container.read(freeformProvider);
        expect(state, isA<FunctionConversionResult>());
        final result = state as FunctionConversionResult;
        expect(result.functionName, 'stdatmT');
        // formattedValue should include the unit label (e.g. "2.0000006 m")
        expect(result.formattedValue, contains(' m'));
        expect(result.formattedValue, isNot(equals('m')));
      },
    );

    test('function name input + function name output → EvaluationError', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('tempF', 'tempC');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationError>());
    });

    test('expression input + ~funcName output → EvaluationError', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5 km', '~tempC');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationError>());
    });

    test('function name output with no inverse → EvaluationError', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5', 'sin');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationError>());
      expect((state as EvaluationError).message, contains('No inverse'));
    });
  });
}
