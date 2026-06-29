## ADDED Requirements

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

## MODIFIED Requirements

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
