## ADDED Requirements

### Requirement: Conformable-units button in freeform AppBar

The freeform page AppBar SHALL include an icon button that opens the
conformable-units modal.  The button SHALL NOT appear when any other page
(e.g. worksheet) is active.

#### Scenario: Button is visible on the freeform page

- **WHEN** the freeform page is active
- **THEN** the conformable-units icon button is present in the AppBar

#### Scenario: Button is absent on other pages

- **WHEN** the worksheet page is active
- **THEN** the conformable-units icon button is not present in the AppBar

### Requirement: Conformable-units button enabled state

The conformable-units button SHALL be enabled when the current `freeformProvider`
state is any of the following result types that carry a well-defined evaluated
quantity:

- `EvaluationSuccess` — a numeric expression result
- `ConversionSuccess` — a two-field conversion result
- `UnitDefinitionResult` — the user typed a bare unit name (e.g. `byte`)
- `FunctionConversionResult` — a function was applied to a value

In all other states (`EvaluationIdle`, `EvaluationError`,
`FunctionDefinitionResult`) the button SHALL be disabled.  `FunctionDefinitionResult`
is specifically excluded because a bare function name (e.g. `tempC`) does not
produce a quantity with a fixed dimension — it is a definition lookup, not an
evaluation.

#### Scenario: Button is enabled after successful evaluation

- **WHEN** `freeformProvider` holds `EvaluationSuccess`
- **THEN** the conformable-units button is enabled

#### Scenario: Button is enabled after successful conversion

- **WHEN** `freeformProvider` holds `ConversionSuccess`
- **THEN** the conformable-units button is enabled

#### Scenario: Button is enabled for a unit definition result

- **WHEN** `freeformProvider` holds `UnitDefinitionResult` (e.g. the user typed `byte`)
- **THEN** the conformable-units button is enabled

#### Scenario: Button is enabled after a function conversion result

- **WHEN** `freeformProvider` holds `FunctionConversionResult` (e.g. `tempC(100)`)
- **THEN** the conformable-units button is enabled

#### Scenario: Button is disabled when input is idle

- **WHEN** `freeformProvider` holds `EvaluationIdle`
- **THEN** the conformable-units button is disabled

#### Scenario: Button is disabled when evaluation errored

- **WHEN** `freeformProvider` holds `EvaluationError`
- **THEN** the conformable-units button is disabled

#### Scenario: Button is disabled for a bare function definition result

- **WHEN** `freeformProvider` holds `FunctionDefinitionResult` (e.g. the user typed `tempC`)
- **THEN** the conformable-units button is disabled

### Requirement: Pressing the button force-evaluates then opens the modal

When the conformable-units button is pressed, any pending debounce timer SHALL
be cancelled and the "Convert from" expression SHALL be evaluated immediately.
After evaluation, if the result is one of the enabled states (`EvaluationSuccess`,
`ConversionSuccess`, `UnitDefinitionResult`, or `FunctionConversionResult`),
the conformable-units modal SHALL be opened.  If evaluation produces any other
result, the modal SHALL NOT open.

#### Scenario: Modal opens after force-evaluate on button press

- **WHEN** the "Convert from" field contains a valid expression and the button
  is pressed before the debounce timer fires
- **THEN** the expression is evaluated immediately and the modal opens

#### Scenario: Modal does not open when force-evaluate errors

- **WHEN** the "Convert from" field contains an invalid expression and the
  button is pressed
- **THEN** the expression is evaluated, produces an error, and the modal does
  not open

### Requirement: Conformable-units modal displays a scrollable list

Pressing the conformable-units button SHALL open a modal bottom sheet
containing a scrollable list of `ConformableEntry` items returned by
`UnitRepository.findConformable` for the evaluated quantity's dimension.

Each list item SHALL display:

- A primary text line:
  - For alias entries (`aliasFor` is non-null): `"<name> = <aliasFor>"` (e.g.
    `"B = byte"`)
  - For all other entries: the entry's `name` alone
- A secondary text line determined as follows:
  - If `functionLabel` is non-null: the `functionLabel` string (e.g.
    `'[function]'` or `'[piecewise linear function]'`)
  - Else if `definitionExpression` is non-null: the `definitionExpression`
    string
  - Else: the string `'[primitive unit]'`

#### Scenario: Modal lists conformable entries for evaluated dimension

- **WHEN** the "Convert from" expression evaluates to a length quantity and the
  button is pressed
- **THEN** the modal contains list items for `m`, `ft`, `km`, and other
  registered length units and functions, sorted case-insensitively by name

#### Scenario: Derived unit item shows definition expression

- **WHEN** the modal contains an entry for `calorie_th` with
  `definitionExpression: '4.184 J'`
- **THEN** the list item's secondary text is `'4.184 J'`

#### Scenario: Primitive unit item shows bracketed label

- **WHEN** the modal contains an entry for `m` with both secondary fields null
- **THEN** the list item's secondary text is `'[primitive unit]'`

#### Scenario: Function item shows bracketed function label

- **WHEN** the modal contains an entry for `tempC` with
  `functionLabel: '[function]'`
- **THEN** the list item's secondary text is `'[function]'`

#### Scenario: Piecewise function item shows bracketed piecewise label

- **WHEN** the modal contains an entry with
  `functionLabel: '[piecewise linear function]'`
- **THEN** the list item's secondary text is `'[piecewise linear function]'`

#### Scenario: Alias item shows "name = target" as primary text

- **WHEN** the modal contains an alias entry with `name: 'B'` and
  `aliasFor: 'byte'`
- **THEN** the list item's primary text is `'B = byte'`

#### Scenario: Alias item shows the target's expression as secondary text

- **WHEN** the modal contains an alias entry with `aliasFor: 'byte'` and
  `definitionExpression: '8 bit'`
- **THEN** the list item's secondary text is `'8 bit'`

### Requirement: Selecting a list item overwrites the Convert-to field

Tapping a list item SHALL dismiss the modal and replace the entire contents of
the "Convert to" text field with the entry's `name`.  Any existing text in the
field is discarded.

Overwriting is used (rather than appending) because the selected unit is
already known to be conformable with the input; appending any existing field
content could produce a non-conformable expression.

After the field is updated, real-time evaluation SHALL be triggered as if the
user had typed the new value.

#### Scenario: Selecting an entry fills an empty Convert-to field

- **WHEN** the "Convert to" field is empty and the user taps the entry `'ft'`
- **THEN** the "Convert to" field contains `'ft'` and the modal is dismissed

#### Scenario: Selecting an entry overwrites existing Convert-to text

- **WHEN** the "Convert to" field contains `'km'` and the user taps `'ft'`
- **THEN** the "Convert to" field contains `'ft'` (not `'km ft'`) and the modal
  is dismissed

#### Scenario: Evaluation is triggered after fill

- **WHEN** the user selects an entry from the modal and the evaluation mode is
  real-time
- **THEN** evaluation runs with the updated "Convert to" value
