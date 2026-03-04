## Why

GNU Units supports `logB(x)` as shorthand for `log(x)/log(B)` where B is any
integer greater than 1, enabling natural expressions like `log2(65536)` or
`log8(512)`.  Adding this allows users to compute logarithms in any integer base
without workarounds, and makes `log10` and `log2` redundant as explicit aliases.

## What Changes

- The parser SHALL recognize `log` followed immediately by an integer suffix ≥ 2
  (e.g. `log2`, `log10`, `log256`) as a function call that evaluates
  `log(x)/log(B)`, mirroring the existing trailing-exponent logic in
  `Parser._identifierOrFunction`.
- `log(x)` with no suffix continues to mean base-10 logarithm (unchanged).
- The `log10` alias on the `log` builtin SHALL be removed (covered by `log10(x)`).
- The `log2` builtin function (if present) SHALL be removed (covered by `log2(x)`).
- No new `UnitaryFunction` subclass is introduced; the parser synthesises the
  expression `log(x)/log(B)` directly as an AST node (a `BinaryOpNode` dividing
  two `FunctionNode`s), analogous to how trailing-exponent units are synthesised.

## Capabilities

### New Capabilities

- `log-n-function`: Parser recognition of `logB(x)` syntax and its evaluation
  as `log(x)/log(B)` for any integer B ≥ 2.

### Modified Capabilities

- `function-class`: Remove `log10` alias from the `log` `BuiltinFunction`
  definition (requirement table update).
- `function-registry`: Remove any requirement or scenario that references `log2`
  or `log10` as registered names; update the "all builtins registered" scenario
  to omit those names.

## Impact

- `lib/core/domain/data/builtin_functions.dart` — remove `log10` alias from
  `log` definition; remove `log2` builtin if present.
- `lib/core/domain/parser.dart` — add `logB` suffix parsing in
  `_identifierOrFunction`, building a synthetic `BinaryOpNode` AST.
- `test/core/domain/` — new tests for `logB` parsing and evaluation; update
  existing tests that reference `log10`/`log2` as registered names or direct
  calls.
