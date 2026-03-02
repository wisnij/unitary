## Why

The term "builtin" is ambiguous in this codebase: it describes both the
pre-defined math functions (`sin`, `cos`, etc.) and the pre-shipped unit
definitions.  Renaming the unit-related identifiers to "predefined" makes the
distinction clear and better communicates that these units ship with the app
(not that they are primitives baked into a language runtime).

## What Changes

- Rename file `lib/core/domain/data/builtin_units.dart` → `predefined_units.dart`
- Rename file `tool/generate_builtin_units.dart` → `generate_predefined_units.dart`
- Rename file `tool/generate_builtin_units_lib.dart` → `generate_predefined_units_lib.dart`
- Rename file `test/core/domain/data/builtin_units_test.dart` → `predefined_units_test.dart`
- Rename file `test/tool/generate_builtin_units_lib_test.dart` → `generate_predefined_units_lib_test.dart`
- Rename function `registerBuiltinUnits()` → `registerPredefinedUnits()`
- Rename factory `UnitRepository.withBuiltinUnits()` → `UnitRepository.withPredefinedUnits()`
- Update all call sites, imports, and comments that reference the above

**Not renamed:** `isBuiltinFunction`, `_builtinFunctions`, `_evaluateBuiltin` — these
refer to built-in math functions (`sin`, `cos`, `sqrt`, etc.) and are unambiguous.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None.  This is a pure rename; no external behaviour or requirements change.

## Impact

- **Source files:** `lib/core/domain/data/`, `lib/core/domain/models/`,
  `lib/features/freeform/state/`, `tool/`
- **Test files:** `test/core/domain/data/`, `test/core/domain/parser/`,
  `test/core/domain/services/`, `test/tool/`
- **Documentation:** `doc/` files that mention `builtin_units.dart`,
  `registerBuiltinUnits`, or `withBuiltinUnits`; `lib/core/domain/data/README.md`
- **Codegen output:** The regeneration comment inside `predefined_units.dart`
  must reference the new tool name
- **No API changes:** All callers are internal; no public API is affected
