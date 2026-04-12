## 1. Notifier Methods

- [x] 1.1 Add `expandAll()` to `BrowserNotifier`: sets `collapsedGroups` to `{}`
- [x] 1.2 Add `collapseAll()` to `BrowserNotifier`: collects all group labels from the active view index and assigns them to `collapsedGroups`
- [x] 1.3 Write unit tests for `expandAll()` and `collapseAll()` in the browser provider test file

## 2. AppBar Buttons

- [x] 2.1 Add Expand All `IconButton` (`Icons.unfold_more`, tooltip "Expand all") to the Browse AppBar section in `home_screen.dart`; wire to `browserProvider.notifier.expandAll()`
- [x] 2.2 Add Collapse All `IconButton` (`Icons.unfold_less`, tooltip "Collapse all") to the Browse AppBar section in `home_screen.dart`; wire to `browserProvider.notifier.collapseAll()`
- [x] 2.3 Disable both buttons when `state.searchQuery.isNotEmpty` (pass `null` as `onPressed`)
- [x] 2.4 Place buttons between the Search button and the View-mode toggle button

## 3. Tests

- [x] 3.1 Widget test: Expand All button is present on Browse page
- [x] 3.2 Widget test: Collapse All button is present on Browse page
- [x] 3.3 Widget test: both buttons are disabled when search query is non-empty

## 4. Final checks

- [x] 4.1 Run `flutter test --reporter failures-only` — all tests pass
- [x] 4.2 Run `flutter analyze` — no lint errors
