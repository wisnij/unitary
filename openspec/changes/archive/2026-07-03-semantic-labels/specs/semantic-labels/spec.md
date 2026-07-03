## ADDED Requirements

### Requirement: Operator keys expose accessible action labels

Each key in the Freeform operator key panel SHALL expose an accessible label
through the semantics tree describing the operation it performs, rather than
relying on the rendered glyph.  The label MUST be a human-readable word or short
phrase (for example "multiply" for `*`, "divide" for `/`, "power" for `^`,
"inverse" for `~`, "open parenthesis" for `(`).  The visible glyph MUST remain
unchanged, and the raw glyph MUST NOT be announced in place of the label.

#### Scenario: Screen reader announces an operator key by its action

- **WHEN** assistive technology focuses the `*` operator key
- **THEN** the announced label is "multiply" (not the glyph "*")

#### Scenario: Every operator key has a non-empty label

- **WHEN** the key panel is rendered
- **THEN** every key in `freeformKeyPanelSymbols` has a non-empty accessible
  label in the semantics tree

#### Scenario: Visual glyph is unchanged

- **WHEN** the key panel is rendered
- **THEN** each key still displays its original glyph text and layout is
  unaffected

### Requirement: Completion suggestions expose name and kind

Each suggestion in the predictive-completion overlay SHALL expose an accessible
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

- **WHEN** the completion overlay is rendered
- **THEN** each suggestion still shows its original display text (plain name,
  `name-`, or `name(`) with no visible change
