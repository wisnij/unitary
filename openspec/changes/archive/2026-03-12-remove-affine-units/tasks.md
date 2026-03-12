## 1. Remove core model code

- [x] 1.1 Remove `AffineUnit` class from `lib/core/domain/models/unit.dart`
- [x] 1.2 Remove `bool get isAffine => false` getter from the `Unit` base class in the same file

## 2. Remove AST and parser code

- [x] 2.1 Remove `AffineUnitNode` class from `lib/core/domain/parser/ast.dart`
- [x] 2.2 Remove the affine unit parsing block (the `if (_repo != null) { final unit = ...; if (unit != null && unit.isAffine) ... }` block) from `lib/core/domain/parser/parser.dart`

## 3. Remove codegen tool code

- [x] 3.1 Remove `_emitAffine()` function from `tool/generate_predefined_units_lib.dart`
- [x] 3.2 Remove `case 'affine': _emitAffine(...)` from the type dispatcher in the same file

## 4. Remove tests

- [x] 4.1 Remove the skipped "Parser: affine unit syntax (with repo)" test group from `test/core/domain/parser/parser_test.dart` (keep the non-affine tests in that group: "5 N with repo", "5e3 still parses as 5000.0 with repo")
- [x] 4.2 Remove the skipped affine evaluation tests from `test/core/domain/parser/evaluator_test.dart`
- [x] 4.3 Remove affine codegen tests from `test/tool/generate_predefined_units_lib_test.dart` (the "affine unit emission" group and the "supplementary affine entry preserved" test)

## 5. Update documentation

- [x] 5.1 Remove the affine-specific syntax rules, examples, and design rationale sections from `doc/quantity_arithmetic_design.md`
- [x] 5.2 Remove affine mentions from `doc/design_progress.md` (design decisions note, Phase 3 completion summary, unit type list)
- [x] 5.3 Remove affine mentions from `doc/implementation_plan.md` (Phase 3 task list and design_progress notes)
- [x] 5.4 Remove affine mention from `doc/architecture.md`
- [x] 5.5 Remove affine mention from `lib/core/domain/data/README.md`

## 6. Verify

- [x] 6.1 Run `flutter analyze` — confirm zero warnings/errors
- [x] 6.2 Run `flutter test --reporter failures-only` — confirm all tests pass
