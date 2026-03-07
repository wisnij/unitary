## Why

Piecewise-linear function definitions in GNU Units can have name tokens containing both `[` (for the output unit) and `(` (for a parenthesized unit expression).  `_classifyLine` in `tool/import_gnu_units_lib.dart` checks for `(` first, so these entries are wrongly classified as unsupported nonlinear definitions instead of piecewise functions.

## What Changes

- In `_classifyLine`, move the `[` (piecewise) check before the `(` (unsupported nonlinear) check.

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `gnu-units-import-pipeline`: The classification priority rule for name tokens must be clarified — a name token containing `[` SHALL be classified as piecewise regardless of whether it also contains `(`.

## Impact

- `tool/import_gnu_units_lib.dart`: reorder two blocks in `_classifyLine`
- `test/tool/import_gnu_units_lib_test.dart`: add regression test for name tokens containing both `[` and `(`
- No API or dependency changes
