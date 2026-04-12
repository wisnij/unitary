## Context

The browse page renders a flat `ListView.builder` with interleaved group-header
and entry tiles.  `_BrowseListView` is currently a `StatelessWidget` with no
`ScrollController`.  Groups are built by `BrowserNotifier.visibleGroups()` and
passed down as a `BrowseGroups` value (`List<(String, List<BrowseEntry>)>`).
Collapsed groups emit only their header tile (0 entries), so the flat list
length changes when groups are toggled.

There is no Flutter built-in widget for a draggable fast-scroll thumb with a
label bubble.  All pub.dev packages for this pattern are 2–5 years old and
unmaintained; a custom implementation is the correct choice.

## Goals / Non-Goals

**Goals:**

- Draggable thumb on the right edge that scrolls the list when dragged.
- Label bubble showing the current group name while the thumb is being dragged.
- Thumb fades in on scroll activity and fades out after a short idle period.
- Thumb hidden when the content fits on screen (no scrolling needed) or when
  search is active (filtered results are short).
- Works identically in alphabetical view (letter labels) and dimension view
  (dimension-name labels).
- `FastScrollBar` is a generic, reusable widget — not coupled to the browser.

**Non-Goals:**

- Pixel-perfect group boundary detection (approximate fraction-based mapping is
  sufficient for a fast-navigation affordance).
- Sticky group headers (separate feature).
- Support for horizontal scroll or nested scrollables.
- Jump-to-letter sidebar (tappable A–Z strip); drag-thumb only for now.

## Decisions

### 1. Fraction-based scroll ↔ label mapping

**Decision:** Map the thumb position as a fraction (0.0–1.0) of list height to
an approximate flat-list item index, then binary-search `groupAnchors` to find
the label.

**Why not pixel-exact group boundaries?**  Computing exact pixel offsets for
each group header requires either (a) knowing item heights up-front or (b)
`RenderBox` lookups after layout.  `ListView.builder` uses lazy rendering, so
(b) only works for items currently in the viewport.  Pre-computing item heights
is fragile against font-scale and theme changes.

Fraction-based mapping is accurate enough: group headers and entry tiles are
similar heights (~50 px vs ~72 px), so the approximation places the label
within 1–2 groups of the true position.  Users treat the thumb as a rough
navigation tool, not a precise cursor.

**Anchor list contract:**

```dart
// groupAnchors: ordered by itemIndex, one entry per group header.
// Each element: (flat-list index of the group header, group label string).
List<(int, String)> groupAnchors
```

Label lookup:

```dart
String labelForFraction(double f) {
  final target = (f * itemCount).round().clamp(0, itemCount - 1);
  var label = groupAnchors.first.$2;
  for (final (idx, lbl) in groupAnchors) {
    if (idx <= target) label = lbl; else break;
  }
  return label;
}
```

### 2. Stack-based overlay (not Overlay widget)

**Decision:** Wrap the `ListView` in a `Stack` inside a `LayoutBuilder`.  The
thumb and label are `Positioned` children of the Stack.

**Why not Flutter's `Overlay`?**  `Overlay` is required when the widget must
float above the AppBar or other routes.  The thumb only needs to float above
the list content; a `Stack` confined to the list area is simpler, avoids
`OverlayEntry` lifecycle management, and stays in the normal widget tree.

### 3. `_BrowseListView` becomes `StatefulWidget`

**Decision:** Convert `_BrowseListView` from `StatelessWidget` to
`StatefulWidget`.  The state owns the `ScrollController` and computes
`groupAnchors` from the current `items` list.

`groupAnchors` is derived from the same `items` list already built for
`ListView.builder`, so it adds no extra computation: iterate once, record the
flat index of each `_GroupHeaderItem`.

### 4. Fade animation and auto-hide

**Decision:** `FastScrollBar` owns an `AnimationController` (duration 200 ms)
for the fade transition.  A `Timer` (1.5 s) resets on each scroll event; when
it fires, the controller reverses (fade out).  Dragging cancels the timer and
keeps the thumb fully visible.

`ScrollController.addListener` drives both the thumb position update and the
fade-in trigger.  The listener guard `controller.position.maxScrollExtent > 0`
prevents the thumb from appearing when the list fits on screen.

### 5. Hide during search

**Decision:** `FastScrollBar` accepts a `bool active` parameter (defaults
`true`).  `_BrowseListView` passes `active: searchQuery.isEmpty`.  When
`active` is false the widget renders only its `child` with no overlay.

This is simpler than animating the thumb away and avoids confusing label
updates while the item list is changing rapidly due to search input.

### 6. Thumb tracks scroll controller (bidirectional sync)

When the user scrolls normally (not via the thumb), the thumb position must
update.  The `ScrollController` listener computes
`fraction = pixels / maxScrollExtent` and updates `_thumbFraction` via
`setState`.  This fraction is then used to compute
`Positioned.top = fraction * (listHeight - thumbHeight)`.

`listHeight` is captured from `LayoutBuilder.constraints.maxHeight`, stored as
a field, and kept up to date via `LayoutBuilder` rebuild.

## Risks / Trade-offs

**Approximate label during drag** → The displayed group label can lag 1–2
groups behind the true visible group when groups have very different sizes
(e.g., the "#" group at the end of alphabetical view has few entries).  This
is acceptable; the label is a navigation hint, not a precise indicator.  
_Mitigation_: None needed; behavior is consistent with similar apps.

**Flat-list item count changes on collapse/expand** → Toggling a group changes
`items.length` and shifts group anchors.  `_BrowseListView` rebuilds on every
`BrowserState` change, so `itemCount` and `groupAnchors` passed to
`FastScrollBar` are always current.  The `ScrollController` retains its pixel
offset; the thumb fraction may shift slightly after a rebuild.  
_Mitigation_: Acceptable; the list already jumps on collapse/expand.

**ScrollController attached to a dead scroll position** → If
`FastScrollBar._onDragUpdate` fires before `ScrollController.hasClients` is
true (e.g. on first frame), calling `jumpTo` would throw.  
_Mitigation_: Guard all `controller` calls with `controller.hasClients`.

## Migration Plan

1. Add `lib/shared/widgets/fast_scroll_bar.dart` (new file, no impact on other
   screens).
2. Convert `_BrowseListView` to `StatefulWidget`, add `ScrollController`, build
   `groupAnchors`, wrap in `FastScrollBar`.
3. Pass `active: state.searchQuery.isEmpty` from `BrowserScreen`.
4. All existing browse tests continue to pass unchanged (no model/provider
   changes).
5. Add widget tests for `FastScrollBar` and integration tests for the updated
   `_BrowseListView`.

No migration of persistent data, no breaking API changes, no new dependencies.

## Open Questions

- **Thumb size and shape**: use a rounded rectangle (~6 × 48 px) styled from
  `ColorScheme.primary` at reduced opacity?  Confirm with visual review.
- **Label bubble placement**: left of thumb (standard) vs floating in center of
  screen (some apps)?  Left-of-thumb is less intrusive; use that unless visual
  review says otherwise.
- **Minimum content threshold**: hide the thumb when fewer than N items exist?
  The `maxScrollExtent > 0` guard already handles this for most cases; an
  explicit item-count floor may be redundant.
