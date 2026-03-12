## Why

The unit database contains 147 nonlinear unit definitions (GNU Units
"nonlinear units") that cannot be expressed as simple linear or affine
conversions — e.g., `circlearea`, `pH`, `windchill`, `tempC`.  These are all
currently marked "unsupported" in units.json, leaving them unavailable for
evaluation.  Adding support for defined functions eliminates every unsupported
entry and completes the unit database.

## What Changes

- Add `DefinedFunction` concrete subclass of `UnitaryFunction` with
  `params: List<String>`, `forward: String`, and `inverse: String?` fields;
  the forward/inverse expressions are re-parsed and evaluated on each call via
  `ExpressionParser`
- Add `Map<String, Quantity>? variables` field to `EvalContext`; `UnitNode.evaluate()`
  checks `variables` before the repo so parameter names shadow real units
- Add `variables: Map<String, Quantity>?` parameter to `ExpressionParser`,
  threaded into `EvalContext`
- **BREAKING**: Add nullable `EvalContext? context` parameter to
  `UnitaryFunction.call()` and `callInverse()`; `DefinedFunction` throws at
  runtime if `context` is null; other subclasses ignore it;
  `FunctionNode.evaluate()` passes its own `EvalContext`
- Extend `EvalContext.visited` to track in-progress function evaluations
  (prefix `"fn:<id>"`) so recursive defined-function calls throw `EvalException`
  instead of stack-overflowing
- Extend the importer (`import_gnu_units_lib.dart`) to recognise
  `nonlinear_definition` lines and emit `defined_function` entries in units.json;
  eliminates all 147 unsupported entries; zero-arg alias form
  (`name() target`) emitted as an alias `GnuEntry`
- Extend the codegen (`generate_predefined_units_lib.dart`) to emit
  `registerDefinedFunctions(repo)` in `predefined_units.dart`, called last in
  `withPredefinedUnits()`; domain/range unit strings are resolved inline via
  `ExpressionParser` at registration time (same pattern as piecewise functions)
- Import `tempC`, `tempF`, `tempreaumur` as `defined_function` entries,
  replacing their current hard-coded `AffineUnit` registrations; `AffineUnit`
  infrastructure (class, `AffineUnitNode`, codegen support) is left in place
  for a separate cleanup change
- Audit `_knownEvalFailures` in `predefined_units_test.dart`; entries that
  become resolvable once defined functions are registered must be removed

## Capabilities

### New Capabilities

- `defined-function`: `DefinedFunction` class; parameter value injection via
  `EvalContext.variables`; variables threading through `ExpressionParser`;
  recursion detection via extended `visited` set; `DefinedFunction` construction
  and evaluation contract
- `defined-function-registry`: importer parsing of `nonlinear_definition` lines
  (regex field extraction, bracket-pair interval parsing, zero-arg alias form);
  `defined_function` JSON schema; codegen emission of `registerDefinedFunctions`

### Modified Capabilities

- `function-class`: `UnitaryFunction.call()` / `callInverse()` gain a nullable
  `EvalContext?` parameter; `EvalContext` gains a `variables` field;
  `ExpressionParser` gains a `variables` parameter
- `function-registry`: `registerDefinedFunctions` added to
  `withPredefinedUnits()` registration sequence (after piecewise functions)
- `gnu-units-import-pipeline`: importer recognises and parses
  `nonlinear_definition`; units.json gains the `defined_function` entry type

## Impact

- `lib/core/domain/models/function.dart` — `UnitaryFunction`, new `DefinedFunction`
- `lib/core/domain/parser/ast.dart` — `EvalContext` (add `variables`),
  `UnitNode.evaluate()` (variables-first lookup)
- `lib/core/domain/parser/parser.dart` — `ExpressionParser` (add `variables`)
- `lib/core/domain/data/builtin_functions.dart` — `call()` / `callInverse()`
  signature update (no-op extra param)
- `lib/core/domain/data/predefined_units.dart` — regenerated; new
  `registerDefinedFunctions()`
- `tool/import_gnu_units_lib.dart` — `_classifyLine` for `nonlinear_definition`
- `tool/generate_predefined_units_lib.dart` — new `_emitDefinedFunction` emitter
- `test/core/domain/models/function_test.dart` — `DefinedFunction` tests
- `test/core/domain/data/predefined_units_test.dart` — `_knownEvalFailures` audit
- `test/tool/import_gnu_units_lib_test.dart` — `nonlinear_definition` parsing tests
- `test/tool/generate_predefined_units_lib_test.dart` — codegen tests
