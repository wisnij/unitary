## 1. Domain Models

- [x] 1.1 Define `WorksheetRowKind` sealed class with `UnitRow` and `FunctionRow` variants
- [x] 1.2 Define `WorksheetRow` model (label, expression, kind)
- [x] 1.3 Define `WorksheetTemplate` model (id, name, rows)
- [x] 1.4 Write unit tests for `WorksheetRow` and `WorksheetTemplate` construction

## 2. Predefined Templates

- [x] 2.1 Implement the 10 predefined worksheet templates (Length, Mass, Time, Temperature, Volume, Area, Speed, Pressure, Energy, Digital Storage)
- [x] 2.2 Write tests verifying each template's row count, kinds, and expression strings

## 3. Worksheet Engine

- [x] 3.1 Implement `WorksheetEngine` (or equivalent): `UnitRow` source → base quantity → `UnitRow` targets (ratio-based)
- [x] 3.2 Extend engine: `FunctionRow` source → base quantity via `func.call()`
- [x] 3.3 Extend engine: `FunctionRow` target → display value via `func.callInverse()`
- [x] 3.4 Extend engine: mixed `UnitRow`/`FunctionRow` in same worksheet (temperature case)
- [x] 3.5 Handle invalid/empty input: clear all non-active rows
- [x] 3.6 Handle dimension mismatch: per-row error string
- [x] 3.7 Write engine tests: simple unit conversion (m → ft), compound expression (m/s → km/h), full temperature round-trip (tempC(0) → K=273.15, tempF=32, R=491.67), invalid input, dimension mismatch

## 4. Worksheet State

- [x] 4.1 Define `WorksheetState` (worksheetId, activeRowIndex, displayValues per worksheet)
- [x] 4.2 Implement `WorksheetNotifier` (non-`autoDispose` `NotifierProvider`): `onRowChanged(worksheetId, rowIndex, text)` — runs engine synchronously on every keystroke, updates displayValues
- [x] 4.3 Implement `onRowFocused(worksheetId, rowIndex)` — records focus without triggering recalculation
- [x] 4.4 Implement `selectWorksheet(worksheetId)` — switches active template, preserves per-template display values
- [x] 4.5 Write state tests: source transfer on keystroke only, value retention across worksheet switches, empty input clears rows

## 5. Worksheet UI

- [x] 5.1 Create `lib/features/worksheet/` directory structure (models/, state/, presentation/widgets/)
- [x] 5.2 Implement `WorksheetRowWidget`: label, numeric `TextField`, expression secondary label
- [x] 5.3 Implement `WorksheetScreen`: scrollable `Column` of `WorksheetRowWidget`s, wired to `WorksheetNotifier`
- [x] 5.4 Implement AppBar dropdown (`DropdownButton`) listing all predefined templates by name
- [x] 5.5 Enable the "Worksheet" drawer `ListTile` in `HomeScreen` and wire navigation to `WorksheetScreen`
- [x] 5.6 Write widget tests: rows render with correct labels, selecting dropdown switches worksheet, active row not overwritten during update

## 6. Final Checks

- [x] 6.1 Run `flutter test --reporter failures-only` — all tests pass
- [x] 6.2 Run `flutter analyze` — no linting errors
- [x] 6.3 Update `README.md` and `doc/design_progress.md` to reflect Phase 6 completion
