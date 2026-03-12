## Why

Affine units (`AffineUnit`, `AffineUnitNode`) were an earlier approach to
handling offset-based conversions (e.g., temperature scales).  Now that
defined functions are fully implemented and all temperature units are expressed
as GNU Units-defined functions, the affine code path is entirely dead — no
affine units are registered, and the parser branch that handled them is never
reached.  Removing this dead code reduces complexity and eliminates a
confusing, partially-implemented abstraction.

## What Changes

- Remove `AffineUnit` class and `Unit.isAffine` getter from
  `lib/core/domain/models/unit.dart`
- Remove `AffineUnitNode` class from `lib/core/domain/parser/ast.dart`
- Remove affine unit parsing block from `lib/core/domain/parser/parser.dart`
- Remove `_emitAffine()` function and `case 'affine'` dispatch from
  `tool/generate_predefined_units_lib.dart`
- Remove all skipped and affine-related tests from `parser_test.dart`,
  `evaluator_test.dart`, and `test/tool/generate_predefined_units_lib_test.dart`
- Remove affine-specific documentation from `doc/quantity_arithmetic_design.md`,
  `doc/design_progress.md`, `doc/implementation_plan.md`, `doc/architecture.md`,
  and `lib/core/domain/data/README.md`

## Capabilities

### New Capabilities

_(none — this is a pure removal refactor)_

### Modified Capabilities

_(none — affine units were never a user-visible, spec-level feature)_

## Impact

- **`lib/core/domain/models/unit.dart`**: Remove `AffineUnit` class and
  `isAffine` getter
- **`lib/core/domain/parser/ast.dart`**: Remove `AffineUnitNode` class
- **`lib/core/domain/parser/parser.dart`**: Remove affine unit parsing block
- **`tool/generate_predefined_units_lib.dart`**: Remove `_emitAffine()` and
  the `'affine'` case in the type dispatcher
- **Tests**: Remove skipped affine tests and affine codegen tests
- **Documentation**: Remove affine-specific sections from design and progress
  docs; update unit type lists where affine appears
- No user-visible behavior changes; no API changes
