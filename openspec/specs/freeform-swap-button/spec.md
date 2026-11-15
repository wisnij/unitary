# Freeform Swap Button

## Purpose

A swap button displayed between the "Convert from" and "Convert to" fields on the
freeform screen, allowing the user to exchange the two field values with a single tap
and immediately re-evaluate the expression.

## Requirements

### Requirement: Swap button enabled state reflects field content
The swap button SHALL be enabled when both the "Convert from" and "Convert to"
fields contain text, and disabled otherwise.

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
When the swap button is tapped, the system SHALL atomically exchange the text content
of the "Convert from" and "Convert to" fields and immediately trigger evaluation.

#### Scenario: Successful swap
- **WHEN** both fields are non-empty and the user taps the swap button
- **THEN** the "Convert from" field contains the previous "Convert to" text
- **AND** the "Convert to" field contains the previous "Convert from" text
- **AND** evaluation is triggered immediately with the new field values

### Requirement: Swap button is present in the app bar
The freeform screen SHALL display the swap button as an action in its app bar
at all times and at every window width, placed before the other app bar
actions.  The button SHALL have a tooltip that describes the action.  The
"Convert from" and "Convert to" fields SHALL be separated by a 16 dp gap with
no control between them.

#### Scenario: Button is in the app bar
- **WHEN** the freeform screen is displayed
- **THEN** a swap button is rendered in the app bar, before the history and conformable-units buttons

#### Scenario: Button has a tooltip
- **WHEN** the swap button is rendered
- **THEN** it exposes the tooltip "Swap from and to"

#### Scenario: No control between the fields
- **WHEN** the freeform screen is displayed
- **THEN** the "Convert to" field starts 16 dp below the bottom of the "Convert from" field

#### Scenario: Present at two-pane widths
- **WHEN** the freeform screen is displayed at a medium or expanded window width
- **THEN** the swap button is still rendered in the app bar
