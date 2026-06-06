## Context

Currency units are already present in the app via the GNU Units database, but
their conversion factors are compiled into `predefined_units.dart` as Dart
`const` objects and cannot be changed at runtime.  The compiled rates are over
a year old.

Two constraints shape this design:

1. `UnitRepository` is currently append-only — `register()` throws on collision.
   A mutation pathway must be added carefully to preserve the resolved-quantity
   cache's correctness.
2. The same mutation pathway will be needed for user-defined custom units in
   Phase 11, so it should be general rather than currency-specific.

## Goals / Non-Goals

**Goals:**

- Live exchange rates fetched in the background on every app launch (when stale)
- Manual refresh trigger in Settings
- Offline / API-failure tolerance (keep existing rates)
- General dynamic-unit layer usable by Phase 11 custom units
- No change to startup latency perceived by the user

**Non-Goals:**

- Updates more frequent than once per 24 hours
- Real-time rate streaming
- Implementing user-defined units (Phase 11) — only the infrastructure
- Changing compiled fallback rates in `predefined_units.dart`

## Decisions

### D1 — Dynamic layer in `UnitRepository`

Add a second pair of maps alongside the existing static ones:

```
_dynamicUnits:  Map<String, Unit>        // primary ID → unit
_dynamicLookup: Map<String, Unit>        // all names (id + aliases) → unit
```

All lookup methods (`findUnitWithPrefix`, `_findExact`, etc.) check
`_dynamicLookup` before `_unitLookup`.  Three new public methods:

- `registerDynamic(Unit unit)` — adds or replaces the entry for `unit.id` and
  all its aliases in the dynamic maps; clears the entire `_resolvedQuantityCache`
  (see D2).
- `unregisterDynamic(String id)` — removes the entry; lookups fall back to the
  static layer if a compiled unit exists under the same name.
- `Iterable<Unit> get allDynamicUnits` — returns current dynamic layer for
  persistence consumers.

**Alternative considered:** A `DynamicUnitRepository` wrapper class.
Rejected — adds indirection with no gain; the repo already owns all lookups and
the cache.

### D2 — Cache invalidation strategy

`registerDynamic` clears the **entire** `_resolvedQuantityCache`.  Currency
updates happen at most once per 24 hours; the cache rebuild cost on next use is
negligible.  A targeted invalidation (only currency-dimension entries, or only
transitive dependents) would be more precise but adds complexity that isn't
warranted here.

### D3 — Currency detection heuristic

At repository initialisation, identify updatable currency units by:

1. Collect every name (primary ID and aliases) registered in the repo that
   matches `[A-Z]{3}`.
2. Call `resolveUnit()` on each.  Keep those whose result has dimension
   `{US$: 1}`.
3. Exclude `US$` itself (the primitive base; its rate is always 1.0 by
   definition).

This correctly captures all ~183 ISO 4217 currency codes in the database.
It also captures `XAU`, `XAG`, and `XPT`: their full evaluation chain is
`goldounce = goldprice × troyounce`, where `goldprice` has dimension
`US$/troyounce`, so the product dimension is `{US$: 1}`.  (A naïve alias-chain
follower returns `kg` for these, which is incorrect; the evaluator is required.)

Detection runs once during the `buildCurrencyDescriptors()` call (see D5) and
the result is cached.

### D4 — Precious metals update target

