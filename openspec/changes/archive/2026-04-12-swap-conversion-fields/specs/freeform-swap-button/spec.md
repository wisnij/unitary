## ADDED Requirements

### Requirement: Swap button is present between the two input fields
The freeform screen SHALL display a swap button between the "Convert from" and "Convert to" fields at all times.

#### Scenario: Button is visible in the layout
- **WHEN** the freeform screen is displayed
- **THEN** a swap button is rendered between the two text fields

### Requirement: Swap button enabled state reflects field content
The swap button SHALL be enabled when both the "Convert from" and "Convert to" fields contain text, and disabled otherwise.

#### Scenario: Both fields are non-empty
- **WHEN** both the "Convert from" and "Convert to" fields contain at least one character
- **THEN** the swap button is enabled

#### Scenario: Input field is empty
- **WHEN** the "Convert from" field is empty (regardless of the "Convert to" field)
- **THEN** the swap button is disabled

#### Scenario: Output field is empty
- **WHEN** the "Convert to" field is empty (regardless of the "Convert from" field)
- **THEN** the swap button is disabled

#### Scenario: Both fields are empty
- **WHEN** both fields are empty
- **THEN** the swap button is disabled

### Requirement: Tapping swap exchanges field contents and re-evaluates
When the swap button is tapped, the system SHALL atomically exchange the text content of the "Convert from" and "Convert to" fields and immediately trigger evaluation.

#### Scenario: Successful swap
- **WHEN** both fields are non-empty and the user taps the swap button
- **THEN** the "Convert from" field contains the previous "Convert to" text
- **AND** the "Convert to" field contains the previous "Convert from" text
- **AND** evaluation is triggered immediately with the new field values
