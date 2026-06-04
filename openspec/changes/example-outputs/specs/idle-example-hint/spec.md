## MODIFIED Requirements

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
