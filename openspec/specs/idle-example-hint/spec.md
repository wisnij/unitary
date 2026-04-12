# Spec: idle-example-hint

## Purpose

When the freeform screen is idle (no expression has been entered), display a curated example expression as a hint to help users discover app features.  The hint is visually distinct from real output and is tappable to auto-fill the input field.


## Requirements

### Requirement: Example list exists
The system SHALL maintain a curated, non-empty list of example expression strings covering a variety of app features (unit conversions, SI prefixes, physical constants, defined functions, compound expressions).

#### Scenario: List is non-empty
- **WHEN** the app is compiled
- **THEN** the example list contains at least 10 entries

#### Scenario: All examples are evaluable
- **WHEN** each example string is parsed and evaluated against the production `UnitRepository`
- **THEN** no example produces an unknown-unit or parse error

### Requirement: Idle display shows instruction and random example
The freeform screen SHALL display two lines in the idle result area when no input has been entered: a fixed instruction line reading "Enter an expression above." and a "Try: \<example\>" line with a randomly selected example expression.

#### Scenario: Initial launch
- **WHEN** the app launches and the freeform screen is idle (no expression typed)
- **THEN** the idle result area shows the text "Enter an expression above." followed by "Try: \<example\>" where \<example\> is one of the curated example strings

#### Scenario: Hint is visually distinct from real output
- **WHEN** the idle result area is displayed
- **THEN** both lines are styled in a muted colour so they are not mistaken for evaluated output

### Requirement: Tapping the idle display fills the input
When the idle display is tapped, the system SHALL copy the example expression into the "Convert from" field and immediately trigger evaluation.

#### Scenario: Tap fills Convert from and evaluates
- **WHEN** the user taps the idle result display
- **THEN** the "Convert from" text field is populated with the example expression and evaluation runs as if the user had typed it

#### Scenario: Idle display is tappable
- **WHEN** an example is present in the idle display
- **THEN** the display has a pointer cursor or equivalent affordance indicating it is interactive

### Requirement: Example changes on each idle transition
Each time the screen returns to idle, the system SHALL display a different example from the previous one.

#### Scenario: User clears input and returns to idle
- **WHEN** a user enters an expression and then deletes all input, returning the screen to idle
- **THEN** a different example expression is shown from the one that was displayed before the user started typing

#### Scenario: User taps example to load it, then clears
- **WHEN** a user taps the idle display to load the example into the input field, then clears the field
- **THEN** the idle display shows a different example from the one that was tapped
