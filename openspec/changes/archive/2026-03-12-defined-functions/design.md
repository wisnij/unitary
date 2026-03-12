## Context

GNU Units defines 147 "nonlinear units" — units whose value is computed by an
arbitrary expression rather than a constant factor.  Examples include
`circlearea(r)`, `pH(x)`, `windchill(T,speed)`, and the temperature scales
`tempC(x)` / `tempF(x)`.  The current importer marks all of these as
"unsupported"; they are absent from the unit database and unavailable for
evaluation.

`BuiltinFunction` (hardcoded Dart closures) and `PiecewiseFunction` (lookup
tables) already exist.  This change adds `DefinedFunction` — a function whose
forward and inverse behaviours are expressions evaluated at call time.

`tempC` and `tempF` are currently registered as `AffineUnit` entries via
hand-maintained code.  They will be replaced by imported `DefinedFunction`
entries; the `AffineUnit` infrastructure is left for a separate cleanup.

## Goals / Non-Goals

**Goals:**
- Introduce `DefinedFunction` with forward/inverse expressions evaluated at
  call time via `ExpressionParser`
- Inject parameter values into `EvalContext` so they shadow real units during
  expression evaluation
- Detect recursive `DefinedFunction` calls and throw `EvalException`
- Extend the importer to parse `nonlinear_definition` lines and emit
  `defined_function` entries in units.json
- Extend the codegen to emit `registerDefinedFunctions()` in
  `predefined_units.dart`
- Replace `tempC` / `tempF` / `tempreaumur` `AffineUnit` registrations with
  imported `DefinedFunction` equivalents
- Eliminate all 147 unsupported entries from units.json

**Non-Goals:**
- Removing `AffineUnit`, `AffineUnitNode`, `isAffine`, or `_emitAffine`
  (separate cleanup change)
- Caching parsed ASTs for defined-function expressions (re-parse on every call
  is acceptable for this use case)
- User-defined functions (runtime definition, not database-driven)

## Decisions

### `DefinedFunction` stores expressions as strings; re-parses on every call
**Decision**: `DefinedFunction` holds `forward: String` and `inverse: String?`.
`evaluate()` calls `ExpressionParser(repo: context!.repo, variables: vars,
visited: newVisited).evaluate(forward)` on every invocation.  No AST is cached.

**Rationale**: Caching parsed ASTs requires the `UnitRepository` to be present
at construction time (to recognise identifiers) and adds lifecycle complexity.
Defined-function calls happen infrequently (unit conversions, not tight loops),
so re-parsing has no perceptible cost.

**Alternative**: Lazy-parse to AST on first call, cache.  Rejected — adds
concurrency subtlety and invalidation logic for no measurable gain.

---

### Parameter values injected via `EvalContext.variables`
**Decision**: Add `Map<String, Quantity>? variables` to `EvalContext`.
`UnitNode.evaluate()` checks `variables` before the repo lookup.  Param names
silently shadow any real unit with the same name.

**Rationale**: Parameters are scoped to the function call; they must not mutate
the shared `UnitRepository`.  A per-call variables map threaded through
`EvalContext` is the minimal change and fits the existing context-passing model.

**Alternative**: Temporarily register synthetic `PrimitiveUnit` instances in the
repo.  Rejected — mutates global state, is not thread-safe, and is semantically
incorrect.

---

### `ExpressionParser` gains a `variables` parameter
**Decision**: `ExpressionParser({required UnitRepository repo,
Map<String, Quantity>? variables, Set<String>? visited})`.  The variables map
is forwarded into every `EvalContext` constructed by the parser.

**Rationale**: `DefinedFunction.evaluate()` needs to pass the param→value
bindings into the evaluation; `ExpressionParser` is the only entry point for
string evaluation, so this is the natural injection site.

---

### Nullable `EvalContext?` added to `UnitaryFunction.call()` / `callInverse()`
**Decision**: `call(List<Quantity> args, [EvalContext? context])` and
`callInverse(List<Quantity> args, [EvalContext? context])`.  `DefinedFunction`
throws `EvalException` at runtime if `context` is null.  `BuiltinFunction` and
`PiecewiseFunction` ignore the parameter.  `FunctionNode.evaluate()` always
passes its own `EvalContext`.

**Rationale**: `DefinedFunction` needs the repo and visited set to evaluate its
expressions.  Making `call()` accept context is the minimal API change; making
it nullable avoids breaking test sites that call `fn.call(args)` directly on
`BuiltinFunction` / `PiecewiseFunction` without a context.

**Alternative**: Store the repo in `DefinedFunction` at construction time.
Rejected — the context also carries `visited` (needed for recursion detection),
which is dynamic per-call state not suitable for storage.

---

### Recursion detection via `"<id>()"` key in `visited` set
**Decision**: `DefinedFunction.evaluate()` adds `"<id>()"` to a copy of
`context.visited` before constructing the inner `ExpressionParser`.  The
extended set is passed as `visited` to that parser, propagating to any nested
`DefinedFunction` calls via `FunctionNode → call(args, context)`.  A re-entry
for the same id throws `EvalException('Circular function definition detected
for "<id>"')`.

