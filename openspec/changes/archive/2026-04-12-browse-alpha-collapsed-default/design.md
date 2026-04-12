## Context

The browse page has two views: dimension (default, all collapsed) and
alphabetical (all expanded).  The asymmetry was intentional at the time — the
dimension view has ~20 groups so collapsed is useful, while the alphabetical
view has 27 groups (A–Z + #) and all-expanded was chosen to match the
expand-all button's existing behaviour.  In practice, all-expanded floods the
screen on first load.  Making both views start collapsed creates a consistent
default and a lighter initial state.

The collapse state for each view is tracked independently in `BrowserNotifier`
as a `Set<String>` of collapsed group labels.  The default for alphabetical is
an empty set (nothing collapsed = all expanded).  Changing the default requires
initialising that set with all known alphabetical group labels instead of the
empty set.

## Goals / Non-Goals

**Goals:**

- Alphabetical view opens with all groups collapsed.
- Behaviour after first open is unchanged (tap to expand/collapse, Expand All,
  Collapse All, and search auto-expand all work as before).
- Switching back to alphabetical from dimension resets to the new all-collapsed
  default (consistent with the existing reset-on-switch behaviour).

**Non-Goals:**

- Persisting collapse state across sessions (out of scope).
- Changing the dimension view default (already collapsed).

## Decisions

### Initialise alphabetical collapse set from all group labels

**Decision:** On first build, populate the alphabetical collapsed set with the
full set of group labels derived from the catalog, the same way the dimension
view already does.

**Rationale:** The dimension view's all-collapsed default is already implemented
by seeding the collapsed set with every group label.  Reusing the same pattern
keeps the two views symmetric and requires no new mechanism — only a one-line
change to the alphabetical initialisation path in `BrowserNotifier`.

**Alternative considered:** Keep empty set as default and add an
`initializeCollapsed` flag.  Rejected — unnecessary complexity for a trivial
change.

## Risks / Trade-offs

- **Risk:** Users who relied on all-expanded alphabetical view will need an
  extra tap to open any group.
  **Mitigation:** The Expand All button remains in the AppBar for one-tap
  restoration of the previous experience.

## Open Questions

_(none)_
