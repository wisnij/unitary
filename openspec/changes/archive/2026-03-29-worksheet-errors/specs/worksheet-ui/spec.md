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

When the row is displaying an error value (`isError: true`), the input field's
text SHALL be rendered in `colorScheme.error` color.  All other field styling
(border, background, padding) SHALL remain unchanged.

#### Scenario: Row shows label and expression
- **WHEN** a length worksheet row for feet is displayed
- **THEN** the label "feet" is visible in muted color and expression "ft" is
  visible in the primary highlight color

#### Scenario: Error row text uses error color
- **WHEN** a row displays an error value (e.g., `"out of bounds"`)
- **THEN** the input field text is rendered in `colorScheme.error` color

#### Scenario: Normal row text uses default color
- **WHEN** a row displays a valid numeric value
- **THEN** the input field text is rendered in the default (unoverridden) color
