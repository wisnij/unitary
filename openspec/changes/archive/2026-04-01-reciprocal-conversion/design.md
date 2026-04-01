## Context

`FreeformNotifier._evaluateConversion` currently returns an `EvaluationError`
whenever `_isConversionConformable` returns false.  Reciprocal dimensions (e.g.
`mph` and `s/m`) fail that check and produce a confusing error.  GNU Units
performs the conversion on `1/input` instead and labels the result "reciprocal
conversion".

The relevant code paths are:
- `lib/core/domain/models/dimension.dart` — `Dimension` arithmetic and conformability
- `lib/features/freeform/state/freeform_provider.dart` — `_evaluateConversion` (the change point)
- `lib/features/freeform/state/freeform_state.dart` — `EvaluationResult` sealed hierarchy
- `lib/features/freeform/presentation/widgets/result_display.dart` — rendering switch

## Goals / Non-Goals

**Goals:**
- Detect when input and output dimensions are exact reciprocals (after
  dimensionless-unit stripping) and convert `1/input` to the output unit.
- Produce a new `ReciprocalConversionSuccess` result that carries the display
  data needed for the agreed layout.
- Render the result with a warning-color "reciprocal conversion" notice, the
  reciprocal input label on its own line, then the normal value and reciprocal
  value lines.
- Parenthesize the input expression in the label whenever it contains a `/`
  character (to keep `1 / (mile/hour)` syntactically unambiguous).

**Non-Goals:**
- Reciprocal detection in worksheet mode.
- Reciprocal detection when the output field names a function
  (`FunctionNameNode` path).
- Changing the conformability logic for the non-reciprocal error path.

## Decisions

### Decision 1: Add `Dimension.isReciprocalOf` helper

`Dimension` already has `power(int)`.  `D1.isReciprocalOf(D2)` is implemented
as `this == other.power(-1)`.  This is a one-liner that composes existing
primitives and keeps the reciprocal check readable at the call site.

**Alternative considered:** Inline the check at the call site in
`_evaluateConversion`.  Rejected: `Dimension` is a value type and
`isReciprocalOf` is a natural operation on it; it belongs there.

### Decision 2: Perform the conversion with negated input quantity

Once reciprocal dimensions are confirmed, the converted value is
`1 / (inputQty.value * outputQty.value)`.  This follows directly from the
existing conversion formula (`convertedValue = inputQty.value / outputQty.value`)
applied to a quantity whose value is `1/inputQty.value`:

```
1/inputQty → outputUnit:  (1/V_in) / V_out  =  1 / (V_in × V_out)
```

No new `Quantity` arithmetic is needed; the formula is expressed inline.

**Alternative considered:** Construct a new `Quantity(1/inputQty.value, …)`
and call the existing conversion helper on it.  Rejected: more indirection for
a trivial scalar expression.

### Decision 3: Pass raw input string into `_evaluateConversion` for label construction

`_evaluateConversion` already receives `output` as a raw string (for
`formatOutputUnit`).  Adding a matching `input` raw-string parameter is the
minimal change needed to format `1 / mph` vs `1 / (mile/hour)`.  The label is
built by checking whether `input.trim()` contains `/`; if so, the input is
wrapped in parentheses.

The raw string is the user's verbatim text (e.g. `"mile/hour"`), trimmed of
leading/trailing whitespace.  No parsing of the string is done for the label —
it is treated as an opaque display token.

**Alternative considered:** Reconstruct the input expression from the AST.
Rejected: the AST does not preserve the original spelling, and the raw string
is already available at the call site.

### Decision 4: `ReciprocalConversionSuccess` carries a pre-formatted reciprocal label

`ReciprocalConversionSuccess` stores four fields:
- `reciprocalInputLabel` — pre-formatted string, e.g. `"1 / mph"` or `"1 / (mile/hour)"`
- `formattedResult` — e.g. `"= 2.2369363 s/m"` (primary value line)
- `formattedReciprocal` — e.g. `"= (1 / 0.44704) s/m"` (secondary value line)
- `outputUnit` — raw output unit string (kept for potential future use, matches `ConversionSuccess`)

Pre-formatting in the provider (not the widget) keeps the widget layer
presentational and is consistent with how all other result types work.

### Decision 5: Warning color for the "reciprocal conversion" notice

`ResultDisplay` uses `colorScheme.tertiary` for the notice text and for the
container border color when displaying `ReciprocalConversionSuccess`.  Tertiary
is the Material 3 slot for accents that are neither primary nor error — it reads
as "different" without alarming the user the way `colorScheme.error` would.

**Alternative considered:** `colorScheme.error`.  Rejected: reciprocal
conversion is not an error; the user should read it as a helpful clarification,
not a failure.

**Alternative considered:** Amber/orange via a hard-coded `Color`.  Rejected:
hard-coded colors break dark-mode theming.

## Risks / Trade-offs

- **Dimensionless stripping and reciprocal check interact**: `_isConversionConformable`
  strips dimensionless units before checking; the reciprocal check must apply
  the same stripping so the two checks are consistent.  The implementation
  mirrors the same strip-then-compare pattern.  → Ensured by extracting the
  stripped dimensions once and using them for both checks.

- **User confusion if both checks pass**: It is theoretically possible for a
  pair of dimensions to be both conformable and reciprocals of each other (only
  when both are dimensionless).  Conformability takes priority; the reciprocal
  path is only reached when the conformability check fails.  → No special case
  needed.

- **Parenthesization heuristic**: Wrapping on `/` is a syntactic approximation.
  An input like `1/(a*b)` that happens to not contain `/` at top level would
  not be parenthesized.  But such expressions will evaluate correctly regardless
  — the parens are only cosmetic for display.  → Acceptable for MVP; can be
  refined if complaints arise.

## Migration Plan

Pure additive change.  No data migrations, no persistent state affected.
Existing `ConversionSuccess` and `EvaluationError` paths are unchanged; the
reciprocal path is a new branch inserted before the error return.  All
exhaustive `switch` statements over `EvaluationResult` gain one new arm.

Rollback: revert the three files (`freeform_provider.dart`,
`freeform_state.dart`, `result_display.dart`) and the one-line addition to
`dimension.dart`.
