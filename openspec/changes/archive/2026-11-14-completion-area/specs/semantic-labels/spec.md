## MODIFIED Requirements

### Requirement: Completion suggestions expose name and kind

Each suggestion in the predictive-completion area SHALL expose an accessible
label that includes both the suggestion's name and its kind (unit, prefix, or
function).  The label MUST convey the kind that is otherwise indicated only
visually (the trailing `-` for prefixes and trailing `(` for functions), so a
screen-reader user can distinguish a unit from a prefix from a function.  The
visible display text MUST remain unchanged.

#### Scenario: Prefix suggestion announces its kind

- **WHEN** assistive technology focuses a prefix suggestion whose name is "kilo"
- **THEN** the announced label identifies it as a prefix (e.g. "kilo, prefix")

#### Scenario: Function suggestion announces its kind

- **WHEN** assistive technology focuses a function suggestion whose name is
  "tempC"
- **THEN** the announced label identifies it as a function (e.g. "tempC,
  function")

#### Scenario: Unit suggestion announces its kind

- **WHEN** assistive technology focuses a unit suggestion whose name is "meter"
- **THEN** the announced label identifies it as a unit (e.g. "meter, unit")

#### Scenario: Visual display text is unchanged

- **WHEN** the completion area is rendered
- **THEN** each suggestion still shows its original display text (plain name,
  `name-`, or `name(`) with no visible change
