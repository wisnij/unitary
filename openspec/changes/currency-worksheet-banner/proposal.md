## Why

The Currency worksheet converts between live exchange rates, but a user looking
at it has no way to tell how fresh those rates are without leaving for the
Settings screen.  The last-sync timestamp is contextually important on that
screen and should be visible in place.  Rather than bolt a one-off widget onto
the Currency worksheet, we introduce a general worksheet banner mechanism so any
worksheet can surface a small piece of contextually-useful information.

## What Changes

- Add an optional **banner** to the `WorksheetTemplate` model: a typed,
  const-constructible descriptor (sealed class) declaring what contextual
  information a worksheet wants to display.
- Render the banner as a small, unobtrusive bar above the worksheet rows when
  the active template declares one; templates without a banner are unchanged.
- Introduce a currency-rates banner variant that shows the last successful rate
  sync — the same timestamp shown in Settings — or "Using built-in rates" when
  no live rates have been fetched.
- Attach the currency-rates banner to the predefined **Currency** worksheet.
- Add a **rate-refresh action** to the worksheet AppBar when the active template
  is currency-aware (declares the currency-rates banner), behaving identically to
  the Settings refresh button: 60-second cooldown, in-progress spinner, and the
  same error dialog on failure.
- Extract the refresh control (button + spinner + cooldown + error dialog) from
  the Settings currency section into a reusable widget shared by Settings and the
  worksheet AppBar.
- Extract the date/time formatting currently private to the Settings currency
  section into a shared helper so the banner and Settings show an identical
  value.

## Capabilities

### New Capabilities

- `worksheet-banner`: general mechanism by which a worksheet template may declare
  an optional banner, the available banner types, and the small/unobtrusive way
  the worksheet UI renders it above the rows.

### Modified Capabilities

- `currency-worksheet`: the predefined Currency worksheet declares the
  currency-rates banner and its AppBar offers a rate-refresh action.
- `currency-rates`: the manual-refresh control (cooldown, spinner, error
  feedback) is no longer exclusive to Settings — it is a reusable control also
  offered in the currency worksheet AppBar.

## Impact

- **Models**: `lib/features/worksheet/models/worksheet.dart` — new optional
  `banner` field on `WorksheetTemplate`; new `WorksheetBanner` sealed type.
- **UI**: `lib/features/worksheet/presentation/worksheet_screen.dart` — render
  the banner; add the refresh action to the AppBar; new banner widget in
  `presentation/widgets/`.
- **Currency UI**: refresh control extracted from `CurrencySettingsSection` into
  a reusable widget (e.g. `currency/presentation/currency_refresh_button.dart`),
  reused by Settings and the worksheet AppBar; the error dialog moves with it.
- **Data**: `lib/features/worksheet/data/predefined_worksheets.dart` — Currency
  template gains a banner.
- **Currency**: reuses `currencyStatusProvider`
  (`lib/features/currency/state/currency_provider.dart`); no new providers.
- **Shared**: a date/time formatter extracted from
  `lib/features/currency/presentation/currency_settings_section.dart` into
  `lib/shared/utils/date_formatter.dart`; Settings updated to use it.
- No new dependencies.
