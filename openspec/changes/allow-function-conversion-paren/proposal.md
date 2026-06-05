## Why

When the user selects a function name from the predictive completion overlay,
an open parenthesis is automatically appended (e.g. `tempC(`).  If this
auto-completed text lands in the output field, `parseQuery` does not recognize
it as a function name and returns an error instead of performing the inverse
conversion.

## What Changes

- `parseQuery()` SHALL also recognize `IDENTIFIER LPAR` (and `INVERSE
  IDENTIFIER LPAR`) as a function-name pattern, treating it identically to the
  bare-identifier form and producing a `FunctionNameNode`.
- The trailing `LPAR` is consumed as part of the recognition; it is not passed
  to `parseExpression`.

## Capabilities

### New Capabilities

- None — this is a parser-rule extension to an existing capability.

### Modified Capabilities

- `conversion-request-types`: The `parseQuery()` requirement for
  `FunctionNameNode` recognition must be extended to cover the
  `IDENTIFIER LPAR` (and `INVERSE IDENTIFIER LPAR`) token patterns in
  addition to the current bare-identifier patterns.

## Impact

- `lib/core/domain/parser/parser.dart` — two additional token-pattern branches
  in `parseQuery()`.
- `openspec/specs/conversion-request-types/spec.md` — delta spec updates the
  `parseQuery()` requirement to document the new patterns.
- No new dependencies.  No API surface changes outside `parseQuery()`.
