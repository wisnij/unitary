## Context

`UnitRepository.withPredefinedUnits()` builds a repository populated only
from the compiled static layer (`predefined_units.dart`).  Currency rates
become "live" only after `registerDynamic()` is called on a repository
instance — first in `main.dart` (applying stored rates before the first
frame) and again whenever `CurrencyStatusNotifier` fetches new rates
(`unitRepositoryVersionProvider.increment()` signals this).

`unitRepositoryProvider` (`lib/core/domain/models/unit_repository_provider.dart`)
is the single shared instance that receives both of these updates; it is
overridden in `main.dart` with the rate-loaded repo and read by
`parserProvider` (freeform) and `BrowserNotifier`.

`lib/features/worksheet/state/worksheet_provider.dart` instead defines:

```dart
final _worksheetParserProvider = Provider<ExpressionParser>((ref) {
  return ExpressionParser(repo: UnitRepository.withPredefinedUnits());
});
```

This creates a second, independent `UnitRepository` that never receives
`registerDynamic` calls — so worksheet rows always use the compiled
fallback currency rates, both at launch and after any refresh.

## Goals / Non-Goals

**Goals:**

- Worksheet computations use the same `UnitRepository` instance as the
  rest of the app (`unitRepositoryProvider`), so they reflect rates
  loaded at startup.
- After a currency rate refresh (`unitRepositoryVersionProvider`
  increments), on-screen worksheet values update without requiring the
  user to navigate away and back or retype their input.

**Non-Goals:**

- No change to `computeWorksheet()`'s signature or algorithm.
- No change to worksheet persistence format (`WorksheetRepository`,
  `WorksheetPersistState`).
- No change to how currency rates are fetched, stored, or registered.

## Decisions

### Share `unitRepositoryProvider` instead of constructing a private repo

`_worksheetParserProvider` becomes:

```dart
final _worksheetParserProvider = Provider<ExpressionParser>((ref) {
  return ExpressionParser(repo: ref.read(unitRepositoryProvider));
});
```

This matches the existing pattern in
`lib/features/freeform/state/parser_provider.dart`. Because
`unitRepositoryProvider` itself never changes its returned instance (only
the instance's internal dynamic-unit map mutates via `registerDynamic`),
`ref.read` is sufficient — no rebuild of `_worksheetParserProvider` is
needed when rates change, only a recompute of worksheet display values
(see next decision).

**Alternative considered**: pass `unitRepositoryProvider`'s value directly
into `computeWorksheet` calls and drop `_worksheetParserProvider`
entirely. Rejected — the existing provider already bundles the repo into
an `ExpressionParser`, which is what `computeWorksheet` expects; keeping
it minimizes the diff.

### Recompute displayed values when `unitRepositoryVersionProvider` changes

`WorksheetNotifier.build()` already contains a loop that, given
`WorksheetRepository.load().sources` (a `Map<templateId, WorksheetSourceEntry>`),
calls `computeWorksheet` per template and produces `worksheetValues`. This
loop is extracted into a private helper `_computeAllFromSources(persist)`
reused in two places:

1. `build()` — initial seeding (unchanged behavior).
2. A `ref.listen<int>(unitRepositoryVersionProvider, (_, _) { ... })`
   registered inside `build()`, which re-reads
   `ref.read(worksheetRepositoryProvider).load()` and calls
   `_computeAllFromSources(persist)` again, replacing
   `state.worksheetValues` wholesale.

This mirrors `BrowserNotifier`'s existing `ref.listen<int>(unitRepositoryVersionProvider, ...)`
pattern used for catalog rebuilds.

Re-deriving from persisted sources (rather than tracking richer in-memory
state) keeps the recompute idempotent and reuses code already covered by
existing tests. Templates with no persisted source remain blank, same as
today.

**Alternative considered**: only recompute the *active* worksheet
(`state.worksheetId`). Rejected — a user may switch templates without
typing (no new persisted source for the new template until they type),
but if they *had* typed in another currency-bearing template earlier in
the session, that template's stale values would only refresh on next
keystroke. Recomputing all persisted sources is cheap (a handful of
templates, each a handful of rows) and keeps all cached worksheets
consistent.

### Test impact

Existing `worksheet_provider_test.dart` cases don't override
`unitRepositoryProvider`, so they continue to get a default
`UnitRepository.withPredefinedUnits()` — equivalent to today's behavior
for non-currency templates. New tests for the currency-reactivity
behavior will override `unitRepositoryProvider` with a repo that has
`registerDynamic` units, plus drive `unitRepositoryVersionProvider`,
following the pattern in `test/features/currency/state/currency_provider_test.dart`
and `test/features/browser/state/browser_provider_test.dart`.

## Risks / Trade-offs

- **[Risk]** Recomputing all persisted-source templates on every rate
  refresh is O(templates × rows) — negligible given current template
  counts (≤12 rows, ~11 templates).  → No mitigation needed.
- **[Risk]** If `_computeAllFromSources` throws for one template (as the
  existing `build()` loop guards with try/catch), that template's values
  could be left stale rather than cleared.  → Preserve the existing
  per-template try/catch so one bad template doesn't blank or crash the
  whole recompute.

## Migration Plan

No data migration. This is a pure code/wiring fix; existing persisted
worksheet state (`WorksheetPersistState`) is read as-is.
