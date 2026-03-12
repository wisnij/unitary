# Defined Function


## Purpose

Define the `DefinedFunction` concrete subclass of `UnitaryFunction` for
functions whose forward and inverse behaviours are specified by expression
strings evaluated at call time, along with the supporting changes to
`EvalContext` and `ExpressionParser` that make parameter variable bindings
available during expression evaluation.


## Requirements

### Requirement: DefinedFunction class
The system SHALL provide a `DefinedFunction` concrete subclass of
`UnitaryFunction` for functions whose forward and inverse behaviours are
defined by expression strings evaluated at call time.  It SHALL expose:

- `params: List<String>` — ordered list of parameter names; length equals `arity`
- `forward: String` — expression evaluated for forward calls; parameter names
  are bound to the corresponding argument `Quantity` values during evaluation
- `inverse: String?` — expression evaluated for inverse calls; the function's
  own `id` is bound to the single inverse argument during evaluation;
  `null` means no inverse is defined
- `noerror: bool` — stored for fidelity to the GNU Units source; has no
  behavioural effect

`arity` SHALL equal `params.length`.

`hasInverse` SHALL be `true` if and only if `inverse` is non-null.

Functions with more than one parameter SHALL NOT have an inverse
(`inverse` must be `null` when `params.length > 1`).  Constructing a
`DefinedFunction` with multiple params and a non-null `inverse` SHALL throw
`ArgumentError`.

#### Scenario: arity equals params length
- **WHEN** a `DefinedFunction` is constructed with two parameter names
- **THEN** `arity` is `2`

#### Scenario: hasInverse true when inverse present
- **WHEN** a `DefinedFunction` is constructed with a non-null `inverse` string
- **THEN** `hasInverse` is `true`

#### Scenario: hasInverse false when inverse absent
- **WHEN** a `DefinedFunction` is constructed with `inverse: null`
- **THEN** `hasInverse` is `false`

#### Scenario: Multi-param function with inverse is rejected at construction
- **WHEN** a `DefinedFunction` is constructed with two or more params and a
  non-null `inverse`
- **THEN** `ArgumentError` is thrown

---

### Requirement: DefinedFunction forward evaluation
`DefinedFunction.evaluate()` SHALL:

1. Require a non-null `EvalContext` to have been passed to `call()`.  If
   `call()` received a null context, `evaluate()` SHALL throw `EvalException`
   with a message identifying the function.
2. Build a `Map<String, Quantity>` binding each param name to the corresponding
   argument `Quantity` value (same order as `params`).
3. Add `"<id>()"` to a copy of `context.visited` (the recursion guard key).
4. Construct `ExpressionParser(repo: context.repo, variables: paramBindings,
   visited: extendedVisited)` and call `.evaluate(forward)`.
5. Return the resulting `Quantity`.

The param bindings carry the full `Quantity` (value and dimension) of each
argument, so that parameter names inside the expression resolve to unit-like
quantities with the correct dimension.

#### Scenario: Single-param forward evaluation
- **WHEN** `call([Quantity(3.0, {m:1})], context)` is invoked on
  `DefinedFunction(id:'circlearea', params:['r'], forward:'pi r^2', ...)`
- **THEN** the result is approximately `Quantity(28.274..., {m:2})`
  (since `π × 3² = 28.274...`)

#### Scenario: Multi-param forward evaluation
- **WHEN** `call([Quantity(3.0, {}), Quantity(4.0, {})], context)` is invoked
  on `DefinedFunction(id:'f', params:['x','y'], forward:'2 x + y', ...)`
- **THEN** the result is `Quantity(10.0, {})` (since `2×3 + 4 = 10`)

#### Scenario: Param name shadows real unit
- **WHEN** a param named `r` is bound to `Quantity(5.0, {})` and the
  expression references `r`
- **THEN** `r` resolves to `Quantity(5.0, {})`, not to the roentgen unit

#### Scenario: Null context raises EvalException
- **WHEN** `call(args, null)` is invoked on a `DefinedFunction`
- **THEN** `EvalException` is thrown naming the function

---

### Requirement: DefinedFunction inverse evaluation
`DefinedFunction.evaluateInverse()` SHALL:

