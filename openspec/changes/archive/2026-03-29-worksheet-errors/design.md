# Design: Worksheet Errors

## Context

`computeWorksheet()` currently catches all exceptions from target-row
conversion and collapses them to the string `"error"`.  `WorksheetResult`
is a thin wrapper around `List<String?>`, so the engine has no structured way
to distinguish an error display string from a numeric value string.
`WorksheetRowWidget` renders every non-empty string identically.

The three root causes of row-level errors today are:

| Cause | Exception type | Location |
|---|---|---|
| Dimension mismatch (e.g., length vs. mass) | `DimensionException` | `_unitRowTarget` |
| Domain/range bounds violation | `EvalException` (from `_validateSpec`) | `UnitaryFunction.call` / `callInverse` |
| No inverse defined for a `FunctionRow` target | Explicit `!hasInverse` guard | `_funcRowTarget` |

The domain-violation case is the least distinguishable: `_validateSpec` throws
a plain `EvalException`, indistinguishable at the catch site from every other
`EvalException` (circular reference, unknown unit, etc.).

## Goals / Non-Goals

**Goals:**

- Produce a short, user-facing error label for the three primary failure modes
  ("wrong unit type", "out of bounds", "no inverse").
- Fall back to a generic "error" label for unexpected failures.
- Render error rows in `colorScheme.error` so failures are visually distinct.

**Non-Goals:**

- Full error detail strings (long messages, tooltips, tappable explanations).
- Errors on the source row (source errors already clear all rows).
- Persistence of error state across sessions.
- Errors from invalid worksheet template definitions (these are programmer
  errors, not user-facing).

## Decisions

### Decision 1 — Add `BoundsException` to `errors.dart`

`UnitaryFunction._validateSpec` currently throws `EvalException` for bounds
violations.  This makes it impossible for `computeWorksheet` to tell a domain
error apart from other `EvalException`s without inspecting the message string.

**Decision:** introduce `BoundsException extends UnitaryException` and throw it
from `_validateSpec` when a value falls outside the min/max bounds.  The
exception carries the violating value, the bound, and the function id for
context, but the worksheet engine only uses its type — not its message.

**Alternative considered:** inspect the `EvalException.message` for keywords.
Rejected: fragile coupling between the engine and the function layer's message
formatting.

### Decision 2 — `WorksheetCellResult` record replaces bare `String?`

`WorksheetResult.values` is currently `List<String?>`.  A `null` entry means
"preserve / clear"; a non-null `String` means "write this text to the
controller".  There is no structured way to flag a cell as an error.

**Decision:** introduce a `WorksheetCellResult` record with fields
`(String text, bool isError)`.  `WorksheetResult` becomes
`List<WorksheetCellResult?>`, where `null` retains its existing "clear" semantic
and a non-null value carries both the display text and an error flag.

```
WorksheetCellResult(text: '3.28084', isError: false)   // normal value
WorksheetCellResult(text: 'out of bounds', isError: true)  // error
```

**Alternative considered:** a parallel `List<bool>` for error flags alongside
the existing `List<String?>`.  Rejected: keeping two parallel lists in sync is
error-prone and complicates consumers.

**Alternative considered:** a sealed `WorksheetCellResult` with `Value` and
`Error` subclasses.  Rejected: a record with a flag is simpler for this
two-state case; the extra subclass machinery is not warranted.

### Decision 3 — Error message mapping in `computeWorksheet`

The engine maps exception types to short labels at the catch site:

| Exception | Label |
|---|---|
| `DimensionException` | `"wrong unit type"` |
| `BoundsException` | `"out of bounds"` |
| Explicit `!hasInverse` | `"no inverse"` |
| All other exceptions | `"error"` |

The `!hasInverse` guard in `_funcRowTarget` already runs before `callInverse`
is invoked, so it is still checked explicitly rather than caught as an
exception.

### Decision 4 — `isError` flag on `WorksheetRowWidget`

The row widget is a stateless `StatelessWidget` with no domain dependency.
Rather than passing a `WorksheetCellResult` directly, add a single `bool
isError` parameter.  When true, the `TextField` text style uses
`colorScheme.error`.  The `InputDecoration` is left unchanged (no border color
change); only the text color signals the error state.

**Alternative considered:** change the `InputDecoration.errorText` or border
style.  Rejected: `errorText` adds extra layout height below the field, shifting
other rows; the spec requires a color change on the text only.

## Risks / Trade-offs

- **`BoundsException` is a new public type.** Any code that catches
  `UnitaryException` broadly already handles it; only code that catches
  `EvalException` specifically will miss it.  Current callers of
  `UnitaryFunction.call` outside the worksheet (freeform evaluator, tests)
  catch `UnitaryException`, so no regressions expected.
- **Error label strings are not localized.** Consistent with the rest of the
  app (Phase 9 concern).
- **`WorksheetCellResult` is a new public type in the worksheet layer.**
  Only `computeWorksheet`, `WorksheetResult`, `WorksheetState`, and the
  worksheet screen consume it; the blast radius is small.

## Open Questions

_(none)_
