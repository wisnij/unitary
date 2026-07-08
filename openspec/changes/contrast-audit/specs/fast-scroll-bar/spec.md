# Fast Scroll Bar — contrast-audit delta

## MODIFIED Requirements

### Requirement: Drag handle appearance
The `FastScrollBar` thumb SHALL be styled to communicate that it is a draggable
handle, not a passive indicator.

- The thumb SHALL use a pill shape wider than a standard scrollbar (≥ 10 dp).
- The thumb's composited fill SHALL have a WCAG 2.x contrast ratio of at least
  3:1 against the page surface in both light and dark themes.
- The thumb SHALL display three short horizontal grip lines centred vertically
  within the pill, visually indicating vertical drag affordance.
- The grip lines SHALL be rendered in a colour derived from `onPrimary` with a
  WCAG 2.x contrast ratio of at least 3:1 against the composited thumb fill in
  both light and dark themes.

#### Scenario: Thumb displays grip lines
- **WHEN** the thumb is visible
- **THEN** three horizontal grip lines are visible centred within the pill

#### Scenario: Grip lines visible in dark theme
- **WHEN** the app is in dark mode and the thumb is visible
- **THEN** the grip lines are visually distinct from the pill background, with
  at least 3:1 contrast against it

#### Scenario: Thumb perceivable against light surface
- **WHEN** the thumb is rendered over the light-theme surface
- **THEN** its composited fill has at least 3:1 contrast against that surface

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
- The de-emphasised neighbour labels SHALL retain a WCAG 2.x contrast ratio of
  at least 4.5:1 against the panel background in both light and dark themes;
  de-emphasis is carried by text size and weight, not by contrast alone.
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

#### Scenario: Neighbour labels legible while de-emphasised
- **WHEN** the panel shows neighbour labels in either theme
- **THEN** each neighbour label's composited text color has at least 4.5:1
  contrast against the panel background
