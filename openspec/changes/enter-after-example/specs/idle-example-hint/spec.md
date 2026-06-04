## ADDED Requirements

### Requirement: Tapping the idle display unfocuses both input fields
After the example expression is inserted into the "Convert from" field and evaluation is triggered, the system SHALL remove input focus from both freeform text fields, dismissing the on-screen keyboard.  This applies regardless of which field (if any) held focus before the tap.

#### Scenario: Keyboard dismisses after tapping example with no prior focus
- **WHEN** neither freeform field is focused
- **AND** the user taps the idle result display
- **THEN** the "Convert from" field is populated with the example expression and evaluation runs
- **AND** neither freeform field has focus afterwards

#### Scenario: Keyboard dismisses after tapping example when Convert-from was focused
- **WHEN** the "Convert from" field has input focus
- **AND** the user taps the idle result display
- **THEN** the "Convert from" field is populated with the example expression and evaluation runs
- **AND** neither freeform field has focus afterwards

#### Scenario: Keyboard dismisses after tapping example when Convert-to was focused
- **WHEN** the "Convert to" field has input focus
- **AND** the user taps the idle result display
- **THEN** the "Convert from" field is populated with the example expression and evaluation runs
- **AND** neither freeform field has focus afterwards
