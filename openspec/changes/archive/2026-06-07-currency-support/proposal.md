## Why

The app supports currency units via the GNU Units database, but the exchange rates
compiled into `predefined_units.dart` are stale (sourced from a definitions file
that is over a year old).  Phase 8 of the implementation plan calls for live,
auto-updating currency rates; this change delivers that along with the general
mechanism needed to support user-defined units in Phase 11.

## What Changes

- `UnitRepository` gains a **dynamic layer**: a runtime map of units that shadows
  the compiled static layer, with `registerDynamic` / `unregisterDynamic` /
  `allDynamicUnits` operations and cache-clearing on update.
- A **`CurrencyRateRepository`** loads and persists exchange rates (SharedPreferences
  JSON), applies them to the repo's dynamic layer at startup, and exposes a
  refresh API.
- A **`CurrencyService`** fetches live rates from an external API, merges them
  with stored rates, and triggers a repo update.
- Currency units are detected at runtime by evaluating all 3-uppercase-letter
  unit names and keeping those whose resolved dimension is `{US$: 1}`.  Precious
  metal price units (`goldprice`, `silverprice`, `platinumprice`) are handled as
  a special case: their rate (in `US$/troyounce`) is updated directly rather than
  the ISO code alias.
- On every app launch, a staleness check runs in the background: if stored rates
  are absent or older than 24 hours, a fetch is triggered automatically.  This
  also covers first launch (no stored rates → fetch immediately).  The compiled
  rates in `predefined_units.dart` serve as the fallback until the first
  successful fetch.
- The Settings screen gains a currency section: last-updated timestamp and a
  manual refresh button.
- `unitRepositoryProvider` remains synchronous; the repo is available immediately
  with compiled fallback rates.  The dynamic layer is updated in place when the
  background fetch completes.

## Capabilities

### New Capabilities

- `dynamic-units`: Runtime unit registration layer inside `UnitRepository` that
  shadows compiled units; foundation for both currency rate updates and future
  user-defined units.
- `currency-rates`: Currency detection heuristic, rate storage schema,
  fetch/refresh cycle, offline fallback, and the staleness UI.

### Modified Capabilities

*(none — no existing spec-level requirements change)*

## Impact

- **`lib/core/domain/models/unit_repository.dart`** — dynamic layer additions
- **`lib/core/domain/data/predefined_units.dart`** — no change to existing
  compiled units; rates remain as fallback values
- **`lib/features/currency/`** — new feature directory: service, repository,
  providers, UI widget
- **New dependency**: an HTTP client package (e.g. `http`) for rate fetching
- **`unitRepositoryProvider`** — remains synchronous (`Provider<UnitRepository>`);
  stored rates are applied to the dynamic layer before the first frame so no
  async loading state is needed in dependent providers
- **`lib/features/browser/`** — `BrowserNotifier` gains catalog-rebuild logic
  triggered by `unitRepositoryVersionProvider` so the unit list reflects live
  currency rates after a background fetch
