## MODIFIED Requirements

### Requirement: BuiltinFunction subclass
The system SHALL provide a `BuiltinFunction` concrete subclass of
`UnitaryFunction` for each of the following functions:

| id     | description                                              |
|--------|----------------------------------------------------------|
| `sin`  | sine of an angle in radians; returns dimensionless       |
| `cos`  | cosine of an angle in radians; returns dimensionless     |
| `tan`  | tangent of an angle in radians; returns dimensionless    |
| `asin` | arcsine of a dimensionless value; returns radians        |
| `acos` | arccosine of a dimensionless value; returns radians      |
| `atan` | arctangent of a dimensionless value; returns radians     |
| `ln`   | natural logarithm of a positive dimensionless value      |
| `log`  | base-10 logarithm of a positive dimensionless value      |
| `exp`  | e raised to a dimensionless power; returns dimensionless |

Each `BuiltinFunction` SHALL have `hasInverse == false`.

`log` SHALL have no aliases.  The `log2` builtin is removed; arbitrary-base
logarithms are handled by the parser's `logB(x)` desugaring instead.

Domain and range constraints for each function SHALL match the table in
`design.md` D1.

#### Scenario: sin of zero
- **WHEN** `sin` is called with argument `0` (dimensionless or radian)
- **THEN** the result is `0` (dimensionless)

#### Scenario: sin of π/2 radians
- **WHEN** `sin` is called with argument `π/2` in radians
- **THEN** the result is `1.0` (dimensionless), within floating-point tolerance

#### Scenario: asin of 1
- **WHEN** `asin` is called with argument `1.0` (dimensionless)
- **THEN** the result is `π/2` with radian dimension, within floating-point tolerance

#### Scenario: asin of value outside [-1, 1] is rejected
- **WHEN** `asin` is called with argument `1.5`
- **THEN** `EvalException` is thrown (max bound violation)

#### Scenario: ln of e
- **WHEN** `ln` is called with argument `e` (dimensionless)
- **THEN** the result is `1.0` (dimensionless), within floating-point tolerance

#### Scenario: ln of zero is rejected
- **WHEN** `ln` is called with argument `0.0`
- **THEN** `EvalException` is thrown (open min bound violation)

#### Scenario: ln of negative value is rejected
- **WHEN** `ln` is called with argument `-1.0`
- **THEN** `EvalException` is thrown (min bound violation)

#### Scenario: log of 100
- **WHEN** `log` is called with argument `100.0` (dimensionless)
- **THEN** the result is `2.0` (dimensionless), within floating-point tolerance

#### Scenario: exp of 1
- **WHEN** `exp` is called with argument `1.0` (dimensionless)
- **THEN** the result is approximately `e` (dimensionless), within floating-point tolerance

#### Scenario: BuiltinFunction has no inverse
- **WHEN** `hasInverse` is checked on any `BuiltinFunction` instance
- **THEN** it returns `false`

#### Scenario: log has no log10 alias
- **WHEN** `findFunction("log10")` is called on a repository with predefined units
- **THEN** it returns `null`

#### Scenario: log2 is not registered
- **WHEN** `findFunction("log2")` is called on a repository with predefined units
- **THEN** it returns `null`
