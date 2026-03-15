## 1. State Type

- [x] 1.1 Add `FunctionConversionResult({required String functionName, required String formattedValue})` to `freeform_state.dart` as a new `sealed` subtype of `EvaluationResult`

## 2. Provider

- [x] 2.1 In `freeform_provider.dart`, update `_handleFunctionNameOutput` to return `FunctionConversionResult(functionName: outputNode.name, formattedValue: formatted)` instead of `EvaluationSuccess`

## 3. Widget

- [x] 3.1 In `result_display.dart`, add a `FunctionConversionResult` arm to the exhaustive `switch` that displays `"${r.functionName}(${r.formattedValue})"` in the primary-color bold style (no reciprocal row)

## 4. Tests

- [x] 4.1 Add unit tests for `FunctionConversionResult`: verify field storage and that it is an `EvaluationResult`
- [x] 4.2 Add/update `FreeformNotifier` tests: `evaluate("tempF(68)", "tempC")` produces `FunctionConversionResult` with correct `functionName` and `formattedValue`; function-without-inverse in output still produces `EvaluationError`
- [x] 4.3 Add widget tests for `ResultDisplay` with `FunctionConversionResult`: rendered text is `"tempC(20)"` in primary style; no reciprocal row present

## 5. Verification

- [x] 5.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 5.2 Run `flutter analyze` and confirm no linting errors
