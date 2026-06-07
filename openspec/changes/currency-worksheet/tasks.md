## 1. Model

- [ ] 1.1 Add `WorksheetOrdering` enum (`magnitude`, `alphabetical`, `none`) to the worksheet domain models
- [ ] 1.2 Add `ordering` field of type `WorksheetOrdering` to `WorksheetTemplate`

## 2. Update existing templates

- [ ] 2.1 Set `ordering: magnitude` on all existing all-`UnitRow` templates (angle, length, mass, time, volume, area, speed, pressure, energy, digital-storage)
- [ ] 2.2 Set `ordering: none` on the `temperature` template

## 3. Add currency template

- [ ] 3.1 Add the `currency` `WorksheetTemplate` (`ordering: alphabetical`) with 12 `UnitRow` entries in ISO-alphabetical order: AUD, CAD, CHF, CNY, EUR, GBP, HKD, JPY, KRW, MXN, SGD, USD

## 4. Tests

- [ ] 4.1 Add a test asserting the `currency` template has id `"currency"`, name `"Currency"`, and `ordering: alphabetical`
- [ ] 4.2 Add a test asserting the `currency` template has exactly 12 rows, all `UnitRow`
- [ ] 4.3 Add a test asserting row expressions equal `{"AUD", "CAD", "CHF", "CNY", "EUR", "GBP", "HKD", "JPY", "KRW", "MXN", "SGD", "USD"}`
- [ ] 4.4 Add a test asserting spelled-out labels (e.g. `"USD"` → `"United States dollar"`, `"CHF"` → `"Swiss franc"`, `"EUR"` → `"Euro"`)
- [ ] 4.5 Add a test asserting currency rows appear in alphabetical label order ("Australian dollar" … "United States dollar")
- [ ] 4.6 Update the "Registry returns all N templates" test to expect 12 templates
- [ ] 4.7 Update the magnitude-ordering test to iterate only templates where `ordering == magnitude` (removing any prior id-based or all-UnitRow condition)
- [ ] 4.8 Verify `temperature` template has `ordering: none`

## 5. Verify

- [ ] 5.1 Run `flutter test --reporter failures-only` — all tests pass
- [ ] 5.2 Run `flutter analyze` — no linting errors
