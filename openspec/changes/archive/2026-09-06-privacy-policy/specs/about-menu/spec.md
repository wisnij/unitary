## MODIFIED Requirements

### Requirement: About screen
The app SHALL provide a dedicated About screen (analogous to the Settings screen) containing five entries in order: Version, Build (conditional), License terms, Privacy policy, Project home.  The two document links (License terms, Privacy policy) SHALL be adjacent, ahead of Project home.

#### Scenario: About screen renders with app bar
- **WHEN** the About screen is displayed
- **THEN** an app bar titled "About" is shown with a back navigation control

#### Scenario: Privacy policy appears between License terms and Project home
- **WHEN** the About screen is displayed
- **THEN** the Privacy policy entry is rendered after License terms and before Project home

## ADDED Requirements

### Requirement: Privacy policy entry opens the bundled policy
The About screen SHALL contain a tappable "Privacy policy" entry that pushes a screen rendering the bundled `PRIVACY.md`, matching the navigation behaviour of the License terms entry rather than the URL-launching behaviour of Project home.  The policy shown SHALL be the copy bundled with the running build, so it describes that build's behaviour and is available without a network connection.

#### Scenario: Tapping Privacy policy opens the policy screen
- **WHEN** the user taps "Privacy policy"
- **THEN** the privacy policy screen is pushed onto the navigation stack

#### Scenario: Policy screen renders the bundled document
- **WHEN** the privacy policy screen is displayed
- **THEN** the bundled policy is shown as formatted text under an app bar with back navigation
