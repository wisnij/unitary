## Why

The Browse page groups entries into collapsible sections, but there is no way
to quickly expand or collapse all groups at once.  Users must tap each group
header individually, which is tedious when many groups are visible.

## What Changes

- Add an **Expand All** button to the Browse page AppBar that expands every
  group in the current view.
- Add a **Collapse All** button to the Browse page AppBar that collapses every
  group in the current view.
- Both buttons operate on whichever view is currently active (alphabetical or
  dimension).
- The buttons are always visible when the Browse page is open (no search
  interaction changes their presence).

## Capabilities

### New Capabilities

_(none — this change extends an existing capability)_

### Modified Capabilities

- `unit-browser`: Adding expand-all and collapse-all AppBar buttons that
  bulk-modify the per-group collapsed state in the current view.

## Impact

- `lib/features/browse/`: `BrowserScreen`, `BrowserNotifier`, `BrowserState`
- `lib/features/home/home_screen.dart`: AppBar buttons wired to notifier actions
- No new dependencies
