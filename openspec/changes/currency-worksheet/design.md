## Context

Phase 8 shipped live currency exchange rates fetched from Frankfurter v2.  At
startup, rates are loaded from SharedPreferences and registered as dynamic
units in `UnitRepository`.  All 12 target currencies (AUD, CAD, CHF, CNY, EUR,
GBP, HKD, JPY, KRW, MXN, SGD, USD) are guaranteed to be present as unit names
by the time the worksheet screen renders.

The existing worksheet infrastructure (`WorksheetTemplate`, `WorksheetRow`,
`computeWorksheet`, `WorksheetNotifier`) already handles `UnitRow` entries
whose expressions resolve to conformable units.  All currency units resolve to
the same dimension (`{US$: 1}`), so the engine will perform ratio-based
conversion with no changes required.

## Goals / Non-Goals

**Goals:**

- Add a `WorksheetOrdering` enum (`magnitude`, `alphabetical`, `none`) and an
  `ordering` field to `WorksheetTemplate`.
- Add a `currency` worksheet template with 12 rows, one per major ISO code,
  with `ordering: alphabetical`.
- Assign `ordering: none` to the `temperature` template (mixed row kinds, no
  defined magnitude ordering).
- Replace the "all-UnitRow" proxy condition in the ordering requirement with
  the explicit `ordering: magnitude` field.

**Non-Goals:**

- Changing how currency units or exchange rates are stored or fetched.
- Adding a "live rates" visual indicator to the worksheet UI.
- Supporting user-configurable currency row selection.

## Decisions

### Decision: All rows are `UnitRow`

Currency identifiers (USD, EUR, etc.) are registered as ordinary `DerivedUnit`
instances in `UnitRepository`.  `ExpressionParser.parseQuery("USD")` returns a
`DefinitionRequestNode`, not a `FunctionNameNode`, so `UnitRow` is the correct
kind.  No `FunctionRow` entries are needed.

### Decision: `WorksheetOrdering` enum with `magnitude`, `alphabetical`, `none`

Three values cover all current and anticipated cases:

- `magnitude` — rows must be in non-decreasing quantity order; the ordering
  test evaluates each row's expression via `ExpressionParser.evaluate`.  If a
  `magnitude`-tagged template accidentally includes a `FunctionRow`, the test
  throws `EvalException('Unknown unit: …')` because `UnitNode.evaluate` never
  checks `findFunction`—making the misconfiguration visible at test time with no
  extra guard needed.
- `alphabetical` — rows are ordered by their `label` (spelled-out name); used
  for currency where exchange-rate magnitude changes daily.
- `none` — no ordering contract; used for `temperature` which has a mix of
  absolute-scale `UnitRow`s and affine `FunctionRow`s that have no meaningful
  shared magnitude ordering.

This replaces the previous "all-UnitRow" proxy condition and the id-based
`currency` carve-out, making ordering policy explicit and co-located with each
template definition.

Alternative considered: sort currency by current rate at template build time.
Rejected: the sort would be stale after the next refresh and differ across
devices/sessions.

### Decision: No new infrastructure beyond the ordering field

The `currency` template is just another entry in the existing
`predefinedWorksheetTemplates` list.  The only model change is adding
`WorksheetOrdering` and the `ordering` field to `WorksheetTemplate`.

## Risks / Trade-offs

- **Risk**: A currency unit is missing from `UnitRepository` at worksheet render
  time (e.g., first launch with no stored rates and no network).
  → Mitigation: `computeWorksheet` already emits a per-row error string on
  `EvalException`; missing units surface as row errors rather than crashes.
  Built-in fallback rates in the currency-rates phase ensure all 12 are always
  present.
