## ADDED Requirements

### Requirement: Currency unit detection
`UnitRepository` SHALL provide a `buildCurrencyDescriptors()` method that
identifies all updatable currency units by evaluating every registered name
matching the pattern `[A-Z]{3}` and retaining those whose resolved dimension
equals `{US$: 1}`.  The primitive `US$` itself SHALL be excluded.  The result
SHALL be cached after the first call.

Each returned `CurrencyDescriptor` SHALL contain:
- `isoCode`: the matched 3-letter name
- `unitId`: the primary ID of the unit to update via `registerDynamic`
- `expressionTemplate`: the string template used to construct the updated expression
- `originalUnit`: the current compiled unit (for preserving aliases)

For precious metals, the `unitId` SHALL be the intermediate price unit
(`goldprice`, `silverprice`, `platinumprice`) rather than the ounce unit, and
the `expressionTemplate` SHALL be `{rate} US$/troyounce`.  For all other
currencies, `unitId` SHALL be the primary ID of the unit the ISO code aliases,
and `expressionTemplate` SHALL be `{rate} US$`.

#### Scenario: Standard currency detected
- **WHEN** `buildCurrencyDescriptors()` is called on a repository with predefined units
- **THEN** the result includes a descriptor for EUR with `unitId` of `euro` and template `{rate} US$`

#### Scenario: Precious metal detected with correct update target
- **WHEN** `buildCurrencyDescriptors()` is called
- **THEN** the result includes a descriptor for XAU with `unitId` of `goldprice` and template `{rate} US$/troyounce`

#### Scenario: Base currency excluded
- **WHEN** `buildCurrencyDescriptors()` is called
- **THEN** the result does NOT include a descriptor for USD or US$

#### Scenario: Non-currency 3-letter acronyms excluded
- **WHEN** `buildCurrencyDescriptors()` is called
- **THEN** units such as RSI (thermal resistance) and FIT (failure rate) are NOT included in the result

### Requirement: Rate persistence
`CurrencyRateRepository` SHALL persist exchange rates to SharedPreferences under
the key `currencyRates` as a JSON object with the following structure:
- `updatedAt`: ISO 8601 UTC timestamp of the last successful fetch
- `rates`: a map from unit ID to `{rate: double, date: string}`, where `rate` is
  the USD value of one unit and `date` is the source date string from the API

Rates SHALL be keyed by unit ID (not ISO code), matching the `unitId` field of
`CurrencyDescriptor`.

#### Scenario: Rates survive app restart
- **WHEN** rates are saved and the app is restarted
- **THEN** `load()` returns the previously saved rates with their dates and `updatedAt` timestamp

#### Scenario: Partial update preserves unaffected rates
- **WHEN** a new fetch returns rates for only a subset of known currencies
- **THEN** currencies absent from the fetch response retain their previously stored rate and date

### Requirement: Per-unit last-updated lookup
`CurrencyRateRepository` SHALL expose a `lastUpdatedForUnit(String unitId)`
method that returns the source `date` string for the given unit, or `null` if
no rate data is available for it.

The method SHALL first check for a direct key match in the stored rates map.
If not found, it SHALL search the `CurrencyDescriptor` list for any entry whose
`originalUnit.id` matches `unitId` and return the date for that descriptor's
`unitId` key.  This allows units such as `goldounce` to resolve to the same date
as `goldprice` without duplicating storage entries.

#### Scenario: Direct lookup for a standard currency
- **WHEN** `lastUpdatedForUnit("euro")` is called after rates have been loaded
- **THEN** the method returns the date string stored for `euro`

#### Scenario: Indirect lookup for a precious metal ounce unit
- **WHEN** `lastUpdatedForUnit("goldounce")` is called after rates have been loaded
- **THEN** the method returns the date string stored for `goldprice`

#### Scenario: Lookup for a non-currency unit
- **WHEN** `lastUpdatedForUnit("meter")` is called
- **THEN** the method returns `null`

