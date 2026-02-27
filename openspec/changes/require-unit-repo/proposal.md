## Why

`EvalContext.repo` is currently nullable, preserving a "Phase 1" fallback where any unrecognized identifier silently becomes a raw dimension. With the full unit database in place and unknown units now surfaced as errors (see change `unknown-unit-error`), there is no longer a valid reason to evaluate expressions without a repository — the null path is a dead code path in production. Eliminating it removes a special-case branch from the evaluator, makes `EvalContext` and `ExpressionParser` simpler, and prevents accidental no-repo usage from going undetected.

## What Changes

- **BREAKING**: `EvalContext.repo` changes from `UnitRepository?` to `UnitRepository` (non-nullable). All callers must provide a repository.
- **BREAKING**: `ExpressionParser({UnitRepository? repo, ...})` → `ExpressionParser({required UnitRepository repo, ...})`. The no-arg constructor is removed.
- Remove the `if (repo == null)` branch from `UnitNode.evaluate()`, leaving a single evaluation path.
- Add a `UnitRepository.passthrough()` factory (or test-only subclass) that returns a fresh `PrimitiveUnit` for any name, to replace the null-repo behavior in parser-isolation tests.
- Update all test helpers (`eval()`, `evalWithRepo()`) and test cases that currently use `ExpressionParser()` without a repo to use the passthrough repository.
- Update `EvalContext` doc comment to remove references to Phase 1 / null-repo mode.

## Capabilities

### New Capabilities
- `passthrough-unit-repo`: A test-utility `UnitRepository` variant that accepts any identifier and returns a synthetic `PrimitiveUnit`, used to exercise the evaluator without a real unit database.

### Modified Capabilities
- `unknown-unit-error`: The `repo == null` → raw-dimension path no longer exists; unknown units always throw (unless the caller explicitly uses the passthrough repo).

## Impact

- `lib/core/domain/parser/ast.dart` — `EvalContext`, `UnitNode.evaluate()`
- `lib/core/domain/parser/parser.dart` — `ExpressionParser` constructor and `evaluate()`
- `lib/core/domain/services/unit_resolver.dart` — `resolveUnit()` call to `ExpressionParser`
- `test/core/domain/parser/evaluator_test.dart` — `eval()` helper and tests relying on null-repo behavior
- `test/core/domain/parser/expression_parser_test.dart` — no-arg `ExpressionParser()` usages
- New test utility: `test/helpers/passthrough_unit_repository.dart` (or similar)
- Dependency: this change should be sequenced **after** `unknown-unit-error` is implemented and merged.
