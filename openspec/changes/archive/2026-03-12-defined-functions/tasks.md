## 1. EvalContext and ExpressionParser

- [x] 1.1 Add `Map<String, Quantity>? variables` field to `EvalContext` in `ast.dart` (default `null`); update the constructor
- [x] 1.2 In `UnitNode.evaluate()`, check `context.variables` before the repo lookup: if `variables` is non-null and contains the name, return the bound `Quantity` directly
- [x] 1.3 Add `Map<String, Quantity>? variables` parameter to `ExpressionParser` constructor; thread it into every `EvalContext` created during `evaluate()`
- [x] 1.4 Add tests for `EvalContext.variables` shadowing: variable shadows real unit; variable not present falls through to repo; null variables is transparent
- [x] 1.5 Add tests for `ExpressionParser` with `variables`: expression using a bound name resolves to the bound `Quantity`

## 2. UnitaryFunction call() signature

- [x] 2.1 Add optional `EvalContext? context` parameter to `UnitaryFunction.call()` and `callInverse()` in `function.dart`; `BuiltinFunction` and `PiecewiseFunction` implementations accept and ignore it
- [x] 2.2 Update `FunctionNode.evaluate()` in `ast.dart` to pass its own `EvalContext` as the `context` argument to `fn.call()` and `fn.callInverse()`
- [x] 2.3 Verify all existing `function_test.dart` tests still pass (call sites that omit context should work unchanged)

## 3. DefinedFunction class

- [x] 3.1 Add `DefinedFunction` class to `function.dart` with fields `params`, `forward`, `inverse`, `noerror`; `arity` equals `params.length`; `hasInverse` is `inverse != null`; constructor throws `ArgumentError` if `params.length > 1` and `inverse != null`
- [x] 3.2 Implement `DefinedFunction.evaluate()`: require non-null context (throw `EvalException` if null), build param→arg variables map, add `"<id>()"` to a copy of `context.visited`, construct `ExpressionParser(repo: context.repo, variables: vars, visited: extendedVisited)` and evaluate `forward`
- [x] 3.3 Implement `DefinedFunction.evaluateInverse()`: same null-context check, build `{id: arg}` variables map, add `"<id>()"` to visited, evaluate `inverse`
- [x] 3.4 Add tests for `DefinedFunction` class properties: arity, hasInverse, multi-param inverse rejected
- [x] 3.5 Add tests for forward evaluation: single-param, multi-param, param shadows real unit, null context throws
- [x] 3.6 Add tests for inverse evaluation: result matches expected, null context throws
- [x] 3.7 Add tests for recursion detection: direct self-recursion throws `EvalException`; mutual recursion throws; non-recursive chain succeeds

## 4. Importer changes

- [x] 4.1 Update `_classifyLine` in `import_gnu_units_lib.dart` to detect nonlinear definitions (name contains `(` but not `[`) and route them to a new `_parseNonlinearDefinition` helper instead of emitting `unsupported`
- [x] 4.2 Implement `_parseNonlinearDefinition`: extract `id` and `params` from the `name(p1,p2,...)` signature; detect zero-arg alias form and emit `function_alias` entry with `target`
- [x] 4.3 Implement optional-field extraction via regex: scan for `units=[...]`, `domain=<tokens>`, `range=<token>`, and `noerror` in the remaining text (all space-delimited, in order); extract each if present
- [x] 4.4 Implement domain interval list parsing: consume bracket-pairs greedily (from `[`/`(` to matching `]`/`)`, skip any comma/whitespace between pairs) to produce one interval string per param
- [x] 4.5 Parse `units=[u1,u2,...;rangeUnit]`: split content on `;` to separate domain unit expressions (comma-split) from range unit; handle absent `units=` as empty domain units and null range unit
- [x] 4.6 Split forward/inverse: after all optional tokens are consumed, the remainder is the expression body; split on `;` to separate `forward` from `inverse` (trim both; `inverse` is null if no `;`)
- [x] 4.7 Update `entriesToJson()` to serialize `defined_function` entries under `"units"` with all required fields (`params`, `forward`, `inverse`, `domainUnits`, `domainBounds`, `rangeUnit`, `rangeBounds`, `noerror`); omit optional fields when null
- [x] 4.8 Add importer tests for single-param function, multi-param function with domain bounds, no-separator bracket pairs, absent `units=`, zero-arg alias, `noerror` flag, `inverse`-absent case
- [x] 4.9 Update existing importer test that asserted nonlinear definitions produce `"unsupported"` entries; replace with `"defined_function"` expectation

## 5. Codegen changes

- [x] 5.1 Add `_emitDefinedFunction` emitter in `generate_predefined_units_lib.dart`: emit a block that resolves each `domainUnits` string and the `rangeUnit` string via `ExpressionParser(repo: repo).evaluate(...)` at registration time, constructs a `DefinedFunction(...)`, and calls `repo.registerFunction(...)`
- [x] 5.2 Wire `defined_function` type into the codegen switch (alongside `primitive`, `derived`, etc.) so `_emitDefinedFunction` is called for each such entry
- [x] 5.3 Handle `function_alias` entries: fold them into the target function's `aliases` list (same mechanism as unit alias folding, but in the function namespace)
- [x] 5.4 Emit a `registerDefinedFunctions(UnitRepository repo)` top-level function containing all `defined_function` registrations
- [x] 5.5 Add `registerDefinedFunctions(repo)` call to `UnitRepository.withPredefinedUnits()` after `registerPiecewiseFunctions(repo)`
- [x] 5.6 Add codegen tests for `defined_function` emission: correct `DefinedFunction(...)` constructor call; domain/range units resolved via `ExpressionParser`; `registerDefinedFunctions` top-level function emitted
- [x] 5.7 Add codegen test for `function_alias` folding: alias id appears in target function's `aliases` list

## 6. Database regeneration

- [x] 6.1 Run `dart tool/import_gnu_units.dart` to regenerate `units-parsed.json` and `units.json`; verify that all 147 formerly-unsupported entries now have `type: "defined_function"` or `type: "function_alias"`
- [x] 6.2 Run `dart tool/generate_predefined_units.dart` to regenerate `predefined_units.dart`; verify it compiles and contains `registerDefinedFunctions`
- [x] 6.3 Confirm `units.json` has zero entries with `reason: "nonlinear_definition"` in the `"unsupported"` section

## 7. Integration and test audit

- [x] 7.1 Audit `_knownEvalFailures` in `predefined_units_test.dart`: run the evaluation regression test against the regenerated `predefined_units.dart`; remove every entry that now evaluates successfully
- [x] 7.2 Run `flutter test --reporter failures-only` and fix any regressions
- [x] 7.3 Run `flutter analyze` and fix any linting errors
