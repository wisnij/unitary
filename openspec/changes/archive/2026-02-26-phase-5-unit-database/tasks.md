## 1. Codegen Tool — Tests

- [x] 1.1 Create `test/tool/generate_builtin_units_lib_test.dart` with tests for
  `resolveAliasChains()`: returns empty maps for empty input, direct alias,
  chained alias, alias merged with canonical unit's existing `aliases` field
- [x] 1.2 Add tests for `resolveAliasChains()` — namespace separation: prefix alias
  resolves within prefix namespace only; same id in both namespaces (e.g. `m`
  for meter in units and milli in prefixes) resolves independently
- [x] 1.3 Add tests for `recursiveMerge()` and `mergeSupplementary()`: supplementary
  wins on conflict, parsed-only key preserved, supplementary-only entry added,
  deeply nested maps merged correctly, empty supplementary is a no-op
- [x] 1.4 Add tests for `generateDartCode()` — primitive unit emission (with/without
  aliases, with/without description, with `isDimensionless: true`)
- [x] 1.5 Add tests for `generateDartCode()` — derived unit emission (with/without
  aliases)
- [x] 1.6 Add tests for `generateDartCode()` — prefix unit emission (uses
  `registerPrefix`)
- [x] 1.7 Add tests for `generateDartCode()` — affine unit emission (factor, offset,
  baseUnitId)
- [x] 1.8 Add tests for `generateDartCode()` — unsupported and alias entries are
  omitted from output; alias is folded into canonical unit's aliases list
- [x] 1.9 Add tests for `generateDartCode()` — structure: emits flat
  `_registerUnits` and `_registerPrefixes` functions; `registerBuiltinUnits`
  calls each; units go into `_registerUnits`, prefixes into `_registerPrefixes`
- [x] 1.10 Add tests for `generateDartCode()` — generated file begins with
  do-not-edit header comment
- [x] 1.11 Add tests for string escaping in generated literals (single quote,
  backslash, dollar sign)

## 2. Codegen Tool — Implementation

- [x] 2.1 Create `tool/generate_builtin_units_lib.dart` with `recursiveMerge()`,
  `mergeSupplementary()`, and `resolveAliasChains()` functions; alias chain
  resolution operates within each namespace independently, returning
  `(unitAliases, prefixAliases)` record
- [x] 2.2 Implement `generateDartCode()` with import header, `registerBuiltinUnits`,
  and flat `_registerUnits` / `_registerPrefixes` private functions
- [x] 2.3 Implement per-entry Dart code formatters for `primitive`, `derived`,
  `prefix`, `affine` types (skip `alias` and `unsupported`)
- [x] 2.4 Create `tool/generate_builtin_units.dart` executable: reads
  `lib/core/domain/data/units-parsed.json` and
  `lib/core/domain/data/units-supplementary.json`, calls `mergeSupplementary()`,
  writes merged `lib/core/domain/data/units.json`, calls `generateDartCode()`,
  writes `lib/core/domain/data/builtin_units.dart`, runs `dart format` on output
- [x] 2.5 Run all existing tests (`flutter test --reporter failures-only`) — all
  pass (codegen lib has no side effects yet)

## 3. Importer Tool — Tests

- [x] 3.1 Create `test/tool/import_gnu_units_lib_test.dart` with tests for
  `parseGnuUnitsFile()`: blank lines, comments, inline comments, line
  continuations, non-definition directive lines
- [x] 3.2 Add parsing tests: conditional directives — `!utf8` included, `!locale
  en_US` included, `!locale en_GB` skipped, `!var UNITS_SYSTEM si` included,
  `!var UNITS_SYSTEM esu` skipped, `!varnot` logic
- [x] 3.3 Add parsing tests: prefix entry, primitive (`!`), dimensionless primitive
  (`!dimensionless`), derived unit
- [x] 3.4 Add parsing tests: alias detection — single bare identifier that IS in
  known ID set → `alias`; single bare identifier NOT in known ID set (e.g.,
  `kilometer`) → `derived`; unsupported nonlinear `id(x)`, unsupported
  piecewise linear `id[unit]`; source metadata (filename and line number)
- [x] 3.5 Add tests for `entriesToJson()`: entries are placed in the correct section
  (`units`, `prefixes`, `unsupported`); importer-owned fields are included;
  pass-through fields (description, aliases, category) are not included
- [x] 3.6 Add `entriesToJson()` tests: `definition` is omitted for unsupported
  entries; `isDimensionless` is included only for primitive; `target` for alias;
  `reason` for unsupported; empty list produces empty sections

## 4. Importer Tool — Implementation

- [x] 4.1 Create `tool/import_gnu_units_lib.dart` with `GnuEntry` class and
  `parseGnuUnitsFile()` using two-pass parsing: first pass collects all unit IDs
  and prefix IDs separately (respecting conditionals), second pass classifies
  entries with namespace-aware alias membership check; conditional stack handles
  `!utf8`, `!locale`, `!var`, `!varnot` against fixed settings
  (`UNITS_SYSTEM=si`, `UNITS_ENGLISH=US`); `!include` splices included file
  logical lines inline when a `FileReader` callback is provided
- [x] 4.2 Implement `entriesToJson()`: serializes parsed entries into
  `{'units': {...}, 'prefixes': {...}, 'unsupported': {...}}` map with only
  importer-owned fields; no pass-through fields
- [x] 4.3 Create `tool/import_gnu_units.dart` executable: reads
  `tool/gnu_units/definitions.units`, calls `parseGnuUnitsFile()` then
  `entriesToJson()`, writes `lib/core/domain/data/units-parsed.json` (no
  reading of existing data)
- [x] 4.4 Create `tool/gnu_units/` directory with a `README.md` explaining where to
  place the GNU Units definitions file
- [x] 4.5 Run all tests — all pass

## 5. Initial JSON Files

- [x] 5.1 Create `lib/core/domain/data/units-supplementary.json` with descriptions
  for all existing units (SI base units, temperature, digital storage, and
  all Phase 5 unit categories); affine temperature unit definitions go here
- [x] 5.2 Run `dart run tool/generate_builtin_units.dart` against the existing
  `units-parsed.json` and new `units-supplementary.json` to produce the
  initial `units.json`
- [x] 5.3 Verify no alias or id collisions across all entries
- [x] 5.4 Add `lib/core/domain/data/README.md` documenting the four-file pipeline,
  which files to edit, and the workflow commands

## 6. Regenerate builtin_units.dart

- [x] 6.1 Run `dart run tool/generate_builtin_units.dart` to produce the new
  `lib/core/domain/data/units.json` and
  `lib/core/domain/data/builtin_units.dart` from merged data
- [x] 6.2 Confirm generated file passes `dart analyze` with no issues
- [x] 6.3 Run `flutter test test/core/domain/data/builtin_units_test.dart --reporter
  failures-only` — all existing tests pass

## 7. Phase 5 Tests

- [x] 7.1 Add `builtin_units_test.dart` group for volume units: unit and alias
  registration count is nonzero
- [x] 7.2 Update the "all units register without collision" test count to the new
  total after Phase 5 additions
- [x] 7.3 Run `flutter test --reporter failures-only` — all tests pass

## 8. Documentation

- [x] 8.1 Update `README.md` Project Status section: Phase 5 complete with new test count
- [x] 8.2 Update `doc/implementation_plan.md`: mark Phase 5 tasks complete, add
  test count and completion date
- [x] 8.3 Update `doc/design_progress.md`: add Phase 5 entry to implementation log
