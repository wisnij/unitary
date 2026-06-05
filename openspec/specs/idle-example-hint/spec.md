# Spec: idle-example-hint

## Purpose

When the freeform screen is idle (no expression has been entered), display a curated example expression as a hint to help users discover app features.  The hint is visually distinct from real output and is tappable to auto-fill the input field.


## Requirements

### Requirement: Example list exists
The system SHALL maintain a curated, non-empty list of `FreeformExample` objects covering a variety of app features (unit conversions, SI prefixes, physical constants, defined functions, compound expressions).  Each `FreeformExample` has a required `inputExpression` field (the "Convert from" expression) and an optional `outputExpression` field (the "Convert to" expression).

#### Scenario: List is non-empty
- **WHEN** the app is compiled
- **THEN** the example list contains at least 10 entries

#### Scenario: All examples are evaluable
- **WHEN** each example's `inputExpression` string is parsed and evaluated against the production `UnitRepository`
- **THEN** no example produces an unknown-unit or parse error

#### Scenario: At least one example has an output expression
- **WHEN** the app is compiled
- **THEN** at least one entry in the example list has a non-null `outputExpression`

### Requirement: Idle display shows instruction and random example
The freeform screen SHALL display two lines in the idle result area when no input has been entered: a fixed instruction line reading "Enter an expression above." and a "Try: \<hint\>" line where the hint is the example expression, or `<inputExpression> → <outputExpression>` when the example carries an output expression.

#### Scenario: Initial launch — example without output
- **WHEN** the app launches and the freeform screen is idle
- **AND** the selected example has no `outputExpression`
- **THEN** the idle result area shows "Enter an expression above." followed by `Try: <inputExpression>`

#### Scenario: Initial launch — example with output
- **WHEN** the app launches and the freeform screen is idle
- **AND** the selected example has a non-null `outputExpression`
- **THEN** the idle result area shows "Enter an expression above." followed by `Try: <inputExpression> → <outputExpression>`

#### Scenario: Hint is visually distinct from real output
- **WHEN** the idle result area is displayed
- **THEN** both lines are styled in a muted colour so they are not mistaken for evaluated output

### Requirement: Tapping the idle display fills the input
When the idle display is tapped, the system SHALL copy the example's `inputExpression` into the "Convert from" field.  If the example also has an `outputExpression`, it SHALL be copied into the "Convert to" field.  Evaluation SHALL be triggered immediately.

#### Scenario: Tap fills Convert from only (no output expression)
- **WHEN** the user taps the idle result display
- **AND** the selected example has no `outputExpression`
- **THEN** the "Convert from" text field is populated with `inputExpression` and evaluation runs
- **AND** the "Convert to" field is not modified

#### Scenario: Tap fills both fields (with output expression)
- **WHEN** the user taps the idle result display
- **AND** the selected example has a non-null `outputExpression`
- **THEN** the "Convert from" text field is populated with `inputExpression`
- **AND** the "Convert to" text field is populated with `outputExpression`
- **AND** evaluation runs as if the user had typed both values

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

### Requirement: Example changes on each idle transition
Each time the screen returns to idle, the system SHALL display a different example from the previous one.

#### Scenario: User clears input and returns to idle
- **WHEN** a user enters an expression and then deletes all input, returning the screen to idle
- **THEN** a different example expression is shown from the one that was displayed before the user started typing

#### Scenario: User taps example to load it, then clears
- **WHEN** a user taps the idle display to load the example into the input field, then clears the field
- **THEN** the idle display shows a different example from the one that was tapped
