# Currency Rates

## Purpose

Specifies how Unitary fetches, stores, applies, and displays live currency
exchange rates.  Rates are sourced from the Frankfurter v2 API and kept fresh
via a 24-hour background staleness check; a manual refresh button with a
60-second cooldown is available in Settings.

## Requirements

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
the `expressionTemplate` SHALL be `1|{rate} US$/troyounce`.  For all other
currencies, `unitId` SHALL be the primary ID of the unit the ISO code aliases,
and `expressionTemplate` SHALL be `1|{rate} US$`.

#### Scenario: Standard currency detected
- **WHEN** `buildCurrencyDescriptors()` is called on a repository with predefined units
- **THEN** the result includes a descriptor for EUR with `unitId` of `euro` and template `1|{rate} US$`

#### Scenario: Precious metal detected with correct update target
- **WHEN** `buildCurrencyDescriptors()` is called
- **THEN** the result includes a descriptor for XAU with `unitId` of `goldprice` and template `1|{rate} US$/troyounce`

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
  the raw API rate (quote units per 1 USD; troy ounces per 1 USD for precious
  metals) and `date` is the source date string from the API

Rates SHALL be keyed by unit ID (not ISO code), matching the `unitId` field of
`CurrencyDescriptor`.

#### Scenario: Rates survive app restart
- **WHEN** rates are saved and the app is restarted
- **THEN** `load()` returns the previously saved rates with their dates and `updatedAt` timestamp

#### Scenario: Partial update preserves unaffected rates
- **WHEN** a new fetch returns rates for only a subset of known currencies
- **THEN** currencies absent from the fetch response retain their previously stored rate and date

### Requirement: Matching a unit to its currency descriptor

`CurrencyRateRepository` SHALL expose a static `descriptorForUnit(Unit unit,
List<CurrencyDescriptor> descriptors)` method that returns the
`CurrencyDescriptor` corresponding to `unit`, or `null` if `unit` does not
correspond to any live currency rate.

A descriptor `d` matches `unit` when either:
- `d.originalUnit.id == unit.id`, or
- `unit.aliases` contains `d.isoCode`.

This method performs no I/O and does not require any rates to have been
loaded — it answers "is this a currency unit" independent of whether a live
rate has ever been fetched.

#### Scenario: Standard currency matches via originalUnit.id
- **WHEN** `descriptorForUnit(euroUnit, descriptors)` is called, where
  `euroUnit.id == "euro"` and a descriptor has `originalUnit.id == "euro"`
- **THEN** that descriptor is returned

#### Scenario: Precious metal price unit matches via originalUnit.id
- **WHEN** `descriptorForUnit(goldpriceUnit, descriptors)` is called, where
  `goldpriceUnit.id == "goldprice"` and the XAU descriptor has
  `originalUnit.id == "goldprice"`
- **THEN** the XAU descriptor is returned

#### Scenario: Precious metal ounce unit matches via ISO-code alias
- **WHEN** `descriptorForUnit(goldounceUnit, descriptors)` is called, where
  `goldounceUnit.id == "goldounce"`, `goldounceUnit.aliases` contains `"XAU"`,
  and the XAU descriptor has `isoCode == "XAU"`
- **THEN** the XAU descriptor is returned

#### Scenario: Non-currency unit has no match
- **WHEN** `descriptorForUnit(meterUnit, descriptors)` is called, where
  `meterUnit.id == "meter"` and no descriptor has `originalUnit.id == "meter"`
  or an `isoCode` present in `meterUnit.aliases`
- **THEN** `null` is returned

### Requirement: Per-unit last-updated lookup

`CurrencyRateRepository` SHALL expose a `lastUpdatedForUnit(Unit unit,
List<CurrencyDescriptor> descriptors)` method that returns the source `date`
string for the given unit, or `null` if no rate data is available for it.

The method SHALL use `descriptorForUnit(unit, descriptors)` to find the
matching `CurrencyDescriptor`. If no descriptor matches, the method SHALL
return `null`. Otherwise it SHALL return
`load()?.rates[descriptor.unitId]?.date` (which is itself `null` if no rates
have been loaded or the descriptor's `unitId` is absent from the stored
rates).

This allows units such as `goldounce` to resolve to the same date as
`goldprice` without duplicating storage entries, using the ISO-code alias
matching defined by `descriptorForUnit`.

#### Scenario: Direct lookup for a standard currency
- **WHEN** `lastUpdatedForUnit(euroUnit, descriptors)` is called after rates
  have been loaded, where `euroUnit.id == "euro"`
- **THEN** the method returns the date string stored under `"euro"`

#### Scenario: Indirect lookup for a precious metal ounce unit
- **WHEN** `lastUpdatedForUnit(goldounceUnit, descriptors)` is called after
  rates have been loaded, where `goldounceUnit.id == "goldounce"` and
  `goldounceUnit.aliases` contains `"XAU"`
- **THEN** the method returns the date string stored under `"goldprice"`

#### Scenario: Lookup for a non-currency unit
- **WHEN** `lastUpdatedForUnit(meterUnit, descriptors)` is called, where
  `meterUnit.id == "meter"`
- **THEN** the method returns `null`

#### Scenario: Currency unit with no rates loaded yet
- **WHEN** `lastUpdatedForUnit(euroUnit, descriptors)` is called and `load()`
  returns `null` (no rates have ever been saved)
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
On every app launch, `CurrencyStatusNotifier.maybeRefresh()` SHALL be called
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
SHALL be stored as-is (no inversion); the expression template uses the GNU Units
rational form `1|{rate} US$` to encode the reciprocal precisely.  Only
currencies present in the `CurrencyDescriptor` list SHALL be stored;
unrecognised codes SHALL be ignored.

#### Scenario: Raw API rate stored without inversion
- **WHEN** Frankfurter returns `{"quote": "EUR", "rate": 0.86, "date": "2026-06-06", ...}`
- **THEN** the stored rate for `euro` is `0.86` and the dynamic unit expression is `1|0.86 US$`

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

### Requirement: Manual refresh error feedback
When a manually-triggered refresh fails (network error, non-200 response, or
unparseable payload), the Settings screen SHALL display an error dialog.
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
- **WHEN** the user taps the manual refresh button and the fetch fails
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
