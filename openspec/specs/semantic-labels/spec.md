# Semantic Labels

## Purpose

Gives the app's custom-drawn interactive controls — the Freeform operator key
panel and predictive-completion suggestion overlay, the tappable idle-example
hint, and long-press copy gestures — accessible labels, roles, and actions in
the semantics tree, so assistive technology (screen readers, braille displays,
switch access) can convey what each control does and what kind of entry it is,
independent of the visual glyph or display text.  These labels are inert for
users without assistive technology enabled and produce no visual or behavioral
change.

## Requirements

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

### Requirement: Idle example exposes button semantics

The tappable idle-example display on the freeform screen SHALL expose
`button: true` semantics along with its tap action, so assistive technology
reports it as an actionable control rather than static text.  The visual
appearance SHALL remain unchanged.

#### Scenario: Idle example reported as a button

- **WHEN** assistive technology inspects the idle-example display while the
  freeform screen is idle and an `onTap` handler is present
- **THEN** the semantics node has the button flag set and exposes a tap action

#### Scenario: Non-idle result is not a button

- **WHEN** the result display shows any non-idle evaluation state
- **THEN** its semantics node does not have the button flag set

### Requirement: Long-press copy gestures expose labeled custom actions

Each long-press-to-copy gesture outside the worksheet — the About screen's
copyable rows and the unit entry detail's copyable definition — SHALL expose
the copy action to assistive technology as a labeled `CustomSemanticsAction`
(e.g. "Copy version", "Copy definition"), so the action is discoverable in
TalkBack's actions menu and VoiceOver's rotor.  Invoking the custom action
SHALL have the same effect as the long press, including the confirmation
snackbar.  The long-press gesture itself SHALL remain unchanged.

(The worksheet value-cell copy action is specified in the `worksheet-ui`
capability.)

#### Scenario: About screen copy action discoverable

- **WHEN** assistive technology inspects a copyable About screen row
- **THEN** a labeled custom semantics action is exposed, and invoking it copies
  the row's value to the clipboard

#### Scenario: Unit detail copy action discoverable

- **WHEN** assistive technology inspects the copyable definition text on the
  unit entry detail page
- **THEN** a labeled custom semantics action is exposed, and invoking it copies
  the definition to the clipboard
