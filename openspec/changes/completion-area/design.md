## Context

`CompletionField` wraps each freeform `TextField` and owns its own suggestion overlay (`OverlayPortal` + `CompositedTransformFollower`).  The overlay opens below the field unless the field is in the lower half of the viewport, shows up to 8 rows of 48 dp, and covers whatever is beneath it: the swap button, the other field, and the result display.

The freeform body is currently:

```
Column
├─ Expanded
│  └─ ReadableWidth
│     └─ SingleChildScrollView      (from field, swap, to field, result)
└─ _KeyPanel                        (when shown)
```

`ReadableWidth` is `Align(topCenter)` + `ConstrainedBox(maxWidth: 600)`.  The key panel is shown when a field has focus on mobile, and always on desktop and web.

Estimated free height below the result with the keyboard open, before the swap row is removed (from widget sizes, not measured): about 165 dp on a tall phone with a one-line result, about 110 dp with a multi-line conversion result, and about 40 dp on a short phone.

Constraints that must keep holding:

- The `rebuild-scope` spec: a keystroke rebuilds the freeform screen subtree root zero times.
- 48 dp touch targets and the `"<name>, <kind>"` accessible labels.
- On web, the browser moves focus away from the text field at pointer-down, before `onTap` fires.

## Goals / Non-Goals

**Goals:**

- Suggestions never cover a field or the result.
- The area uses whatever free space exists and still works when there is almost none.
- Browsing stays possible: all suggestions (up to the repository limit of 50) are reachable by scrolling.
- One design for every window width and for web.

**Non-Goals:**

- Changing which suggestions are produced or how they are ranked.
- Keyboard selection of suggestions.
- Using the area for anything other than completions.

## Decisions

### D1: One shared `CompletionArea` widget, owned by the screen

A new `CompletionAreaLayout` widget receives the two fields' controllers, focus nodes, and `onChanged` callbacks (as `CompletionTarget`s) and the scrolling content as its child.  It listens to all four listenables, picks the field that has focus, builds the `CompletionQuery` from that field's text and cursor, and watches `completionsProvider`.  Selecting a chip applies `applyCompletion` to the focused field's controller, restores focus and the cursor position, and calls that field's `onChanged`.

The chips themselves are drawn by `CompletionArea`, a presentational widget that takes a list of suggestions and a selection callback.  Splitting the two keeps the provider and focus logic out of the rendering, so a later switch from chips to rows touches only `CompletionArea`.

`CompletionField` keeps its name and its role as the configured `TextField` wrapper (soft wrap, keyboard type, autocorrect and suggestions off).  The overlay, the layer link, the above/below logic, and the suggestion watch are removed from it.  `applyCompletion` and `completionSemanticLabel` move with the code that uses them; the display-name and insert-text helpers move to the area.

*Alternative considered:* keep the suggestion logic in each `CompletionField` and have it publish suggestions upward.  Rejected: two publishers for one display needs extra state and gives nothing in return.

### D2: Layout with `CustomMultiChildLayout`

The area's height depends on the height of the content above it, which a plain `Column` cannot express (a loose `Flexible` does not give its unused space to a sibling).  A small layout widget with a `MultiChildLayoutDelegate` does it in one pass:

1. Lay out the content (the `SingleChildScrollView`) with a loose height limit.  The limit is the full height when there are no suggestions, and the full height minus one chip line (48 dp) when there are.  The scroll view shrink-wraps to its content when the content is shorter than the limit.
2. Lay out the area with a tight height equal to the remaining space, and place it directly below the content.

```
Column
├─ Expanded
│  └─ ReadableWidth
│     └─ (layout widget)
│        ├─ content: SingleChildScrollView   height ≤ H − floor
│        └─ area:    CompletionArea          height = H − content
└─ _KeyPanel
```

`ReadableWidth` moves outside the layout widget, so the area has the same 600 dp cap and centering as the fields.  The delegate itself fills its incoming constraints, which is what `Expanded` gives it.

The floor applies only while suggestions are showing.  On a screen with at least 48 dp free, nothing above the area moves when suggestions appear or disappear.  On a shorter screen, the scroll viewport shrinks by at most 48 dp while suggestions are showing.

*Alternatives considered:* measuring the content with a `GlobalKey` after the frame (one frame late, visible jump); putting the area inside the scroll view (it would scroll away instead of staying above the key panel); a fixed-height strip (wastes the free space on tall phones and tablets, which is most of the benefit for browsing).

