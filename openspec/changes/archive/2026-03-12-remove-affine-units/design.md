## Context

Affine units were implemented in Phase 3 as the mechanism for handling
offset-based unit conversions (temperature scales).  They required special
parser handling: `tempF(212)` was parsed as an `AffineUnitNode`, distinct from
a regular function call or unit application.

Since then, defined functions have been implemented and the GNU Units import
pipeline generates `DefinedFunction` instances for temperature conversions
(`tempC`, `tempF`, `tempK`, `tempR`).  The `AffineUnit` and `AffineUnitNode`
code paths are now completely unreachable: no affine units are registered,
and the parser block that checks `unit.isAffine` never matches.

The goal of this change is to delete all of that dead code.

## Goals / Non-Goals

**Goals:**

- Remove `AffineUnit` class and `Unit.isAffine` getter
- Remove `AffineUnitNode` AST node class
- Remove the affine unit parser branch
- Remove `_emitAffine()` and `case 'affine'` from the codegen tool
- Remove all affine-related tests (all are already skipped)
- Remove affine documentation from design and progress docs

**Non-Goals:**

- Changing temperature conversion behavior (already handled by defined functions)
- Modifying the defined-function or parser infrastructure beyond removing affine code
- Updating `units.json` or `predefined_units.dart` (no affine entries exist)

## Decisions

**Delete, don't deprecate.**  Since no affine units are registered and the
code is entirely unreachable, there is no migration concern.  Deprecation
markers would be noise; straight deletion is correct.

**Remove skipped tests entirely.**  The skipped tests in `parser_test.dart`
and `evaluator_test.dart` tested behaviour that no longer exists.  Removing
them is cleaner than leaving permanently-skipped dead tests.

**No codegen re-run needed.**  `predefined_units.dart` and `units.json`
contain no affine entries, so regenerating them is not required as part of
this change.  Removing the `_emitAffine` handler is safe; if the importer
were ever to encounter an `affine` type entry in the future (it won't), it
would emit a warning rather than silently producing broken code.

**Documentation: remove sections, keep historical context minimal.**
Sections in `quantity_arithmetic_design.md` and `design_progress.md` that
describe affine syntax and design rationale should be removed.  Brief mention
in commit history is sufficient; no stub "removed" comments needed.

## Risks / Trade-offs

**Risk:** A unit in `units-supplementary.json` could be of type `affine`
that was overlooked → will be caught by existing unit evaluation regression
test (`predefined_units_test.dart`) which iterates all registered units.

**Risk:** Removing the `isAffine` getter could break a callsite that wasn't
found in the search → mitigated by `dart analyze` / compilation errors caught
before tests run.

## Migration Plan

No runtime migration needed.  This is a compile-time-only removal.

Steps:
1. Delete affine code from `unit.dart`, `ast.dart`, `parser.dart`
2. Delete affine codegen from `generate_predefined_units_lib.dart`
3. Remove affine tests from test files
4. Update documentation files
5. Run `flutter analyze` and `flutter test` to verify clean state
