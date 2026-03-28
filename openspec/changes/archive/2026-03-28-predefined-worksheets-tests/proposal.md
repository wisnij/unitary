## Why

The predefined worksheet tests hard-code which rows are `UnitRow` vs `FunctionRow`
by name, and either skip or only partially verify ordering, making them brittle
when templates change.  The unit/function registry already knows which expressions
are functions and which are units; the tests should derive expected kinds from it
rather than asserting by rote.

## What Changes

- Add a cross-template test that calls `parseQuery(row.expression)` for every row in
  every predefined template and asserts the returned node type is consistent with
  `row.kind` (`FunctionNameNode` → `FunctionRow`; `DefinitionRequestNode` or
  `ExpressionNode` → `UnitRow`).
- Add a cross-template test that, for any template whose rows are all `UnitRow`,
  verifies they are sorted smallest-to-largest by evaluating each expression with
  the parser and comparing `Quantity.value`; equal-magnitude rows break ties by
  expression string (lexicographic).
- Every template group SHALL have exactly one `containsAll` test covering all of
  its intended expressions.  Current gaps and fixes:
  - **Mass**: expand the partial `containsAll` (currently 3 expressions) to all 10.
  - **Speed**: expand the partial `containsAll` (currently 7 expressions) to all 10.
  - **Temperature**: replace the 6 individual per-row kind tests with a single
    `containsAll` over all 6 expressions.  Kind correctness is covered by the
    cross-template test.
  - **Energy**: replace the individual `contains('Wh')` check with a `containsAll`
    over all 10 expressions.
  - **Area**: replace the two individual `contains` checks with a `containsAll`
    over all 10 expressions.
  - **Pressure**, **Volume**: add a `containsAll` over all 10 expressions (currently
    have no expression checks).
  - **Length**, **Time**, **Digital Storage**: already have full `containsAll` — no
    change needed.

## Capabilities

### New Capabilities

*(none — this is a test-only change)*

### Modified Capabilities

*(none — existing spec requirements are unchanged; tests are improved to verify
them more precisely)*

## Impact

- `test/features/worksheet/data/predefined_worksheets_test.dart` — primary change
- Tests will need an `ExpressionParser` built with `UnitRepository.withPredefinedUnits()`
  and access to the `FunctionNameNode` / `DefinitionRequestNode` AST node types
