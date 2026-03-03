Function Class
==============

Purpose
-------

Define the `UnitaryFunction` abstract base class and its supporting types
(`QuantitySpec`, `Bound`) that represent named callable identifiers in the
expression evaluator, along with the concrete `BuiltinFunction` subclass for
the set of built-in mathematical functions.


Requirements
------------

### Requirement: UnitaryFunction abstract base class
The system SHALL provide a `UnitaryFunction` abstract class as the base for all
named callable identifiers.  It SHALL expose:
- `id: String` — primary registration name
- `aliases: List<String>` — alternative names (may be empty)
- `arity: int` — required number of arguments
- `domain: List<QuantitySpec>?` — optional per-argument constraint specs
- `range: QuantitySpec?` — optional constraint on the return value
- `allNames: List<String>` getter returning `[id, ...aliases]`
- `hasInverse: bool` getter
- `call(List<Quantity> args) → Quantity` — validates args, evaluates, validates result
- `callInverse(List<Quantity> args) → Quantity` — throws if `hasInverse` is false
- `evaluate(List<Quantity> args) → Quantity` — subclass-implemented forward logic
- `evaluateInverse(List<Quantity> args) → Quantity` — subclass-implemented inverse logic

#### Scenario: allNames includes id and all aliases
- **WHEN** a `UnitaryFunction` is created with id `"foo"` and aliases `["bar", "baz"]`
- **THEN** `allNames` returns `["foo", "bar", "baz"]`

#### Scenario: allNames with no aliases
- **WHEN** a `UnitaryFunction` is created with id `"foo"` and no aliases
- **THEN** `allNames` returns `["foo"]`

---

### Requirement: QuantitySpec and Bound constraint types
The system SHALL provide a `Bound` class with:
- `value: double` — the bound value
- `closed: bool` — `true` means inclusive (≤ or ≥); `false` means exclusive (< or >)

The system SHALL provide a `QuantitySpec` class with:
- `dimension: Dimension?` — required dimension; `null` means any dimension is accepted
- `min: Bound?` — lower bound on the quantity's value; `null` means no lower bound
- `max: Bound?` — upper bound on the quantity's value; `null` means no upper bound

All fields SHALL be optional and default to `null` (no restriction).

#### Scenario: QuantitySpec with no constraints accepts anything
- **WHEN** a `QuantitySpec` is created with no arguments
- **THEN** all three fields are `null`

#### Scenario: Bound with closed endpoint
- **WHEN** a `Bound` is created with value `1.0` and `closed: true`
- **THEN** `value` is `1.0` and `closed` is `true`

---

### Requirement: call() validates argument count
`call()` SHALL throw `EvalException` when invoked with a number of arguments that
does not match `arity`.  The error message SHALL identify the function name, the
expected count, and the actual count.

#### Scenario: Too few arguments
- **WHEN** `call()` is invoked with fewer arguments than `arity`
- **THEN** `EvalException` is thrown naming the function and the mismatch

#### Scenario: Too many arguments
- **WHEN** `call()` is invoked with more arguments than `arity`
- **THEN** `EvalException` is thrown naming the function and the mismatch

#### Scenario: Correct argument count proceeds
- **WHEN** `call()` is invoked with exactly `arity` arguments that satisfy all other constraints
- **THEN** evaluation proceeds without an argument-count error

---

### Requirement: call() validates argument dimensions
For each argument position that has a non-null `QuantitySpec` in `domain`,
`call()` SHALL throw `DimensionException` when the argument's dimension does not
match the spec's `dimension` (if specified).

Validation for dimensionless primitive dimensions (e.g. radian) SHALL accept
both quantities carrying that dimension and pure dimensionless quantities (empty
dimension map), following the same conformability rule used throughout the system
for dimensionless primitives.

When `domain` is `null`, or a particular entry is `null`, any dimension is
accepted for that argument.

#### Scenario: Argument with wrong dimension is rejected
- **WHEN** `call()` is invoked with an argument whose dimension does not conform to the spec
- **THEN** `DimensionException` is thrown

#### Scenario: Dimensionless primitive spec accepts pure number
- **WHEN** a domain spec requires radian dimension
- **AND** the argument is a pure dimensionless `Quantity` (empty dimension map)
- **THEN** the argument is accepted without error

#### Scenario: Dimensionless primitive spec accepts radian quantity
- **WHEN** a domain spec requires radian dimension
- **AND** the argument has dimension `{radian: 1}`
- **THEN** the argument is accepted without error

#### Scenario: Null domain means no dimension constraint
- **WHEN** `domain` is `null`
- **THEN** any dimension is accepted for all arguments

---

### Requirement: call() validates argument value bounds
For each argument position that has a non-null `QuantitySpec` in `domain`,
`call()` SHALL throw `EvalException` when the argument's value violates the
spec's `min` or `max` bound.  The error message SHALL identify the function name
and the violated constraint.

A closed bound includes the endpoint (≤ / ≥); an open bound excludes it (< / >).

#### Scenario: Value below closed minimum is rejected
- **WHEN** `call()` is invoked with an argument value strictly less than a closed `min` bound
- **THEN** `EvalException` is thrown

#### Scenario: Value equal to closed minimum is accepted
- **WHEN** `call()` is invoked with an argument value equal to a closed `min` bound
- **THEN** the bound check passes

#### Scenario: Value equal to open minimum is rejected
- **WHEN** `call()` is invoked with an argument value equal to an open `min` bound
- **THEN** `EvalException` is thrown

#### Scenario: Value above closed maximum is rejected
- **WHEN** `call()` is invoked with an argument value strictly greater than a closed `max` bound
- **THEN** `EvalException` is thrown

#### Scenario: Value equal to closed maximum is accepted
- **WHEN** `call()` is invoked with an argument value equal to a closed `max` bound
- **THEN** the bound check passes

#### Scenario: Value equal to open maximum is rejected
- **WHEN** `call()` is invoked with an argument value equal to an open `max` bound
- **THEN** `EvalException` is thrown

---

### Requirement: call() validates return value
After `evaluate()` returns, `call()` SHALL validate the result against `range`
(if non-null) using the same dimension and bound rules as for arguments.
It SHALL throw `DimensionException` or `EvalException` as appropriate if the
result violates the spec.

#### Scenario: Return value violating range dimension is rejected
- **WHEN** `evaluate()` returns a `Quantity` whose dimension does not match `range.dimension`
- **THEN** `call()` throws `DimensionException`

#### Scenario: Return value violating range bounds is rejected
- **WHEN** `evaluate()` returns a `Quantity` whose value violates a `range` bound
- **THEN** `call()` throws `EvalException`

#### Scenario: Null range means no return constraint
- **WHEN** `range` is `null`
- **THEN** the return value is not validated

---

### Requirement: callInverse() raises error when inverse not defined
`callInverse()` SHALL throw `EvalException` when `hasInverse` is `false`.
The error message SHALL identify the function by name.

`evaluateInverse()` in the base class SHALL throw `EvalException` by default,
so subclasses that do not override it automatically satisfy this requirement.

#### Scenario: callInverse on non-invertible function
- **WHEN** `callInverse()` is invoked on a `UnitaryFunction` with `hasInverse == false`
- **THEN** `EvalException` is thrown with a message identifying the function

---

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
