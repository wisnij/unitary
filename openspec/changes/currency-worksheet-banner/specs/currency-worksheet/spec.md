## ADDED Requirements

### Requirement: Currency worksheet declares the currency-rates banner

The predefined `currency` template SHALL declare the currency-rates
`WorksheetBanner` so that, when the Currency worksheet is active, the rate-sync
status banner is displayed above its rows.  No other predefined template SHALL
declare this banner.

#### Scenario: Currency template carries the banner

- **WHEN** the `currency` template is retrieved from the registry
- **THEN** its `banner` is the currency-rates `WorksheetBanner` variant

#### Scenario: Other templates have no banner

- **WHEN** any predefined template other than `currency` is retrieved
- **THEN** its `banner` is `null`

#### Scenario: Banner visible on the Currency worksheet

- **WHEN** the Currency worksheet is the active worksheet
- **THEN** the currency-rates banner is displayed above the currency rows

### Requirement: Currency worksheet AppBar offers a rate-refresh action

The worksheet screen's AppBar SHALL present a rate-refresh action when the active
worksheet template is currency-aware (its `banner` is the currency-rates
`WorksheetBanner` variant).  This action SHALL use the same reusable refresh
control as the Settings "Currency rates" section, so it behaves identically:
triggering an immediate fetch, enforcing the 60-second cooldown, showing an
in-progress spinner, and displaying the same error dialog on failure.

For any active template that is not currency-aware, the AppBar SHALL NOT present
a rate-refresh action.

#### Scenario: Refresh action present on the Currency worksheet

- **WHEN** the Currency worksheet is the active worksheet
- **THEN** the AppBar shows a currency rate-refresh action

#### Scenario: Refresh action absent on other worksheets

- **WHEN** any worksheet other than Currency is active
- **THEN** the AppBar shows no rate-refresh action

#### Scenario: Worksheet refresh triggers a fetch like Settings

- **WHEN** the user taps the worksheet AppBar refresh action
- **THEN** an immediate exchange-rate fetch is initiated, a spinner is shown, and the 60-second cooldown begins — identically to the Settings refresh button

#### Scenario: Worksheet refresh failure shows the error dialog

- **WHEN** the user taps the worksheet AppBar refresh action and the fetch fails
- **THEN** the same error dialog used by the Settings refresh button is displayed
