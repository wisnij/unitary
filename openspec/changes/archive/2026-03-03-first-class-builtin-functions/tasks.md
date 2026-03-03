## 1. Core data classes

- [x] 1.1 Write tests for `Bound` (value, closed flag) and `QuantitySpec` (all fields nullable, default null)
- [x] 1.2 Create `lib/core/domain/models/function.dart` with `Bound` and `QuantitySpec` classes

## 2. UnitaryFunction abstract class

- [x] 2.1 Write tests for `UnitaryFunction` validation via a concrete test double: arg count mismatch, wrong argument dimension, dimensionless-primitive conformance (pure number accepted for radian spec), closed/open min/max bound enforcement, return value dimension and bound constraints, `callInverse` throwing when `hasInverse == false`
- [x] 2.2 Implement `UnitaryFunction` abstract class in `function.dart`: fields (`id`, `aliases`, `arity`, `domain`, `range`), `allNames` getter, abstract `evaluate`/`evaluateInverse`, `call()` with full validation, `callInverse()` default that throws `EvalException`

## 3. BuiltinFunction subclass

- [x] 3.1 Write tests for `BuiltinFunction` class structure: `hasInverse == false`, arity is 1 for all builtins, domain and range `QuantitySpec` instances match the spec table
- [x] 3.2 Implement `BuiltinFunction` concrete subclass in `function.dart`

## 4. Builtin function instances

- [x] 4.1 Write evaluation tests for all 9 builtins: `sin(0)`, `sin(π/2 rad)`, `cos(0)`, `cos(π rad)`, `tan(0)`, `asin(1.0)` → π/2 rad, `acos(1.0)` → 0 rad, `atan(1.0)` → π/4 rad, `ln(e)` → 1, `log(100)` → 2 (base 10), `exp(1)` → e; plus domain violations: `asin(1.5)`, `acos(-2.0)`, `ln(0)`, `ln(-1)`, `log(0)`, `log(-1)`
- [x] 4.2 Create `lib/core/domain/data/builtin_functions.dart` with all 9 `BuiltinFunction` instances
- [x] 4.3 Implement `registerBuiltinFunctions(UnitRepository repo)` in `builtin_functions.dart`
- [x] 4.4 Write tests for `registerBuiltinFunctions()`: all 9 names (`sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `ln`, `log`, `exp`) findable via `findFunction` after registration

## 5. UnitRepository extension

- [x] 5.1 Write tests for `registerFunction` and `findFunction`: find by id, find by alias, null for unknown name, exact lookup only (plural form not matched, prefixed form not matched)
- [x] 5.2 Write tests for `registerFunction` collision detection: duplicate function name, function name colliding with unit, function name colliding with prefix
- [x] 5.3 Write tests for `register()` (unit) rejecting names that collide with a registered function (by id and by alias)
- [x] 5.4 Write tests for `withPredefinedUnits()` making all 9 builtins findable via `findFunction`
- [x] 5.5 Implement `_functions`/`_functionLookup` maps and `registerFunction()`/`findFunction()` in `unit_repository.dart`
- [x] 5.6 Update `register()` in `unit_repository.dart` to check `_functionLookup` for name collisions before registering
- [x] 5.7 Update `UnitRepository.withPredefinedUnits()` to call `registerBuiltinFunctions(this)`

## 6. Parser and AST changes

- [x] 6.1 Write tests for parser recognizing function calls via repository: registered function name followed by `(` produces `FunctionNode`; unregistered name is not a function call; no-repo parser treats `sin(x)` as unit identifier
- [x] 6.2 Write tests for `FunctionNode.evaluate()`: correct result dispatched through repo, `EvalException` when `context.repo == null`, `EvalException` for unknown function name in repo
- [x] 6.3 Update `_identifierOrFunction()` in `parser.dart`: replace `isBuiltinFunction(name)` check with `_repo?.findFunction(name) != null`
- [x] 6.4 Update `FunctionNode.evaluate()` in `ast.dart`: look up function via `context.repo?.findFunction(name)`, throw `EvalException` if repo is null or name not found, call `func.call(args)`
- [x] 6.5 Remove `_builtinFunctions` const set, `isBuiltinFunction()` function, and `_evaluateBuiltin()` switch from `ast.dart`

## 7. Test migration

- [x] 7.1 Update existing evaluator and parser tests that call builtin functions without a repository to supply a `UnitRepository` with `registerBuiltinFunctions()` (or use `withPredefinedUnits()`)
- [x] 7.2 Update any existing tests that use `log()` to expect base-10 behavior (`log(100)` → `2`)

## 8. Documentation

- [x] 8.1 Update `doc/design_progress.md` to record the completed change
