## 1. Rename Source Files

- [x] 1.1 Rename `lib/core/domain/data/builtin_units.dart` → `predefined_units.dart`
- [x] 1.2 Rename `tool/generate_builtin_units_lib.dart` → `generate_predefined_units_lib.dart`
- [x] 1.3 Rename `tool/generate_builtin_units.dart` → `generate_predefined_units.dart`

## 2. Rename Test Files

- [x] 2.1 Rename `test/core/domain/data/builtin_units_test.dart` → `predefined_units_test.dart`
- [x] 2.2 Rename `test/tool/generate_builtin_units_lib_test.dart` → `generate_predefined_units_lib_test.dart`

## 3. Update Identifiers

- [x] 3.1 Rename factory `UnitRepository.withBuiltinUnits()` → `withPredefinedUnits()` in `unit_repository.dart`
- [x] 3.2 Rename `registerBuiltinUnits()` → `registerPredefinedUnits()` in `predefined_units.dart` and `generate_predefined_units_lib.dart`
- [x] 3.3 Update all call sites of `withBuiltinUnits()` and `registerBuiltinUnits()` across `lib/`, `test/`, and `tool/`

## 4. Update Imports and Internal References

- [x] 4.1 Update all `import` statements that reference `builtin_units.dart` → `predefined_units.dart`
- [x] 4.2 Update all `import` statements that reference `generate_builtin_units_lib.dart` → `generate_predefined_units_lib.dart`
- [x] 4.3 Update the output file path string in `generate_predefined_units.dart` (`builtin_units.dart` → `predefined_units.dart`)
- [x] 4.4 Update the `// Run dart run tool/generate_builtin_units.dart` regeneration comment inside `predefined_units.dart`
- [x] 4.5 Update the `includes('void registerBuiltinUnits')` string assertion in `generate_predefined_units_lib_test.dart`

## 5. Update Documentation

- [x] 5.1 Update `lib/core/domain/data/README.md` references
- [x] 5.2 Update references in `doc/` files (`architecture.md`, `phase2_plan.md`, `phase4_plan.md`, `dimensionless_units_design.md`, `design_progress.md`, `implementation_plan.md`)

## 6. Verify

- [x] 6.1 Grep for remaining `builtin_units`, `registerBuiltinUnits`, `withBuiltinUnits` to confirm no stragglers
- [x] 6.2 Run `dart analyze` and confirm no errors
- [x] 6.3 Run `flutter test --reporter failures-only` and confirm all tests pass
