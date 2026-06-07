## Why

Phase 8 added live currency exchange rates that are automatically refreshed
from the Frankfurter v2 API.  Now that currency units are dynamic and
up-to-date, a dedicated Currency worksheet gives users a convenient multi-unit
view for comparing exchange rates at a glance.

## What Changes

- Add a new `currency` predefined `WorksheetTemplate` with 12 rows (one per
  major ISO currency code): AUD, CAD, CHF, CNY, EUR, GBP, HKD, JPY, KRW, MXN,
  SGD, USD.
- Rows are ordered **alphabetically by ISO code** rather than by unit magnitude;
  currency exchange rates fluctuate constantly so magnitude ordering is
  meaningless and misleading.
- The "all-UnitRow templates ordered smallest to largest" requirement in the
  `worksheet-templates` spec must be updated to allow ISO-alphabetical ordering
  for the `currency` template.
- Template count increases from 11 to 12.

## Capabilities

### New Capabilities

- `currency-worksheet`: The predefined currency conversion worksheet template,
  its 12 rows, and its ISO-alphabetical ordering policy.

### Modified Capabilities

- `worksheet-templates`: Template count changes from 11 to 12; the ascending
  magnitude ordering requirement must be relaxed to exclude templates whose
  rows are ordered by ISO code rather than magnitude (i.e., the `currency`
  template).

## Impact

- `lib/features/worksheet/domain/worksheet_templates.dart` — add the `currency`
  template definition.
- `test/features/worksheet/domain/worksheet_templates_test.dart` — add/update
  tests for the new template and the relaxed ordering requirement.
- No new dependencies.  All 12 currency symbols (`USD`, `EUR`, etc.) are
  already registered as dynamic units by the currency-rates phase.
