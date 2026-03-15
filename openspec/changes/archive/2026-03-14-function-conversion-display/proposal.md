## Why

When the output field contains a bare function name (e.g. `tempC`), the freeform
evaluator applies the function's inverse to the input quantity and returns an
`EvaluationSuccess` — which displays only a bare number.  The user sees `= 20`
with no indication of what unit or function the result is expressed in.  For
function-based conversions the result should be presented as a function call,
e.g. `tempC(20)`, making it clear which function produced the value and what the
output means.

## What Changes

- When the output field parses to `FunctionNameNode(f, inverse: false)` and the
  inverse application succeeds, the result SHALL be formatted as
  `functionName(value)` (e.g. `tempC(20)`) rather than a bare number.
- The reciprocal line SHALL be omitted; there is no meaningful reciprocal for a
  function conversion.
- Introduce a new `EvaluationResult` subtype `FunctionConversionResult` to carry
  the function name and formatted numeric value as separate fields, so
  `ResultDisplay` can compose the `name(value)` string and apply appropriate
  styling.  `ConversionSuccess` is left unchanged.
- Extend `ResultDisplay` to render `FunctionConversionResult`.

## Capabilities

### New Capabilities

- `function-conversion-result`: New `FunctionConversionResult` result subtype
  and its `ResultDisplay` rendering; updated `FreeformNotifier` dispatch to
  produce it when the output field is a bare function name.

### Modified Capabilities

<!-- No existing spec-level requirements change. -->

## Impact

- `lib/features/freeform/state/freeform_state.dart` — add
  `FunctionConversionResult(functionName: String, formattedValue: String)`
- `lib/features/freeform/state/freeform_provider.dart` — change
  `_handleFunctionNameOutput` to return `FunctionConversionResult` instead of
  `EvaluationSuccess`
- `lib/features/freeform/presentation/widgets/result_display.dart` — add
  `FunctionConversionResult` arm to the exhaustive `switch`
- `test/features/freeform/` — update or add tests for the new result type and
  its display
- No new package dependencies
