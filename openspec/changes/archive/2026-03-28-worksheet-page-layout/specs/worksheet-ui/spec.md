## MODIFIED Requirements

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
