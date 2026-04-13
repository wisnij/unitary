## Context

The browse page tracks collapsed groups in `BrowserState.collapsedGroups`
(a `Set<String>`).  `BrowserNotifier.setSearchQuery()` clears this set when
the query transitions from empty to non-empty, and restores the saved pre-search
set when the query is cleared.  `toggleGroup()`, `expandAll()`, and
`collapseAll()` all mutate the same set at any time, including during search.

Two UI-layer bugs currently prevent this from working correctly during search:

1. `_BrowseListViewState.build()` computes `isCollapsed` as:
   ```dart
   !widget.searchActive && widget.collapsedGroups.contains(label)
   ```
   The `!widget.searchActive` guard forces every chevron to show "expanded"
   during search, even after `toggleGroup` has added the label to
   `collapsedGroups`.

2. The Expand All and Collapse All `IconButton`s in `home_screen.dart` set
   `onPressed: searchActive ? null : ...`, disabling them during search.

Both fixes are purely in the presentation layer; no state logic changes are
needed.

## Goals / Non-Goals

**Goals:**

- Chevron icon correctly reflects actual collapsed/expanded state at all times,
  including while a search is active.
- Expand All and Collapse All buttons are enabled and functional during search.
- Pre-search collapse state is still saved on search entry and restored on
  search exit (existing behavior, unchanged).
- Spec updated to match the new intended behavior.

**Non-Goals:**

- Persisting collapse state across sessions.
- Any change to search filtering, group visibility, or fast-scroll behavior.

## Decisions

### Keep pre-search state restoration unchanged

When Expand All or Collapse All is invoked during search, it mutates
`collapsedGroups` but does not touch `_preSearchCollapsedGroups`.  When the
user clears the search, the pre-search state is restored as before, discarding
any bulk expand/collapse actions taken during the search.

**Alternative considered:** Update `_preSearchCollapsedGroups` when
Expand All / Collapse All is called during search so the expanded/collapsed
state persists after search exits.  Rejected because it complicates the state
machine and the pre-search restore is the simpler, more predictable contract.

### Fix in the view, not the provider

The `isCollapsed` override lives in the widget; the provider already does the
right thing.  Removing the `!widget.searchActive` guard is the minimal, correct
fix with no risk of breaking non-search behavior.

## Risks / Trade-offs

- **Expand All during search then clear search**: The user expands all groups
  while filtering, then clears the filter; the pre-search collapse state is
  restored, which may feel surprising.  Mitigation: this matches the documented
  contract ("collapse state restored after clearing search") and is consistent
  with the existing `toggleGroup` behavior during search.

## Open Questions

_(none)_
