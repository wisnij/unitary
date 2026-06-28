## ADDED Requirements

### Requirement: Single app shell owns top-level navigation
The application SHALL present its three top-level pages (Freeform, Worksheet,
Browse) through a single app shell that owns one `Scaffold` and builds the
`AppBar` and body for the active page from a destination description.  Each
top-level page SHALL be described by a destination exposing its icon, label,
AppBar title, AppBar actions, and body.  The shell SHALL host the page bodies
in an `IndexedStack` so that each page's widget state is preserved while it is
not the active page.

#### Scenario: Three top-level destinations are presented
- **WHEN** the app is running
- **THEN** the shell exposes exactly the Freeform, Worksheet, and Browse
  destinations

#### Scenario: Active destination drives the AppBar
- **WHEN** the active destination is Worksheet
- **THEN** the AppBar shows the Worksheet destination's title and actions

#### Scenario: Page bodies are kept alive
- **WHEN** the user switches from one destination to another and back
- **THEN** the first page's widget state (text fields, scroll position, active
  template, search state) is unchanged

### Requirement: Drawer navigation at compact and medium widths
At `compact` and `medium` window size classes the shell SHALL present top-level
navigation as a `Drawer`, and the active page's AppBar SHALL show a drawer
toggle (hamburger) in its leading position.  No persistent navigation rail
SHALL be shown at these widths.

#### Scenario: Drawer available at compact width
- **WHEN** the window size class is `compact`
- **THEN** the AppBar shows a hamburger leading icon and tapping it opens the
  navigation drawer

#### Scenario: Drawer available at medium width
- **WHEN** the window size class is `medium`
- **THEN** the AppBar shows a hamburger leading icon and tapping it opens the
  navigation drawer

#### Scenario: No rail at compact or medium width
- **WHEN** the window size class is `compact` or `medium`
- **THEN** no persistent navigation rail is displayed

### Requirement: Persistent navigation rail at expanded width
At the `expanded` window size class the shell SHALL present top-level
navigation as a persistent `NavigationRail` alongside the page body, and SHALL
NOT show a drawer or a hamburger leading icon.  The rail SHALL list the three
top-level destinations and SHALL also provide access to Settings and About.
The rail SHALL highlight the active destination.

#### Scenario: Rail shown at expanded width
- **WHEN** the window size class is `expanded`
- **THEN** a persistent navigation rail is displayed beside the page body and
  no hamburger leading icon is shown

#### Scenario: Rail lists all destinations
- **WHEN** the navigation rail is displayed
- **THEN** it shows the Freeform, Worksheet, and Browse destinations and
  provides access to Settings and About

#### Scenario: Rail highlights the active destination
- **WHEN** the Browse page is active and the rail is displayed
- **THEN** the rail's Browse destination is shown as selected

#### Scenario: Selecting a rail destination switches the page
- **WHEN** the user taps the Worksheet destination in the rail
- **THEN** the Worksheet page becomes active

### Requirement: Active destination indicator in both navigation modes
The current top-level page SHALL be indicated as selected in whichever
navigation surface is active — the drawer at compact/medium widths or the rail
at expanded width.

#### Scenario: Drawer marks active page
- **WHEN** the Worksheet page is active and the drawer is open
- **THEN** the drawer's Worksheet entry is highlighted and the other top-level
  entries are not

#### Scenario: Rail marks active page
- **WHEN** the Worksheet page is active and the rail is displayed
- **THEN** the rail's Worksheet destination is highlighted and the other
  top-level destinations are not

### Requirement: Page state preserved across navigation mechanism
Top-level page state SHALL be preserved when the user navigates between pages
regardless of whether navigation occurs via the drawer or the rail, and SHALL
be preserved when the navigation surface itself changes due to a width change.

#### Scenario: State preserved across rail navigation
- **WHEN** the window size class is `expanded` and the user navigates between
  pages using the rail
- **THEN** each page retains its widget state on return, the same as with
  drawer navigation

#### Scenario: State preserved when crossing the rail breakpoint
- **WHEN** a page has unsaved in-session widget state and the window is resized
  across the expanded breakpoint (drawer ↔ rail)
- **THEN** the page's widget state is preserved
