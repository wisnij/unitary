## MODIFIED Requirements

### Requirement: Manual refresh with cooldown
The application SHALL provide a manual refresh control that triggers an
immediate fetch regardless of the 24-hour staleness threshold.  This control
SHALL be a single reusable widget, offered both in the Settings "Currency rates"
section and in the currency worksheet AppBar.  The control SHALL be disabled for
60 seconds after any refresh attempt (manual or automatic) and SHALL show the
remaining cooldown duration while locked out.  A spinner SHALL be displayed
while a fetch is in progress.  Because all instances share the same
`currencyStatusProvider` state, the cooldown and in-progress state SHALL be
consistent across every place the control appears.

#### Scenario: Manual refresh triggers fetch
- **WHEN** the user taps the refresh control
- **THEN** a fetch is initiated immediately and a spinner is shown

#### Scenario: Button disabled during cooldown
- **WHEN** a fetch has been initiated within the last 60 seconds
- **THEN** the refresh control is disabled and displays the remaining cooldown time

#### Scenario: Button re-enabled after cooldown
- **WHEN** 60 seconds have elapsed since the last fetch attempt
- **THEN** the refresh control becomes active again

#### Scenario: Cooldown shared across locations
- **WHEN** the user triggers a refresh from one location (e.g. Settings)
- **THEN** the refresh control in the other location (e.g. the currency worksheet AppBar) is simultaneously disabled with the same remaining cooldown

### Requirement: Manual refresh error feedback
When a manually-triggered refresh fails (network error, non-200 response, or unparseable payload), the application SHALL display an error dialog.  The same dialog SHALL be used regardless of where the refresh was triggered (Settings or the currency worksheet AppBar).

The dialog SHALL contain:
- A title indicating the rates could not be updated
- A brief message confirming that the refresh failed
- A collapsible "Details" section containing the full error message, collapsed by default

Background auto-refresh failures (via `CurrencyStatusNotifier.maybeRefresh`)
SHALL NOT produce any user-visible error message.

`CurrencyService.fetchRates` SHALL return a `String?` — null on success, an
error description on failure — rather than swallowing errors silently.
`CurrencyStatusNotifier.refresh` SHALL propagate this value to callers as its
`Future<String?>` return type.

#### Scenario: Error dialog on manual refresh failure
- **WHEN** the user taps a manual refresh control and the fetch fails
- **THEN** an error dialog is displayed with a title indicating failure and an OK button

#### Scenario: Error details hidden by default
- **WHEN** the error dialog is shown
- **THEN** the "Details" section is collapsed and the raw error message is not visible

#### Scenario: Error details visible after expand
- **WHEN** the user taps the "Details" label in the error dialog
- **THEN** the section expands and the full error message becomes visible

#### Scenario: Auto-refresh failure is silent
- **WHEN** the app-launch background refresh fails
- **THEN** no error dialog or message is shown to the user
