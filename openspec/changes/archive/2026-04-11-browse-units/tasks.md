## 1. Data Model

- [x] 1.1 Create `lib/features/browser/models/browse_entry.dart` with `BrowseEntryKind` enum (`unit`, `prefix`, `function`) and `BrowseEntry` value class (`name`, `primaryId`, `kind`, `aliasFor`, `summaryLine`, `dimension`)
- [x] 1.2 Write unit tests for `BrowseEntry` construction and field semantics

## 2. Dimension Label Pipeline

- [x] 2.1 Add a `"dimensions"` top-level key to `lib/core/domain/data/units-supplementary.json` with label objects for common dimensions (Length, Mass, Time, Temperature, Area, Volume, Speed, Pressure, Energy, Force, Power, Angle, Solid Angle, Dimensionless, Digital Storage, and others as applicable)
- [x] 2.2 Update `generate_predefined_units_lib.dart` to read the `"dimensions"` map from the merged JSON and emit a top-level `Map<String, String> dimensionLabels` constant in `predefined_units.dart`
- [x] 2.3 Write tool tests for the new `"dimensions"`-key codegen (correct map emitted; missing key produces empty map; unknown keys ignored)
- [x] 2.4 Regenerate `lib/core/domain/data/units.json` and `lib/core/domain/data/predefined_units.dart`

## 3. UnitRepository Catalog

- [x] 3.1 Add a `final Map<String, String> dimensionLabels` field to `UnitRepository` (defaults to empty map); update `withPredefinedUnits()` to pass in the generated `dimensionLabels` constant
- [x] 3.2 Implement `List<BrowseEntry> buildBrowseCatalog()` on `UnitRepository`: iterate `allUnits` (excluding `PrefixUnit`), `allPrefixes`, and `allFunctions`; expand `allNames` for each; resolve dimension via `_resolvedQuantityCache`; build and return the full list
- [x] 3.3 Write unit tests for `buildBrowseCatalog()`: all units/prefixes/functions present; aliases appear as separate entries with correct `aliasFor`; unresolvable units have null `dimension`; `summaryLine` correct for each entry kind

## 4. BrowserNotifier and Providers

- [x] 4.1 Create `lib/features/browser/state/browser_provider.dart` with `BrowseViewMode` enum (`alphabetical`, `dimension`) and `BrowserState` value class (viewMode, searchQuery, collapsedGroups, alphabeticalIndex, dimensionIndex) — note: `dimensionIndexBuilding` was designed out; both indices are built eagerly in `BrowserNotifier.build()`
- [x] 4.2 Implement alphabetical index building in `BrowserNotifier`: group entries by case-insensitive first letter; non-letter entries go in `#`; sort groups A→Z with `#` last; sort entries within each group case-insensitively
- [x] 4.3 Implement dimension index building (eager, in `BrowserNotifier.build()`): group by `entry.dimension`; resolve group labels using `dimensionLabels`; sort labeled groups before unlabeled, each tier sorted case-insensitively — `dimensionIndexBuilding` flag not used (building is synchronous)
- [x] 4.4 Implement view-mode toggle: switching views resets `collapsedGroups` to the new view's defaults (alphabetical: empty set; dimension: full group-label set)
- [x] 4.5 Implement group collapse/expand: `toggleGroup(String label)` adds/removes the label from `collapsedGroups`
- [x] 4.6 Implement search query update: `setSearchQuery(String query)` stores the query; `collapsedGroups` is not modified
- [x] 4.7 Write unit tests for `BrowserNotifier`: alphabetical grouping (letter buckets, `#` bucket, sort order); dimension grouping (labeled before unlabeled, sort within tiers); collapse toggle; view-switch collapse reset; search filtering (substring match, case-insensitive, empty groups hidden); search does not affect `collapsedGroups`

## 5. BrowserScreen

- [x] 5.1 Create `lib/features/browser/presentation/browser_screen.dart` with `BrowserScreen` stateless widget; consume `BrowserNotifier`
- [x] 5.2 Implement the flat item list builder: produces an interleaved sequence of group-header items and entry items from the active index; respects `collapsedGroups` (entry items omitted for collapsed groups) unless search is active
- [x] 5.3 Implement group header row widget: shows group label, trailing chevron (down = expanded, right = collapsed), taps call `toggleGroup`
- [x] 5.4 Implement entry row widget: title (primary ID or `"alias = primaryId"`), subtitle (`summaryLine`); taps call `Navigator.push` to `UnitEntryDetailScreen` with `primaryId` and `kind`
- [x] 5.5 Implement AppBar: view-mode toggle button (e.g. segmented button or icon toggle), search icon button that shows/hides search bar
- [x] 5.6 Implement search bar: text field below AppBar; updates `BrowserNotifier.setSearchQuery` on change; clear button resets query
- [x] 5.7 ~~Show `CircularProgressIndicator` in place of the list when `dimensionIndexBuilding` is true~~ — removed; index building is synchronous so no loading state is needed

## 6. UnitEntryDetailScreen

- [x] 6.1 Create `lib/features/browser/presentation/unit_entry_detail_screen.dart`; accepts `primaryId` and `BrowseEntryKind`; re-looks up the domain object from `UnitRepository`
- [x] 6.2 Implement primary name heading and aliases section (shown only when aliases are present)
- [x] 6.3 Implement description section (shown only when description is non-null)
- [x] 6.4 Implement definition section: `[primitive unit]` for `PrimitiveUnit`; expression string for `DerivedUnit`/`PrefixUnit`; forward expression for `DefinedFunction`; `[builtin function]` for `BuiltinFunction`; `[piecewise linear function]` for `PiecewiseFunction`
- [x] 6.5 Implement inverse section (functions only): shown when `hasInverse == true` and an inverse expression string is available
- [x] 6.6 Implement resolved-quantity section (units and prefixes only): call `resolveUnit`, format as `1 <name> = <quantity>`; silently omit if resolution throws
- [x] 6.7 Implement domain/range section (functions only): shown when `domain` or `range` carries a quantity or bounds; omitted otherwise
- [x] 6.8 Implement piecewise control-point table (`PiecewiseFunction` only): two-column table of all `points` in order; column headers from `domain[0]`/`range` quantity expressions or fallback `"Input"`/`"Output"`
- [x] 6.9 Write unit/widget tests for `UnitEntryDetailScreen`: correct sections rendered per entry kind; aliases section absent when empty; resolved quantity shown for unit, absent for function; resolved quantity absent on resolution failure; piecewise table row count matches `points.length`

## 7. Navigation Integration

- [x] 7.1 Add `browser` variant to `_TopLevelPage` enum in `home_screen.dart`
- [x] 7.2 Add a "Browse" `ListTile` to the navigation drawer (between Worksheet and the divider); tapping it calls `_switchPage(_TopLevelPage.browser)`
- [x] 7.3 Wire `BrowserScreen` into `HomeScreen` body: render `BrowserScreen` when `_currentPage == _TopLevelPage.browser`

## 8. Documentation

- [x] 8.1 Update `README.md` current-progress section to reflect the new Browse feature
- [x] 8.2 Update `doc/design_progress.md` to record Phase 7 (Browse) as complete
