## Context

The unit database pipeline consists of two developer-run tools:

1. `tool/import_gnu_units.dart` — reads `tool/gnu_units/definitions.units` and
   writes `lib/core/domain/data/units-parsed.json`
2. `tool/generate_predefined_units.dart` — reads
   `lib/core/domain/data/units-parsed.json` and
   `lib/core/domain/data/units-supplementary.json`, merges them into
   `lib/core/domain/data/units.json`, and generates
   `lib/core/domain/data/predefined_units.dart`

The GNU Units `.units` source files live in `tool/gnu_units/` and the JSON
pipeline artifacts (`units-parsed.json`, `units-supplementary.json`,
`units.json`) live alongside generated Dart source in `lib/core/domain/data/`.
This mixes data files with Dart source code and splits the pipeline's data
across two unrelated directories.

The project already has an `assets/units/` directory (currently empty).

## Goals / Non-Goals

**Goals:**

- Consolidate all non-Dart data files for the pipeline under `assets/units/`
- Keep generated Dart source (`predefined_units.dart`, `builtin_functions.dart`)
  in `lib/core/domain/data/` where it belongs
- Update tool scripts to reference the new paths
- Update documentation to reflect the new layout
- No change to the pipeline's logic or output

**Non-Goals:**

- Changing the pipeline logic, merge algorithm, or code generation
- Declaring any of these files as Flutter runtime assets in `pubspec.yaml`
  (they are codegen-time inputs/outputs only, not loaded at app runtime)
- Moving Dart source files

## Decisions

### Decision: Move `.units` source files to `assets/units/` (flat)

The GNU Units source files (`definitions.units`, `cpi.units`, `currency.units`,
`elements.units`) and their associated metadata (`LICENSE.md`, `README.md`)
move from `tool/gnu_units/` to `assets/units/`.

**Rationale:** `tool/` is for Dart tool scripts; data files that those scripts
consume belong in `assets/`.  Placing them directly in `assets/units/` (rather
than a nested `assets/units/gnu_units/` subdirectory) keeps the path simple and
consistent with the other files in that directory.

**Alternative considered:** `assets/units/gnu_units/` subdirectory.  Rejected
because the added nesting provides no organizational benefit — all files in
`assets/units/` are pipeline data and there is no ambiguity.

### Decision: Move JSON pipeline artifacts to `assets/units/`

`units-parsed.json`, `units-supplementary.json`, and `units.json` move from
`lib/core/domain/data/` to `assets/units/`.

**Rationale:** These are data files consumed and produced by developer tools,
not Dart source code.  Their presence in `lib/` is misleading.

### Decision: Do NOT add Flutter asset declarations for the moved files

The `.units` and JSON files are never loaded by the Flutter app at runtime.
They are only read/written by `dart run tool/*.dart` commands.  Adding them to
`pubspec.yaml`'s asset list would bundle them into the app binary unnecessarily.

### Decision: Update path constants in tool scripts, not make them configurable

The tool scripts use hardcoded path strings relative to the repo root.
These will be updated to point to `assets/units/`.  Making the paths
configurable (via CLI flags) is out of scope and adds complexity without
clear benefit.

## Risks / Trade-offs

**[Risk] Developer muscle memory for old paths** → Mitigation: Update all
documentation (README, data-dir README, pipeline diagram) and keep the
`lib/core/domain/data/README.md` with a forwarding note pointing to
`assets/units/` for at least one release cycle.

**[Risk] Tool tests that hardcode old paths fail** → Mitigation: The tasks
include auditing `test/tool/` for path references and updating them.

**[Risk] `git mv` losing blame history on the JSON files** → Acceptable; these
are generated/machine-maintained files with no meaningful commit-by-commit
history to preserve.

## Migration Plan

1. `git mv tool/gnu_units/* assets/units/` (moves `.units` files and metadata)
2. `git mv lib/core/domain/data/units*.json assets/units/`
3. Update path constants in `tool/import_gnu_units.dart`
4. Update path constants in `tool/generate_predefined_units.dart`
5. Update path references in `test/tool/` tests
6. Update `lib/core/domain/data/README.md` to document the new layout
7. Remove the now-empty `tool/gnu_units/` directory
8. Verify the full pipeline still runs end-to-end and tests pass

**Rollback:** Revert the commit.  No data loss because all moved files are
either checked in or regenerable.

## Open Questions

None.
