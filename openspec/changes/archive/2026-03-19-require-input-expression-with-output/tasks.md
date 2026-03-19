## 1. Implementation

- [x] 1.1 In `FreeformNotifier.evaluate()`, call `parseExpression(input)` instead of `parseQuery(input)` when `output.trim()` is non-empty
- [x] 1.2 Remove the `DefinitionRequestNode`-in-input fallback block (the `inputNode is DefinitionRequestNode` branch that calls `parser.parseExpression(inputNode.unitName)`)

## 2. Tests

- [x] 2.1 Add test: `evaluate("cal", "J")` converts `1 cal` to `J` (bare unit name input with non-empty output — same outcome, new parse path)
- [x] 2.2 Add test: `evaluate("tempF", "tempC")` produces `EvaluationError` with "Unknown unit" message (input parsed via `parseExpression` as `UnitNode`, not `FunctionNameNode`)
- [x] 2.3 Add test: `evaluate("stdtemp", "tempF")` produces conversion result of `32` (bare unit name input + function name output via inverse)
- [x] 2.4 Verify all existing `FreeformNotifier` tests still pass

## 3. Spec Sync

- [x] 3.1 Run `flutter test --reporter failures-only` and confirm no regressions
- [x] 3.2 Run `flutter analyze` and confirm no lint errors
