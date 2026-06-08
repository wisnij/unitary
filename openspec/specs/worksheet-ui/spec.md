# Worksheet UI

## Purpose

Defines the user interface requirements for worksheet mode: the screen layout,
row widget appearance, real-time update behavior, template selection, clipboard
interactions, and in-session state retention.

## Requirements

### Requirement: Worksheet screen
The application SHALL provide a worksheet screen accessible from the main
navigation drawer.  The screen SHALL display the active worksheet's rows as a
scrollable vertical list of labeled numeric input fields.

The worksheet screen SHALL be a top-level destination equivalent to the freeform
screen.  Its AppBar SHALL display a hamburger menu icon (drawer toggle) in the
leading position.  No back-arrow SHALL appear in the worksheet AppBar.

#### Scenario: Worksheet screen accessible from drawer
- **WHEN** the user taps "Worksheet" in the navigation drawer
- **THEN** the worksheet screen is displayed

#### Scenario: Rows displayed for active worksheet
- **WHEN** the worksheet screen is open with the `length` template active
- **THEN** 9 labeled numeric input fields are displayed, one per row

#### Scenario: Worksheet AppBar shows hamburger icon
- **WHEN** the worksheet screen is displayed
- **THEN** the AppBar leading icon is the hamburger menu icon, not a back-arrow

#### Scenario: Hamburger icon opens the drawer
- **WHEN** the user taps the hamburger icon on the worksheet screen
- **THEN** the navigation drawer opens

#### Scenario: Drawer highlights active page
- **WHEN** the worksheet screen is active and the drawer is open
- **THEN** the "Worksheet" drawer entry is highlighted as selected

#### Scenario: Freeform entry not highlighted on worksheet screen
- **WHEN** the worksheet screen is active and the drawer is open
- **THEN** the "Freeform" drawer entry is not highlighted

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

### Requirement: Label and input column widths

All rows in a worksheet template SHALL share the same label column width, so
that every input field starts at the same horizontal position.

The shared label column width SHALL be determined by the widest rendered label
in the active template, subject to the following constraints:

- **Minimum**: 130 dp — prevents the column from appearing too narrow when all
  labels are short.
- **Maximum**: the largest width at which the input field remains at least
  12 em wide (where 1 em equals the `bodyLarge` font size) — ensures the
  numeric field always has sufficient room.

Label text that exceeds the column width SHALL be truncated with an ellipsis.

#### Scenario: All input fields are equally wide

- **WHEN** a worksheet template is displayed
- **THEN** every row's input field has the same width

#### Scenario: Short-label template uses 130 dp minimum

- **WHEN** the widest rendered label in the active template is narrower than 130 dp
- **THEN** the label column is exactly 130 dp wide

#### Scenario: Long-label template expands the label column

- **WHEN** the widest rendered label in the active template is wider than 130 dp
  and the 12 em input minimum still allows it
- **THEN** the label column is wide enough to display the widest label without truncation

#### Scenario: Label truncated when template has very long labels

- **WHEN** the widest label in the active template would make the input field
  narrower than 12 em
- **THEN** the label is truncated with an ellipsis and the input field is at
  least 12 em wide

### Requirement: Real-time cross-row update
The worksheet engine SHALL be invoked synchronously on every keystroke in any
row.  When the engine completes, all non-active rows SHALL update their
displayed values immediately.

The active row (the one being edited) SHALL NOT be overwritten by the engine.

#### Scenario: Active row preserved during update
- **WHEN** the user is typing in the `m` row
- **THEN** the `m` row continues to show exactly what the user typed, not a recomputed value

#### Scenario: Other rows update immediately on keystroke
- **WHEN** the user types `1` in the `m` row
- **THEN** all other rows display their computed equivalents without delay

### Requirement: Source transfer on keystroke only
Typing in a row makes it the active (source) row.  Merely focusing a row
(tapping without typing) SHALL NOT transfer source ownership and SHALL NOT
trigger recalculation.

#### Scenario: Focus without typing does not recalculate
- **WHEN** the user taps a non-active row without typing
- **THEN** no recalculation occurs and other rows retain their current values

#### Scenario: Keystroke transfers source
- **WHEN** the user begins typing in a previously non-active row
- **THEN** that row becomes the active row and other rows recalculate from it

### Requirement: Worksheet selector
The AppBar SHALL contain a dropdown that lists all predefined worksheet
templates by name, sorted in case-insensitive alphabetical order.  Selecting a
template makes it the active worksheet.

The selected item (displayed in the AppBar when the dropdown is closed) SHALL
use `titleLarge` font size.  The items listed in the open dropdown menu SHALL
use `bodyLarge` font size.

#### Scenario: Dropdown lists all templates
- **WHEN** the user opens the worksheet selector dropdown
- **THEN** all 12 predefined template names are listed

#### Scenario: Dropdown items are in alphabetical order
- **WHEN** the user opens the worksheet selector dropdown
- **THEN** the templates are listed in case-insensitive alphabetical order by name (Angle, Area, Currency, Digital Storage, Energy, Length, Mass, Pressure, Speed, Temperature, Time, Volume)

#### Scenario: Selecting a template switches the worksheet
- **WHEN** the user selects "Speed" from the dropdown
- **THEN** the speed worksheet rows are displayed

### Requirement: Copy value on long press
Long-pressing a row's numeric input field SHALL copy its current displayed
value to the system clipboard and show a brief confirmation snackbar.  If the
field is empty, the long press SHALL be a no-op.

#### Scenario: Long press copies value
- **WHEN** the user long-presses a non-empty numeric input field
- **THEN** the field's current text is copied to the clipboard

#### Scenario: Long press on empty field is a no-op
- **WHEN** the user long-presses an empty numeric input field
- **THEN** nothing is copied and no snackbar is shown

### Requirement: Transfer active value via label long press
Long-pressing a row's label area SHALL copy the active row's current value into
the pressed row's input field and trigger recalculation as if the user had
typed that value directly.  This gesture SHALL be a no-op if there is no active
row or if the pressed row is itself the active row.

#### Scenario: Label long press transfers active value
- **WHEN** the feet row is active with value `1` and the user long-presses the inches label
- **THEN** the inches field shows `1` and all other rows recalculate from 1 inch

#### Scenario: Label long press with no active row is a no-op
- **WHEN** no row is active and the user long-presses a label
- **THEN** nothing happens

### Requirement: In-session value retention
Worksheet display values SHALL be retained when the user navigates away from
the worksheet screen (e.g., to freeform or settings) and then returns within
the same app session.

#### Scenario: Values retained after navigation away and back
- **WHEN** the user enters values in a worksheet, navigates to freeform, then returns to the worksheet
- **THEN** the previously entered values are still displayed

### Requirement: Values reset between sessions
Worksheet display values SHALL be cleared when the app is restarted.  There is
no persistent storage in Phase 6.

#### Scenario: Values cleared on app restart
- **WHEN** the app is restarted after entering worksheet values
- **THEN** all worksheet fields are empty

### Requirement: Per-worksheet value isolation
Each worksheet template SHALL maintain its own independent set of display
values.  Switching to a different worksheet and back SHALL preserve the
original worksheet's values for the duration of the session.

#### Scenario: Switching worksheets preserves each worksheet's values
- **WHEN** the user enters values in the length worksheet, switches to mass, enters values there, then switches back to length
- **THEN** the length worksheet still shows the values entered before switching
