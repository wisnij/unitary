## Context

`parseQuery()` in `ExpressionParser` recognizes a bare function name (a single
identifier token, optionally preceded by `~`) and returns a `FunctionNameNode`.
This drives the freeform output field: when the user types `tempC` in the
output field, the evaluator applies `tempC`'s inverse to the input.

The predictive completion overlay appends a trailing `(` when inserting a
function name (e.g. selecting `tempC` inserts `tempC(`).  After auto-completion
the output field contains `tempC(`, which tokenizes as `IDENTIFIER LPAR`.
`parseQuery` does not recognize this pattern, falls through to
`parseExpression`, and produces a parse error because the `(` is never closed.

The fix is a one-line pattern extension in `parseQuery`: also accept two tokens
`IDENTIFIER LPAR` (or `INVERSE IDENTIFIER LPAR`) as equivalent to the
bare-identifier form.

## Goals / Non-Goals

**Goals:**

- `parseQuery` recognizes `funcName(` in the output field and produces
  `FunctionNameNode(name, inverse: false)`, identical to `funcName`.
- `parseQuery` recognizes `~funcName(` and produces
  `FunctionNameNode(name, inverse: true)`, identical to `~funcName`.
- Downstream behavior (inverse call, result display) is unchanged.

**Non-Goals:**

- No change to `parseExpression`; partial function calls like `tempC(` in the
  input field remain a parse error (they are incomplete expressions).
- No change to auto-completion behavior; the trailing `(` is already inserted
  by the overlay and that is not being modified.
- No change to how `FunctionNameNode` is used after recognition.

## Decisions

### Consume the LPAR without producing a node for it

The `LPAR` token is recognized purely as syntactic sugar for intent signaling.
It carries no semantic value when parsed as a query; discarding it keeps
`FunctionNameNode` unchanged and avoids touching any downstream code.

**Alternative considered**: Strip the trailing `(` in the UI layer before
calling `parseQuery`.  Rejected — mixing display and parsing concerns, and
requires changes in more places than a single parser method.

### Only strip exactly one trailing LPAR

The pattern accepted is `IDENTIFIER LPAR EOF` (two significant tokens).
`IDENTIFIER LPAR RPAR EOF` (a closed call) is left to `parseExpression` so it
evaluates as a zero-argument call.  This keeps the rule narrow and avoids
ambiguity.

## Risks / Trade-offs

- [False positive] A user who types `km(` would not get a function-name result
  today (since `km` is a unit, not a function).  The new pattern still checks
  `findFunction(name)` first, so `km(` still falls through to `parseExpression`
  and produces an error.  No regression.
- [Incomplete input] Accepting `tempC(` is a deliberate "lenient" parse of
  incomplete input.  It is safe because this path is only taken when
  `findFunction` confirms the name is registered.
