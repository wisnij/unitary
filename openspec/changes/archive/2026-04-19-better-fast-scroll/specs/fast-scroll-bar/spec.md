## ADDED Requirements

### Requirement: Drag handle appearance
The `FastScrollBar` thumb SHALL be styled to communicate that it is a draggable
handle, not a passive indicator.

- The thumb SHALL use a pill shape wider than a standard scrollbar (≥ 10 dp).
- The thumb SHALL display three short horizontal grip lines centred vertically
  within the pill, visually indicating vertical drag affordance.
- The grip lines SHALL be rendered in a colour that contrasts with the pill
  background and remains legible in both light and dark themes.

#### Scenario: Thumb displays grip lines
- **WHEN** the thumb is visible
- **THEN** three horizontal grip lines are visible centred within the pill

#### Scenario: Grip lines visible in dark theme
- **WHEN** the app is in dark mode and the thumb is visible
- **THEN** the grip lines are visually distinct from the pill background

---

## MODIFIED Requirements

### Requirement: Draggable scroll thumb
The `FastScrollBar` widget SHALL display a draggable thumb on the right edge of
its child scrollable area when the content is taller than the viewport.

- The thumb SHALL be positioned vertically in proportion to the current scroll
  fraction (`pixels / maxScrollExtent`).
- Dragging the thumb SHALL call `ScrollController.jumpTo()` to move the list to
  the corresponding scroll offset.
- All `ScrollController` interactions SHALL be guarded by `hasClients`; no
  call SHALL be made while the controller has no attached scroll position.
- The thumb SHALL not be rendered when `ScrollController.position.maxScrollExtent`
  is zero (content fits on screen without scrolling).
- The interactive hit area of the thumb SHALL be at least 44 dp wide,
  independent of the visual thumb width, to meet mobile touch-target guidelines.

#### Scenario: Thumb position reflects scroll offset
- **WHEN** the user scrolls the list to the halfway point
- **THEN** the thumb is positioned at the vertical midpoint of the list area

#### Scenario: Dragging thumb scrolls the list
- **WHEN** the user drags the thumb downward by half the list height
- **THEN** the list scrolls forward to approximately the midpoint of its total
  content

#### Scenario: Thumb absent when content fits on screen
- **WHEN** the total content height is less than or equal to the viewport height
- **THEN** no thumb is rendered

#### Scenario: Hit area wider than visual thumb
- **WHEN** the thumb is visible
- **THEN** the draggable hit area extends at least 44 dp from the right edge,
  regardless of the visual thumb width

---

### Requirement: Group label bubble
While the thumb is being dragged, the `FastScrollBar` SHALL display a label
panel to the left of the thumb showing the current group and its immediate
neighbours.

- The label SHALL be derived from the `groupAnchors` list: an ordered list of
  `(itemIndex, label)` pairs, one per group header.
- The label for a given scroll fraction SHALL be the label of the last anchor
  whose `itemIndex` is ≤ `(fraction × itemCount).round()`.
- The panel SHALL display the current group label prominently in the centre,
  with up to 2 neighbouring group labels above and up to 2 below, in a
  de-emphasised style.
- Neighbour rows SHALL be omitted when fewer than the maximum number of
  neighbours exist in that direction (e.g. at the start or end of the list).
- The panel SHALL appear immediately when a drag gesture begins and disappear
  immediately when the drag ends.
- The panel SHALL be clamped so it does not overflow above the top of the
  viewport.

#### Scenario: Panel shows correct group at start of drag
- **WHEN** the user begins dragging the thumb at the top of the list
- **THEN** the panel's prominent label shows the first group, with up to 2
  following groups shown below it

#### Scenario: Current group updates as thumb moves
- **WHEN** the user drags the thumb past the boundary of a new group
- **THEN** the panel's prominent label changes to that group's label

#### Scenario: Neighbours shown while dragging mid-list
- **WHEN** the user drags the thumb to a position with at least 2 groups above
  and 2 groups below the current group
- **THEN** the panel shows 2 neighbour labels above the current group and 2
  neighbour labels below it

#### Scenario: Fewer neighbours shown near list boundaries
- **WHEN** the user drags the thumb to a position with only 1 group above the
  current group
- **THEN** only 1 neighbour label is shown above the current group

#### Scenario: Panel hidden when not dragging
- **WHEN** the user is not actively dragging the thumb
- **THEN** no label panel is shown
