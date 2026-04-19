## Context

`FastScrollBar` in `lib/shared/widgets/fast_scroll_bar.dart` wraps a scrollable
child and overlays a draggable thumb on the right edge.  The current thumb is a
`GestureDetector` wrapping a `_ThumbWidget` (6×48 px rounded rectangle), with
no invisible hit-area expansion and no visual affordance indicating it is
draggable.  While dragging, a `_LabelBubble` to the left of the thumb shows the
single group at the current scroll position.

Three aspects need improvement:

1. The 6 dp touch target is too narrow for reliable mobile use.
2. The plain rectangle gives no cue that the widget responds to drag gestures.
3. The single-label bubble gives no spatial context about neighbouring groups.

## Goals / Non-Goals

**Goals:**

- Touch target ≥ 44 dp wide without altering the visual thumb's right-edge
  placement.
- Thumb appearance communicates "drag handle" via shape and grip marks.
- While dragging, the label panel shows the current group plus up to 2
  neighbours above and 2 below.

**Non-Goals:**

- Making the number of neighbour labels configurable via the widget API —
  a named constant is sufficient.
- Changing thumb fade/visibility behaviour.
- Changing drag mechanics or `labelForFraction` semantics.
- Showing the neighbour panel when not dragging.

## Decisions

### 1. Touch target: transparent padding, not a larger visual thumb

**Decision:** Wrap the visual thumb in a `SizedBox(width: 44)` and right-align
it inside, so the `GestureDetector` covers 44 dp regardless of how wide the
drawn thumb is.  The visual thumb width is a separate constant (`_thumbWidth`,
changed to 12 dp by Decision 2); `_thumbHitWidth = 44.0` documents the
independent hit-area size.

**Alternatives considered:**
- *Use a separate invisible `GestureDetector` behind the thumb*: Requires two
  overlapping widgets with hit-test coordination; more complex and error-prone
  than a single wider widget.

The `SizedBox` approach keeps the two concerns (visual size, touch target)
independently controlled by separate constants.

---

### 2. Drag handle appearance

**Decision:** Widen the visual thumb to 12 dp and add three evenly-spaced
horizontal grip lines (each ~8 dp wide, 2 dp tall, `onSurface` color at reduced
opacity) centred vertically in the pill.

**Alternatives considered:**
- *Three dots (drag-handle icon)*: The `Icons.drag_handle` asset uses horizontal
  bars, which is canonical on Android.  Horizontal bars better suggest vertical
  drag than dots.
- *No visual change, only hit-area expansion*: Does not address discoverability.
- *Use a pre-drawn asset or custom painter*: Unnecessary complexity; `Column` +
  `Container` rows achieves the same result without an asset.

Grip lines use `colorScheme.onSurface.withValues(alpha: 0.4)` so they are
visible in both light and dark themes.  The pill colour remains `primary` at
0.6 alpha.

---

### 3. Neighbour label panel

**Decision:** Add a static helper `groupIndexForFraction()` that returns the
index of the current group within `groupAnchors`.  The peek panel widget
(`_PeekPanel`) calls this to gather up to 2 anchors above and 2 below, then
stacks them vertically with the current group prominent and neighbours
de-emphasised.

**Panel layout:**
- Each row is a single-line `Text`.
- Current group: `titleMedium`, bold, `onPrimary`.
- Neighbours: `bodySmall`, `onPrimary.withValues(alpha: 0.65)`.
- No separator lines; vertical spacing creates rhythm.
- The whole panel replaces `_LabelBubble`; same left-of-thumb positioning logic
  applies, with the vertical anchor point changed from the top edge of the thumb
  to the midpoint of the current-group row.

**Clipping:** The panel's top is clamped to 0 so it never overflows above the
viewport.  When fewer than 2 neighbours exist in a direction (e.g. at the start
of the list), those rows are simply omitted — no placeholder rows.

**Alternatives considered:**
- *Expose `neighbourCount` as a widget parameter*: Premature generalisation;
  a named constant keeps the API simple.
- *Show neighbours always (not just while dragging)*: The static panel would
  add permanent right-edge clutter on every browse-mode load.
- *Scroll the panel instead of clamping*: Adds animation complexity with no
  meaningful benefit.

## Risks / Trade-offs

- **Long group names may push the panel off the left edge of narrow screens.**
  Mitigation: cap panel `maxWidth` at `min(screenWidth * 0.6, 220)`.
- **`groupIndexForFraction` adds a second O(n) scan** (first is
  `labelForFraction`).  With at most ~60 groups in the current dataset this is
  negligible; both helpers could be merged into one in a future cleanup if
  profiling shows otherwise.
- **Widened hit area may overlap the list's own scroll edge** in rare layouts
  where the list has no right padding.  The transparent hit zone occupies space
  that was already empty (the `_thumbRightPadding` region), so no content is
  obscured.

## Platform Notes

### Web: native scrollbar suppression

Flutter web renders a native platform scrollbar on any scrollable widget via
`ScrollBehavior.buildScrollbar`.  When `FastScrollBar` is active it provides
its own scroll indicator, so having both visible is redundant and confusing.

**Decision:** Inject a private `_NoScrollbarBehavior` (a `ScrollBehavior`
subclass that overrides `buildScrollbar` to return the child unchanged) via
`ScrollConfiguration` wrapping `widget.child` inside the `active` path.
This affects only the subtree managed by `FastScrollBar` and does not alter
the global `ScrollConfiguration`.

The `active: false` path returns `widget.child` unwrapped, so the platform
scrollbar is preserved when the custom thumb is intentionally suppressed.

## Open Questions

*(none — scope is clear)*
