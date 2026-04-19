## Why

The fast-scroll thumb on the browse page is a 6×48 px visual target with no
invisible hit-area expansion, making it nearly impossible to grab reliably on a
mobile touchscreen.  The thumb is also a plain rounded rectangle with no visual
cues that it is interactive, so users may not realise it can be dragged.
Additionally, the group-label bubble currently shows only the single group at
the current thumb position, giving the user no spatial context about what lies
above or below — they must drag blindly to find a distant group.

## What Changes

- Expand the touch target of the scroll thumb to a comfortable mobile width
  (≥ 44 dp).
- Restyle the thumb to look like a standard drag handle (e.g. a wider pill with
  grip lines/dots), so users understand at a glance that it is draggable.
- Replace the single-label group bubble with a multi-label "peek" panel that
  shows the current group in the center plus a configurable number of
  neighbouring groups above and below, so the user can see surrounding groups
  while dragging and use them as approximate scroll targets.

## Capabilities

### New Capabilities

*(none — all changes are modifications to the existing fast-scroll-bar
capability)*

### Modified Capabilities

- `fast-scroll-bar`: Three requirement changes:
  1. The draggable thumb's interactive hit area must be wide enough for
     comfortable mobile use (≥ 44 dp), independent of the visual thumb width.
  2. The thumb's visual appearance must clearly indicate it is a drag handle
     (e.g. a wider pill shape with grip lines or dots).
  3. The group-label bubble must display neighbouring group labels above and
     below the current group label while the thumb is being dragged.

## Impact

- `lib/shared/widgets/fast_scroll_bar.dart` — widen `GestureDetector` hit area;
  restyle `_ThumbWidget` as a drag handle; replace `_LabelBubble` with a
  multi-label peek panel widget.
- `openspec/specs/fast-scroll-bar/spec.md` — delta spec updating the two
  affected requirements.
- Widget tests in `test/shared/widgets/fast_scroll_bar_test.dart` — new and
  updated test cases covering wider hit area, drag-handle appearance, and
  neighbour label rendering.
