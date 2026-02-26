## Context

The current `lib/core/domain/data/builtin_units.dart` is hand-crafted Dart with
53 units across 10 categories. Phase 5 requires adding six new categories
(volume, area, speed, pressure, energy, digital storage) plus a new `bit`
information primitive. The GNU Units project provides a well-maintained,
authoritative database of unit definitions. Importing from it gives us
accuracy, coverage, and a repeatable process for future additions.

The pipeline has two independent tools with three JSON files as intermediates:

```
tool/gnu_units/definitions.units
          │
     [import_gnu_units]  →  units-parsed.json  (importer-owned only; generated)
                                    +
                         units-supplementary.json  (manually curated; checked in)
                                    │
                     [generate_builtin_units: mergeSupplementary]
                                    │
                               units.json  (merged; checked in for codegen)
                                    │
                               [codegen]
                                    │
                           builtin_units.dart
```

Both `units.json` and `builtin_units.dart` are **checked in**. This means:
- Reviewers can diff the generated Dart without running tools.
- A future CI lint step can verify the generated file is up to date.
- The app works offline at build time with no tool dependencies.

`units-supplementary.json` is also **checked in** as the canonical home for
all manually-curated data (descriptions, aliases, categories, affine
definitions). `units-parsed.json` is **not checked in**; it is regenerated on
each importer run.

## Goals / Non-Goals

**Goals:**

- Implement `import_gnu_units_lib.dart` + `import_gnu_units.dart` to parse GNU
  Units format and write importer-owned fields to `units-parsed.json`.
- Implement `generate_builtin_units_lib.dart` + `generate_builtin_units.dart` to
  read `units-parsed.json` and `units-supplementary.json`, merge them into
  `units.json`, and emit `builtin_units.dart` with `const` Dart objects.
- Create the initial `units-supplementary.json` covering all descriptions for
  existing units plus Phase 5 categories.
- Create the initial `units.json` (generated from the merge).
- Regenerate `builtin_units.dart` from `units.json`.
- Write unit tests for both tool libraries.

**Non-Goals:**

- Automated CI verification that the generated file is up to date (future work).
- Parsing every GNU Units feature (function units, multi-dimensional tables,
  `!set`, `!var` directives, etc.).
- Running the importer as part of the build.
- Currency or custom-unit categories (later phases).

## Decisions

### D1: JSON as the intermediate format

**Decision**: Use checked-in JSON files as the intermediates.

**Rationale**: JSON is human-readable, diff-friendly, and easily manipulated in
Dart. Splitting into a parsed file and a supplementary file keeps importer
output separate from manually-curated data, so neither accidentally clobbers
the other. A binary or generated-only approach would make manual annotation
painful.

**Alternative considered**: Generate Dart directly from the GNU Units file.
Rejected because it allows no manual curation and makes the affine-unit problem
(see D3) much harder.

### D2: File-level split between importer-owned and supplementary data

**Decision**: Separate the data into two files instead of mixing importer-owned
and pass-through fields in a single file:
- **`units-parsed.json`** — written by the importer on every run. Contains only
  importer-owned fields: `type`, `definition`, `gnuUnitsSource`, `source`, and
  type-specific fields (`isDimensionless`, `target`, `reason`). Never read by
  the importer; starts fresh each run. Not checked in.
- **`units-supplementary.json`** — maintained by hand. Contains manually-curated
  fields: `description`, `aliases`, `category`, affine parameters, and any
  other fields the importer cannot derive. Checked in.

The codegen tool merges the two files into `units.json` using
`mergeSupplementary()` before generating Dart. Supplementary fields win over
parsed fields on conflict; supplementary-only entries (such as affine
temperature units) are added as-is.

**Alternative considered**: A single `units.json` where the importer reads the
existing file and preserves pass-through fields on every re-run (the original
design). Rejected because it required the importer to understand which fields
were "owned" at field granularity, and created risk of accidental clobber when
the ownership rules were not followed exactly.

### D3: Affine temperature units in `units-supplementary.json`

**Decision**: Affine unit entries (`"type": "affine"` with fields `factor`,
`offset`, `baseUnitId`) live entirely in `units-supplementary.json`. The GNU
Units importer never sets `type: "affine"` — those lines are
`"unsupported"` in parsed output. The codegen emits `AffineUnit(...)` for
`"type": "affine"` entries regardless of which file they originated from.

**Alternative considered**: Keep a `_registerManualUnits()` section in the
generated Dart that the codegen doesn't touch. Rejected because it requires a
more complex partial-generation scheme and mixes generated and manual code.

### D4: Alias resolution strategy with namespace separation

**Decision**: GNU Units-sourced alias entries (`"type": "alias"`) are stored as
separate JSON objects keyed by alias id within their section (`"units"` or
`"prefixes"`). The codegen resolves alias chains at generation time within each
namespace independently, and folds each alias id into the canonical unit's
`aliases` list.

`resolveAliasChains()` returns a `(unitAliases, prefixAliases)` record, where
each map is `canonical_id -> [extra alias ids]` resolved exclusively within its
own namespace. This prevents cross-namespace collisions: `m` appears as meter
in the units namespace and as milli in the prefixes namespace, and the two must
never be confused.

For entries that list aliases directly in their `"aliases"` field (hand-crafted
or via supplementary), those are combined with alias-chain-resolved extras at
emit time, deduplicating to avoid double-registration.

### D5: Flat codegen structure (`_registerUnits` / `_registerPrefixes`)

