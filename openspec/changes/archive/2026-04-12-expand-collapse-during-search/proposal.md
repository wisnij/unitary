## Why

The browse page's expand/collapse behavior is partially broken during an active
search.  Two related problems exist:

1. When the user taps a group header to collapse it while a search is active,
   the entries disappear correctly but the chevron icon still shows "expanded",
   giving misleading visual feedback.
2. The Expand All and Collapse All AppBar buttons are disabled during search,
   so the user cannot bulk-manage group visibility while filtering — exactly
   when it would be most useful.

## What Changes

- Fix the group header chevron to reflect the actual collapsed state during
  search (remove the forced "expanded" override).
- Enable Expand All and Collapse All during search so the user can bulk-expand
  or bulk-collapse filtered results.
- Update spec: the requirement that both buttons are disabled during search is
  reversed — they SHALL remain enabled and functional during search.
- Add test coverage for the corrected behaviors.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `unit-browser`: The collapsible-groups requirement changes:
  - Chevron must reflect actual state during search (bug fix).
  - Expand All / Collapse All must be enabled (not disabled) during search.

## Impact

- `lib/features/browser/presentation/browser_screen.dart` — remove the
  `!widget.searchActive &&` guard from the `isCollapsed` computation in
  `_BrowseListViewState.build()`.
- `lib/features/freeform/presentation/home_screen.dart` — remove the
  `searchActive ? null :` guards from the Expand All and Collapse All
  `IconButton.onPressed` callbacks.
- `test/features/browser/presentation/browser_screen_test.dart` — add
  scenarios for chevron state and Expand All / Collapse All during search.
- `openspec/specs/unit-browser/spec.md` — update the collapsible-groups
  requirement (delta spec).
