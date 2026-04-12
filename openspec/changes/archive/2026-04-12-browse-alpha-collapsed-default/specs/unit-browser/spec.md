## MODIFIED Requirements

### Requirement: Alphabetical view
In the alphabetical view the catalog SHALL be displayed as a grouped list
keyed by the case-insensitive first character of the entry name.

- Groups A through Z contain entries whose name begins with the corresponding
  letter (case-insensitive).
- A final `#` group contains entries whose name begins with any non-letter
  character.
- Groups SHALL be sorted A → Z with `#` last.
- Entries within each group SHALL be sorted case-insensitively by name.
- All groups SHALL start collapsed when the alphabetical view is first entered.

#### Scenario: Letter group contains correct entries
- **WHEN** the alphabetical view is active
- **THEN** an entry whose name begins with `"f"` or `"F"` appears in the `F`
  group

#### Scenario: Non-letter entries in # group
- **WHEN** the alphabetical view is active
- **THEN** an entry whose name begins with a digit or symbol appears in the
  `#` group

#### Scenario: Groups start collapsed in alphabetical view
- **WHEN** the browser is navigated to for the first time in a session with
  the alphabetical view active
- **THEN** all letter groups are collapsed

---

### Requirement: Collapsible groups
Group headers in both views SHALL be tappable to toggle the expanded/collapsed
state of that group.

- A trailing chevron icon SHALL indicate the current state: pointing down when
  expanded, pointing right when collapsed.
- Collapsed groups show only their header row; entry rows are hidden.
- Switching between views SHALL reset each view to its default collapsed/
  expanded state (alphabetical: all collapsed; dimension: all collapsed).
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

#### Scenario: Expand All and Collapse All are disabled during search
- **WHEN** a non-empty search query is active
- **THEN** the Expand All and Collapse All buttons are disabled