1. Require a non-null `EvalContext` (same check as forward evaluation).
2. Build a `Map<String, Quantity>` binding the function's `id` to the single
   inverse argument `Quantity`.
3. Add `"<id>()"` to a copy of `context.visited`.
4. Construct `ExpressionParser(repo: context.repo, variables: binding,
   visited: extendedVisited)` and call `.evaluate(inverse!)`.
5. Return the resulting `Quantity`.

#### Scenario: Inverse evaluation recovers the original argument
- **WHEN** `callInverse([Quantity(28.274..., {m:2})], context)` is invoked on
  a `DefinedFunction(id:'circlearea', inverse:'sqrt(circlearea/pi)', ...)`
- **THEN** the result is approximately `Quantity(3.0, {m:1})`

#### Scenario: Inverse expression uses function name as variable
- **WHEN** the inverse expression references the function id as a variable
- **THEN** that identifier resolves to the inverse argument value, not to the
  function in the registry

---

### Requirement: DefinedFunction recursion detection
`DefinedFunction.evaluate()` and `evaluateInverse()` SHALL detect and reject
circular function calls by adding `"<id>()"` to `context.visited` before
evaluating.

If `"<id>()"` is already present in `context.visited` when `evaluate()` or
`evaluateInverse()` is entered, `EvalException` SHALL be thrown immediately
with a message identifying the circular dependency.

Because `context.visited` is threaded through the `ExpressionParser` into any
nested `DefinedFunction` calls, mutual recursion between two or more functions
is also detected.

#### Scenario: Direct self-recursion throws EvalException
- **WHEN** a `DefinedFunction`'s forward expression calls the function itself
- **THEN** `EvalException` is thrown (circular function definition detected)
  rather than a stack overflow

#### Scenario: Mutual recursion throws EvalException
- **WHEN** function A's expression calls function B, and B's expression calls A
- **THEN** `EvalException` is thrown when the cycle is closed

#### Scenario: Non-recursive chain does not throw
- **WHEN** function A's expression calls function B, which does not call A
- **THEN** evaluation succeeds without error

---

### Requirement: EvalContext supports parameter variable bindings
`EvalContext` SHALL expose a `Map<String, Quantity>? variables` field
(default `null`, meaning no variable bindings are active).

`UnitNode.evaluate()` SHALL check `context.variables` before performing a repo
lookup: if `variables` is non-null and contains the unit name as a key, the
associated `Quantity` is returned directly without consulting the repository.

When `variables` is `null` or does not contain the name, behaviour is unchanged
(the repo lookup proceeds as before).

#### Scenario: Variable binding shadows repo unit
- **WHEN** `EvalContext.variables` contains `{"r": Quantity(3.0, {m:1})}`
- **AND** `r` is also a registered unit in the repo
- **THEN** evaluating `r` returns `Quantity(3.0, {m:1})` from the variables map

#### Scenario: Variable not in map falls through to repo
- **WHEN** `EvalContext.variables` is `{"x": Quantity(2.0, {})}` and the
  expression contains `m` (meters)
- **THEN** evaluating `m` performs a normal repo lookup and returns the meter
  quantity

#### Scenario: Null variables does not affect evaluation
- **WHEN** `EvalContext.variables` is `null`
- **THEN** all identifier lookups proceed via the repo as before

---

### Requirement: ExpressionParser accepts variable bindings
`ExpressionParser` SHALL accept an optional
`Map<String, Quantity>? variables` parameter.  This map SHALL be forwarded into
every `EvalContext` constructed during `evaluate()`, making the bindings
visible to all `UnitNode` evaluations within that parse-evaluate call.

#### Scenario: Variables passed to ExpressionParser reach UnitNode
- **WHEN** `ExpressionParser(repo: repo, variables: {"x": Quantity(5.0, {})})
  .evaluate("x + 1")`
- **THEN** the result is `Quantity(6.0, {})` (x resolves to 5.0)

#### Scenario: No variables means no bindings
- **WHEN** `ExpressionParser(repo: repo).evaluate("m + 1")` is evaluated
  (syntactically invalid, but the point is no variable injection)
- **THEN** normal repo lookup applies for all identifiers
