## Context

`UnitNode.evaluate()` in `lib/core/domain/parser/ast.dart` handles the case where `repo.findUnitWithPrefix(unitName)` returns no match. Currently it falls back to `Quantity(1.0, Dimension({unitName: 1}))` — a raw primitive dimension with the identifier as its sole key. This was intentional during early phases to allow expression-level debugging before the unit database existed. Phase 5 is complete; the fallback now hides user errors.

There are two distinct null-repo paths:
1. `repo == null` — the "Phase 1 / parser-isolation" mode where no repository is provided at all. Identifiers always become raw dimensions. Used in parser/evaluator tests that don't need unit resolution.
2. `repo != null && unit not found` — a real lookup failure. This is the path that changes.

## Goals / Non-Goals

**Goals:**
- When a unit name is not found in a provided repository, throw `EvalException` so the error is visible to the user.
- Keep the `repo == null` path unchanged (raw-dimension fallback preserved for parser-isolation testing).
- Preserve the `EvalException` propagation path through `freeform_provider` so the error appears as a UI error message with no further changes needed.

**Non-Goals:**
- Changing how `AffineUnitNode`, `reduce()`, or `resolveUnit()` handle inputs.
- Changing `UnitRepository.findUnitWithPrefix()` or `findUnit()` return signatures.
- Adding any new error types; `EvalException` is already the correct type for evaluation-time errors.

## Decisions

### Throw `EvalException` with the unit name in the message
**Decision**: `throw EvalException('Unknown unit: "$unitName"')`

**Rationale**: `EvalException` is already the type used for all evaluation-time failures (dimension mismatch, circular reference, etc.). It propagates through `ExpressionParser.evaluate()` and is caught by `freeform_provider`'s `on UnitaryException` handler with no extra wiring needed. The message includes the unit name so users can see exactly what they misspelled.

**Alternative considered**: A new `UnknownUnitException` subclass — rejected because it adds a type for no benefit; callers already catch the parent `UnitaryException` or `EvalException`.

### Change is in `UnitNode.evaluate()`, not in `findUnitWithPrefix()`
**Decision**: The throw happens in `ast.dart` after the repo lookup returns null, not inside `UnitRepository`.

**Rationale**: `findUnitWithPrefix()` returning null is a valid signal (e.g., callers may want to probe membership without an error). The semantic "this is an error" belongs at the evaluation layer.

## Risks / Trade-offs

- **Risk**: Some units in `builtin_units_dart` might have definitions that reference another unit whose name was previously silently falling back to a raw dimension. → **Mitigation**: The regression test in `builtin_units_test.dart` (`_knownEvalFailures` / `Evaluation` group) will detect any new failures immediately. If any surface, investigate whether the referenced name is a missing alias or a genuine unsupported unit, and fix the definition or add to `_knownEvalFailures`.
- **Trade-off**: The `repo == null` path continues to produce raw dimensions, which means `ExpressionParser()` (no repo) still silently accepts nonsense identifiers. Acceptable because this mode is only used internally in test helpers, not in the production app.
