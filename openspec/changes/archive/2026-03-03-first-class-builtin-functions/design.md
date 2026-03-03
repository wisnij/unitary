## Context

Built-in functions (`sin`, `ln`, `exp`, etc.) are currently wired directly into
the AST evaluator: a `const Set<String>` in `ast.dart` drives parse-time
detection, and a `_evaluateBuiltin()` switch drives evaluation.  There is no
class representing a function, no registry, and no inverse support.

`AffineUnit` objects (temperature conversions) are registered in `UnitRepository`
and handled by a separate `AffineUnitNode` in the AST.  The long-term plan is to
unify affine units and piecewise functions under the same `UnitaryFunction`
abstraction, but that migration is out of scope here.

Key constraints from the existing architecture:

- `EvalContext` carries an optional `UnitRepository? repo`.  No repo → Phase 1
  behavior (raw-dimension identifiers, no unit resolution).
- `UnitRepository` separates units from prefixes to allow overlapping names
  (e.g. `m` for both meter and milli).  Functions need similar separation.
- `radian` is a dimensionless primitive unit.  Quantities in radians have
  dimension `{radian: 1}`, but are conformable with pure dimensionless numbers
  throughout the system (see `PrimitiveUnit.isDimensionless`).


## Goals / Non-Goals

**Goals:**

- `UnitaryFunction` abstract base class: id, aliases, arity, optional
  domain/range `QuantitySpec` metadata; `call()` validates args and result
  against specs automatically; optional `callInverse()` for subclasses that
  support it
- `BuiltinFunction` concrete subclass for the 9 builtin functions
- Function registry inside `UnitRepository` (`registerFunction` /
  `findFunction`)
- `lib/core/domain/data/builtin_functions.dart` housing all `BuiltinFunction`
  instances and a `registerBuiltinFunctions()` registration function
- Parser and `FunctionNode` updated to use registry lookup exclusively
- Collision detection: a name cannot be both a function and a unit/prefix

**Non-Goals:**

- `AffineFunction` (future — replaces `AffineUnit`/`AffineUnitNode`)
- `PiecewiseFunction` (future — GNU Units piecewise definitions)
- User-defined functions
- Actually invoking `callInverse()` anywhere (wiring is future work)
- Prefix support for functions
- Backward compatibility for no-repo function evaluation (see Risks)


## Decisions

### D1 — `UnitaryFunction` class structure

Each argument position and the return value is described by a `QuantitySpec`,
which bundles three optional constraints: dimension, minimum value, and maximum
value.  Min/max are represented by a `Bound` that carries both the value and
whether that endpoint is closed (inclusive) or open (exclusive).

```dart
class Bound {
  final double value;
  final bool closed;  // true = inclusive (≤/≥), false = exclusive (</>)
  const Bound(this.value, {required this.closed});
}

class QuantitySpec {
  final Dimension? dimension;  // null = any dimension accepted
  final Bound? min;            // null = no lower bound
  final Bound? max;            // null = no upper bound
  const QuantitySpec({this.dimension, this.min, this.max});
}
```

`UnitaryFunction` uses these to describe and validate its inputs and output:

```dart
abstract class UnitaryFunction {
  final String id;
  final List<String> aliases;
  final int arity;                    // required
  final List<QuantitySpec>? domain;   // optional; one entry per argument
  final QuantitySpec? range;          // optional; null = no constraints declared

  List<String> get allNames => [id, ...aliases];

  // Validates args against domain, calls evaluate(), validates result against range.
  Quantity call(List<Quantity> args);

  bool get hasInverse;
  Quantity callInverse(List<Quantity> args);  // throws EvalException if !hasInverse

  // Subclasses implement this; call() wraps it with validation.
  Quantity evaluate(List<Quantity> args);
  Quantity evaluateInverse(List<Quantity> args);  // override when hasInverse = true
}
```

The base `call()` implementation:
1. Checks argument count against `arity`
2. For each argument with a non-null `domain` entry: validates dimension (if
   specified) and value against `min`/`max` bounds (if specified)
3. Delegates to `evaluate(args)`
4. Validates the result against `range` (if non-null)

`callInverse()` mirrors this pattern, validating args then delegating to
`evaluateInverse()`, which throws `EvalException('No inverse defined for
"$id"')` by default.

**Dimension validation and radian:**  When a `QuantitySpec` specifies a
dimensionless primitive dimension (such as radian), validation accepts both
quantities that carry that dimension and pure dimensionless quantities (empty
dimension map).  This follows the same conformability rule already used
throughout the system for dimensionless primitives.

The domain and range specs for the 9 builtin functions:

| function | domain spec                                        | range spec    |
|----------|----------------------------------------------------|---------------|
| sin      | dim=radian                                         | dimensionless |
| cos      | dim=radian                                         | dimensionless |
| tan      | dim=radian                                         | dimensionless |
| asin     | dim=dimensionless, min=−1 (closed), max=1 (closed) | dim=radian    |
| acos     | dim=dimensionless, min=−1 (closed), max=1 (closed) | dim=radian    |
| atan     | dim=dimensionless                                  | dim=radian    |
| ln       | dim=dimensionless, min=0 (open)                    | dimensionless |
| log      | dim=dimensionless, min=0 (open)                    | dimensionless |
| exp      | dim=dimensionless                                  | dimensionless |

