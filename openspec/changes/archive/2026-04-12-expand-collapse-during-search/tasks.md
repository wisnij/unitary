## 1. Spec Update

- [x] 1.1 Sync delta spec into `openspec/specs/unit-browser/spec.md`: update the
  "Collapsible groups" requirement to reflect enabled buttons and correct
  chevron behavior during search

## 2. Fix Chevron Icon During Search

- [x] 2.1 In `lib/features/browser/presentation/browser_screen.dart`,
  remove the `!widget.searchActive &&` guard from the `isCollapsed` computation
  in `_BrowseListViewState.build()` so the chevron reflects actual state during
  search

## 3. Enable Expand All / Collapse All During Search

- [x] 3.1 In `lib/features/freeform/presentation/home_screen.dart`, remove the
  `searchActive ? null :` guard from the Expand All `IconButton.onPressed`
- [x] 3.2 In `lib/features/freeform/presentation/home_screen.dart`, remove the
  `searchActive ? null :` guard from the Collapse All `IconButton.onPressed`

## 4. Tests

- [x] 4.1 In `test/features/browser/presentation/browser_screen_test.dart`, add
  a test: collapsing a group during search hides its entries and shows the
  right-pointing chevron
- [x] 4.2 Add a test: Expand All during search expands all groups (chevron
  points down, entries visible)
- [x] 4.3 Add a test: Collapse All during search collapses all groups (chevron
  points right, entries hidden)
- [x] 4.4 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 4.5 Run `flutter analyze` and confirm no linting errors
