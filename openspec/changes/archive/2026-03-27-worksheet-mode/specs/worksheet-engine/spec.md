## ADDED Requirements

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

### Requirement: Dimension conformability
The engine SHALL verify that the source row's base `Quantity` is conformable
with each target row's expected dimension.  If a row's expression fails to
evaluate or produces an incompatible dimension, that row SHALL display an error
string rather than a value.

#### Scenario: Conformable rows produce values
- **WHEN** all rows in a worksheet share the same physical dimension
- **THEN** all rows display valid computed values

#### Scenario: Incompatible dimension shows error
- **WHEN** a worksheet row expression evaluates to a dimension incompatible with the source
- **THEN** that row displays an error string (not a numeric value)

### Requirement: Invalid or empty input clears all rows
If the active row's input string is empty or cannot be parsed as a number, the
engine SHALL set all non-active rows to empty string (`""`).

#### Scenario: Empty input clears other rows
- **WHEN** the user clears the active row's text field
- **THEN** all other row display values become `""`

#### Scenario: Non-numeric input clears other rows
- **WHEN** the user types a non-numeric string in a row
- **THEN** all other row display values become `""`
