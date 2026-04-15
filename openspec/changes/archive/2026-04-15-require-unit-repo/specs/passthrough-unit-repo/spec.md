## ADDED Requirements

### Requirement: PassthroughUnitRepository accepts any identifier
A `PassthroughUnitRepository` test utility SHALL be available in `test/helpers/`
that extends `UnitRepository` and returns a synthetic `PrimitiveUnit` for any
unit name, allowing evaluator tests to exercise the expression parser without
registering real units.

#### Scenario: Any name resolves to a PrimitiveUnit
- **WHEN** `PassthroughUnitRepository().findUnit('wakalixes')` is called for an arbitrary name not in any real database
- **THEN** a non-null `PrimitiveUnit` is returned whose `id` equals the lookup name

#### Scenario: Any name with prefix resolves without error
- **WHEN** `PassthroughUnitRepository().findUnitWithPrefix('wakalixes')` is called
- **THEN** a `UnitMatch` is returned with a non-null `unit` whose `id` equals `'wakalixes'`

#### Scenario: Evaluating a passthrough expression produces a raw-dimension Quantity
- **WHEN** `ExpressionParser(repo: PassthroughUnitRepository()).evaluate('5 wakalixes')` is called
- **THEN** the result is `Quantity(5.0, Dimension({'wakalixes': 1}))` with no exception thrown
