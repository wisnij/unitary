## ADDED Requirements

### Requirement: Each row's kind is consistent with its expression as parsed by the registry

For every row in every predefined template, the `kind` field SHALL be consistent
with how `ExpressionParser.parseQuery(row.expression)` classifies the expression
against the live `UnitRepository`:

- `FunctionNameNode` → row kind SHALL be `FunctionRow`
- Any other node type (`DefinitionRequestNode`, any `ExpressionNode`) → row kind SHALL be `UnitRow`

#### Scenario: UnitRow expression resolves to a non-function node

- **WHEN** `parseQuery` is called with the `expression` of a `UnitRow` from any predefined template
- **THEN** the result is NOT a `FunctionNameNode`

#### Scenario: FunctionRow expression resolves to a FunctionNameNode

- **WHEN** `parseQuery` is called with the `expression` of a `FunctionRow` from any predefined template
- **THEN** the result IS a `FunctionNameNode`

### Requirement: All-UnitRow templates are ordered smallest to largest

For any predefined template whose rows are all `UnitRow`, evaluating each row's
expression with `ExpressionParser.evaluate` SHALL yield `Quantity` values in
non-decreasing order.  When two adjacent rows produce the same `Quantity.value`,
their expression strings SHALL be in non-decreasing lexicographic order.

#### Scenario: All-UnitRow template rows are in ascending magnitude order

- **WHEN** each row expression in an all-`UnitRow` template is evaluated to a `Quantity`
- **THEN** the resulting `.value` sequence is non-decreasing from first to last row

#### Scenario: Equal-magnitude rows are ordered by expression string

- **WHEN** two adjacent rows in an all-`UnitRow` template evaluate to the same `Quantity.value`
- **THEN** the earlier row's expression string is lexicographically ≤ the later row's expression string

### Requirement: Volume template rows

The `volume` template SHALL contain exactly the following expressions (in
smallest-to-largest order): `mL`, `tsp`, `tbsp`, `floz`, `cup`, `pt`, `qt`,
`L`, `gal`, `bbl` — all `UnitRow`.

#### Scenario: Volume template expressions

- **WHEN** the `volume` template is retrieved from the registry
- **THEN** its rows contain all of: `mL`, `tsp`, `tbsp`, `floz`, `cup`, `pt`, `qt`, `L`, `gal`, `bbl`

### Requirement: Pressure template rows

The `pressure` template SHALL contain exactly the following expressions (in
smallest-to-largest order): `Pa`, `mbar`, `torr`, `mmHg`, `kPa`, `inHg`,
`psi`, `bar`, `atm`, `MPa` — all `UnitRow`.

#### Scenario: Pressure template expressions

- **WHEN** the `pressure` template is retrieved from the registry
- **THEN** its rows contain all of: `Pa`, `mbar`, `mmHg`, `torr`, `kPa`, `inHg`, `psi`, `bar`, `atm`, `MPa`
