## ADDED Requirements

### Requirement: Structured cell result
`computeWorksheet` SHALL return results as `List<WorksheetCellResult?>` where
each non-null entry carries a `String text` and a `bool isError` flag.  A
`null` entry retains its existing "clear / preserve" semantic (source row or
invalid input).

A normal value entry SHALL have `isError: false`.  An error entry SHALL have
`isError: true` and `text` set to a short human-readable label.

#### Scenario: Normal value result has isError false
- **WHEN** a target row converts successfully
- **THEN** the result entry has `isError: false` and `text` is the formatted numeric string

#### Scenario: Error result has isError true
- **WHEN** a target row conversion fails for any reason
- **THEN** the result entry has `isError: true` and `text` is a non-empty error label

### Requirement: Specific error labels
The engine SHALL produce the following short labels based on failure kind:

- Dimension mismatch (`DimensionException`): `"wrong unit type"`
- Domain or range bounds violation (`BoundsException`): `"out of bounds"`
- No inverse defined for a `FunctionRow` target: `"no inverse"`
- All other failures: `"error"`

#### Scenario: Dimension mismatch error label
- **WHEN** a target `UnitRow`'s dimension is incompatible with the base quantity
- **THEN** the result entry has `isError: true` and `text` is `"wrong unit type"`

#### Scenario: Out-of-bounds error label
- **WHEN** the base quantity's value falls outside a `FunctionRow` target's domain
- **THEN** the result entry has `isError: true` and `text` is `"out of bounds"`

#### Scenario: No-inverse error label
- **WHEN** a `FunctionRow` target's function has no inverse
- **THEN** the result entry has `isError: true` and `text` is `"no inverse"`

#### Scenario: Generic error label fallback
- **WHEN** a target row fails for an unexpected reason
- **THEN** the result entry has `isError: true` and `text` is `"error"`

## MODIFIED Requirements

### Requirement: Dimension conformability
The engine SHALL verify that the source row's base `Quantity` is conformable
with each target row's expected dimension.  If a row's expression fails to
evaluate or produces an incompatible dimension, that row SHALL display an error
label rather than a value (see Requirement: Specific error labels).

#### Scenario: Conformable rows produce values
- **WHEN** all rows in a worksheet share the same physical dimension
- **THEN** all rows display valid computed values

#### Scenario: Incompatible dimension shows error
- **WHEN** a worksheet row expression evaluates to a dimension incompatible with the source
- **THEN** that row displays the label `"wrong unit type"` (not a numeric value)
