## MODIFIED Requirements

### Requirement: Collapsible groups
Group headers in both views SHALL be tappable to toggle the expanded/collapsed
state of that group.

- A trailing chevron icon SHALL indicate the current state: pointing down when
  expanded, pointing right when collapsed.
- Collapsed groups show only their header row; entry rows are hidden.
- Switching between views SHALL reset each view to its default collapsed/
  expanded state (alphabetical: all expanded; dimension: all collapsed).
- The AppBar SHALL contain an **Expand All** button (tooltip "Expand all") that
  expands every group in the current view by clearing the collapsed set.
- The AppBar SHALL contain a **Collapse All** button (tooltip "Collapse all")
  that collapses every group in the current view by adding all group labels to
  the collapsed set.
- Both buttons SHALL be disabled while a search query is active.

#### Scenario: Tapping an expanded group header collapses it
- **WHEN** a group is expanded and the user taps its header
- **THEN** the group's entry rows are hidden and the chevron points right

#### Scenario: Tapping a collapsed group header expands it
- **WHEN** a group is collapsed and the user taps its header
- **THEN** the group's entry rows become visible and the chevron points down

#### Scenario: Switching views resets collapse state
- **WHEN** the user collapses some groups in one view and then switches to the
  other view and back
- **THEN** the first view's groups are back to their default expanded/collapsed
  state

#### Scenario: Expand All expands every group
- **WHEN** some groups are collapsed and the user taps the Expand All button
- **THEN** all group headers show the expanded chevron and all entry rows are
  visible

#### Scenario: Collapse All collapses every group
- **WHEN** some groups are expanded and the user taps the Collapse All button
- **THEN** all group headers show the collapsed chevron and no entry rows are
  visible

#### Scenario: Expand All and Collapse All are disabled during search
- **WHEN** a non-empty search query is active
- **THEN** the Expand All and Collapse All buttons are disabled
