## 1. CurrencyRateRepository: fix and extend lookup

- [ ] 1.1 Update `currency_rate_repository_test.dart`: change `_xauDescriptor.originalUnit`
      to a `goldprice` stub (id `goldprice`, no aliases) matching real
      `_buildCurrencyDescriptors()` output; add a `_meter` unit stub.
- [ ] 1.2 Add tests for `CurrencyRateRepository.descriptorForUnit(Unit, descriptors)`:
      matches `euro` via `originalUnit.id`, matches `goldprice` via
      `originalUnit.id`, matches `goldounce` (alias `XAU`) via ISO-code alias,
      returns `null` for `meter`.
- [ ] 1.3 Update `lastUpdatedForUnit` tests to pass `Unit` objects (`_euro`,
      `_goldounce`, `_meter`) instead of bare ID strings; add a case for
      "currency unit with no rates loaded yet returns null".
- [ ] 1.4 Implement `CurrencyRateRepository.descriptorForUnit` (static) in
      `lib/features/currency/data/currency_rate_repository.dart`.
- [ ] 1.5 Update `lastUpdatedForUnit` signature to
      `lastUpdatedForUnit(Unit unit, List<CurrencyDescriptor> descriptors)`,
      implemented via `descriptorForUnit`.

## 2. Date formatting helper

- [ ] 2.1 Add tests for `formatShortDate(DateTime)` in
      `test/shared/utils/date_formatter_test.dart` (e.g. `2026-06-06` ->
      `"Jun 6, 2026"`, single-digit and double-digit days, all twelve months).
- [ ] 2.2 Implement `formatShortDate` in `lib/shared/utils/date_formatter.dart`.

## 3. Unit entry detail screen

- [ ] 3.1 Update `_buildScreen` test helper in
      `unit_entry_detail_screen_test.dart` to override
      `currencyRateRepositoryProvider` with a `CurrencyRateRepository` backed
      by `SharedPreferences.setMockInitialValues({})` (optionally pre-seeded
      with rates per test).
- [ ] 3.2 Add tests: "Last updated" section shown for `euro` with a stored
      rate date, formatted via `formatShortDate`.
- [ ] 3.3 Add test: "Last updated" section shown for `goldounce` resolving to
      the `goldprice` stored date.
- [ ] 3.4 Add test: "Last updated" section shown for `goldprice` directly.
- [ ] 3.5 Add test: currency unit with no rates loaded yet shows "Using
      built-in rates".
- [ ] 3.6 Add test: non-currency unit (e.g. `meter`) shows no "Last updated"
      section.
- [ ] 3.7 Add test: "Last updated" section appears after the "Value" section
      in widget order.
- [ ] 3.8 Wire `currencyRateRepositoryProvider` into `UnitEntryDetailScreen`
      and pass the `CurrencyRateRepository` instance down to `_UnitDetailBody`
      (following the existing `repo`/`settings` parameter pattern).
- [ ] 3.9 Implement the "Last updated" section in `_UnitDetailBody`, using
      `repo.buildCurrencyDescriptors()`,
      `CurrencyRateRepository.descriptorForUnit`, and
      `lastUpdatedForUnit` + `formatShortDate`.

## 4. Verification and docs

- [ ] 4.1 Run `flutter test --reporter failures-only`.
- [ ] 4.2 Run `flutter analyze`.
- [ ] 4.3 Update `doc/design_progress.md` with a dated entry summarizing the
      change.
