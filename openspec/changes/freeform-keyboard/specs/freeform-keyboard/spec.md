## ADDED Requirements

### Requirement: Symbol panel appears above system keyboard when a freeform field is focused

The freeform screen SHALL display a supplementary symbol key panel above the system
keyboard whenever either the "Convert from" or "Convert to" text field has input
focus.  The panel SHALL disappear when neither field is focused.

On desktop and web platforms there is no system keyboard, so the panel SHALL be
permanently visible regardless of focus state.

#### Scenario: Panel appears when Convert-from field is focused

- **WHEN** the user taps the "Convert from" text field
- **THEN** the system keyboard appears and the symbol panel is visible immediately
  above it

#### Scenario: Panel appears when Convert-to field is focused

- **WHEN** the user taps the "Convert to" text field
- **THEN** the system keyboard appears and the symbol panel is visible immediately
  above it

#### Scenario: Panel disappears when focus leaves both fields

- **WHEN** the user dismisses the keyboard (e.g., taps outside both fields or presses
  the back button)
- **THEN** the symbol panel is no longer visible

#### Scenario: Panel is always visible on desktop and web

- **WHEN** the app is running on a desktop or web platform
- **THEN** the symbol panel is visible at all times, regardless of which field (if
  any) has focus

#### Scenario: Panel does not flicker when focus moves between fields

- **WHEN** the user taps from one freeform field directly to the other
- **THEN** the symbol panel remains continuously visible throughout the transition

### Requirement: Symbol panel contains exactly the nine expression syntax buttons

The symbol panel SHALL contain exactly the following buttons in order:
`^`, `*`, `/`, `|`, `+`, `-`, `~`, `(`, `)`.  The `~` button inserts the
inverse operator (same lexical role as `|`).

#### Scenario: Panel contents

- **WHEN** the symbol panel is visible
- **THEN** it displays exactly nine buttons labelled `^`, `*`, `/`, `|`, `+`, `-`,
  `~`, `(`, `)` in that order

### Requirement: Tapping a symbol button inserts the symbol at the cursor

When a symbol button is tapped, the system SHALL insert the corresponding character at
the current cursor position in the focused field (replacing any selected text), leave
the cursor immediately after the inserted character, and keep the system keyboard
visible.

#### Scenario: Insert symbol at cursor with no selection

- **WHEN** the "Convert from" field contains `5 ft` with the cursor after `ft`
- **AND** the user taps the `^` button
- **THEN** the field contains `5 ft^` with the cursor after `^`
- **AND** the system keyboard remains visible

#### Scenario: Insert symbol replaces selected text

- **WHEN** the "Convert from" field has the text `km` selected
- **AND** the user taps the `*` button
- **THEN** the selected text is replaced with `*` and the cursor is placed after it

#### Scenario: Insert symbol in Convert-to field

- **WHEN** the "Convert to" field is focused with the cursor at the end
- **AND** the user taps the `(` button
- **THEN** `(` is appended to the Convert-to field

#### Scenario: Insertion in Convert-from triggers re-evaluation in real-time mode

- **WHEN** the evaluation mode is real-time
- **AND** the user taps a symbol button while the "Convert from" field is focused
- **THEN** the debounced re-evaluation pipeline is triggered

#### Scenario: Insertion in Convert-from does not trigger re-evaluation in on-submit mode

- **WHEN** the evaluation mode is on-submit
- **AND** the user taps a symbol button while the "Convert from" field is focused
- **THEN** no automatic re-evaluation is triggered