**Rationale**: The existing unit-resolution `visited` set uses the same
mechanism; reusing it for functions keeps the circular-detection logic in one
place.  Unit names cannot contain parentheses, so `"<id>()"` is unambiguous
and needs no prefix.

---

### Domain/range `QuantitySpec` resolved at registration time
**Decision**: `registerDefinedFunctions(repo)` (emitted by the codegen) calls
`ExpressionParser(repo: repo).evaluate(unitString)` for each domain and range
unit expression string, then passes the resolved `Quantity` values to the
`DefinedFunction` constructor as `QuantitySpec.quantity`.  Same pattern as
`registerPiecewiseFunctions`.

**Rationale**: Domain/range validation must run on every call; re-resolving unit
strings every call would be wasteful.  Resolving once at startup is consistent
with how piecewise functions handle `outputUnit`.

---

### Function aliases handled at importer / codegen level
**Decision**: A zero-argument definition `name() target` is recognised by the
importer as an alias `GnuEntry`.  The codegen adds the alias name to the target
function's `aliases` list.  No runtime alias lookup is needed.

**Rationale**: Consistent with how unit aliases are handled throughout the
pipeline.  Avoids lazy-resolution complexity.

---

### Variable scoping: each `DefinedFunction` call gets a fresh scope
**Decision**: `DefinedFunction.evaluate()` builds a new
`Map<String, Quantity> vars` containing only its own params.  This map becomes
the `variables` of the inner `ExpressionParser`.  Variables from an outer
function's context are not visible inside a callee.

**Rationale**: Proper lexical scoping — a callee's param names should not be
affected by the caller's param bindings.  The outer context's `repo` and
`visited` are still forwarded; only the `variables` map is replaced.

---

### Multi-argument domain interval parsing: greedy bracket-pair consumption
**Decision**: The importer parses domain/range interval lists by greedily
consuming characters from an opening `[` or `(` to its matching `]` or `)`,
then skipping any intervening commas or whitespace.  This handles both
`[a,b],[c,)` and `(a,b)(c,d)` (no separator) without ambiguity.

---

### JSON schema for `defined_function` entries
**Decision**: Key is the function name only (e.g., `"circlearea"`).  Fields:
`type: "defined_function"`, `params: [...]`, `forward: "..."`,
`inverse: "..."` (optional), `domainUnits: [...]` (unit expression strings,
one per param), `domainBounds: [...]` (interval strings, one per param),
`rangeUnit: "..."` (optional), `rangeBounds: "..."` (optional), `noerror: bool`.

---

### Registration order in `withPredefinedUnits()`
**Decision**: `registerBuiltinFunctions` → `registerPredefinedUnits` →
`registerPiecewiseFunctions` → `registerDefinedFunctions`.

**Rationale**: Defined functions may reference piecewise functions in their
expressions (e.g., to compose conversions), so piecewise functions must be
present first.

## Risks / Trade-offs

- **Re-parsing on every call**: Minor overhead per defined-function evaluation.
  Acceptable for the use case (unit conversions happen once per user input, not
  in tight loops).  → No mitigation needed; revisit if profiling reveals a
  problem.

- **Param names shadow real units**: A param named `r` silently shadows the
  `roentgen` unit inside the function body.  GNU Units behaves the same way;
  no detection is provided.  → Documented behaviour; no mitigation.

- **Nullable `context` in `call()`**: Test sites that call `fn.call(args)`
  directly on `BuiltinFunction` / `PiecewiseFunction` without context will
  continue to work (null is acceptable for those subclasses).  `DefinedFunction`
  tests must always pass a context.  → Clear runtime error with message if
  context is accidentally omitted for a `DefinedFunction`.

- **`AffineUnit` coexists with `DefinedFunction` tempC**: During the
  transition, `AffineUnit` infrastructure remains but no `AffineUnit` instances
  are registered in the production repo (tempC/tempF become `DefinedFunction`).
  Existing tests that manually register `AffineUnit` continue to pass.  → No
  conflict; dead code cleaned up in a follow-on change.

- **`_knownEvalFailures` audit**: An unknown number of units previously blocked
  by missing tempF/tempC or other defined functions will start evaluating
  successfully.  Failing to remove them from `_knownEvalFailures` would cause
  test failures.  → Audit as part of implementation; remove entries that now
  pass.

## Migration Plan

1. Implement `DefinedFunction` and `EvalContext.variables` (no database changes)
2. Extend `ExpressionParser` with `variables` parameter
3. Update `UnitaryFunction.call()` / `callInverse()` signature; update
   `FunctionNode.evaluate()` to pass context
4. Extend importer to parse `nonlinear_definition`; regenerate units.json
5. Extend codegen to emit `registerDefinedFunctions`; regenerate
   `predefined_units.dart`
6. Audit `_knownEvalFailures`; remove entries that now pass
7. Run full test suite; confirm no regressions
