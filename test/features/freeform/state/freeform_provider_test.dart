import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/expression_parser.dart';
import 'package:unitary/features/freeform/state/freeform_provider.dart';
import 'package:unitary/features/freeform/state/freeform_state.dart';
import 'package:unitary/features/freeform/state/parser_provider.dart';
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

    test('initial state has a non-null, non-empty example', () {
      final state = container.read(freeformProvider) as EvaluationIdle;
      expect(state.example, isNotNull);
      expect(state.example, isNotEmpty);
    });

    test('example changes when returning to idle after evaluation', () {
      final notifier = container.read(freeformProvider.notifier);
      final first =
          (container.read(freeformProvider) as EvaluationIdle).example;

      // Evaluate something to leave idle, then return to idle.
      notifier.evaluate('2 + 3', '');
      notifier.evaluate('', '');

      final second =
          (container.read(freeformProvider) as EvaluationIdle).example;
      expect(second, isNot(equals(first)));
    });

    test('example changes when cleared after evaluation', () {
      final notifier = container.read(freeformProvider.notifier);
      final first =
          (container.read(freeformProvider) as EvaluationIdle).example;

      notifier.evaluate('2 + 3', '');
      notifier.clear();

      final second =
          (container.read(freeformProvider) as EvaluationIdle).example;
      expect(second, isNot(equals(first)));
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

    test(
      'evaluate reciprocal dimensions produce ReciprocalConversionSuccess',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('mph', 's/m');
        final state = container.read(freeformProvider);
        expect(state, isA<ReciprocalConversionSuccess>());
        final success = state as ReciprocalConversionSuccess;
        expect(success.outputUnit, 's/m');
        expect(success.formattedResult, startsWith('= '));
        expect(success.formattedResult, contains('s/m'));
        expect(success.formattedReciprocal, startsWith('= (1 / '));
      },
    );

    test('evaluate reciprocal conversion value is correct', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('mph', 's/m');
      final state =
          container.read(freeformProvider) as ReciprocalConversionSuccess;
      // 1 / (mph_in_base * sm_in_base) ≈ 2.2369363
      expect(state.formattedResult, contains('2.236936'));
    });

    test(
      'evaluate conformable expressions still produce ConversionSuccess',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('mph', 'm/s');
        final state = container.read(freeformProvider);
        expect(state, isA<ConversionSuccess>());
      },
    );

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

    test(
      'function name input + function name output → EvaluationError (Unknown unit)',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // With non-empty output, input is parsed via parseExpression, so
        // "tempF" becomes UnitNode("tempF") which fails as an unknown unit.
        notifier.evaluate('tempF', 'tempC');
        final state = container.read(freeformProvider);
        expect(state, isA<EvaluationError>());
        expect((state as EvaluationError).message, contains('Unknown unit'));
      },
    );

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

    // -- Unit/prefix definition display --

    test(
      'alias for derived unit → UnitDefinitionResult with alias and definition lines',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('cal', '');
        final state = container.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        // 'cal' is an alias for 'calorie_th'
        expect(result.aliasLine, '= calorie_th');
        expect(result.definitionLine, isNotNull);
        expect(result.definitionLine, startsWith('= '));
        expect(result.formattedResult, startsWith('= '));
      },
    );

    test(
      'alias for primitive unit → UnitDefinitionResult with alias line only',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('meter', '');
        final state = container.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        expect(result.aliasLine, '= m');
        expect(result.definitionLine, isNull);
        expect(result.formattedResult, '= 1 m');
      },
    );

    test(
      'canonical derived unit id → UnitDefinitionResult with definition line only',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('calorie_th', '');
        final state = container.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        expect(result.aliasLine, isNull);
        expect(result.definitionLine, isNotNull);
        expect(result.definitionLine, startsWith('= '));
        expect(result.formattedResult, startsWith('= '));
      },
    );

    test(
      'derived unit whose expression equals formatted result → definitionLine omitted',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // stdtemp (alias for standardtemp) has expression '273.15 K', which
        // evaluates to 273.15 K — the definition line would duplicate the
        // formatted result, so it should be suppressed.
        notifier.evaluate('standardtemp', '');
        final state = container.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        expect(result.aliasLine, isNull);
        expect(result.definitionLine, isNull);
        expect(result.formattedResult, '= 273.15 K');
      },
    );

    test(
      'derived unit whose expression matches formatted result up to spacing → definitionLine omitted',
      () async {
        // Register a synthetic unit with expression '1 m/s' (no spaces around
        // '/').  The formatter produces '1 m / s' (spaces around '/'), so the
        // two strings differ only in whitespace — definitionLine should be
        // suppressed.
        final repo = UnitRepository.withPredefinedUnits();
        repo.register(
          const DerivedUnit(id: '_test_mps', expression: '1 m/s'),
        );
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final testSettings = SettingsRepository(prefs);
        final testContainer = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(testSettings),
            parserProvider.overrideWithValue(ExpressionParser(repo: repo)),
          ],
        );
        addTearDown(testContainer.dispose);

        testContainer.read(freeformProvider.notifier).evaluate('_test_mps', '');
        final state = testContainer.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        expect(result.aliasLine, isNull);
        expect(result.definitionLine, isNull);
        expect(result.formattedResult, '= 1 m / s');
      },
    );

    test(
      'canonical primitive unit id → UnitDefinitionResult with result only',
      () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('m', '');
        final state = container.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        expect(result.aliasLine, isNull);
        expect(result.definitionLine, isNull);
        expect(result.formattedResult, '= 1 m');
      },
    );

    test(
      'prefix+unit alias → UnitDefinitionResult with decomposed canonical ids',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // "kmeters" → prefix "kilo" + unit "m" (via alias "meter" → plural "meters")
        notifier.evaluate('kmeters', '');
        final state = container.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        expect(result.aliasLine, '= kilo m');
        expect(result.definitionLine, isNull);
        expect(result.formattedResult, startsWith('= '));
        expect(result.formattedResult, contains('m'));
      },
    );

    test(
      'canonical prefix+unit → UnitDefinitionResult with decomposed canonical ids',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // "km" → prefix "kilo" (alias "k") + unit "m" → alias line shows canonical ids
        notifier.evaluate('km', '');
        final state = container.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        expect(result.aliasLine, '= kilo m');
        expect(result.definitionLine, isNull);
        expect(result.formattedResult, '= 1000 m');
      },
    );

    test(
      'bare prefix alias → UnitDefinitionResult with canonical prefix id',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // "M" is the short alias for prefix "mega"; verify no unit named "M"
        // shadows it (unit names take priority over prefix names).
        final repo = container.read(parserProvider).repo;
        expect(
          repo?.findUnit('M'),
          isNull,
          reason: 'test assumes no unit with name or alias "M" is registered',
        );
        notifier.evaluate('M', '');
        final state = container.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        expect(result.aliasLine, '= mega');
        expect(result.definitionLine, isNull);
        expect(result.formattedResult, startsWith('= '));
      },
    );

    test(
      'bare canonical prefix id → UnitDefinitionResult with no alias line',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // "kilo" is the canonical prefix id (its alias is "k", which is a unit)
        notifier.evaluate('kilo', '');
        final state = container.read(freeformProvider);
        expect(state, isA<UnitDefinitionResult>());
        final result = state as UnitDefinitionResult;
        expect(result.aliasLine, isNull);
        expect(result.definitionLine, isNull);
        expect(result.formattedResult, '= 1000');
      },
    );

    test(
      'bare unit name input with non-empty output converts as expression',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // With non-empty output, input is parsed via parseExpression, so
        // "cal" becomes UnitNode("cal") = 1 cal, then converted to J.
        notifier.evaluate('cal', 'J');
        final state = container.read(freeformProvider);
        expect(state, isA<ConversionSuccess>());
        final result = state as ConversionSuccess;
        expect(result.convertedValue, closeTo(4.184, 1e-6));
      },
    );

    test(
      'bare unit name input + function name output converts via inverse',
      () {
        final notifier = container.read(freeformProvider.notifier);
        // "stdtemp" = 273.15 K; "tempF" inverse applied to 273.15 K → 32 °F
        notifier.evaluate('stdtemp', 'tempF');
        final state = container.read(freeformProvider);
        expect(state, isA<FunctionConversionResult>());
        final result = state as FunctionConversionResult;
        expect(result.functionName, 'tempF');
        expect(result.formattedValue, contains('32'));
      },
    );

    test('DefinitionRequestNode output falls back to conversion', () {
      final notifier = container.read(freeformProvider.notifier);
      notifier.evaluate('5 km', 'm');
      final state = container.read(freeformProvider);
      expect(state, isA<ConversionSuccess>());
      final result = state as ConversionSuccess;
      expect(result.convertedValue, closeTo(5000.0, 1e-6));
    });

    group('reciprocal input label formatting', () {
      test('plain unit name produces label without parentheses', () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('mph', 's/m');
        final state =
            container.read(freeformProvider) as ReciprocalConversionSuccess;
        expect(state.reciprocalInputLabel, '1 / mph');
      });

      test('expression with division produces label with parentheses', () {
        final notifier = container.read(freeformProvider.notifier);
        notifier.evaluate('mile/hour', 's/m');
        final state =
            container.read(freeformProvider) as ReciprocalConversionSuccess;
        expect(state.reciprocalInputLabel, '1 / (mile/hour)');
      });

      test(
        'leading and trailing whitespace is trimmed before building label',
        () {
          final notifier = container.read(freeformProvider.notifier);
          notifier.evaluate('  mph  ', 's/m');
          final state =
              container.read(freeformProvider) as ReciprocalConversionSuccess;
          expect(state.reciprocalInputLabel, '1 / mph');
        },
      );
    });
  });
}
