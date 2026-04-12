## Why

The browse page can contain thousands of entries across many groups, and the
only way to navigate is linear scrolling.  A draggable fast-scroll thumb with a
group-label bubble — familiar from contacts and file-manager apps — lets users
jump to a distant section in one gesture without hunting for a group header.

## What Changes

- A new reusable `FastScrollBar` widget wraps any `ListView` and overlays a
  draggable thumb on the right edge of the screen.
- While the thumb is being dragged, a label bubble appears to the left of the
  thumb showing the name of the group at the current scroll position.
- The thumb fades in when the list is scrolled or the thumb is touched, and
  fades out after a short idle period.
- `_BrowseListView` is updated to own a `ScrollController`, compute group
  boundaries (flat-list item index per group), and pass them to `FastScrollBar`.
- The feature works identically in both alphabetical view (letter groups: A, B,
  C…) and dimension view (dimension-name groups: Length, Mass, Time…).
- No new pub.dev dependency is introduced; the implementation uses only Flutter
  core primitives (`ScrollController`, `GestureDetector`, `Stack`, animation).

## Capabilities

### New Capabilities

- `fast-scroll-bar`: A self-contained overlay widget that provides a draggable
  scroll thumb with a group-label bubble for `ListView`-based screens.  Accepts
  a `ScrollController`, total item count, and a list of
  `(itemIndex, label)` anchor pairs that map scroll positions to group names.

### Modified Capabilities

- `browse-view`: The browse list view gains a `ScrollController` and group
  boundary data, and is wrapped with `FastScrollBar`.  No spec-level behavior
  changes to browsing, searching, or collapsing; only new navigation affordance
  added.

## Impact

- **New file**: `lib/shared/widgets/fast_scroll_bar.dart`
- **Modified file**: `lib/features/browser/presentation/browser_screen.dart`
  (`_BrowseListView` — adds `ScrollController` and `FastScrollBar` wrapper)
- No changes to state management, providers, models, or data layer.
- No changes to the detail screen or search behavior.
- No new dependencies.
