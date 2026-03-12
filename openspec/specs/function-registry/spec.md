Function Registry
=================

Purpose
-------

Define how `UnitaryFunction` objects are stored in and retrieved from
`UnitRepository`, including collision detection across the function, unit, and
prefix registries, and how builtin functions are registered and wired into the
parser and evaluator.


Requirements
------------

### Requirement: UnitRepository stores and retrieves functions
`UnitRepository` SHALL maintain a registry of `UnitaryFunction` objects
alongside its existing unit and prefix registries.

`registerFunction(UnitaryFunction f)` SHALL register a function by its id and
all aliases, making it retrievable by any of those names via `findFunction`.

`findFunction(String name) → UnitaryFunction?` SHALL return the function
registered under `name`, or `null` if no function is registered under that name.

#### Scenario: Registered function is found by id
- **WHEN** a `UnitaryFunction` with id `"foo"` is registered
- **THEN** `findFunction("foo")` returns that function

#### Scenario: Registered function is found by alias
- **WHEN** a `UnitaryFunction` with id `"foo"` and alias `"bar"` is registered
- **THEN** `findFunction("bar")` returns that function

#### Scenario: Unregistered name returns null
- **WHEN** `findFunction` is called with a name that has not been registered
- **THEN** it returns `null`

---

### Requirement: findFunction uses exact lookup only
`findFunction` SHALL NOT perform prefix splitting, plural stripping, or any
other fuzzy matching.  Only exact name matches are returned.

#### Scenario: Plural form of function name is not matched
- **WHEN** a function with id `"foo"` is registered
- **AND** `findFunction("foos")` is called
- **THEN** `null` is returned

#### Scenario: Prefixed form of function name is not matched
- **WHEN** a function with id `"sin"` is registered
- **AND** `findFunction("ksin")` is called
- **THEN** `null` is returned

---

### Requirement: registerFunction rejects name collisions
`registerFunction` SHALL throw `ArgumentError` when any of the function's names
(id or any alias) collides with:
- A name already registered in the function registry
- Any name in the unit registry
- Any name in the prefix registry

The error message SHALL identify the colliding name and the existing entry that
owns it.

#### Scenario: Duplicate function id rejected
- **WHEN** `registerFunction` is called with a function whose id is already registered as a function
- **THEN** `ArgumentError` is thrown

#### Scenario: Function alias colliding with existing function is rejected
- **WHEN** `registerFunction` is called with a function whose alias matches an existing function's name
- **THEN** `ArgumentError` is thrown

#### Scenario: Function name colliding with unit is rejected
- **WHEN** `registerFunction` is called with a function whose id matches a registered unit name
- **THEN** `ArgumentError` is thrown

#### Scenario: Function name colliding with prefix is rejected
- **WHEN** `registerFunction` is called with a function whose id matches a registered prefix name
- **THEN** `ArgumentError` is thrown

---

### Requirement: Unit registration rejects function name collisions
`register()` (unit registration) SHALL throw `ArgumentError` when any of the
unit's names (id or any alias) collides with a name in the function registry.

#### Scenario: Unit id colliding with function is rejected
- **WHEN** `register` is called with a unit whose id matches a registered function name
- **THEN** `ArgumentError` is thrown

#### Scenario: Unit alias colliding with function is rejected
- **WHEN** `register` is called with a unit whose alias matches a registered function name
- **THEN** `ArgumentError` is thrown

---

### Requirement: Builtin functions registered via registerBuiltinFunctions
The system SHALL provide a `registerBuiltinFunctions(UnitRepository repo)`
top-level function in `lib/core/domain/data/builtin_functions.dart` that
registers all `BuiltinFunction` instances into `repo`.

This function SHALL be the sole registration entry point for builtin functions,
mirroring the structure of `registerPredefinedUnits` in `predefined_units.dart`.

#### Scenario: All builtins registered
- **WHEN** `registerBuiltinFunctions(repo)` is called on an empty repository
- **THEN** `findFunction` returns a non-null result for each of:
  `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `ln`, `log`, `exp`

---

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

---

### Requirement: Parser detects function calls via repository
The parser SHALL treat `identifier(` as a function call if and only if a
`UnitaryFunction` with that name exists in the repository (`_repo`).

When `_repo` is `null` or `_repo.findFunction(name)` returns `null`, the
identifier is not treated as a function call.

#### Scenario: Registered function parsed as FunctionNode
- **WHEN** the parser has a repository containing a function `"sin"`
- **AND** the input contains `sin(x)`
- **THEN** a `FunctionNode` with name `"sin"` is produced

#### Scenario: Unregistered identifier followed by ( is not a function call
- **WHEN** the parser encounters an identifier not registered as a function, followed by `(`
- **THEN** it is not parsed as a function call

#### Scenario: No repository means no function calls recognized
- **WHEN** the parser is constructed without a repository
- **AND** the input contains `sin(x)`
- **THEN** `sin` is parsed as a unit identifier rather than a function call

---

### Requirement: FunctionNode evaluates via repository
`FunctionNode.evaluate()` SHALL look up the function by name in `context.repo`,
then delegate to `UnitaryFunction.call()`.

It SHALL throw `EvalException` when `context.repo` is `null`.

It SHALL throw `EvalException` when the function name is not found in the
repository.

#### Scenario: Function call evaluates correctly
- **WHEN** a `FunctionNode` for `"sin"` is evaluated with a repository containing `sin`
- **THEN** the result equals the sine of the evaluated argument

#### Scenario: No repository throws EvalException
- **WHEN** a `FunctionNode` is evaluated with `context.repo == null`
- **THEN** `EvalException` is thrown

#### Scenario: Unknown function name throws EvalException
- **WHEN** a `FunctionNode` for an unregistered name is evaluated with a repository
- **THEN** `EvalException` is thrown
