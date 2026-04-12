## Context

The Browse page already supports per-group expand/collapse via `toggleGroup()` in
`BrowserNotifier`.  Collapse state is stored as a `Set<String> collapsedGroups`
in `BrowserState`.  The dimension view starts fully collapsed; the alphabetical
view starts fully expanded.  A search query saves and restores the pre-search
collapse state.

The AppBar already contains Search and View-mode toggle buttons, both wired via
`Consumer` widgets in `home_screen.dart`.  Adding Expand All / Collapse All
follows the same pattern.

## Goals / Non-Goals

**Goals:**

- Add `expandAll()` and `collapseAll()` methods to `BrowserNotifier`.
- Add two icon buttons to the Browse AppBar that call those methods.

**Non-Goals:**

- Persistent expand/collapse state across sessions.
- Interaction with search (search already saves/restores collapse state
  independently; expand/collapse all will be disabled while search is active
  to avoid confusion about what will be restored when search ends).

## Decisions

**D1 — Two new notifier methods, not a generic bulk-update.**
`expandAll()` and `collapseAll()` are concise, self-documenting additions to
`BrowserNotifier` that mirror the existing `toggleGroup()` method.  A generic
`setAllGroups(bool)` or `setCollapsedGroups(Set)` alternative would expose
internal representation unnecessarily.

`expandAll()` sets `collapsedGroups` to `{}`.

`collapseAll()` computes the full label set for the active view from the
already-built `_alphabeticalIndex` / `_dimensionIndex` and assigns it to
`collapsedGroups`.

**D2 — Disable buttons during active search.**
While a search query is non-empty, expand/collapse all have no visible effect
(groups are force-expanded in `visibleGroups()`, and the collapse state will
be overwritten by the pre-search snapshot when search ends).  Disabling the
buttons avoids surprising no-ops and matches the principle that UI controls
should reflect what they will actually do.  Implementation: pass `enabled`
based on `state.searchQuery.isEmpty` to each button's `Consumer`.

**D3 — Icon choice.**
`Icons.unfold_more` (expand all) and `Icons.unfold_less` (collapse all) are
the standard Material icons for this semantic.  Tooltips: "Expand all" and
"Collapse all".

**D4 — Button order in AppBar.**
Expand All and Collapse All are added between the existing Search button and
the View-mode toggle button, left to right: Search | Expand All | Collapse All |
View toggle.  This groups the two bulk-collapse buttons together near the
view-mode toggle (which also resets collapse state).

## Risks / Trade-offs

- **Stale index in collapseAll()** — `_alphabeticalIndex` and `_dimensionIndex`
  are built eagerly in `build()`.  `collapseAll()` reads these directly, so
  there is no risk of stale data.
  No mitigation needed.

- **Button count in AppBar** — Four icon buttons may feel crowded on narrow
  phones.  Accepted for now; future work could consolidate into a menu if UX
  testing reveals issues.
