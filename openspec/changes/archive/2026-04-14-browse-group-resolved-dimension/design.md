## Context

The dimension-grouped browse view builds its group labels in
`BrowserNotifier._buildDimensionIndex` via a local `labelFor` helper.
Currently `labelFor` returns the human-readable label when one is defined, or
the canonical representation otherwise.  The returned string is used as both
the display text (in `_GroupHeaderTile`) and the collapse-state key
(`BrowserState.collapsedGroups`).  Both uses are therefore updated by changing
`labelFor` alone.

## Goals / Non-Goals

**Goals:**
- For labeled dimension groups, display `"Label (canonical representation)"`.
- For unlabeled groups, leave the display string unchanged.
- Keep the collapse-state key consistent with the display label (same string).
- Keep the fast-scroll bar label consistent (it also uses the group label string
  from `groupAnchors`).

**Non-Goals:**
- Changing the alphabetical view.
- Changing how labels are defined or stored in `units.json`.
- Changing how sorting between labeled and unlabeled groups works.

## Decisions

**Decision: Change only `labelFor` in `_buildDimensionIndex`.**

The group label is the single shared string used for display, collapse-state
tracking, and fast-scroll anchor labels.  Changing the `labelFor` helper
propagates the new format everywhere without touching the UI widget or the
collapse/expand logic.

Alternative considered: pass separate display and key strings through
`BrowseGroups`.  Rejected — unnecessary complexity for this small change.
`BrowseGroups` is a private typedef; changing its shape would ripple through
`visibleGroups`, `build`, `collapseAll`, and several tests.

## Risks / Trade-offs

- Existing test assertions that match the current plain-label strings in
  dimension view will need updating to the new `"Label (rep)"` format.  The
  number of affected tests is small (those that check group labels directly).
