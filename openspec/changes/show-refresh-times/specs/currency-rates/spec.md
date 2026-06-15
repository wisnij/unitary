## ADDED Requirements

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

## MODIFIED Requirements

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
