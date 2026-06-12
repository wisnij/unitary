## Why

The Currency worksheet shows conversion values computed from the
compiled-in fallback exchange rates, never the live rates that the app
loads from storage at startup or fetches via manual/background refresh.
This is because the worksheet feature evaluates rows using its own
private `UnitRepository` instance, completely disconnected from the
shared, rate-aware repository the rest of the app uses.

## What Changes

- `_worksheetParserProvider` (in `lib/features/worksheet/state/worksheet_provider.dart`)
  no longer constructs its own `UnitRepository.withPredefinedUnits()`.
  It instead builds its `ExpressionParser` from the shared
  `unitRepositoryProvider`, which has stored currency rates applied at
  startup and dynamic units updated on refresh.
- `WorksheetNotifier` listens for `unitRepositoryVersionProvider` changes
  (incremented after a currency rate refresh) and recomputes the
  currently active worksheet's display values from its stored source
  row/text, so on-screen values update without requiring navigation away
  and back.
- No changes to `computeWorksheet()` itself or to the worksheet
  persistence format — only to how the worksheet feature obtains and
  refreshes its `UnitRepository`.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `currency-worksheet`: add a requirement that the Currency worksheet's
  conversions use the shared, rate-aware `UnitRepository` (reflecting
  stored rates at launch) and recompute automatically after a currency
  rate refresh.

## Impact

- `lib/features/worksheet/state/worksheet_provider.dart` — repository
  wiring and reactive recompute on rate refresh.
- Tests for `WorksheetNotifier` / worksheet provider that currently rely
  on the private repo instance will need to provide
  `unitRepositoryProvider` overrides instead (matching the pattern
  already used by freeform and browser tests).
- No changes to `worksheet_engine.dart`, worksheet templates, or
  persisted data formats.
