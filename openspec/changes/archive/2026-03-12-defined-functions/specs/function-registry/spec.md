## MODIFIED Requirements

### Requirement: withPredefinedUnits registers builtin functions
`UnitRepository.withPredefinedUnits()` SHALL register all builtin functions,
predefined units and prefixes, piecewise functions, and defined functions by
calling the following registration functions during construction, in order:

1. `registerBuiltinFunctions(repo)`
2. `registerPredefinedUnits(repo)`
3. `registerPiecewiseFunctions(repo)`
4. `registerDefinedFunctions(repo)`

#### Scenario: Builtin functions available in standard repository
- **WHEN** a `UnitRepository` is created with `withPredefinedUnits()`
- **THEN** `findFunction("sin")` returns a non-null `UnitaryFunction`
- **AND** `findFunction("exp")` returns a non-null `UnitaryFunction`

#### Scenario: Defined functions available in standard repository
- **WHEN** a `UnitRepository` is created with `withPredefinedUnits()`
- **THEN** `findFunction("circlearea")` returns a non-null `DefinedFunction`
- **AND** `findFunction("tempC")` returns a non-null `DefinedFunction`

#### Scenario: Defined functions registered after piecewise functions
- **WHEN** `withPredefinedUnits()` constructs the repository
- **THEN** `registerDefinedFunctions` is called after `registerPiecewiseFunctions`,
  so defined functions may safely reference piecewise functions in their
  expression bodies
