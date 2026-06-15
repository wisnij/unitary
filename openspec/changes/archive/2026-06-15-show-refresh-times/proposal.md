## Why

Currency conversions depend on exchange rates that are fetched periodically
from an external API and can become stale.  The Settings screen shows when
rates were *last fetched overall*, but the unit browser's detail page for an
individual currency (e.g. `euro`, `goldounce`, `goldprice`) gives no
indication of how current that specific rate is.  Users inspecting a currency
unit have no way to tell whether its value reflects today's market or a
rate from days ago.

## What Changes

- The unit entry detail page SHALL show an additional "Last updated" section
  for any unit that represents a live currency rate (standard currencies and
  precious metals such as `goldounce`/`XAU` and `goldprice`).
- The section displays the source date of the most recently fetched rate for
  that unit (e.g. "Jun 6, 2026"), or an indication that built-in/compiled
  rates are in use if no live rate has ever been fetched.
- Non-currency units (and currency-adjacent units with no live rate, such as
  `US$` itself) do not show this section.
- Fixes a latent bug in `CurrencyRateRepository.lastUpdatedForUnit`: the
  precious-metal "ounce" units (`goldounce`/XAU, `silverounce`/XAG,
  `platinumounce`/XPT) could not actually resolve to their underlying price
  unit's stored date with the real `CurrencyDescriptor` data produced by
  `buildCurrencyDescriptors()`, because the indirect lookup compared
  `originalUnit.id` rather than the unit's ISO-code alias. The lookup is
  reworked to match on either the unit's own ID or one of its aliases against
  the descriptor's `isoCode`.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `currency-rates`: `lastUpdatedForUnit` is reworked to accept the `Unit`
  being displayed (instead of a bare unit-ID string) and to correctly resolve
  precious-metal ounce units via their ISO-code alias.
- `unit-entry-detail`: adds a new "Last updated" section for currency units,
  shown after the existing "Value" section.

## Impact

- `lib/features/currency/data/currency_rate_repository.dart`:
  `lastUpdatedForUnit` signature and matching logic change; new helper to
  detect whether a unit corresponds to a `CurrencyDescriptor` at all
  (independent of whether rates have been loaded).
- `lib/features/browser/presentation/unit_entry_detail_screen.dart`: new
  "Last updated" section in `_UnitDetailBody`, reading from
  `currencyRateRepositoryProvider` and `UnitRepository.buildCurrencyDescriptors()`.
- New shared date-formatting helper for rendering API date strings
  (`"YYYY-MM-DD"`) as `"Jun 6, 2026"`.
- Test updates: `currency_rate_repository_test.dart`,
  `unit_entry_detail_screen_test.dart`, and any test scaffolding that
  constructs `UnitEntryDetailScreen` will need
  `currencyRateRepositoryProvider` overridden.
