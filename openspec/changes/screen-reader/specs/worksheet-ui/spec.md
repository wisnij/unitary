# Worksheet UI (delta)

## MODIFIED Requirements

### Requirement: Row widget
Each row SHALL display a label and an expression as two stacked text elements,
alongside a numeric input field.

- The label SHALL be rendered in `bodyMedium` size using `onSurfaceVariant`
  color (secondary, muted).
- The expression SHALL be rendered in `bodySmall` size using `colorScheme.primary`
  color (highlighted), matching the highlight color used for freeform conversion
  results.

The input field SHALL use a numeric keyboard type.

When the row is displaying an error value (`isError: true`), the input field
SHALL be empty and the error string SHALL be displayed via the field's
`InputDecoration.errorText`, so that the error is rendered as an error message
line below the field (not as field content), is signaled by more than color
alone, and is exposed to assistive technology through the decoration's native
error semantics.  All other field styling (border, background, padding) SHALL
remain unchanged for non-error rows.

#### Scenario: Row shows label and expression
- **WHEN** a length worksheet row for feet is displayed
- **THEN** the label "feet" is visible in muted color and expression "ft" is
  visible in the primary highlight color

#### Scenario: Error row uses errorText
- **WHEN** a row displays an error value (e.g., `"out of bounds"`)
- **THEN** the input field's text is empty and the error string appears as the
  field's `errorText` below the field

#### Scenario: Error exposed to assistive technology
- **WHEN** a row displays an error value
- **THEN** the field's semantics convey the error message via the decoration's
  error semantics

#### Scenario: Normal row shows plain value
- **WHEN** a row displays a valid numeric value
- **THEN** the input field shows the value with no `errorText` and default
  (unoverridden) text color

### Requirement: Copy value on long press
Long-pressing a row's numeric input field SHALL copy its current displayed
value to the system clipboard and show a brief confirmation snackbar.  If the
field is empty, the long press SHALL be a no-op.

The same copy action SHALL also be exposed to assistive technology as a
labeled custom semantics action (label "Copy value"), so screen-reader users
can discover and trigger it without knowing the long-press gesture.

#### Scenario: Long press copies value
- **WHEN** the user long-presses a non-empty numeric input field
- **THEN** the field's current text is copied to the clipboard

#### Scenario: Long press on empty field is a no-op
- **WHEN** the user long-presses an empty numeric input field
- **THEN** nothing is copied and no snackbar is shown

#### Scenario: Copy action discoverable via semantics
- **WHEN** assistive technology inspects a row's numeric input field
- **THEN** a custom semantics action labeled "Copy value" is exposed, and
  invoking it copies the field's current text to the clipboard
