## Why

Build-time data files — GNU Units source files and the JSON pipeline artifacts —
are currently scattered across `tool/gnu_units/` and `lib/core/domain/data/`,
mixing non-Dart data with Dart source.  Consolidating them under `assets/units/`
matches the project's existing asset conventions and makes the data pipeline's
inputs/outputs easier to locate.

## What Changes

- Move `tool/gnu_units/*.units` (and associated `LICENSE.md` / `README.md`) to
  `assets/units/`
- Move `lib/core/domain/data/units-parsed.json`, `units-supplementary.json`, and
  `units.json` to `assets/units/`
- Update `tool/import_gnu_units.dart` to read from and write to the new paths
- Update `tool/generate_predefined_units.dart` to read from and write to the new
  paths
- Update `lib/core/domain/data/README.md` (or relocate it) to reflect the new
  layout
- Update any path references in tests under `test/tool/`

Dart source files (`predefined_units.dart`, `builtin_functions.dart`) remain in
`lib/core/domain/data/` unchanged.

## Capabilities

### New Capabilities

- `gnu-units-pipeline-files`: Documents the authoritative locations for all
  GNU Units source files and JSON pipeline artifacts used by the import/codegen
  toolchain.

### Modified Capabilities

None — no runtime behavior, API contracts, or user-visible specs change.

## Impact

- **Tool scripts**: `tool/import_gnu_units.dart`, `tool/generate_predefined_units.dart`
  — path constants updated
- **Data files**: `lib/core/domain/data/README.md` updated; `units*.json` removed from
  that directory
- **Tool tests**: any path literals in `test/tool/` pointing to the old locations
- **`pubspec.yaml`**: asset declarations may need updating if any JSON files are
  declared (currently only `LICENSE.md` is declared; the `.units` and JSON files
  are codegen-time artifacts, not runtime assets, so no new Flutter asset
  declarations are required)
- **No runtime behavior change**: `predefined_units.dart` is generated at
  codegen time; the app never loads the JSON files at runtime
