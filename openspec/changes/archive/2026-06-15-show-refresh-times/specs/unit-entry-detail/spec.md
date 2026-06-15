## ADDED Requirements

### Requirement: Last updated (currency units)

The detail page SHALL display a "Last updated" section, after the Value section, for unit and prefix entries that correspond to a live currency rate (as determined by `CurrencyRateRepository.descriptorForUnit` against `UnitRepository.buildCurrencyDescriptors()`).

- If `CurrencyRateRepository.lastUpdatedForUnit` returns a non-null date
  string, the section SHALL show that date formatted as `"Mmm D, YYYY"`
  (e.g. `"Jun 6, 2026"`), parsed from the stored `"YYYY-MM-DD"` string.
- If the unit corresponds to a currency descriptor but
  `lastUpdatedForUnit` returns `null` (no live rate has ever been fetched),
  the section SHALL read `"Using built-in rates"`.
- If the unit does not correspond to any currency descriptor, no "Last
  updated" section is rendered.

#### Scenario: Last updated shown for a standard currency
- **WHEN** the detail page is opened for `euro` and a live rate for `euro`
  was last fetched with source date `"2026-06-06"`
- **THEN** a "Last updated" section is shown reading `"Jun 6, 2026"`

#### Scenario: Last updated shown for a precious metal ounce unit
- **WHEN** the detail page is opened for `goldounce` (alias `XAU`) and a live
  rate for `goldprice` was last fetched with source date `"2026-06-05"`
- **THEN** a "Last updated" section is shown reading `"Jun 5, 2026"`

#### Scenario: Last updated shown for a precious metal price unit
- **WHEN** the detail page is opened for `goldprice` and a live rate for
  `goldprice` was last fetched with source date `"2026-06-05"`
- **THEN** a "Last updated" section is shown reading `"Jun 5, 2026"`

#### Scenario: Built-in rates indicator when no live rate fetched
- **WHEN** the detail page is opened for a currency unit (e.g. `euro`) and no
  live rate has ever been fetched
- **THEN** a "Last updated" section is shown reading `"Using built-in rates"`

#### Scenario: No section for non-currency units
- **WHEN** the detail page is opened for a unit that does not correspond to
  any currency descriptor (e.g. `meter`)
- **THEN** no "Last updated" section is rendered

#### Scenario: Last updated section appears after Value
- **WHEN** the detail page is opened for a currency unit with both a Value
  section and a Last updated section
- **THEN** the Last updated section appears after the Value section
