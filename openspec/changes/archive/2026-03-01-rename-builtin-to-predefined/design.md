## Context

Two unrelated concepts in the codebase both use the word "builtin":

1. **Math functions** — `sin`, `cos`, `sqrt`, etc., resolved by `_evaluateBuiltin`
   and tracked in `_builtinFunctions` / `isBuiltinFunction`.
2. **Predefined unit definitions** — the units shipped with the app, stored in
   `builtin_units.dart`, loaded via `registerBuiltinUnits()` and
   `UnitRepository.withBuiltinUnits()`.

The overlap causes confusion when reading code: a reference to "builtin" could
mean either concept.  This change renames only the unit-related identifiers to
"predefined", leaving the math-function identifiers untouched.

## Goals / Non-Goals

**Goals:**
- Rename five files (source, tool, test) from `*_builtin_units*` to
  `*_predefined_units*`
- Rename `registerBuiltinUnits` → `registerPredefinedUnits` and
  `UnitRepository.withBuiltinUnits` → `UnitRepository.withPredefinedUnits`
- Update all imports, call sites, comments, and documentation that reference
  the above identifiers

**Non-Goals:**
- Renaming math-function identifiers (`isBuiltinFunction`, `_builtinFunctions`,
  `_evaluateBuiltin`) — those are clear and unambiguous as-is
- Changing behaviour, interfaces, or test assertions (except identifier names)
- Updating archived OpenSpec change docs (historical artefacts, left as-is)

## Decisions

**Rename files and identifiers in one commit.**  Because all callers are
internal, there is no deprecation period needed.  A single atomic commit avoids
a window where old and new names coexist and tests break.

**Use `dart rename` / manual search-and-replace.**  Dart has no built-in
refactoring CLI, so the rename is done by renaming the files then doing a
targeted find-and-replace across the affected paths.  The scope is small and
well-bounded, making manual replacement safe.

**Update the codegen comment inside `predefined_units.dart`.**  The generated
file contains a `// Run dart run tool/generate_builtin_units.dart ...` comment;
it must be updated to reference `generate_predefined_units.dart` so developers
know how to regenerate the file.

## Risks / Trade-offs

[Import paths break until all references are updated] → Apply the rename
atomically: rename the file, then update all imports in the same pass before
running tests.

[Missed reference in docs or a comment] → After renaming, do a final grep for
`builtin_units`, `registerBuiltinUnits`, and `withBuiltinUnits` across the
entire repo to catch any stragglers.
