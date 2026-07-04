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
SHALL show the error string as its text rendered in `colorScheme.error`,
preceded by an error icon (`Icons.error_outline` in the error color, matching
the freeform error display) as the field's prefix icon, so the error state is
signaled by more than color alone.  The icon SHALL expose the semantic label
"Error" so assistive technology conveys the error state alongside the message
text.  An erroring field SHALL render at the same height as a non-error field,
so row spacing is unaffected by errors appearing or disappearing.  All other
field styling (border, background, padding) SHALL remain unchanged.

#### Scenario: Row shows label and expression
- **WHEN** a length worksheet row for feet is displayed
- **THEN** the label "feet" is visible in muted color and expression "ft" is
  visible in the primary highlight color

#### Scenario: Error row shows message with icon
- **WHEN** a row displays an error value (e.g., `"out of bounds"`)
- **THEN** the input field shows the error string in `colorScheme.error` with
  an `error_outline` prefix icon in the error color

#### Scenario: Error state exposed to assistive technology
- **WHEN** a row displays an error value
- **THEN** the error icon exposes the semantic label "Error" in the semantics
  tree

#### Scenario: Error row height matches normal rows
- **WHEN** one row displays an error value and another displays a valid number
- **THEN** both input fields render at the same height

#### Scenario: Normal row shows plain value
- **WHEN** a row displays a valid numeric value
- **THEN** the input field shows the value with no prefix icon and default
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
