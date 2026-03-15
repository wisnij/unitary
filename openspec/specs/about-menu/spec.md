# About Menu

## Purpose

Specifies the About screen and its entry point in the sidebar drawer.  The
About screen provides users with app-level information: version, optional build
metadata, license terms, and a link to the project home page.


## Requirements

### Requirement: About entry in sidebar drawer footer
The sidebar drawer SHALL contain an "About" entry in a footer section alongside the "Settings" entry.  The footer section (divider + Settings + About) SHALL be anchored to the bottom of the drawer whenever the drawer is taller than the navigation content above it; when navigation content would overflow, the footer scrolls with the rest of the drawer content.

#### Scenario: About entry visible in drawer
- **WHEN** the user opens the sidebar drawer
- **THEN** an "About" entry with an info icon is visible at the bottom of the drawer, below Settings

#### Scenario: Footer anchored to bottom when space allows
- **WHEN** the drawer is taller than the navigation items above the divider
- **THEN** the divider, Settings, and About entries are flush with the bottom of the drawer

#### Scenario: Tapping About navigates to About screen
- **WHEN** the user taps "About" in the drawer
- **THEN** the drawer closes and the About screen is pushed onto the navigation stack


### Requirement: About screen
The app SHALL provide a dedicated About screen (analogous to the Settings screen) containing four entries in order: Version, Build (conditional), License terms, Project home.

#### Scenario: About screen renders with app bar
- **WHEN** the About screen is displayed
- **THEN** an app bar titled "About" is shown with a back navigation control


### Requirement: Version entry displays app version
The About screen SHALL display the current app version number (e.g. "0.5.9") as a non-interactive informational tile.  The version SHALL be read at runtime using `package_info_plus`.  Long-pressing the tile SHALL copy the version string to the clipboard and show a brief confirmation.

#### Scenario: Version tile shows app version
- **WHEN** the About screen is displayed and `package_info_plus` has resolved
- **THEN** the Version tile subtitle shows the current app version string

#### Scenario: Version unavailable during load
- **WHEN** `package_info_plus` has not yet resolved
- **THEN** the Version tile subtitle shows a loading indicator

#### Scenario: Long-pressing Version tile copies value
- **WHEN** the user long-presses the Version tile
- **THEN** the version string is copied to the clipboard and a confirmation snackbar is shown


### Requirement: Build entry displays build metadata
The About screen SHALL display build metadata (e.g. "20260315-123456.abc1234") as a non-interactive informational tile.  The metadata SHALL be read from the `BUILD_METADATA` compile-time constant.  The tile SHALL be hidden entirely when no build metadata is set (i.e. when `BUILD_METADATA` is absent or empty).  Long-pressing the tile SHALL copy the metadata string to the clipboard and show a brief confirmation.

#### Scenario: Build tile shown when metadata present
- **WHEN** the app was compiled with a non-empty `BUILD_METADATA` dart-define
- **THEN** the Build tile is visible on the About screen displaying that metadata string

#### Scenario: Build tile hidden when metadata absent
- **WHEN** the app was compiled without a `BUILD_METADATA` dart-define
- **THEN** the Build tile is not shown on the About screen

#### Scenario: Long-pressing Build tile copies value
- **WHEN** the user long-presses the Build tile
- **THEN** the build metadata string is copied to the clipboard and a confirmation snackbar is shown


### Requirement: License terms entry opens formatted license text
The About screen SHALL contain a tappable "License terms" entry with subtitle "GNU AGPL 3.0".  When tapped, the app SHALL navigate to a full-screen view that renders the GNU Affero General Public License version 3 as formatted Markdown, bundled as an asset from `LICENSE.md`.  Any hyperlinks in the license text SHALL be tappable and open in the system browser.

#### Scenario: License terms tile shows subtitle
- **WHEN** the About screen is displayed
- **THEN** the License terms tile shows "GNU AGPL 3.0" as its subtitle

#### Scenario: Tapping License terms opens license screen
- **WHEN** the user taps "License terms"
- **THEN** a full-screen license view is pushed onto the navigation stack

#### Scenario: License screen renders formatted Markdown
- **WHEN** the license screen is displayed
- **THEN** the license text is rendered with Markdown formatting (headers, bold, links) and is scrollable

#### Scenario: User can dismiss license screen
- **WHEN** the user is viewing the license screen
- **THEN** the user can navigate back to the About screen


### Requirement: Project home entry opens GitHub URL
The About screen SHALL contain a tappable "Project home" entry with the project GitHub URL as its subtitle.  When tapped, the app SHALL open the URL in the system browser using `url_launcher`.

#### Scenario: Project home tile shows URL subtitle
- **WHEN** the About screen is displayed
- **THEN** the Project home tile shows the GitHub repository URL as its subtitle

#### Scenario: Tapping Project home opens browser
- **WHEN** the user taps "Project home"
- **THEN** the system browser opens to the project's GitHub repository URL

#### Scenario: URL launch failure is handled gracefully
- **WHEN** the system cannot launch the URL (e.g. no browser available)
- **THEN** the app does not crash
