## 1. Tests

- [x] 1.1 In `test/features/browser/state/browser_provider_test.dart`, rename the
  `'alphabetical view starts fully expanded'` test to
  `'alphabetical view starts fully collapsed'` and change the assertion from
  `expect(collapsedGroups, isEmpty)` to `expect(collapsedGroups, isNotEmpty)`,
  verifying that all alphabetical group labels are present in `collapsedGroups`
  after `setViewMode(BrowseViewMode.alphabetical)`.
- [x] 1.2 Update any test that switches to alphabetical view and immediately calls
  `visibleGroups()` expecting entry rows to be visible — those tests must now
  call `expandAll()` (or `toggleGroup`) before reading entries.

## 2. Implementation

- [x] 2.1 In `lib/features/browser/state/browser_provider.dart`, update
  `setViewMode()`: when `mode == BrowseViewMode.alphabetical`, set
  `collapsedGroups` to the full set of alphabetical group labels
  (`_alphabeticalIndex.map((g) => g.$1).toSet()`) instead of `const {}`.
- [x] 2.2 Update the comment above the `setViewMode()` method to read
  `"- Alphabetical: all groups collapsed (full label set)."` instead of
  `"- Alphabetical: all groups expanded (empty set)."`.

## 3. Verification

- [x] 3.1 Run `flutter test --reporter failures-only` and confirm all tests pass.
- [x] 3.2 Run `flutter analyze` and confirm no linting errors.
