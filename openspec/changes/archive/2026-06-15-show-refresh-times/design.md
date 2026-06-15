## Context

`UnitRepository.buildCurrencyDescriptors()` returns a `List<CurrencyDescriptor>`
identifying every unit backed by a live exchange rate. For most currencies
(e.g. EUR), `CurrencyDescriptor.unitId == CurrencyDescriptor.originalUnit.id ==
'euro'`, and `CurrencyRateRepository` stores the fetched rate under the key
`'euro'`.

Precious metals are different: the *displayed* unit is the ounce unit
(`goldounce`, alias `XAU`), but the *updated/stored* unit is an intermediate
price unit (`goldprice`). In `_buildCurrencyDescriptors()`, the metal
descriptor's `originalUnit` is `goldprice` itself (not `goldounce`):

```dart
final priceUnit = findUnit(metal.unitId); // 'goldprice'
results.add(CurrencyDescriptor(
  isoCode: name,            // 'XAU'
  unitId: metal.unitId,     // 'goldprice'
  expressionTemplate: '1|{rate} US$/troyounce',
  originalUnit: priceUnit,  // id == 'goldprice'
));
```

The existing (unused) `CurrencyRateRepository.lastUpdatedForUnit(String
unitId, ...)` falls back to searching for a descriptor whose
`originalUnit.id == unitId`. For `unitId == 'goldounce'` this never matches
real descriptors (`originalUnit.id == 'goldprice'`), so the documented
"indirect lookup" scenario in `currency-rates/spec.md` does not actually work
against real data — only against the hand-built test fixture, which was
constructed with `originalUnit: goldounce` (not matching
`_buildCurrencyDescriptors()`'s actual output).

This change wires `lastUpdatedForUnit` into the unit browser's detail page and
must fix this mismatch so `goldounce`/`XAU` correctly resolves to the date
stored under `goldprice`.

## Goals / Non-Goals

**Goals:**

- Show a "Last updated" section on the unit detail page for any unit that
  corresponds to a live currency rate, including precious-metal ounce units
  and their intermediate price units.
- Fix `lastUpdatedForUnit` so the lookup works against real
  `buildCurrencyDescriptors()` output, not just idealized test fixtures.
- Distinguish "currency unit with no fetched rate yet" (show "Using built-in
  rates") from "not a currency unit at all" (no section).

**Non-Goals:**

- Changing `_buildCurrencyDescriptors()`'s `originalUnit` field or its use in
  `CurrencyService.fetchRates()` (risk of alias collisions when registering
  dynamic units — out of scope).
- Changing the overall `updatedAt` display in Settings.
- Adding a manual per-unit refresh action on the detail page.

## Decisions

### 1. Match units to descriptors via ID *or* ISO-code alias

Add a pure helper:

```dart
static CurrencyDescriptor? descriptorForUnit(
  Unit unit,
  List<CurrencyDescriptor> descriptors,
) {
  for (final d in descriptors) {
    if (d.originalUnit.id == unit.id || unit.aliases.contains(d.isoCode)) {
      return d;
    }
  }
  return null;
}
```

- `euro` (id `euro`): matches the EUR descriptor via `originalUnit.id ==
  'euro'`.
- `goldprice` (id `goldprice`): matches the XAU descriptor via
  `originalUnit.id == 'goldprice'`.
- `goldounce` (id `goldounce`, alias `XAU`): matches the XAU descriptor via
  `unit.aliases.contains('XAU')` — this is the fix. The same logic covers
  `silverounce`/XAG and `platinumounce`/XPT.

This is a static method (no I/O), so it can also answer "is this a currency
unit at all", independent of whether any rates have been fetched yet.

**Alternative considered:** make `_buildCurrencyDescriptors()` set
`originalUnit` to the ounce unit for metals. Rejected — `fetchRates()` reuses
`originalUnit.aliases`/`description` when registering the dynamic
`goldprice` unit; giving `goldprice` the `XAU` alias would collide with
`goldounce`'s own `XAU` alias and break `registerDynamic`.

### 2. `lastUpdatedForUnit` takes a `Unit`, not a `String`

```dart
String? lastUpdatedForUnit(Unit unit, List<CurrencyDescriptor> descriptors) {
  final descriptor = descriptorForUnit(unit, descriptors);
  if (descriptor == null) return null;
  return load()?.rates[descriptor.unitId]?.date;
}
```

The previous "direct key match" special case is subsumed: for `euro` and
`goldprice`, `descriptorForUnit` matches via `originalUnit.id == unit.id`
and `descriptor.unitId` equals that same id, so `rates[descriptor.unitId]`
is exactly the old direct-match lookup. `lastUpdatedForUnit` is currently
unused elsewhere, so changing its signature has no other call sites.

### 3. New section shown via `descriptorForUnit`, not `lastUpdatedForUnit`, for presence

The detail screen decides whether to render the "Last updated" section using
`descriptorForUnit(unit, descriptors) != null` (no I/O, always available),
then separately calls `lastUpdatedForUnit` for the date string. If the
descriptor exists but no date is available (no rates ever fetched —
`CurrencyRateRepository.load() == null`, or that unit's id absent from
`rates`), the section reads `"Using built-in rates"`, matching the wording
already used in `CurrencySettingsSection`.

### 4. Provider wiring follows the existing `repo`/`settings` pattern

`UnitEntryDetailScreen` (the `ConsumerWidget`) additionally watches
`currencyRateRepositoryProvider` and passes the `CurrencyRateRepository`
instance down to `_UnitDetailBody` as a plain constructor field — the same
pattern already used for `UnitRepository repo` and `UserSettings settings`.
`_FunctionDetailBody` does not need it. No new provider is introduced;
`currencyRateRepositoryProvider` already exists and is overridden in
`main.dart`.

Test scaffolding (`unit_entry_detail_screen_test.dart` and any other test
that builds `UnitEntryDetailScreen`) must add
`currencyRateRepositoryProvider.overrideWithValue(...)` to its `ProviderScope`
overrides, backed by a `SharedPreferences.setMockInitialValues({})` instance.

### 5. Date-only formatting helper

`CurrencyRateEntry.date` is a plain `"YYYY-MM-DD"` string (no time
component), distinct from the `DateTime` `updatedAt` formatted by
`CurrencySettingsSection._formatDateTime`. Add a small shared helper —
`formatShortDate(DateTime date) -> String` in
`lib/shared/utils/date_formatter.dart` — producing `"Jun 6, 2026"` (reusing
the month-abbreviation table). `_UnitDetailBody` parses the stored date string
with `DateTime.parse(...)` and formats it with this helper.

`CurrencySettingsSection._formatDateTime` is left as-is (it also needs
hour/minute); extracting the shared month-name list is an optional follow-up,
not required for this change.

### 6. Section placement and labels

The new "Last updated" section appears immediately after the existing "Value"
section (last in the unit/prefix detail body). Content:

- Date available: `"Jun 6, 2026"`
- Currency unit, no fetched rate yet: `"Using built-in rates"`
- Not a currency unit: section omitted entirely

## Risks / Trade-offs

- **[Risk]** `unit.aliases.contains(d.isoCode)` could theoretically match a
  non-metal unit that happens to carry a 3-letter alias equal to some other
  currency's ISO code, causing an incorrect "Last updated" section.
  → **Mitigation:** `buildCurrencyDescriptors()` already restricts descriptors
  to units whose resolved dimension is `{US$: 1}` (or, for metals, the
  intermediate price unit), so only genuine currency-dimensioned units can
  produce a spurious alias match — `descriptorForUnit` is only consulted for
  units already shown on the currency-relevant detail page, and a false
  positive would still display a *plausible* currency-rate date, not garbage.
  This is the same trade-off the existing `_metalOverrides` design already
  accepts.

- **[Risk]** Existing `currency_rate_repository_test.dart` fixtures encode
  the old (incorrect) `originalUnit: goldounce` shape for the XAU descriptor.
  → **Mitigation:** update the fixture's `originalUnit` to a `goldprice` stub
  (matching real `_buildCurrencyDescriptors()` output) and update test calls
  to pass `Unit` objects instead of bare ID strings.

## Open Questions

None.