### D3: The layout host must not rebuild the content

The layout widget (`FreeSpaceLayout`) needs to know whether suggestions are showing, which changes with keystrokes.  The widget that computes this (`CompletionAreaLayout`) takes the scrolling content as a prebuilt `child` from the screen.  When it rebuilds, the content widget instance is identical, so Flutter does not rebuild the content subtree.  The existing rebuild-scope tests must pass unchanged in their bounds.

### D4: Chips in a `Wrap` inside a vertical scroll view

Suggestions render in rank order in a `Wrap`, inside a `SingleChildScrollView`, aligned to the top-left of the area.  All suggestions are built (at most 50).  The scroll position returns to the top when the query changes.

Each chip is an `OutlinedButton` styled as a pill: 32 dp high, at least 48 dp wide, with the button's padded tap target making the touch target 48 dp high.  Taps in that padding count as taps on the pill, while the hover and press highlights stay inside its border, and a narrow chip is not indented.  `ActionChip` was not used because its sizing and web tap handling (D5) are harder to control.  A chip is never wider than the area; a longer name is ellipsized.

Chips use standard Material 3 role pairings unmodified: `onSurface` text on the page surface with an `outline` border.  Standard pairings are outside the `color-contrast` spec, so no new pinned pairing or exemption is needed.  The overlay's `outlineVariant` exemption is deleted.

*Alternative considered:* full-width rows, as in the overlay.  Rejected for the trial: at 48 dp per row, 165 dp shows 3 candidates, where chips show about 10.  The maintainer may revisit this after using it.

### D5: Keep the existing tap handling per platform

On web the chip inserts at pointer-down, through a `Listener` around the button (pointer-down arrives before the browser's focus-out clears the suggestions); elsewhere it inserts when the press completes, so a scroll drag that starts on a chip does not insert it.  This is the overlay's current behaviour, moved as is.

### D6: When the area shows suggestions

Same rule as today: a field has focus, a token is detected at its cursor, and at least one suggestion exists.  Otherwise the area is empty and takes no minimum height.  After a chip is tapped the area updates from the new text; for a unit the inserted trailing space ends the token, so the area empties.

### D7: Swap button in the app bar

The swap button's row between the fields is removed and replaced by a 16 dp gap, which returns about 32 dp to the area on every screen.  The button becomes the first app bar action, before history and conformable units, at every window width.  It keeps the `swap_vert` icon (the fields are still stacked) and gains the tooltip "Swap from and to", matching the other app bar actions, which all have tooltips.  It still listens to both controllers through a `ListenableBuilder`, so its enabled state updates without a screen rebuild.

At compact width the app bar then holds the drawer button, the title "Unitary", and three actions, which fits a 360 dp phone.

*Alternative considered:* placing the button inside or beside one of the fields.  Rejected: it competes with the clear button and narrows the text.

## Risks / Trade-offs

- **Fewer candidates on small screens than the overlay's 8 rows** → chips pack several per line, and the area scrolls.  On a one-line area the first three or four ranked candidates are visible, so ranking quality matters more; ranking is a recorded follow-up.
- **Chips are harder to scan than a vertical list** → accepted as a trial; D1 keeps the rendering in one widget so switching to rows is a local change.
- **Area height changes as the result changes height** (for example one-line result to a conversion with a reciprocal) → the chips reflow.  This happens after the evaluation debounce, not on each keystroke.
- **The swap button is farther from the fields and from the thumb** → accepted for the height it frees; swap is used far less often than typing.
- **Short screens: the result can be pushed partly out of view** → accepted by the maintainer; the content stays scrollable.
- **The height estimates are not measured** → verify on a phone with the keyboard open, in both orientations, as a task.
- **Web: `onTapDown` inserts when a touch scroll starts on a chip** → existing behaviour of the overlay on web; not made worse.
- **`SingleChildScrollView` now shrink-wraps**, so the empty space below the result is no longer part of the scroll view → no functional effect expected; check that tap-outside and overscroll still feel right.

## Migration Plan

No data or settings change.  The change is a UI replacement in one screen; rollback is reverting the commit.

## Open Questions

- Chip visuals (pill shape, 32 dp height, 8 dp spacing) are a starting point to adjust on a device.
- Whether chips should stay after the trial or become full-width rows.