`ln` computes the natural logarithm; `log` computes base-10 logarithm.

---

### D2 — `BuiltinFunction` instances live in `builtin_functions.dart`

Class definitions (`UnitaryFunction`, `BuiltinFunction`, `QuantitySpec`,
`Bound`) go in `lib/core/domain/models/function.dart`.

The 9 `BuiltinFunction` instances are defined in
`lib/core/domain/data/builtin_functions.dart`, which also exposes:

```dart
void registerBuiltinFunctions(UnitRepository repo) { ... }
```

This mirrors the structure of `predefined_units.dart` /
`registerPredefinedUnits()`.  When more function types are added in the future,
a broader `predefined_functions.dart` can aggregate them alongside
`builtin_functions.dart`.

Builtin functions do not implement the inverse protocol (`hasInverse` is always
`false` for `BuiltinFunction`).  Inverse relationships between builtins are
expressed by the existence of separate registered functions — `sin` and `asin`
are each independent `BuiltinFunction` entries; neither references the other.
The `callInverse()` / `evaluateInverse()` mechanism exists on `UnitaryFunction`
for future subclasses (e.g. `AffineFunction`) where an analytic inverse is
natural to express as part of the same object.

---

### D3 — All function resolution goes through `UnitRepository`

There is no static fallback for function lookup.  The parser uses
`_repo?.findFunction(name)` to detect function calls; `FunctionNode.evaluate()`
uses `context.repo?.findFunction(name)` to dispatch.  If `context.repo` is null,
no functions are recognized (see Risks).

**Parser (`_identifierOrFunction`):**
```dart
// Before:
if (_check(TokenType.leftParen) && isBuiltinFunction(name)) { ... }

// After:
if (_check(TokenType.leftParen) && _repo?.findFunction(name) != null) { ... }
```

**`FunctionNode.evaluate()`:**
```dart
final repo = context.repo;
if (repo == null) throw EvalException("No repository; cannot call '$name'");
final func = repo.findFunction(name);
if (func == null) throw EvalException("Unknown function: '$name'");
return func.call(args);
```

`UnitRepository.withPredefinedUnits()` calls both `registerPredefinedUnits()`
and `registerBuiltinFunctions()`, so all functions are available whenever units
are available.

---

### D4 — Function registry inside `UnitRepository`

`UnitRepository` gains two new maps:

```dart
final Map<String, UnitaryFunction> _functions = {};       // by primary id
final Map<String, UnitaryFunction> _functionLookup = {};  // id + aliases
```

And two new methods:

```dart
void registerFunction(UnitaryFunction f);
UnitaryFunction? findFunction(String name);
```

`registerFunction` adds the function's `allNames` to `_functionLookup`.  It
throws `ArgumentError` on:
- collision within `_functionLookup` (function name already registered)
- collision with any name in `_unitLookup` or `_prefixLookup`

`findFunction` is exact-name lookup only — no prefix splitting, no plural
stripping.  Functions are looked up by their registered names verbatim.

`register` (existing unit registration) is updated to check `_functionLookup`
for collisions before registering.

---

### D5 — `FunctionNode` and `AffineUnitNode` remain separate

`FunctionNode` will look up the function in the registry and delegate to
`UnitaryFunction.call()`.  `AffineUnitNode` continues to look up `AffineUnit`
in the unit registry and apply the linear transform directly.

When `AffineFunction` is introduced in a future change, the parser will find
it via `findFunction()` (checked before `isAffine`) and produce a `FunctionNode`
instead of `AffineUnitNode`.  At that point, `AffineUnitNode` becomes dead code
and can be removed.

**Alternative considered:** merging `FunctionNode` and `AffineUnitNode` into a
single `CallNode` now.  Rejected: premature — the two code paths are still
structurally different and merging them would complicate both without benefit
until `AffineFunction` exists.

---

### D6 — `isBuiltinFunction()` is removed

The module-level `isBuiltinFunction()` function is deleted.  All call sites move
to the pattern in D3.  The `_builtinFunctions` const set and `_evaluateBuiltin()`
switch are also deleted; their logic moves into individual `BuiltinFunction`
instances in `builtin_functions.dart`.


## Risks / Trade-offs

- **No-repo function calls** — Phase 1 / no-repo mode will no longer parse or
  evaluate function calls.  Any tests that call `sin()`, `exp()`, etc. without
  a repository must be updated to supply a `UnitRepository` with builtin
  functions registered (i.e. use `UnitRepository.withPredefinedUnits()` or a
  repo that has called `registerBuiltinFunctions()`).
- **`UnitRepository` naming** — the repository now holds functions in addition
  to units and prefixes.  The name is a misnomer, but the rename is deferred to
  a future refactor as agreed.  Internal comments will note the scope.
- **`log` ≡ base 10, `ln` ≡ natural** — the existing `_evaluateBuiltin()`
  switch routes both `log` and `ln` to `dart:math log()` (natural log).  This
  change corrects `log` to base 10, which is a behavior change for any
  expression using `log`.  Tests using `log` will need updating.


## Open Questions

- When `AffineFunction` is introduced, should existing `AffineUnit` registrations
  be migrated automatically, or will both representations coexist temporarily?
  (Deferred to that change's design.)
