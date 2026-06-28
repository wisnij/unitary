## MODIFIED Requirements

### Requirement: Worksheet screen
The application SHALL provide a worksheet screen accessible as a top-level
destination from the app's top-level navigation.  The screen SHALL display the
active worksheet's rows as a scrollable vertical list of labeled numeric input
fields.

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
window size class:

- At `compact` width: the selector SHALL be a dropdown in the AppBar.  The
  selected item displayed in the AppBar when the dropdown is closed SHALL use
  `titleLarge` font size; the items in the open dropdown menu SHALL use
  `bodyLarge` font size.
- At `medium` and `expanded` width: the selector SHALL be a left-pane list of
  templates shown beside the active worksheet, with the active template
  highlighted; the AppBar SHALL show the active template's name as static title
  text instead of a dropdown.

#### Scenario: Compact width uses an AppBar dropdown
- **WHEN** the window size class is `compact` and the user opens the worksheet
  selector
- **THEN** a dropdown lists all 12 predefined template names in case-insensitive
  alphabetical order (Angle, Area, Currency, Digital Storage, Energy, Length,
  Mass, Pressure, Speed, Temperature, Time, Volume)

#### Scenario: Compact selection switches the worksheet
- **WHEN** the window size class is `compact` and the user selects "Speed" from
  the dropdown
- **THEN** the speed worksheet rows are displayed

#### Scenario: Wide width uses a left-pane list
- **WHEN** the window size class is `medium` or `expanded`
- **THEN** the templates are listed in a left pane in case-insensitive
  alphabetical order with the active template highlighted, and the AppBar shows
  the active template's name as static text

#### Scenario: Wide selection switches the worksheet in the right pane
- **WHEN** the window size class is `medium` or `expanded` and the user taps
  "Speed" in the left-pane list
- **THEN** the right pane shows the speed worksheet rows and "Speed" becomes the
  highlighted template
