## Why

28 units in the GNU Units database are piecewise-linear functions (e.g. `gasmark`,
`sugar_conc_bpe`, wind chill tables) that the import pipeline currently marks as
`type: "unsupported"` with `reason: "piecewise_linear"`.  Adding first-class
support for these functions makes them available for conversion just like any
other unit.


## What Changes

- Add a `PiecewiseFunction` subclass of `UnitaryFunction` that evaluates
  piecewise-linear interpolation and its inverse.
- Extend the GNU Units import pipeline to parse piecewise-linear definitions
  (names of the form `id[outputUnits]`) into a new `"piecewise"` JSON type
  rather than storing them as unsupported.
- Extend the codegen pipeline to emit Dart registration calls for piecewise
  functions alongside builtin functions.
- Register piecewise functions in `UnitRepository` via `findFunction` /
  `registerFunction` (same path as builtin functions).
- Update `_knownEvalFailures` in `predefined_units_test.dart` to remove the 28
  piecewise entries now that they are supported.


## Capabilities

### New Capabilities

- `piecewise-function`: `PiecewiseFunction` class — a concrete subclass of
  `UnitaryFunction` that performs piecewise-linear interpolation (forward and
  inverse) over a fixed set of (x, y) control points, with configurable
  output-unit dimension and optional `noerror` behaviour.

### Modified Capabilities

- `gnu-units-import-pipeline`: parsing logic extended to recognise
  `name[outputUnits]` as a piecewise definition, extract the id, output unit
  expression, `noerror` flag, and control-point list, and emit them as
  `type: "piecewise"` entries in `units.json`.


## Impact

- **`tool/import_gnu_units_lib.dart`** — parse piecewise definitions instead of
  marking them unsupported; add new `GnuEntry` fields for piecewise data.
- **`tool/generate_predefined_units_lib.dart`** — add piecewise emitter that
  produces `PiecewiseFunction(...)` registration calls.
- **`lib/core/domain/models/function.dart`** — add `PiecewiseFunction` class.
- **`lib/core/domain/data/predefined_units.dart`** — regenerated to include
  piecewise registrations.
- **`lib/core/domain/data/units.json`** — 28 entries change from
  `type: "unsupported"` to `type: "piecewise"`.
- **`test/core/domain/models/function_test.dart`** — new tests for
  `PiecewiseFunction`.
- **`test/core/domain/data/predefined_units_test.dart`** — remove 28 entries
  from `_knownEvalFailures`.
- No new Dart package dependencies.
