## 1. Move Files

- [x] 1.1 Move all files from `tool/gnu_units/` to `assets/units/` (git mv to preserve history)
- [x] 1.2 Move `lib/core/domain/data/units-parsed.json` to `assets/units/`
- [x] 1.3 Move `lib/core/domain/data/units-supplementary.json` to `assets/units/`
- [x] 1.4 Move `lib/core/domain/data/units.json` to `assets/units/`
- [x] 1.5 Remove the now-empty `tool/gnu_units/` directory

## 2. Update Import Tool

- [x] 2.1 In `tool/import_gnu_units.dart`, update the input path from
  `tool/gnu_units/definitions.units` to `assets/units/definitions.units`
- [x] 2.2 In `tool/import_gnu_units.dart`, update the output path from
  `lib/core/domain/data/units-parsed.json` to `assets/units/units-parsed.json`
- [x] 2.3 Update the error message that tells the developer where to place the
  GNU Units file to reference `assets/units/` instead of `tool/gnu_units/`

## 3. Update Codegen Tool

- [x] 3.1 In `tool/generate_predefined_units.dart`, update the `dataDir` variable
  (or equivalent path constant) to point to `assets/units/` for the JSON input
  files (`units-parsed.json`, `units-supplementary.json`, `units.json`)
- [x] 3.2 Confirm that the Dart output path (`lib/core/domain/data/predefined_units.dart`)
  remains unchanged

## 4. Update Tool Tests

- [x] 4.1 Search `test/tool/` for any hardcoded paths referencing `tool/gnu_units/`
  or `lib/core/domain/data/units` and update them to the new locations
- [x] 4.2 Search `test/tool/` for any hardcoded paths referencing
  `lib/core/domain/data/units-parsed.json`, `units-supplementary.json`, or
  `units.json` and update them to `assets/units/`

## 5. Update Documentation

- [x] 5.1 Update `lib/core/domain/data/README.md` — revise the pipeline diagram
  and all file path references to reflect that the JSON files now live in
  `assets/units/`
- [x] 5.2 Update the doc-comment header in `tool/import_gnu_units.dart` (the
  `/// Reads … writes …` lines) to reflect the new paths
- [x] 5.3 Update the doc-comment header in `tool/generate_predefined_units.dart`
  to reflect the new paths

## 6. Verify

- [x] 6.1 Run `dart run tool/import_gnu_units.dart` and confirm it reads from
  `assets/units/definitions.units` and writes `assets/units/units-parsed.json`
  without errors
- [x] 6.2 Run `dart run tool/generate_predefined_units.dart` and confirm it reads
  from `assets/units/` and writes `assets/units/units.json` and
  `lib/core/domain/data/predefined_units.dart` without errors
- [x] 6.3 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 6.4 Run `flutter analyze` and confirm no linting errors
