## MODIFIED Requirements

### Requirement: Dimension view
In the dimension view the catalog SHALL be displayed as a grouped list keyed
by the resolved output dimension of each entry.

- Each distinct `Dimension` value forms one group.
- The group label SHALL be determined as follows:
  - If `units.json` defines a label for the canonical representation: the label
    followed by the canonical representation in parentheses, separated by a
    space (e.g. `"Acceleration (m / s^2)"`).
  - If no matching key exists: the canonical representation alone
    (e.g. `"m / s^2"`).
- Groups with a defined label SHALL sort before groups whose label is the
  canonical fallback.  Within each tier groups SHALL be sorted
  case-insensitively by their final label.
- Entries within each group SHALL be sorted case-insensitively by name.
- Entries whose dimension could not be resolved SHALL be excluded from the
  dimension view.
- All groups SHALL start collapsed when the dimension view is first entered or
  when the view toggle returns to dimension after visiting another view.
- The dimension view is the default view when the browse page is first opened
  in a session.

#### Scenario: Labeled dimension group shows label and canonical representation
- **WHEN** the dimension view is active and `units.json` defines a label for
  dimension `"m"`
- **THEN** all entries that resolve to `Dimension({m: 1})` appear in a group
  whose header reads `"<label> (m)"` (e.g. `"Length (m)"`)

#### Scenario: Unlabeled dimension falls back to canonical representation
- **WHEN** the dimension view is active and a dimension has no entry in the
  `"dimensions"` map
- **THEN** the group label equals the output of
  `dimension.canonicalRepresentation()` with no parenthesized suffix

#### Scenario: Labeled groups sort above unlabeled groups
- **WHEN** the dimension view is active and both labeled and unlabeled
  dimension groups are present
- **THEN** all labeled groups appear before all unlabeled groups in the list

#### Scenario: Unresolvable entry excluded from dimension view
- **WHEN** a unit's dimension cannot be resolved (e.g. circular definition)
- **THEN** that entry does not appear in any dimension group

#### Scenario: Dimension view groups start collapsed
- **WHEN** the dimension view is first shown
- **THEN** all group headers are visible but no entry rows are visible

#### Scenario: Dimension view is default on first open
- **WHEN** the browse page is opened for the first time in a session
- **THEN** the dimension view is active