### Requirement: Startup rate application
On app launch, stored rates SHALL be loaded from `CurrencyRateRepository` and
applied to `UnitRepository` via `registerDynamic` before the UI becomes
interactive.  The `unitRepositoryProvider` SHALL remain synchronous; the
compiled fallback rates in `predefined_units.dart` are used until stored rates
are applied.

#### Scenario: Stored rates applied at startup
- **WHEN** the app launches with previously saved rates in SharedPreferences
- **THEN** currency conversions reflect the stored rates before any user interaction

#### Scenario: No stored rates on first launch
- **WHEN** the app launches with no stored rates
- **THEN** currency conversions use the compiled fallback rates from `predefined_units.dart`

### Requirement: Background staleness check
On every app launch, `CurrencyService.maybeRefresh()` SHALL be called
immediately after the repository is ready.  If stored rates are absent or
`updatedAt` is more than 24 hours old, a fetch SHALL be triggered
automatically.  The method SHALL return without awaiting the fetch; it SHALL
NOT block app startup or UI rendering.

#### Scenario: Stale rates trigger background fetch
- **WHEN** the app launches and stored rates are more than 24 hours old
- **THEN** a fetch is initiated in the background without blocking the UI

#### Scenario: Fresh rates suppress fetch
- **WHEN** the app launches and stored rates are less than 24 hours old
- **THEN** no fetch is initiated

#### Scenario: Missing rates treated as stale
- **WHEN** the app launches with no stored rates
- **THEN** a fetch is initiated immediately in the background

#### Scenario: Network failure preserves existing rates
- **WHEN** a background fetch fails due to a network error
- **THEN** the previously stored rates remain in use and no error is shown to the user

### Requirement: Live rate fetch from Frankfurter v2
`CurrencyService` SHALL fetch rates from `https://api.frankfurter.dev/v2/rates?base=USD`.
The response is a JSON array of `{date, base, quote, rate}` objects.  Each rate
SHALL be inverted (`1.0 / rate`) before storage, converting from "quote units
per USD" to "USD per 1 unit".  Only currencies present in the `CurrencyDescriptor`
list SHALL be stored; unrecognised codes SHALL be ignored.

#### Scenario: Rate inversion applied correctly
- **WHEN** Frankfurter returns `{"quote": "EUR", "rate": 0.86, "date": "2026-06-06", ...}`
- **THEN** the stored rate for `euro` is approximately `1.163` (= 1 / 0.86)

#### Scenario: Unrecognised API code ignored
- **WHEN** the API response contains a code not present in the descriptor list
- **THEN** that code is silently skipped and does not affect stored rates

#### Scenario: Per-currency date stored
- **WHEN** the API response contains entries with varying `date` values
- **THEN** each stored rate entry carries its own `date` from the API response

### Requirement: Manual refresh with cooldown
The Settings screen SHALL provide a manual refresh button that triggers an
immediate fetch regardless of the 24-hour staleness threshold.  The button
SHALL be disabled for 60 seconds after any refresh attempt (manual or
automatic) and SHALL show the remaining cooldown duration while locked out.
A spinner SHALL be displayed while a fetch is in progress.

#### Scenario: Manual refresh triggers fetch
- **WHEN** the user taps the refresh button
- **THEN** a fetch is initiated immediately and a spinner is shown

#### Scenario: Button disabled during cooldown
- **WHEN** a fetch has been initiated within the last 60 seconds
- **THEN** the refresh button is disabled and displays the remaining cooldown time

#### Scenario: Button re-enabled after cooldown
- **WHEN** 60 seconds have elapsed since the last fetch attempt
- **THEN** the refresh button becomes active again

### Requirement: Currency status display in Settings
The Settings screen SHALL display a currency section showing the timestamp of
the last successful rate fetch.  If no successful fetch has occurred, the
section SHALL indicate that default (compiled) rates are in use.

#### Scenario: Last updated time shown after successful fetch
- **WHEN** rates have been successfully fetched at least once
- **THEN** the Settings currency section displays the `updatedAt` timestamp of the last fetch

#### Scenario: Default rates indicator on first launch
- **WHEN** no successful fetch has ever occurred
- **THEN** the Settings currency section indicates that compiled default rates are in use
