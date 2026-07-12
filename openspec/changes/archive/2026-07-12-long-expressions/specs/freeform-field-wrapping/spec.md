## ADDED Requirements

### Requirement: Freeform expression fields soft-wrap long expressions

The "Convert from" and "Convert to" expression fields SHALL soft-wrap text that exceeds the field width onto additional visual lines, and SHALL grow vertically without bound to keep the entire expression visible.  Wrapping SHALL be purely visual: no newline characters are inserted into the field text by wrapping.

#### Scenario: Long expression wraps instead of scrolling horizontally

- **WHEN** the user types an expression wider than the field
- **THEN** the text wraps onto additional lines and the field grows taller
- **AND** the full expression is visible without horizontal scrolling

#### Scenario: Field returns to a single line when text is shortened

- **WHEN** a wrapped expression is deleted or shortened to fit one line
- **THEN** the field shrinks back to its single-line height

#### Scenario: Wrapping does not alter the expression text

- **WHEN** an expression wraps across multiple visual lines
- **THEN** the field's text value contains no newline characters
- **AND** evaluation produces the same result as the unwrapped expression

### Requirement: Enter submits and never inserts a newline

The submit action (Enter / the keyboard action key) on a multi-line freeform expression field SHALL retain its existing submit semantics and SHALL NOT insert a newline character.

#### Scenario: Enter in a wrapped Convert-from field advances focus

- **WHEN** the "Convert from" field contains a wrapped multi-line expression and the user presses Enter
- **THEN** evaluation is triggered and focus moves to the "Convert to" field
- **AND** no newline character is inserted into the text

#### Scenario: Enter in a wrapped Convert-to field submits

- **WHEN** the "Convert to" field contains a wrapped multi-line expression and the user presses Enter
- **THEN** evaluation is triggered
- **AND** no newline character is inserted into the text

### Requirement: Completion overlay positions correctly against a multi-line field

The predictive-completion overlay SHALL anchor to the field's current edges as the field grows or shrinks, appearing below the field's bottom edge (or above its top edge when the field is in the lower half of the viewport).

#### Scenario: Overlay appears below a two-line field

- **WHEN** the "Convert from" field has wrapped to two lines and the cursor ends a completable identifier
- **THEN** the completion overlay appears immediately below the field's current (taller) bottom edge

### Requirement: Pasted newlines do not break evaluation

Text pasted into a freeform expression field MAY contain literal newline characters; the system SHALL treat them as whitespace during evaluation.

#### Scenario: Pasted expression containing a newline evaluates

- **WHEN** the user pastes text containing a newline character into an expression field
- **THEN** the expression evaluates as if the newline were a space
