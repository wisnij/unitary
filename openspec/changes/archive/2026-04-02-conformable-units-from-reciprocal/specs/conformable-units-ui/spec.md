## MODIFIED Requirements

### Requirement: Conformable-units button enabled state

The conformable-units button enabled state SHALL be determined by an exhaustive
`switch` over all subtypes of the sealed `EvaluationResult` class.  The button
SHALL be enabled for result types that carry a well-defined evaluated quantity,
and disabled for all others.

A top-level helper `conformableBrowseEnabled(EvaluationResult result) → bool`
SHALL be defined in `freeform_state.dart` and used in both `home_screen.dart`
(for the `browseEnabled` flag) and `freeform_screen.dart` (for the
post-force-evaluate modal-open guard), so the logic is defined in exactly one
place co-located with the `EvaluationResult` sealed class.

The button SHALL be **enabled** for:

- `EvaluationSuccess` — a numeric expression result
- `ConversionSuccess` — a two-field conversion result
- `UnitDefinitionResult` — the user typed a bare unit name (e.g. `byte`)
- `FunctionConversionResult` — a function was applied to a value
- `ReciprocalConversionSuccess` — a reciprocal conversion was performed

The button SHALL be **disabled** for:

- `EvaluationIdle` — no input yet
- `EvaluationError` — the expression failed to evaluate
- `FunctionDefinitionResult` — a bare function name (no fixed-dimension
  quantity)

Because `EvaluationResult` is `sealed`, the Dart compiler enforces exhaustive
coverage of the `switch`; any future subtype that is not explicitly handled will
produce a compile error.

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

#### Scenario: Button is enabled after a reciprocal conversion

- **WHEN** `freeformProvider` holds `ReciprocalConversionSuccess`
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
After evaluation, `conformableBrowseEnabled` SHALL be called on the new result;
if it returns `true`, the conformable-units modal SHALL be opened.  If it
returns `false`, the modal SHALL NOT open.

#### Scenario: Modal opens after force-evaluate on button press

- **WHEN** the "Convert from" field contains a valid expression and the button
  is pressed before the debounce timer fires
- **THEN** the expression is evaluated immediately and the modal opens

#### Scenario: Modal opens after reciprocal conversion force-evaluate

- **WHEN** the "Convert from" field contains a valid expression and the "Convert
  to" field contains a unit whose dimension is the reciprocal of the input, and
  the button is pressed
- **THEN** the expression is evaluated immediately, state becomes
  `ReciprocalConversionSuccess`, and the modal opens

#### Scenario: Modal does not open when force-evaluate errors

- **WHEN** the "Convert from" field contains an invalid expression and the
  button is pressed
- **THEN** the expression is evaluated, produces an error, and the modal does
  not open
