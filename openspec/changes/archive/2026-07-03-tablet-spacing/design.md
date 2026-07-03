## Context

Freeform, Worksheet, and Settings present single-column content inside a pane
sized `PaneSize.fill()` (or, for Settings, a full-width `ListView`).  With nothing
capping the column, content stretches to the full pane width, which on landscape
tablets and desktop web yields over-wide input fields and long line lengths.  This
is the "spacing at tablet sizes" concern from Phase 9 tablet support; touch
targets were separately verified as fine on-device.

## Goals / Non-Goals

**Goals:**

- Cap single-column content at a comfortable readable width, centered, on wide
  layouts.
- Leave phone layouts byte-for-byte unchanged.
- Define the cap in one shared place so it is consistent and trivially tunable.

**Non-Goals:**

- Changing padding scale or the fixed pane widths (220 dp templates, 320 dp
  history).
- Capping the Browse detail pane and About screen (deferred until 600 dp is
  validated on-device).
- Any responsive-tier or orientation logic — the cap is width-driven and inert
  below the threshold.

## Decisions

### A shared `ReadableWidth` wrapper with a single max-width constant

Add one small stateless widget under `lib/shared/` (e.g. `ReadableWidth`) that
wraps its child in `Align(alignment: Alignment.topCenter, child: ConstrainedBox(
maxWidth: kReadableMaxWidth, child: child))`, with `kReadableMaxWidth = 600`.
Each screen wraps its single-column content in it.

- **Why a shared widget + constant over per-screen `ConstrainedBox`:** keeps the
  600 dp value in one place (the spec requires a single consistent cap) and makes
  future tuning a one-line change.
- **Why the cap is inert on phones:** a max-width constraint has no effect when
  the incoming constraints are narrower than the cap, so phone widths are
  unaffected with no branching on size class.
- **Why `Align(topCenter)` and not `Center`:** `Center` expands to fill its
  incoming constraints on *both* axes, which throws an infinite-height error
  inside a vertical scroll view (unbounded main axis).  `Align(topCenter)` caps
  and horizontally centers width while leaving the child's natural vertical
  extent and top alignment untouched, so the same widget is safe to place around
  scrolling content in any of the three screens.

### Placement per screen

- **Freeform:** wrap the `SingleChildScrollView` itself (inside the left `fill`
  pane's `Expanded`), so the scrolling content is capped and centered while the
  key panel — a sibling below it in the outer `Column` — stays full width.
  Wrapping the scroll view (whose height is bounded by the `Expanded`) rather
  than its child column keeps `Align`'s vertical extent well-defined.
- **Worksheet:** wrap the `LayoutBuilder` in the right `fill` pane.  Wrapping at
  this level means the `LayoutBuilder` sees the already-capped 600 dp width, so
  its `maxLabelWidth` computation is measured against the real content width; the
  existing label-column cap (`IntrinsicColumnWidth`, max 200 dp) is unaffected.
  The banner above it stays full width.
- **Settings:** wrap the `ListView` body.  A `ListView` reports unbounded-ish
  width from its parent, so the wrapper caps and centers the list within the
  screen.

### Interaction with the safe-area wrap

These screens already wrap their bodies in `SafeArea` (from the safe-area change).
`ReadableWidth` goes *inside* `SafeArea` so the cap is measured against the
already-inset width, and cutout insets still apply.

## Risks / Trade-offs

- **Horizontal-only capping around a vertically-scrolling view** → resolved by
  using `Align(topCenter)` rather than `Center`: it constrains only the
  cross-axis (width) and defers vertical extent to the child, so scroll behavior
  is unchanged (only `maxWidth` is added) and there is no infinite-height error.
- **600 dp may not be the final value** → it is a single shared constant, so
  tuning after on-device review is a one-line change; the spec fixes the initial
  value at 600 dp deliberately.
- **Freeform key panel alignment** → the key panel sits below the scroll content;
  centering the scroll column must not shift or misalign the full-width key panel.
  Wrap only the scroll content, leaving the key panel as a sibling at full width.
