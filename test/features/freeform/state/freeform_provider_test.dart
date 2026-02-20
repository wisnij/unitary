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

    test('evaluateSingle succeeds for simple expression', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateSingle('2 + 3');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationSuccess>());
      final success = state as EvaluationSuccess;
      expect(success.result.value, 5.0);
      expect(success.formattedResult, '5');
    });

    test('evaluateSingle succeeds for expression with units', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateSingle('5 ft');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationSuccess>());
      final success = state as EvaluationSuccess;
      expect(success.result.value, closeTo(1.524, 1e-6));
      expect(success.formattedResult, contains('m'));
    });

    test('evaluateConversion succeeds for conformable expressions', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateConversion('5 miles', 'km');
      final state = container.read(freeformProvider);
      expect(state, isA<ConversionSuccess>());
      final success = state as ConversionSuccess;
      expect(success.convertedValue, closeTo(8.04672, 1e-4));
      expect(success.formattedResult, startsWith('= '));
      expect(success.formattedResult, contains('km'));
      expect(success.outputUnit, 'km');
    });

    test('evaluateConversion includes reciprocal result', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateConversion('5 miles', 'km');
      final state = container.read(freeformProvider);
      expect(state, isA<ConversionSuccess>());
      final success = state as ConversionSuccess;
      expect(success.formattedReciprocal, startsWith('= (1 / '));
      expect(success.formattedReciprocal, endsWith(') km'));
    });

    test('evaluateConversion fails for non-conformable expressions', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateConversion('5 ft', '3 kg');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationError>());
    });

    test('evaluateSingle returns error for parse error', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateSingle('5 +');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationError>());
      expect((state as EvaluationError).message, isNotEmpty);
    });

    test('evaluateSingle returns error for dimension mismatch', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateSingle('5 ft + 3 kg');
      final state = container.read(freeformProvider);
      expect(state, isA<EvaluationError>());
    });

    test('clear resets to EvaluationIdle', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateSingle('5');
      expect(container.read(freeformProvider), isA<EvaluationSuccess>());
      notifier.clear();
      expect(container.read(freeformProvider), isA<EvaluationIdle>());
    });

    test('evaluateSingle with empty input clears', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateSingle('5');
      notifier.evaluateSingle('');
      expect(container.read(freeformProvider), isA<EvaluationIdle>());
    });

    test('evaluateSingle with whitespace-only input clears', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluateSingle('5');
      notifier.evaluateSingle('   ');
      expect(container.read(freeformProvider), isA<EvaluationIdle>());
    });

    test(
      'evaluateConversion strips dimensionless units for conformability',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // radian has dimension {radian: 1}, but radian is dimensionless,
        // so "1 radian" should be convertible to a plain number.
        notifier.evaluateConversion('1 radian', '1');
        final state = container.read(freeformProvider);
        expect(state, isA<ConversionSuccess>());
        final success = state as ConversionSuccess;
        expect(success.convertedValue, closeTo(1.0, 1e-10));
      },
    );

    test(
      'evaluateConversion strips dimensionless units from both sides',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // Both sides have radians — should still be conformable.
        notifier.evaluateConversion('3 radian', 'radian');
        final state = container.read(freeformProvider);
        expect(state, isA<ConversionSuccess>());
        final success = state as ConversionSuccess;
        expect(success.convertedValue, closeTo(3.0, 1e-10));
      },
    );

    test(
      'evaluateConversion prefixes output unit with × when it starts with a digit',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // "5 km" starts with a digit, so formattedResult should use × prefix.
        notifier.evaluateConversion('5000 m', '5 km');
        final state = container.read(freeformProvider);
        expect(state, isA<ConversionSuccess>());
        final success = state as ConversionSuccess;
        expect(success.formattedResult, contains('× 5 km'));
        expect(success.formattedReciprocal, contains('× 5 km'));
      },
    );
  });
}