For regular currencies, the ISO code is an alias of the unit being updated
(e.g., `EUR` → `euro`; updating `euro`'s expression is sufficient).

For precious metals, the ISO code aliases a *derived* unit (`XAU` → `goldounce`
= `goldprice troyounce`).  Updating `goldounce` would change its meaning (it
would no longer be one troy ounce of gold).  Instead, the update target is the
price unit — `goldprice`, `silverprice`, or `platinumprice` — whose expression
is `N US$/troyounce`.

These three mappings are hardcoded:

| ISO code | Update target | Expression template        |
|----------|---------------|----------------------------|
| `XAU`    | `goldprice`   | `{price} US$/troyounce`    |
| `XAG`    | `silverprice` | `{price} US$/troyounce`    |
| `XPT`    | `platinumprice` | `{price} US$/troyounce`  |

All other detected currencies use the template `{rate} US$`, where `rate` is
the value in USD of 1 unit (i.e., `1 / api_units_per_usd`).

### D5 — `CurrencyDescriptor` and the detected set

Introduce a value class `CurrencyDescriptor`:

```dart
class CurrencyDescriptor {
  final String unitId;          // unit to update (e.g., 'euro', 'goldprice')
  final String isoCode;         // the 3-letter code from the API (e.g., 'EUR', 'XAU')
  final String expressionTemplate; // e.g., '{rate} US$' or '{rate} US$/troyounce'
  final Unit originalUnit;      // current compiled unit (for aliases list)
}
```

`UnitRepository.buildCurrencyDescriptors()` runs the D3 heuristic and returns
`List<CurrencyDescriptor>`.  `CurrencyService` uses this list to map API
response keys to `registerDynamic` calls.

The descriptor list also enables per-unit last-updated lookups for future use
(e.g., the unit browser showing a "Last updated" field on currency detail pages).
`CurrencyRateRepository` should expose a `lastUpdatedForUnit(String unitId)`
method that: (1) checks if `unitId` is a direct key in the stored rates map and
returns its per-entry `date`; (2) if not, searches the descriptor list for any
entry whose `originalUnit.id` matches and returns that descriptor's update target
entry's `date`.  This allows `goldounce` (browsed as the primary unit) to resolve
to the same date as `goldprice` (the stored update target) without duplicating
data in storage.  The `currency-rates` spec should include this as a requirement.

### D6 — Rate storage schema (SharedPreferences)

Key: `currencyRates`
Value: JSON object

```json
{
  "updatedAt": "2026-06-06T14:30:00.000Z",
  "rates": {
    "euro":      {"rate": 1.1623, "date": "2026-06-06"},
    "japanyen":  {"rate": 0.006251, "date": "2026-06-06"},
    "goldprice": {"rate": 4545.45, "date": "2026-06-06"},
    "silverprice": {"rate": 73.69, "date": "2026-06-06"}
  }
}
```

- Keys are **unit IDs** (not ISO codes), matching the `unitId` field of
  `CurrencyDescriptor`.
- `rate`: USD value of 1 unit for currencies; USD per troy ounce for precious metals.
- `date`: the source date string returned by Frankfurter for that specific
  currency (e.g. `"2026-06-06"`).  Different currencies may carry different dates
  since some central banks report less frequently.  This is used for per-unit
  display in the browser; it is **not** used for staleness checking.
- `updatedAt`: ISO 8601 UTC timestamp of when the fetch was performed.  This is
  the field checked against the 24-hour threshold to decide whether to re-fetch.
  It is intentionally separate from the per-currency `date` fields.

Migration path: when sqflite is added in Phase 12, `CurrencyRateRepository` is
reimplemented against the new store.  A one-time migration reads the SharedPreferences
JSON, inserts rows into sqflite, and deletes the old key.  No other code changes.

### D7 — Background fetch flow

On every app launch, `CurrencyService.maybeRefresh()` is called immediately
after the repository is ready.  It does nothing if stored rates are < 24 hours
old; otherwise it fetches in the background.  The method returns `void` — the
caller does not await it.

```
App launch
  └─ unitRepositoryProvider created (synchronous, compiled fallback rates)
  └─ CurrencyRateRepository.load() → applies stored rates via registerDynamic
  └─ CurrencyService.maybeRefresh() [fire-and-forget]
        └─ if stale: fetch from API
              └─ success: CurrencyRateRepository.save(), registerDynamic for each rate
              └─ failure: log, keep current rates, try again next launch
```

Manual refresh from Settings calls the same fetch logic, bypassing the 24h
check, but enforces a 60-second cooldown to avoid hammering the API.  The
refresh button is disabled and shows the remaining cooldown while the lockout
is active.  It does update the status notifier so the UI can show a spinner.

### D8 — `unitRepositoryProvider` stays synchronous

Loading stored rates from SharedPreferences is fast and can run as part of the
startup sequence before the first frame.  The `unitRepositoryProvider` returns
the repo synchronously (with compiled fallbacks); a separate initialisation step
applies stored rates before the UI becomes interactive.

No reactive rebuild is needed when background rates arrive: freeform and
worksheet results are recalculated on every user input change, so the updated
rates are automatically picked up on the next evaluation.  The Settings screen
uses a dedicated `CurrencyStatusNotifier` (a `StateNotifier`) for the
last-updated timestamp and refresh progress indicator.

### D9 — API selection

**Chosen: Frankfurter v2** (`https://api.frankfurter.dev/v2/`)

Endpoint: `GET /v2/rates?base=USD` — returns a JSON array of
`{date, base, quote, rate}` objects, one per currency.  No API key required.
164 currencies including XAU, XAG, XPT, and XPD.  ECB-backed with 84
contributing central banks.  Historical data back to 1948.

Rates are expressed as "quote units per 1 USD"; the app stores the inverse
("USD per 1 unit") so each raw rate is stored as `1.0 / frankfurterRate`.

The per-row `date` field maps directly to the per-entry `date` in the storage
schema (D6), which is why Frankfurter's format is a better fit than
`open.er-api.com` (which returns a flat rate map with a single shared
timestamp).

## Risks / Trade-offs

- **Stale rates on first cold launch with no connectivity**: the user will see
  compiled fallback rates (over a year old) until the network is available.  This
  is a known and accepted limitation; a staleness note in the Settings UI
  mitigates confusion.  → No mitigation needed beyond the UI indicator.

- **API terms of service / sustainability**: free-tier APIs can change pricing
  or shut down.  → The `CurrencyService` interface is isolated; swapping the API
  implementation is a one-file change.

- **Dynamic layer + cache clear on every update**: if `registerDynamic` is ever
  called at high frequency (e.g., bulk custom-unit import in Phase 11), clearing
  the entire cache on each call would be expensive.  → Accept for now; revisit
  if Phase 11 bulk-import is needed, at which point a batched `registerDynamicAll`
  with a single cache clear can be added.

- **Precious metals via a different API endpoint or separate call**: if the
  chosen API does not return XAU/XAG/XPT, those units silently retain compiled
  values.  → Resolved: Frankfurter v2 covers all three.
