## MODIFIED Requirements

### Requirement: About screen
The app SHALL provide a dedicated About screen (analogous to the Settings screen) containing six entries in order: Version, Build (conditional), License terms, Privacy policy, Project home, Source code.  The two document links (License terms, Privacy policy) SHALL be adjacent, ahead of the two web links (Project home, Source code).

#### Scenario: About screen renders with app bar
- **WHEN** the About screen is displayed
- **THEN** an app bar titled "About" is shown with a back navigation control

#### Scenario: Privacy policy appears between License terms and Project home
- **WHEN** the About screen is displayed
- **THEN** the Privacy policy entry is rendered after License terms and before Project home

#### Scenario: Source code is the last entry
- **WHEN** the About screen is displayed
- **THEN** the Source code entry is rendered immediately after Project home

## ADDED Requirements

### Requirement: Project home entry opens the project site
The About screen SHALL contain a tappable "Project home" entry with the
project site URL, `https://unitary.wisnij.dev/`, as its subtitle.  When
tapped, the app SHALL open that URL in the system browser using
`url_launcher`.

#### Scenario: Project home tile shows the site URL
- **WHEN** the About screen is displayed
- **THEN** the Project home tile shows `https://unitary.wisnij.dev/` as its subtitle

#### Scenario: Tapping Project home opens the site
- **WHEN** the user taps "Project home"
- **THEN** the system browser opens `https://unitary.wisnij.dev/`

#### Scenario: Project home launch failure is handled gracefully
- **WHEN** the system cannot launch the URL (e.g. no browser available)
- **THEN** the app does not crash

### Requirement: Source code entry opens the GitHub repository
The About screen SHALL contain a tappable "Source code" entry with the
project's GitHub repository URL, `https://github.com/wisnij/unitary`, as its
subtitle.  When tapped, the app SHALL open that URL in the system browser
using `url_launcher`.  This entry is the app's offer of its corresponding
source.

#### Scenario: Source code tile shows the repository URL
- **WHEN** the About screen is displayed
- **THEN** the Source code tile shows `https://github.com/wisnij/unitary` as its subtitle

#### Scenario: Tapping Source code opens the repository
- **WHEN** the user taps "Source code"
- **THEN** the system browser opens `https://github.com/wisnij/unitary`

#### Scenario: Source code launch failure is handled gracefully
- **WHEN** the system cannot launch the URL (e.g. no browser available)
- **THEN** the app does not crash

## REMOVED Requirements

### Requirement: Project home entry opens GitHub URL
**Reason**: "Project home" now opens the project site rather than the
repository.
**Migration**: Replaced by "Project home entry opens the project site"; the
repository link moves to the new "Source code" entry.
