## Context

`test/features/worksheet/data/predefined_worksheets_test.dart` currently verifies
predefined worksheet row kinds by hard-coding which named rows are `UnitRow` vs
`FunctionRow`, and checks expressions via a mix of full `containsAll` (length, time,
digital-storage), partial `containsAll` (mass, speed), individual `contains` (area,
energy), and nothing (pressure, volume).  The ordering requirement from the spec
("smallest to largest") is not tested at all.

This is a test-only change.  No production code changes.

## Goals / Non-Goals

**Goals:**
- Derive expected `WorksheetRowKind` from the live registry via `parseQuery` rather
  than hard-coding per-row expectations.
- Verify smallest-to-largest ordering for all-`UnitRow` templates programmatically.
- Give every template exactly one `containsAll` test covering its full expression list.

**Non-Goals:**
- Changing any production code.
- Testing the `worksheet_engine` or the UI.
- Exhaustive integration tests (that lives in `worksheet_engine_test.dart`).

## Decisions

### Decision 1: derive kind from `parseQuery` return type

`ExpressionParser.parseQuery(expr)` returns:
- `FunctionNameNode` — when `expr` is a bare identifier registered as a function.
- `DefinitionRequestNode` or an `ExpressionNode` subtype — otherwise.

Expected kind mapping:
```
FunctionNameNode  →  FunctionRow
anything else     →  UnitRow
```

A single cross-template test iterates all rows in all predefined templates, calls
`parseQuery(row.expression)` on a shared `ExpressionParser` built with
`UnitRepository.withPredefinedUnits()`, and asserts `row.kind` matches.

**Rationale:** Avoids hard-coding per-row knowledge that is already encoded in the
function registry; test automatically stays correct if a row's expression is
reclassified.

### Decision 2: verify ordering by evaluating each expression

For a template where all rows are `UnitRow`, the ordering test calls
`parser.evaluate(row.expression)` for each row to obtain a `Quantity`, then checks
that `quantity.value` is non-decreasing across rows.  Ties (equal `.value`) are
broken by comparing the expression strings lexicographically and asserting the
earlier row's expression sorts ≤ the later row's expression.

Only templates where every row is a `UnitRow` are tested (temperature is excluded).
Digital-storage has SI and IEC units interleaved (kB before KiB, etc.); this
ordering is correctly captured by the magnitude-then-expression rule since
`kB = 1000 B < KiB = 1024 B`.

**Rationale:** The spec mandates "smallest to largest" ordering.  Using the
evaluator directly ties the test to the same data that production code uses.

### Decision 3: one `containsAll` per template, no individual `contains` checks

Each template group gets a single `'contains expected expressions'` test whose
body collects all expression strings from the template into a list and asserts
`containsAll(...)`.  Any existing individual `contains` or partial `containsAll`
tests for expressions are removed and replaced by this one test.

The cross-template kind test and ordering test are separate top-level tests (outside
all per-template groups) so they run once and cover everything.

## Risks / Trade-offs

- **Slow setUp**: `UnitRepository.withPredefinedUnits()` parses the full unit
  database.  Use `setUpAll` (not `setUp`) for the shared parser so it is built once
  per test run.  → Low risk; already the pattern in other integration-style tests.

- **Expression ordering tiebreaker**: the lexicographic tiebreaker for equal-magnitude
  rows is tested by the digital-storage template (kB and KiB have different
  magnitudes, so no tie actually occurs there).  If a future template genuinely has
  same-magnitude rows, both the production ordering and the test assertion must agree
  on the same tiebreaker rule.  → Documented here so it is not forgotten.
