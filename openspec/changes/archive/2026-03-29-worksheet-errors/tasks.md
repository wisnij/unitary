## 1. Core Domain — BoundsException

- [x] 1.1 Add `BoundsException extends UnitaryException` to `lib/core/domain/errors.dart`
- [x] 1.2 Update `_validateSpec` in `lib/core/domain/models/function.dart` to throw `BoundsException` instead of `EvalException` for min/max bound violations
- [x] 1.3 Add tests for `BoundsException` being thrown on out-of-bounds domain values

## 2. Worksheet Engine — Structured Result Type

- [x] 2.1 Add `WorksheetCellResult` record `(String text, bool isError)` to `lib/features/worksheet/services/worksheet_engine.dart`
- [x] 2.2 Change `WorksheetResult.values` from `List<String?>` to `List<WorksheetCellResult?>`
- [x] 2.3 Update `computeWorksheet` to return `WorksheetCellResult` instances for all non-null entries

## 3. Worksheet Engine — Specific Error Labels

- [x] 3.1 Catch `DimensionException` separately in `computeWorksheet` and produce `WorksheetCellResult(text: 'wrong unit type', isError: true)`
- [x] 3.2 Catch `BoundsException` separately and produce `WorksheetCellResult(text: 'out of bounds', isError: true)`
- [x] 3.3 Change the explicit `!hasInverse` guard in `_funcRowTarget` to return `WorksheetCellResult(text: 'no inverse', isError: true)` without throwing
- [x] 3.4 Keep catch-all handler producing `WorksheetCellResult(text: 'error', isError: true)`
- [x] 3.5 Add engine tests covering each error label (dimension mismatch, out of bounds, no inverse, generic)
- [x] 3.6 Add engine test confirming successful conversions have `isError: false`

## 4. State — Thread WorksheetCellResult Through

- [x] 4.1 Update `WorksheetState` and `WorksheetNotifier` in `lib/features/worksheet/state/` to store and propagate `isError` alongside display text
- [x] 4.2 Update any consumers of `WorksheetResult.values` that index into the list

## 5. UI — Error Color on Row Widget

- [x] 5.1 Add `bool isError` parameter to `WorksheetRowWidget` (default `false`)
- [x] 5.2 Apply `style: TextStyle(color: colorScheme.error)` to the `TextField` when `isError` is true
- [x] 5.3 Pass the `isError` flag from state to `WorksheetRowWidget` in `WorksheetScreen`
- [x] 5.4 Add widget tests confirming error color is applied when `isError: true` and not applied when `isError: false`

## 6. Cleanup and Verification

- [x] 6.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 6.2 Run `flutter analyze` and confirm no linting errors
