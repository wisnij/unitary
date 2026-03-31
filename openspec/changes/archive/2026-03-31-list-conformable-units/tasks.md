## 1. Domain: ConformableEntry and findConformable

- [x] 1.1 Define `ConformableEntry` data class with `name`, `definitionExpression?`, `functionLabel?`, and `aliasFor?` fields in `lib/core/domain/models/unit_repository.dart`
- [x] 1.2 Add lazy quantity cache (`Map<String, Quantity?>`) to `UnitRepository`
- [x] 1.3 Implement `findConformable(Dimension target)` on `UnitRepository`: iterate `_units.values`, skip `PrefixUnit`, resolve each unit into `Quantity` (catching errors, caching result), compare `quantity.dimension` to `target`, build entry
- [x] 1.4 Set `definitionExpression` on entries for `DerivedUnit`, leave null for `PrimitiveUnit`
- [x] 1.5 Extend `findConformable` to include functions: iterate `_functions.values`, check `range?.quantity?.dimension`, set `functionLabel` (`'[piecewise linear function]'` or `'[function]'`)
- [x] 1.6 For each conformable unit and function, also emit one alias entry per registered alias, with `aliasFor` set to the primary ID and `definitionExpression`/`functionLabel` copied from the primary entry
- [x] 1.7 Sort results case-insensitively by `name` before returning

## 2. Domain tests

- [x] 2.1 Test `ConformableEntry` construction (derived unit, primitive unit, function, and alias cases)
- [x] 2.2 Test `findConformable` returns units with matching dimension and excludes non-matching
- [x] 2.3 Test `findConformable` excludes `PrefixUnit` entries
- [x] 2.4 Test `findConformable` silently excludes unresolvable units
- [x] 2.5 Test `findConformable` result is sorted case-insensitively (aliases sort among other entries)
- [x] 2.6 Test derived unit entries carry `definitionExpression`; primitive unit entries have both secondary fields null
- [x] 2.7 Test function entries: correct `functionLabel` for `PiecewiseFunction` vs other subtypes
- [x] 2.8 Test functions with no `range` or null `range.quantity` are excluded
- [x] 2.9 Test repeated calls return equivalent results (cache stability)
- [x] 2.10 Test unit alias entries appear with `aliasFor` set and carry the target's `definitionExpression`
- [x] 2.11 Test function alias entries appear with `aliasFor` set and carry the target's `functionLabel`

## 3. State: trigger provider and FreeformScreen wiring

- [x] 3.1 Add `conformableBrowseRequestProvider` (`NotifierProvider<ConformableBrowseNotifier, int>`, initial value 0, with `trigger()` method) in the freeform state directory
- [x] 3.2 In `_FreeformScreenState`, use `ref.listenManual` in `initState` to subscribe to `conformableBrowseRequestProvider`; store the `ProviderSubscription` and close it in `dispose`; on each trigger: cancel any pending debounce, call `_evaluate()` synchronously, then defer `_showConformableModal(context)` to post-frame if the result is `EvaluationSuccess`, `ConversionSuccess`, `UnitDefinitionResult`, or `FunctionConversionResult`
- [x] 3.3 Implement `_showConformableModal(BuildContext context)`: read evaluated dimension from `freeformProvider`, call `repo.findConformable(dimension)`, show modal bottom sheet

## 4. UI: AppBar button

- [x] 4.1 In `HomeScreen`, add the conformable-units `IconButton` to `AppBar.actions` only when `_currentPage == _TopLevelPage.freeform`
- [x] 4.2 Button calls `notifier.trigger()`; button is `null` (disabled) when `freeformProvider` state is not one of `EvaluationSuccess`, `ConversionSuccess`, `UnitDefinitionResult`, or `FunctionConversionResult`

## 5. UI: conformable-units modal

- [x] 5.1 Implement modal body widget (can be a private function or class): `DraggableScrollableSheet` wrapping a `ListView.builder` over the `ConformableEntry` list
- [x] 5.2 Render each entry as a `ListTile`; title is `"<name> = <aliasFor>"` for alias entries and `name` otherwise; subtitle is `functionLabel` if non-null, else `definitionExpression` if non-null, else `'[primitive unit]'`
- [x] 5.3 On `ListTile` tap: pop the modal, then overwrite `_outputController` with `entry.name`
- [x] 5.4 After updating `_outputController`, trigger evaluation (cancel debounce and call `_evaluate()`)

## 6. Widget tests

- [x] 6.1 Test conformable-units button is present on freeform page and absent on worksheet page
- [x] 6.2 Test button is enabled for `EvaluationSuccess`, `ConversionSuccess`, `UnitDefinitionResult`, and `FunctionConversionResult`; disabled for `EvaluationIdle`, `EvaluationError`, and `FunctionDefinitionResult`
- [x] 6.3 Test pressing button when debounce is pending force-evaluates before opening modal
- [x] 6.4 Test modal shows expected entries for a known dimension
- [x] 6.5 Test secondary text: `definitionExpression` for derived unit, `'[primitive unit]'` for primitive, `'[function]'` and `'[piecewise linear function]'` for functions
- [x] 6.6 Test tapping an entry fills an empty "Convert to" field
- [x] 6.7 Test tapping an entry overwrites existing "Convert to" text
- [x] 6.8 Test alias entry shows `"name = target"` as primary text and the target's expression as secondary text

## 7. Final checks

- [x] 7.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 7.2 Run `flutter analyze` and confirm no linting errors
