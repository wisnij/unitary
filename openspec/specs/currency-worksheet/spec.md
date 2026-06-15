# Currency Worksheet

## Purpose

Defines the predefined Currency worksheet template for worksheet mode.  Covers
the template's identity, its 12-row structure, the set of supported currencies,
row ordering, and the requirement that each currency expression resolves
successfully against the live unit repository.

## Requirements

### Requirement: Currency worksheet template exists

The application SHALL provide a predefined `WorksheetTemplate` with id
`"currency"`, name `"Currency"`, and `ordering: WorksheetOrdering.alphabetical`.

#### Scenario: Currency template is retrievable

- **WHEN** the predefined template registry is accessed
- **THEN** exactly one template has id `"currency"`, name `"Currency"`, and `ordering == WorksheetOrdering.alphabetical`

### Requirement: Currency template contains 12 rows

The `currency` template SHALL contain exactly 12 `WorksheetRow` entries, all
with kind `UnitRow`, one per major ISO currency code.

#### Scenario: Currency template row count and kinds

- **WHEN** the `currency` template is retrieved from the registry
- **THEN** it has exactly 12 rows and every row has kind `UnitRow`

### Requirement: Currency template row set

The 12 rows SHALL cover the following currencies.  Each row's `expression`
SHALL be the 3-character ISO 4217 code (case-sensitive) and each row's `label`
SHALL be the spelled-out English currency name:

| label | expression |
|-------|------------|
| Australian dollar | AUD |
| British pound | GBP |
| Canadian dollar | CAD |
| Chinese yuan | CNY |
| Euro | EUR |
| Hong Kong dollar | HKD |
| Japanese yen | JPY |
| Mexican peso | MXN |
| Singapore dollar | SGD |
| South Korean won | KRW |
| Swiss franc | CHF |
| United States dollar | USD |

#### Scenario: Currency template expressions

- **WHEN** the `currency` template is retrieved from the registry
- **THEN** the set of row `expression` values equals `{"AUD", "CAD", "CHF", "CNY", "EUR", "GBP", "HKD", "JPY", "KRW", "MXN", "SGD", "USD"}`

#### Scenario: Currency template labels are spelled-out names

- **WHEN** the `currency` template is retrieved from the registry
- **THEN** the row with expression `"USD"` has label `"United States dollar"`, the row with expression `"CHF"` has label `"Swiss franc"`, and the row with expression `"EUR"` has label `"Euro"`

### Requirement: Currency template rows are in alphabetical label order

Rows in the `currency` template SHALL be ordered alphabetically by `label`
(spelled-out currency name).

#### Scenario: Currency template alphabetical label order

- **WHEN** the `currency` template is retrieved from the registry
- **THEN** the `label` values appear in order: "Australian dollar", "British pound", "Canadian dollar", "Chinese yuan", "Euro", "Hong Kong dollar", "Japanese yen", "Mexican peso", "Singapore dollar", "South Korean won", "Swiss franc", "United States dollar"

### Requirement: All currency row expressions are registered units

Every `expression` in the `currency` template SHALL resolve successfully via
`ExpressionParser.evaluate` against the live `UnitRepository` (which includes
the dynamically-loaded currency units from the currency-rates phase).

#### Scenario: Currency expression evaluates without error

- **WHEN** each row expression in the `currency` template is evaluated with `ExpressionParser.evaluate` using the live `UnitRepository`
- **THEN** no `EvalException` is thrown and the resulting `Quantity` has dimension `{US$: 1}`

### Requirement: Currency worksheet uses live exchange rates

The Currency worksheet's `UnitRow` expressions SHALL be evaluated against
the same `UnitRepository` instance used elsewhere in the app (the one
exposed via `unitRepositoryProvider`), so conversions reflect exchange
rates loaded from storage at startup rather than only the compiled
fallback rates.

#### Scenario: Worksheet reflects rates stored at launch

- **WHEN** the app launches with previously saved currency rates in storage, differing from the compiled fallback rates
- **AND** the user types a value into a row of the Currency worksheet
- **THEN** the other rows' displayed values are computed using the stored rates, not the compiled fallback rates

### Requirement: Currency worksheet recomputes after a rate refresh

When a currency rate refresh updates dynamic units in the shared
`UnitRepository` (signaled via `unitRepositoryVersionProvider`), the
worksheet feature SHALL recompute and update the displayed values for
every worksheet template that has a persisted source value, using that
template's stored source row and text.

#### Scenario: Currency worksheet updates after manual refresh

- **WHEN** the user is viewing the Currency worksheet with a value typed into one row
- **AND** a currency rate refresh completes with changed rates
- **THEN** the other rows' displayed values update to reflect the new rates without further user input

#### Scenario: Non-active worksheet with a stored source also updates

- **WHEN** a non-currency worksheet template has a persisted source value from earlier in the session
- **AND** a currency rate refresh completes with changed rates
- **THEN** that template's cached display values are recomputed from its persisted source (unaffected templates remain numerically unchanged)

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