**Decision**: The codegen emits exactly two private functions:
`_registerUnits(repo)` and `_registerPrefixes(repo)`, both called from
`registerBuiltinUnits(repo)`. All unit entries appear in `_registerUnits`;
all prefix entries appear in `_registerPrefixes`. There are no per-category
private functions.

**Rationale**: Category-based grouping (the original design) produced many small
`_register<Category>Units()` functions, adding complexity without benefit.
Since the generated file is not meant to be read directly by humans (it has a
do-not-edit header), flat structure is simpler to generate and maintain.

**Alternative considered**: One `_register<Category>Units()` function per
`"category"` value, mirroring the hand-crafted file structure. Rejected because
it required the generator to maintain a fixed category order and made the
codegen more complex with no user-visible benefit.

### D5b: Conditional directive evaluation

**Decision**: The importer evaluates conditional blocks (`!utf8`, `!locale`,
`!var`, `!varnot`) against a fixed set of effective settings:
`UNITS_SYSTEM=si`, `UNITS_ENGLISH=US`, UTF-8 enabled, locale `en_US`.

A condition stack tracks the current active state. Nested conditionals are
supported (a block is active only if all ancestor blocks are also active).
Non-definition directives (`!set`, `!message`, `!prompt`, `!include`) produce
no entries. `!include` is handled: when a `FileReader` callback is provided,
included files are parsed recursively and their logical lines spliced inline.

**Rationale**: The directives control locale- and system-specific unit
definitions. Our settings are fixed, so static evaluation at import time is
correct and avoids a runtime configuration surface.

### D5c: Two-pass alias detection

**Decision**: Alias detection uses a two-pass approach:
1. **First pass**: collect the complete set of all unit IDs and prefix IDs from
   the file (one pass over continued/joined lines, respecting active
   conditionals), maintaining separate sets for each namespace.
2. **Second pass**: classify each entry. A definition is a unit alias only if
   it is a single bare identifier AND that identifier appears in the unit ID
   set. A prefix-named entry (name ending in `-`) whose definition is a bare
   identifier in the prefix ID set (but not in the unit ID set) is a prefix
   alias.

**Rationale**: A definition like `kilometer` looks like a single identifier but
is NOT a registered unit ID — it is a prefix+unit compound. Without the
membership check, `kilometer` would be misclassified as an alias. Keeping unit
and prefix ID sets separate prevents cross-namespace alias misclassification
(e.g., `m-` meaning milli vs. `m` meaning meter).

### D6: `definition` field as the expression

**Decision**: Use the single field `"definition"` (matching the plan's schema)
for the expression text of derived, prefix, and alias units. The codegen reads
`entry['definition']` as the `expression:` value in generated Dart.

For supplementary entries the field is written manually (e.g.,
`"definition": "12 inch"`). For GNU Units-imported entries it holds the
verbatim text after the unit name on the source line (after comment stripping
and whitespace normalization).

### D7: Digital storage via a new `bit` primitive

**Decision**: Introduce `bit` as a new `PrimitiveUnit` (not dimensionless) with
category `"information"`. `byte` is derived from it. SI prefixes automatically
provide `kilobit`, `MB`, etc. (SI-decimal, 1000-based). IEC binary prefixes
automatically provide `kibibyte`, `MiB`, etc. (1024-based).

### D8: Supplementary merge semantics

**Decision**: `mergeSupplementary(parsed, supplementary)` applies a pure
recursive map merge (`recursiveMerge`). Maps are merged key-by-key; for any
other value type (string, number, boolean, list, null), the supplementary value
wins verbatim over the parsed value. There are no domain-specific rules or
field-type awareness.

**Rationale**: Keeping the merge purely structural makes it easy to reason
about and test. Any field in `units-supplementary.json` simply overrides the
corresponding field in `units-parsed.json`. This means supplementary can
override any importer-owned field (e.g., `type`) if needed — intentional for
cases like adding affine temperature units that the importer marks as
`"unsupported"`.

## Risks / Trade-offs

- **Expression compatibility**: GNU Units expressions use its own syntax that
  is mostly compatible with our parser, but edge cases (e.g., `1|16` rational
  notation, `|` reciprocal) already work. New Phase 5 expressions are reviewed
  manually before being added to `units-supplementary.json`.
- **Alias collisions**: Adding new units (e.g., `b` for bit, `L` for liter)
  could collide with existing prefix symbols or unit IDs. The codegen will
  throw `ArgumentError` on collision at registration time; reviewed manually
  before merge.
- **Supplementary drift**: If `units-supplementary.json` references an entry
  that no longer exists in `units-parsed.json` (because the GNU Units source
  removed it), the supplementary entry will appear in `units.json` without
  importer-owned fields. The codegen will attempt to generate code for it; if
  type or required fields are missing the generation may fail or emit an
  incomplete unit. A future lint step could detect orphaned supplementary
  entries.
- **Generated-file drift**: If `units-supplementary.json` is edited without
  regenerating `units.json` and `builtin_units.dart`, they will be out of sync.
  A future CI step (not in this phase) should verify consistency.

## Open Questions

- Should SI-decimal kilobyte (= 1000 B) also be registered as `kB` to avoid
  confusion, or left to the SI prefix system? → **Deferred**: leave to prefix
  system; explicit `kibibyte`/`KiB` registers the IEC standard.
- When the user provides `tool/gnu_units/definitions.units`, should the importer
  run automatically as part of a `make` target? → **Deferred to future phase**.
