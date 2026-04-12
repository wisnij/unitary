## ADDED Requirements

### Requirement: Fast-scroll bar in browse list
The browse list SHALL display a `FastScrollBar` overlay in both alphabetical
and dimension views.

- The `FastScrollBar` SHALL be supplied the `ScrollController` owned by the
  browse list widget, the total flat-list item count, and a `groupAnchors` list
  derived from the flat item list (one entry per group header, in order).
- The `FastScrollBar` SHALL be inactive (`active: false`) whenever the search
  query is non-empty, hiding the thumb and label bubble for the duration of
  the search.
- In alphabetical view the group anchor labels SHALL be the single-character
  letter (or `#`) of each group header.
- In dimension view the group anchor labels SHALL be the human-readable
  dimension name of each group header.

#### Scenario: Fast-scroll thumb visible on browse list
- **WHEN** the browse page is open with enough entries to scroll
- **THEN** scrolling the list causes the fast-scroll thumb to appear on the
  right edge

#### Scenario: Label shows letter group in alphabetical view
- **WHEN** the alphabetical view is active and the user drags the thumb
- **THEN** the label bubble shows the letter of the group at the current
  scroll position (e.g. `"M"`)

#### Scenario: Label shows dimension name in dimension view
- **WHEN** the dimension view is active and the user drags the thumb
- **THEN** the label bubble shows the human-readable dimension name of the
  group at the current scroll position (e.g. `"Length"`)

#### Scenario: Fast-scroll hidden during search
- **WHEN** the user has entered a non-empty search query
- **THEN** the fast-scroll thumb is not shown
