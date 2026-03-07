## Context

The expression evaluator supports calling registered functions via
`IDENTIFIER LPAR arguments RPAR`.  The `UnitaryFunction` base class already
defines `callInverse()` and `hasInverse`, but there is no syntax to invoke it
from an expression.  The `~` character is already excluded from identifier
scanning in the lexer (listed in `_identifierExcludedChars`), so it is safe to
claim as a new operator token without ambiguity.

Affected files:

- `lib/core/domain/parser/token.dart` — `TokenType` enum
- `lib/core/domain/parser/lexer.dart` — `_scanToken` switch + `_identifierExcludedChars`
- `lib/core/domain/parser/parser.dart` — `function` production comment + parsing logic
- `lib/core/domain/parser/ast.dart` — `FunctionNode`

## Goals / Non-Goals

**Goals:**

- Add `INVERSE` (`~`) as a first-class lexer token
- Allow `~IDENTIFIER(args)` syntax to invoke `callInverse()` on a registered function
- Propagate the `inverse` flag through `FunctionNode` to evaluation dispatch
- Error clearly when `~` is used on a function with `hasInverse == false`

**Non-Goals:**

- Inverse syntax for affine units (those use `AffineUnitNode`, not `FunctionNode`)
- Inverse syntax for the `logB(x)` sugar production (handled separately)
- Any new invertible function implementations (that is left to individual function changes)

## Decisions

### D1: `~` as a prefix operator on function calls (GNU Units compatibility)

`~` binds only to a function call: `~IDENTIFIER(args)`.  This matches the GNU
Units grammar, where `~` is a prefix operator on function names that invokes the
inverse of that function.  It is parsed inside the `function` production, not as
a general unary operator in the expression grammar.

### D2: `FunctionNode` gains an `inverse: bool` field

A single boolean on `FunctionNode` is the minimal change.  Evaluation
dispatches to `func.call(args)` or `func.callInverse(args)` based on this flag.
`callInverse()` already throws `EvalException` when `hasInverse == false`, so
no extra guard is needed in `FunctionNode`.

### D3: Parser checks for `~` inside the existing `_parseIdentifier` function production

The `~` token is consumed before the identifier is read, inside the same branch
that currently handles `IDENTIFIER LPAR`.  This avoids introducing a new
top-level parse rule and keeps the grammar change minimal:

```
function = INVERSE? IDENTIFIER LPAR arguments RPAR
```

### D4: `_identifierExcludedChars` entry for `~` is retained

`~` is already in `_identifierExcludedChars`.  The new `case '~':` branch in
`_scanToken` must appear before the generic "unknown character" error path.
No change to the exclusion set is required.

## Risks / Trade-offs

- **`hasInverse == false` error surface**: Any function that does not implement
  `evaluateInverse()` will throw at evaluation time, not parse time.  This is
  acceptable — the parser cannot know `hasInverse` without a repo, and
  parse-time validation would require coupling the parser to the function
  registry.  The error message from `callInverse()` already names the function.

- **`logB` sugar**: The `logB(x)` production desugars to a `BinaryOpNode`
  wrapping two `FunctionNode("ln", …)` nodes, bypassing `FunctionNode` with a
  function name directly.  `~logB(x)` will therefore produce a parse error
  (identifier `logB` not in function registry).  This is harmless because `log`
  is a `BuiltinFunction` with `hasInverse == false`, so `~log(x)` would fail at
  evaluation time anyway.

## Open Questions

- None at this time.
