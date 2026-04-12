# Fast Scroll Bar Spec

## Purpose

Define the requirements for `FastScrollBar`, a draggable thumb overlay that
enables fast navigation of long scrollable lists and displays a group-label
bubble while dragging.

## Requirements

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

---

### Requirement: Group label bubble
While the thumb is being dragged, the `FastScrollBar` SHALL display a label
bubble to the left of the thumb showing the name of the group at the current
scroll position.

- The label SHALL be derived from the `groupAnchors` list: an ordered list of
  `(itemIndex, label)` pairs, one per group header.
- The label for a given scroll fraction SHALL be the label of the last anchor
  whose `itemIndex` is ≤ `(fraction × itemCount).round()`.
- The bubble SHALL appear immediately when a drag gesture begins and disappear
  immediately when the drag ends.

#### Scenario: Label shows correct group at start of drag
- **WHEN** the user begins dragging the thumb at the top of the list
- **THEN** the label bubble shows the label of the first group

#### Scenario: Label updates as thumb moves down
- **WHEN** the user drags the thumb past the boundary of a new group
- **THEN** the label bubble text changes to that group's label

#### Scenario: Label hidden when not dragging
- **WHEN** the user is not actively dragging the thumb
- **THEN** no label bubble is shown

---

### Requirement: Thumb fade visibility
The thumb SHALL fade in when the list is scrolled and fade out after a short
idle period.

- The thumb SHALL fade in (become fully visible) whenever the
  `ScrollController` emits a scroll event.
- After the last scroll event, the thumb SHALL fade out after an idle timeout
  of approximately 1.5 seconds.
- While the thumb is being dragged, the idle timer SHALL be suspended and the
  thumb SHALL remain fully visible.
- When the drag ends, the idle timer SHALL restart.

#### Scenario: Thumb fades in on scroll
- **WHEN** the user scrolls the list
- **THEN** the thumb becomes visible

#### Scenario: Thumb fades out after idle
- **WHEN** the user stops scrolling and does not interact with the thumb for
  approximately 1.5 seconds
- **THEN** the thumb fades out and is no longer visible

#### Scenario: Thumb stays visible while dragging
- **WHEN** the user is actively dragging the thumb
- **THEN** the thumb remains fully visible regardless of idle timeout

---

### Requirement: Active flag suppresses overlay
When the `active` parameter is `false`, `FastScrollBar` SHALL render only its
`child` with no thumb or label bubble.

#### Scenario: Thumb hidden when inactive
- **WHEN** `FastScrollBar.active` is `false`
- **THEN** neither the thumb nor any label bubble is visible
