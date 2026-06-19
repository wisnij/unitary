## ADDED Requirements

### Requirement: Enter in the Convert-from field advances focus to the Convert-to field

When the user submits the "Convert from" field (presses Enter / the keyboard
action key), the system SHALL move input focus to the "Convert to" field rather
than dismissing input focus.  The system keyboard SHALL remain visible, now
editing the "Convert to" field.

Submitting the "Convert from" field SHALL also trigger evaluation, so on-submit
evaluation mode continues to produce a result.

#### Scenario: Enter in Convert-from moves focus to Convert-to

- **WHEN** the "Convert from" field has input focus and the user presses Enter
- **THEN** the "Convert to" field receives input focus
- **AND** the system keyboard remains visible

#### Scenario: Enter in Convert-from still evaluates in on-submit mode

- **WHEN** the evaluation mode is on-submit
- **AND** the user presses Enter in the "Convert from" field
- **THEN** the current expression is evaluated and the result is displayed

### Requirement: Enter in the Convert-to field dismisses input focus

When the user submits the "Convert to" field (presses Enter / the keyboard
action key), the system SHALL dismiss input focus, ending text entry and
hiding the system keyboard, as it does today.

Submitting the "Convert to" field SHALL also trigger evaluation.

#### Scenario: Enter in Convert-to dismisses focus

- **WHEN** the "Convert to" field has input focus and the user presses Enter
- **THEN** neither freeform field retains input focus
- **AND** the system keyboard is dismissed

#### Scenario: Enter in Convert-to evaluates

- **WHEN** the user presses Enter in the "Convert to" field
- **THEN** the current expression is evaluated and the result is displayed
