## Why

During early phases, evaluating an unrecognized unit identifier silently fell back to treating it as a raw primitive dimension (e.g., `5 wakalixes` → `Quantity(5.0, {'wakalixes': 1})`). This made expression debugging easier when the unit database was incomplete. Now that the full GNU Units database has been imported (Phase 5), this fallback masks user typos and misspelled unit names that should be surfaced as errors.

## What Changes

- When a unit name is not found in the unit repository during expression evaluation, throw an `EvalException` instead of returning a raw dimension.
- **BREAKING**: Expressions containing unrecognized unit names now produce an error instead of a dimensioned result. (Previously, `5 wakalixes` would yield a value; now it raises `EvalException("Unknown unit: \"wakalixes\"")`.)
- Update the `UnitNode` doc comment to remove mention of the raw-dimension fallback.
- Update the evaluator test that asserted fallback behavior to instead assert that an error is thrown.

The `repo == null` path (used in parser-isolation tests) is unchanged — it remains a no-unit-resolution mode for internal testing.

## Capabilities

### New Capabilities
- `unknown-unit-error`: Evaluating an expression with an unrecognized unit name raises a user-visible error.

### Modified Capabilities
- `parser-error-messages`: The set of conditions that produce an `EvalException` now includes unknown unit names.

## Impact

- `lib/core/domain/parser/ast.dart` — `UnitNode.evaluate()`: single-line change to throw instead of return
- `test/core/domain/parser/evaluator_test.dart` — update one test
- `test/core/domain/data/builtin_units_test.dart` — may need comment updates in `_knownEvalFailures` if any entries now fail for a different reason
- UI: no changes needed; `freeform_provider` already handles `EvalException` as a user-visible error message
