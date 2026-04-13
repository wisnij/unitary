## MODIFIED Requirements

### Requirement: Collapsible groups
Group headers in both views SHALL be tappable to toggle the expanded/collapsed
state of that group.

- A trailing chevron icon SHALL indicate the current state: pointing down when
  expanded, pointing right when collapsed.  This applies at all times, including
  while a search query is active.
- Collapsed groups show only their header row; entry rows are hidden.
- Switching between views SHALL reset each view to its default collapsed/
  expanded state (alphabetical: all collapsed; dimension: all collapsed).
- The AppBar SHALL contain an **Expand All** button (tooltip "Expand all") that
  expands every group in the current view by clearing the collapsed set.
- The AppBar SHALL contain a **Collapse All** button (tooltip "Collapse all")
  that collapses every group in the current view by adding all group labels to
  the collapsed set.
- Both buttons SHALL remain enabled and functional while a search query is
  active.

#### Scenario: Tapping an expanded group header collapses it
- **WHEN** a group is expanded and the user taps its header
- **THEN** the group's entry rows are hidden and the chevron points right

#### Scenario: Tapping a collapsed group header expands it
- **WHEN** a group is collapsed and the user taps its header
- **THEN** the group's entry rows become visible and the chevron points down

#### Scenario: Switching views resets collapse state
- **WHEN** the user expands some groups in the alphabetical view and then
  switches to the dimension view and back
- **THEN** the alphabetical view's groups are all collapsed again

#### Scenario: Expand All expands every group
- **WHEN** some groups are collapsed and the user taps the Expand All button
- **THEN** all group headers show the expanded chevron and all entry rows are
  visible

#### Scenario: Collapse All collapses every group
- **WHEN** some groups are expanded and the user taps the Collapse All button
- **THEN** all group headers show the collapsed chevron and no entry rows are
  visible

#### Scenario: Expand All and Collapse All are enabled during search
- **WHEN** a non-empty search query is active
- **THEN** the Expand All and Collapse All buttons are enabled and functional

#### Scenario: Tapping a group header during search shows correct chevron
- **WHEN** a non-empty search query is active and the user taps a group header
- **THEN** the chevron icon reflects the new collapsed/expanded state of that group

#### Scenario: Expand All during search expands all visible groups
- **WHEN** a non-empty search query is active and some groups are collapsed
- **THEN** tapping Expand All expands all groups and shows the expanded chevron
  for each

#### Scenario: Collapse All during search collapses all visible groups
- **WHEN** a non-empty search query is active and some groups are expanded
- **THEN** tapping Collapse All collapses all groups and shows the collapsed
  chevron for each
