## Why

Unitary currently supports only freeform expression evaluation.  Worksheet mode
adds a structured multi-unit conversion interface — the kind of tool users reach
for when they want to see a value expressed in several units simultaneously
without writing an expression for each one.  This is Phase 6 of the
implementation plan and the last major UI feature before persistence and
currency support.

## What Changes

- Add a `WorksheetTemplate` domain model: a named list of rows, each with a
  display label, a unit/function expression string, and a `WorksheetRowKind`
  (`UnitRow` or `FunctionRow`)
- Add 10 predefined worksheet templates (Length, Mass, Time, Temperature,
  Volume, Area, Speed, Pressure, Energy, Digital Storage)
- Add worksheet conversion engine: ratio-based for `UnitRow`, function
  forward/inverse for `FunctionRow`
- Add worksheet UI screen: scrollable list of numeric input fields, one per
  row, with real-time cross-update (500 ms debounce, same as freeform)
- Add AppBar dropdown to switch between worksheets
- Enable the "Worksheet" drawer tile in `HomeScreen` (currently disabled)
- Retain worksheet values in-session via a non-`autoDispose` Riverpod provider
  (values reset on app restart; persistence deferred to Phase 7)

## Capabilities

### New Capabilities

- `worksheet-templates`: Predefined worksheet definitions — domain model for
  `WorksheetTemplate`, `WorksheetRow`, and `WorksheetRowKind`; the 10
  predefined templates
- `worksheet-engine`: Conversion logic that takes a source row value, computes
  the base-unit quantity, and derives display values for all other rows
- `worksheet-ui`: Worksheet screen, row widgets, AppBar dropdown for worksheet
  selection, in-session state management via Riverpod

### Modified Capabilities

## Impact

- **New feature directory**: `lib/features/worksheet/` (models, state, presentation)
- **Modified**: `lib/features/freeform/presentation/home_screen.dart` — enable
  the Worksheet drawer tile and wire navigation
- **No new dependencies**: uses existing `flutter_riverpod`, `ExpressionParser`,
  `UnitRepository`, and the function system already in place
- **No breaking changes** to existing freeform or settings functionality
