## Context

`FreeformNotifier._handleFunctionNameOutput` currently returns `EvaluationSuccess`
when the output field is a bare function name and the inverse succeeds.
`EvaluationSuccess` carries only a formatted number string; the function name is
discarded.  The display widget renders just `= 20` with no context about what
function the result belongs to.

The desired presentation is `functionName(value)` — e.g. `tempC(20)` — mirroring
the call-syntax the user is already familiar with from the input field.

This is a small, self-contained change touching one state type, one provider
method, and one widget arm.  No new dependencies, no data-model changes, no
migration needed.

## Goals / Non-Goals

**Goals:**
- Introduce `FunctionConversionResult` as a new `EvaluationResult` subtype
  carrying `functionName` and `formattedValue` separately.
- Update `_handleFunctionNameOutput` to produce `FunctionConversionResult`
  instead of `EvaluationSuccess`.
- Render `FunctionConversionResult` in `ResultDisplay` as
  `functionName(formattedValue)` with the same primary-color styling used for
  other successful results.
- No reciprocal row (functions are not plain scale factors).

**Non-Goals:**
- Changing how the inverse is computed or which functions support it.
- Adding a reciprocal or "1 / x" line for function conversions.
- Modifying `ConversionSuccess` or any other existing result type.
- Handling `~funcName` in the output field differently than today (still an
  error).

## Decisions

### Separate `FunctionConversionResult` instead of reusing `ConversionSuccess`
**Decision**: Add a new `FunctionConversionResult(functionName, formattedValue)`
subtype rather than shoehorning the function name into `ConversionSuccess.outputUnit`.

**Rationale**: `ConversionSuccess` always shows a reciprocal row and formats its
result as `= value unit`.  Suppressing the reciprocal conditionally would require
a nullable field and a special case in the widget.  A dedicated subtype keeps both
paths clean and makes the exhaustive `switch` self-documenting.

**Alternative considered**: Reuse `EvaluationSuccess` with a manually composed
`"tempC(20)"` string — rejected because it conflates two semantically different
outcomes and loses the structured data needed if future work wants to, e.g., make
the function name tappable.

### Compose `functionName(formattedValue)` in `ResultDisplay`, not in the provider
**Decision**: Store `functionName` and `formattedValue` as separate fields;
combine them in the widget.

**Rationale**: Keeps the state layer free of presentation logic and makes it easy
to adjust formatting (parentheses style, spacing) without touching the provider.

## Risks / Trade-offs

- **Risk**: `EvaluationResult` is a `sealed` class; adding a subtype requires
  updating the exhaustive `switch` in `ResultDisplay` (and any other switches
  over `EvaluationResult`).  → **Mitigation**: The Dart compiler enforces
  exhaustiveness, so any missed switch arm is a compile error, not a silent bug.
- **Risk**: `formattedValue` is a pre-formatted string; any future need to
  re-format (e.g. on settings change) would require re-evaluating.  → Not a
  concern for this change; the same pattern is used by all other result types.
