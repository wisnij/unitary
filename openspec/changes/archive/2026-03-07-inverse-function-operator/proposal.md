## Why

The expression evaluator supports calling functions but has no way to invoke
their inverses, forcing users to manually compute reverse conversions.  Adding a
`~` prefix operator allows expressions like `~tempF(300 K)` to call `callInverse`,
making invertible functions (e.g. affine temperature units, piecewise-linear
interpolation tables) usable in both directions.

## What Changes

- Add `~` as a new lexer token type `INVERSE`
- Update the `function` production to `INVERSE? IDENTIFIER LPAR arguments RPAR`
- Add `inverse: bool` field to `FunctionNode` (default `false`)
- `FunctionNode.evaluate()` calls `func.callInverse()` when `inverse` is `true`

## Capabilities

### New Capabilities

- `inverse-function-operator`: Lexer token, parser grammar production, and AST
  node support for invoking a function's inverse via the `~` prefix operator

### Modified Capabilities

- `function-class`: `callInverse()` is already specified; no requirement changes
- `function-registry`: No requirement changes

## Impact

- `lib/core/domain/models/lexer.dart` — new `INVERSE` token type and `~` scanning
- `lib/core/domain/models/parser.dart` — updated `function` production
- `lib/core/domain/models/ast.dart` — `FunctionNode.inverse` field and dispatch
- Test files for lexer, parser, evaluator, and AST
