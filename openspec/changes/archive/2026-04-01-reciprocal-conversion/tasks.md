## 1. Domain Model

- [x] 1.1 Add `Dimension.isReciprocalOf(Dimension other)` method to `lib/core/domain/models/dimension.dart` returning `this == other.power(-1)`
- [x] 1.2 Add `ReciprocalConversionSuccess` class to `lib/features/freeform/state/freeform_state.dart` with fields `reciprocalInputLabel`, `formattedResult`, `formattedReciprocal`, `outputUnit`

## 2. Tests

- [x] 2.1 Add `Dimension.isReciprocalOf` unit tests to `test/core/domain/models/dimension_test.dart` (true for reciprocals, false for same, false for unrelated, dimensionless is own reciprocal)
- [x] 2.2 Add `ReciprocalConversionSuccess` construction tests to the freeform state test file
- [x] 2.3 Add `FreeformNotifier` integration tests: reciprocal input produces `ReciprocalConversionSuccess`, conformable input still produces `ConversionSuccess`, incompatible input still produces `EvaluationError`
- [x] 2.4 Add label-formatting tests: plain unit → no parens, unit with `/` → parens, whitespace trimmed

## 3. Provider Logic

- [x] 3.1 Add a `_isReciprocalConversion` check in `_evaluateConversion` (in `lib/features/freeform/state/freeform_provider.dart`) that runs after the non-conformable branch, applying the same dimensionless-unit stripping
- [x] 3.2 Add the `_buildReciprocalInputLabel(String input)` helper: trim input, wrap in parens if it contains `/`, prefix with `"1 / "`
- [x] 3.3 Compute `convertedValue = 1.0 / (inputQty.value * outputQty.value)` and `reciprocalValue = inputQty.value * outputQty.value` and build `ReciprocalConversionSuccess` with pre-formatted strings
- [x] 3.4 Pass the raw `input` string through to `_evaluateConversion` (add parameter alongside the existing `output` parameter)

## 4. UI

- [x] 4.1 Add a `ReciprocalConversionSuccess` arm to the exhaustive `switch` in `ResultDisplay` (`lib/features/freeform/presentation/widgets/result_display.dart`) rendering: notice line (`colorScheme.tertiary`), label line (`colorScheme.onSurfaceVariant`), primary value line (`colorScheme.primary`, bold), secondary value line (`colorScheme.onSurfaceVariant`)
- [x] 4.2 Set the container border color to `colorScheme.primary` in the `ReciprocalConversionSuccess` arm

## 5. Verification

- [x] 5.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 5.2 Run `flutter analyze` and confirm no linting errors
