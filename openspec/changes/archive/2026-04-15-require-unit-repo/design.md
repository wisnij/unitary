## Context

After `unknown-unit-error` is applied, the only remaining use of `EvalContext.repo == null` is a legacy "Phase 1" mode in parser-isolation tests. In production, `ExpressionParser` is always constructed with a real `UnitRepository`. The nullable `repo` field exists solely as a historical artifact; eliminating it simplifies `UnitNode.evaluate()` to a single code path and makes it impossible to accidentally construct an evaluator without unit resolution.

**Current state** (post `unknown-unit-error`):
- `EvalContext.repo` is `UnitRepository?`
- `UnitNode.evaluate()` has two branches: null-repo → raw dimension, non-null → repo lookup + throw on miss
- `ExpressionParser` has an optional `repo` parameter; the no-arg form is used in ~5 evaluator tests

## Goals / Non-Goals

**Goals:**
- Make `EvalContext.repo` and `ExpressionParser.repo` non-nullable (required)
- Remove the `if (repo == null)` branch from `UnitNode.evaluate()`
- Provide a `PassthroughUnitRepository` test utility that returns a synthetic `PrimitiveUnit` for any identifier, preserving the observable behavior of the old null-repo path in tests that need it
- Update all affected test helpers and test cases

**Non-Goals:**
- Changing how `findUnit`, `findUnitWithPrefix`, or `resolveUnit` work
- Removing `PassthroughUnitRepository` after this change — it is a legitimate test utility
- Modifying the freeform UI or settings

## Decisions

### `PassthroughUnitRepository` as a concrete subclass in `test/helpers/`
**Decision**: Create `test/helpers/passthrough_unit_repository.dart` containing a `PassthroughUnitRepository` class that extends `UnitRepository` and overrides `findUnit` and `findUnitWithPrefix` to return a `PrimitiveUnit` synthesized from the lookup name.

**Rationale**: Dart has no built-in mocking framework in `flutter_test`. A hand-written subclass is idiomatic, zero-dependency, and explicit about its contract. Placing it in `test/helpers/` makes it reusable across test files without adding production dependencies.

**Alternative considered**: Add a `UnitRepository.passthrough()` factory to production code — rejected because this is test infrastructure and does not belong in `lib/`.

**Alternative considered**: Use `mockito` or `mocktail` — rejected to avoid new dependencies.

### `ExpressionParser` constructor change
**Decision**: Make `repo` a required named parameter: `ExpressionParser({required UnitRepository repo, ...})`.

**Rationale**: The only callers that currently pass no `repo` are test helpers using Phase 1 mode, which will migrate to `PassthroughUnitRepository`. Making it required prevents future accidental no-repo construction.

**Note**: `resolveUnit()` in `unit_resolver.dart` already always passes `repo` to `ExpressionParser`, so it is unaffected.

### `EvalContext.repo` change
**Decision**: Change `final UnitRepository? repo` to `final UnitRepository repo` in `EvalContext`, and remove the `repo` default from the `const` constructor.

**Rationale**: Follows from making `ExpressionParser` require a repo; `EvalContext` is constructed only inside `ExpressionParser.evaluate()`.

## Risks / Trade-offs

- **Risk**: Tests that test pure arithmetic (no unit identifiers) currently use `eval('5 + 3')` via a no-repo helper. After this change, `eval()` must use `PassthroughUnitRepository`. Pure arithmetic expressions don't look up any identifiers, so `PassthroughUnitRepository` is never consulted — behavior is unchanged, but the test setup is slightly heavier. → **Mitigation**: Update the `eval()` helper to inject `PassthroughUnitRepository` by default; individual test cases need no changes.
- **Risk**: `EvalContext` is constructed with `const EvalContext()` in some tests. Making `repo` required breaks `const` construction. → **Mitigation**: Update those sites to pass `PassthroughUnitRepository()`; remove the `const` qualifier where needed.

## Migration Plan

1. Implement `PassthroughUnitRepository` in `test/helpers/`
2. Update `EvalContext` (make `repo` non-nullable)
3. Update `ExpressionParser` constructor (make `repo` required)
4. Remove the `if (repo == null)` branch from `UnitNode.evaluate()`
5. Update test helpers (`eval()`) to use `PassthroughUnitRepository`
6. Update any remaining test sites that construct `EvalContext` or `ExpressionParser` directly
7. Delete the "null repo preserves Phase 1 behavior" test; replace with a `PassthroughUnitRepository` equivalent if the scenario still has value
8. Run full test suite to confirm no regressions
