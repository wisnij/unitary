## MODIFIED Requirements

### Requirement: Builtin functions registered via registerBuiltinFunctions
The system SHALL provide a `registerBuiltinFunctions(UnitRepository repo)`
top-level function in `lib/core/domain/data/builtin_functions.dart` that
registers all `BuiltinFunction` instances into `repo`.

This function SHALL be the sole registration entry point for builtin functions,
mirroring the structure of `registerPredefinedUnits` in `predefined_units.dart`.

`log2` SHALL NOT be registered (it has been removed; arbitrary-base logarithms
are handled by parser desugaring).

#### Scenario: All builtins registered
- **WHEN** `registerBuiltinFunctions(repo)` is called on an empty repository
- **THEN** `findFunction` returns a non-null result for each of:
  `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `ln`, `log`, `exp`

#### Scenario: log2 is not registered by registerBuiltinFunctions
- **WHEN** `registerBuiltinFunctions(repo)` is called
- **THEN** `findFunction("log2")` returns `null`

#### Scenario: log10 is not registered by registerBuiltinFunctions
- **WHEN** `registerBuiltinFunctions(repo)` is called
- **THEN** `findFunction("log10")` returns `null`

---

### Requirement: withPredefinedUnits registers builtin functions
`UnitRepository.withPredefinedUnits()` SHALL register all builtin functions in
addition to all predefined units and prefixes, by calling
`registerBuiltinFunctions` during construction.

#### Scenario: Builtin functions available in standard repository
- **WHEN** a `UnitRepository` is created with `withPredefinedUnits()`
- **THEN** `findFunction("sin")` returns a non-null `UnitaryFunction`
- **AND** `findFunction("exp")` returns a non-null `UnitaryFunction`

#### Scenario: log2 not available in standard repository
- **WHEN** a `UnitRepository` is created with `withPredefinedUnits()`
- **THEN** `findFunction("log2")` returns `null`
