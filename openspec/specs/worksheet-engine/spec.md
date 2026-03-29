# Worksheet Engine

## Purpose

Defines the conversion computation logic for worksheet mode: how a value typed
into one row is converted into values for all other rows, covering both
ratio-based (`UnitRow`) and function-based (`FunctionRow`) row kinds.

## Requirements

### Requirement: UnitRow conversion
Given a source value `v` typed into a `UnitRow` with expression `E_src`, the
engine SHALL compute:

1. Parse and evaluate `E_src` → `unitQty_src` (a `Quantity`)
2. `base = v × unitQty_src.value` (a scalar in primitive units)
3. For each other `UnitRow` with expression `E_j`:
   - Parse and evaluate `E_j` → `unitQty_j`
   - Display value = `base / unitQty_j.value`

#### Scenario: Simple unit conversion
- **WHEN** the user types `1` in the `m` row of the length worksheet
- **THEN** the `ft` row displays approximately `3.28084`

#### Scenario: Compound expression conversion
- **WHEN** the user types `1` in the `m/s` row of the speed worksheet
- **THEN** the `km/h` row displays approximately `3.6`

### Requirement: FunctionRow as source
Given a source value `v` typed into a `FunctionRow` with function name `F`,
the engine SHALL compute:

1. Look up function `F` in `UnitRepository`
2. `base = F.call([Quantity(v, dimensionless)], context)` → a `Quantity` in
   primitive units
3. Distribute `base` to all other rows (see UnitRow and FunctionRow as target)

#### Scenario: Temperature from Celsius
- **WHEN** the user types `100` in the `tempC` row of the temperature worksheet
- **THEN** the `K` row displays `373.15`

### Requirement: FunctionRow as target
Given a base `Quantity` derived from the source row, for a target `FunctionRow`
with function name `F`, the engine SHALL compute:

`display = F.callInverse([base], context)` → a scalar

The function MUST have an inverse (`hasInverse == true`); if not, the row SHALL
display an error string.

#### Scenario: Temperature to Fahrenheit
- **WHEN** the user types `100` in the `tempC` row of the temperature worksheet
- **THEN** the `tempF` row displays `212`

#### Scenario: Temperature full round-trip
- **WHEN** the user types `0` in the `tempC` row
- **THEN** the `K` row displays `273.15`, the `tempF` row displays `32`, and the `degR` row displays `491.67`

### Requirement: Mixed UnitRow and FunctionRow in same worksheet
The engine SHALL correctly interoperate `UnitRow` and `FunctionRow` targets
from a single source, regardless of the source row's kind.

#### Scenario: UnitRow source with FunctionRow target
- **WHEN** the user types `373.15` in the `K` row (a `UnitRow`) of the temperature worksheet
- **THEN** the `tempC` row (`FunctionRow`) displays `100`

#### Scenario: FunctionRow source with UnitRow target
- **WHEN** the user types `100` in the `tempC` row (`FunctionRow`) of the temperature worksheet
- **THEN** the `K` row (`UnitRow`) displays `373.15`

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

### Requirement: Invalid or empty input clears all rows
If the active row's input string is empty or cannot be parsed as a number, the
engine SHALL set all non-active rows to empty string (`""`).

#### Scenario: Empty input clears other rows
- **WHEN** the user clears the active row's text field
- **THEN** all other row display values become `""`

#### Scenario: Non-numeric input clears other rows
- **WHEN** the user types a non-numeric string in a row
- **THEN** all other row display values become `""`
