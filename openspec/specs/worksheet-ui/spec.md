# Worksheet UI

## Purpose

Defines the user interface requirements for worksheet mode: the screen layout,
row widget appearance, real-time update behavior, template selection, clipboard
interactions, and in-session state retention.

## Requirements

### Requirement: No worksheet selected state

When no worksheet template is active (for example on first launch before the
user has ever selected one), the worksheet screen SHALL NOT display any
worksheet rows.  Instead it SHALL present an affordance for choosing a
worksheet, whose form depends on the window size class:

- At `compact` width: the screen body SHALL show the worksheet template list
  (the same list of templates, in the same case-insensitive alphabetical order,
  used in the left pane at wider widths).  Selecting a template SHALL make it
  the active worksheet and replace the list with that worksheet's rows.
- At `medium` and `expanded` width: the left pane SHALL show the template list
  as usual and the right pane SHALL show a centered "Select a worksheet"
  placeholder, mirroring Browse mode's empty detail pane.  Selecting a template
  in the left pane SHALL make it the active worksheet and replace the
  placeholder with that worksheet's rows.

When no worksheet is selected, the AppBar SHALL show the static title text
"Worksheet" rather than a template dropdown or an active template name.

#### Scenario: First launch shows no worksheet rows
- **WHEN** the app is launched for the first time with no persisted selection
- **THEN** the worksheet screen shows no worksheet rows and no template is active

#### Scenario: Compact no-selection shows the template list
- **WHEN** the window size class is `compact` and no worksheet is selected
- **THEN** the screen body shows the worksheet template list in case-insensitive
  alphabetical order

#### Scenario: Compact selection replaces the list with the worksheet
- **WHEN** the window size class is `compact`, no worksheet is selected, and the
  user taps "Speed" in the template list
- **THEN** the speed worksheet rows are displayed and the AppBar shows the speed
  template selector

#### Scenario: Wide no-selection shows a placeholder in the right pane
- **WHEN** the window size class is `medium` or `expanded` and no worksheet is
  selected
- **THEN** the left pane shows the template list and the right pane shows a
  centered "Select a worksheet" placeholder

#### Scenario: Wide selection replaces the placeholder with the worksheet
- **WHEN** the window size class is `medium` or `expanded`, no worksheet is
  selected, and the user taps "Speed" in the left-pane list
- **THEN** the right pane shows the speed worksheet rows and "Speed" becomes the
  highlighted template

#### Scenario: AppBar title when nothing is selected
- **WHEN** no worksheet is selected, at any window size class
- **THEN** the AppBar shows the static title text "Worksheet"

### Requirement: Worksheet screen
The application SHALL provide a worksheet screen accessible as a top-level
destination from the app's top-level navigation.  When a worksheet template is
active, the screen SHALL display that worksheet's rows as a scrollable vertical
list of labeled numeric input fields.  When no template is active, the screen
SHALL instead present a worksheet-selection affordance as defined by the "No
worksheet selected state" requirement.

The worksheet screen SHALL be a top-level destination equivalent to the freeform
screen.  Its AppBar leading affordance is governed by the adaptive-navigation
capability (a hamburger drawer toggle at compact/medium widths; no leading icon
at expanded width, where the navigation rail is used).  No back-arrow SHALL
appear in the worksheet AppBar.

#### Scenario: Worksheet screen accessible from navigation
- **WHEN** the user selects "Worksheet" from the drawer or the navigation rail
- **THEN** the worksheet screen is displayed

#### Scenario: Rows displayed for active worksheet
- **WHEN** the worksheet screen is open with the `length` template active
- **THEN** 9 labeled numeric input fields are displayed, one per row

#### Scenario: No back-arrow in worksheet AppBar
- **WHEN** the worksheet screen is displayed
- **THEN** the AppBar does not show a back-arrow

#### Scenario: Active destination indicated
- **WHEN** the worksheet screen is active
- **THEN** the active navigation surface (drawer or rail) highlights the
  "Worksheet" entry and does not highlight the "Freeform" entry

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
The worksheet template selector SHALL list all predefined worksheet templates by
name, sorted in case-insensitive alphabetical order, and selecting a template
SHALL make it the active worksheet.  Its presentation SHALL depend on the
window size class and on whether a worksheet is currently active:

- At `compact` width with a worksheet active: the selector SHALL be a dropdown
  in the AppBar.  The selected item displayed in the AppBar when the dropdown is
  closed SHALL use `titleLarge` font size; the items in the open dropdown menu
  SHALL use `bodyLarge` font size.
- At `compact` width with no worksheet active: the selector SHALL be the
  full-screen template list defined by the "No worksheet selected state"
  requirement (there is no dropdown, since there is no selected item to show).
- At `medium` and `expanded` width: the selector SHALL be a left-pane list of
  templates shown beside the active worksheet (or the placeholder), with the
  active template highlighted when one is active; the AppBar SHALL show the
  active template's name as static title text when a worksheet is active, and
  the static text "Worksheet" when none is active.

#### Scenario: Compact width uses an AppBar dropdown
- **WHEN** the window size class is `compact`, a worksheet is active, and the
  user opens the worksheet selector
- **THEN** a dropdown lists all 12 predefined template names in case-insensitive
  alphabetical order (Angle, Area, Currency, Digital Storage, Energy, Length,
  Mass, Pressure, Speed, Temperature, Time, Volume)

#### Scenario: Compact selection switches the worksheet
- **WHEN** the window size class is `compact`, a worksheet is active, and the
  user selects "Speed" from the dropdown
- **THEN** the speed worksheet rows are displayed

#### Scenario: Wide width uses a left-pane list
- **WHEN** the window size class is `medium` or `expanded` and a worksheet is
  active
- **THEN** the templates are listed in a left pane in case-insensitive
  alphabetical order with the active template highlighted, and the AppBar shows
  the active template's name as static text

#### Scenario: Wide selection switches the worksheet in the right pane
- **WHEN** the window size class is `medium` or `expanded` and the user taps
  "Speed" in the left-pane list
- **THEN** the right pane shows the speed worksheet rows and "Speed" becomes the
  highlighted template

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
