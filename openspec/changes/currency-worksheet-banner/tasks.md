## 1. Shared formatter

- [ ] 1.1 Write a test for `formatDateTime(DateTime)` in
  `test/shared/utils/date_formatter_test.dart` asserting the date+time output
  matches the current Settings format (e.g. `"Jun 6, 2026, 3:04 PM"`).
- [ ] 1.2 Add public `formatDateTime(DateTime)` to
  `lib/shared/utils/date_formatter.dart`, porting the logic from the private
  `_formatDateTime` in `currency_settings_section.dart`.
- [ ] 1.3 Update `CurrencySettingsSection` to call the shared `formatDateTime`
  and remove its private `_formatDateTime`; confirm existing settings tests pass.

## 2. Banner model

- [ ] 2.1 Write model tests in `test/features/worksheet/models/worksheet_test.dart`
  (or new file) covering: a template with no banner has `banner == null`; a
  template constructed with `CurrencyRatesBanner()` exposes it; both forms are
  `const`.
- [ ] 2.2 Add a `WorksheetBanner` sealed class and `CurrencyRatesBanner` variant
  to `lib/features/worksheet/models/worksheet.dart`.
- [ ] 2.3 Add an optional `final WorksheetBanner? banner` field (default `null`)
  to `WorksheetTemplate`.

## 3. Banner widget

- [ ] 3.1 Write widget tests for the banner: currency-rates banner shows the
  formatted timestamp when `currencyStatusProvider` has `lastUpdatedAt`; shows
  the "Using built-in rates" wording when it is null; updates when the provider
  state changes.
- [ ] 3.2 Add `WorksheetBannerWidget` in
  `lib/features/worksheet/presentation/widgets/worksheet_banner.dart` that
  switches on the `WorksheetBanner` variant.
- [ ] 3.3 Implement the `CurrencyRatesBanner` branch as a small `ConsumerWidget`
  that watches `currencyStatusProvider`, uses the shared `formatDateTime`, and
  renders a thin muted bar (`bodySmall`/`onSurfaceVariant`, optional info icon,
  modest padding) per the design.

## 4. Reusable refresh control

- [ ] 4.1 Write widget tests for `CurrencyRefreshButton`: shows the refresh icon
  when idle, a spinner while fetching, a disabled "Wait Ns" button during
  cooldown, and the error dialog when `refresh()` returns an error.
- [ ] 4.2 Extract the refresh control (icon/spinner/cooldown button) and
  `_RefreshErrorDialog` from `CurrencySettingsSection` into
  `lib/features/currency/presentation/currency_refresh_button.dart` as a
  reusable `ConsumerWidget`.
- [ ] 4.3 Update `CurrencySettingsSection` to use `CurrencyRefreshButton` as its
  `ListTile` trailing; confirm existing settings/refresh tests still pass.

## 5. Screen integration

- [ ] 5.1 Write a widget test for `WorksheetScreen`: the banner bar appears when
  the active template declares a banner and is absent otherwise.
- [ ] 5.2 In `WorksheetScreen.build`, render `WorksheetBannerWidget` above the
  rows when `template.banner != null`; leave layout unchanged when it is null.
- [ ] 5.3 Write a widget test: the AppBar shows the refresh action when the
  active template's banner is `CurrencyRatesBanner` and hides it otherwise.
- [ ] 5.4 In `WorksheetScreen.build`, add `CurrencyRefreshButton` to
  `AppBar.actions` when `template.banner is CurrencyRatesBanner`.

## 6. Currency worksheet wiring

- [ ] 6.1 Write/extend tests in
  `test/features/worksheet/data/predefined_worksheets_test.dart` (or the
  currency worksheet test) asserting the `currency` template's `banner` is
  `CurrencyRatesBanner` and every other predefined template's `banner` is `null`.
- [ ] 6.2 Set `banner: const CurrencyRatesBanner()` on the Currency template in
  `lib/features/worksheet/data/predefined_worksheets.dart`.

## 7. Verification & docs

- [ ] 7.1 Run `flutter test --reporter failures-only`; all tests pass.
- [ ] 7.2 Run `flutter analyze`; no new issues.
- [ ] 7.3 Update `README.md` and `doc/design_progress.md` to note the worksheet
  banner mechanism, the Currency worksheet rate banner, and the worksheet
  AppBar refresh action.
