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

### Requirement: Privacy policy entry opens the hosted policy
The About screen SHALL contain a tappable "Privacy policy" entry with the hosted policy URL as its subtitle.  When tapped, the app SHALL open that URL in the system browser using `url_launcher`, matching the behaviour of the Project home entry.  The app SHALL NOT bundle the policy text, so that the document a user reads is always the current one rather than a copy frozen at the installed release.

#### Scenario: Privacy policy tile shows URL subtitle
- **WHEN** the About screen is displayed
- **THEN** the Privacy policy tile shows the hosted policy URL as its subtitle

#### Scenario: Tapping Privacy policy opens browser
- **WHEN** the user taps "Privacy policy"
- **THEN** the system browser opens to the hosted privacy policy URL

#### Scenario: URL launch failure is handled gracefully
- **WHEN** the system cannot launch the URL (e.g. no browser available)
- **THEN** the app does not crash
