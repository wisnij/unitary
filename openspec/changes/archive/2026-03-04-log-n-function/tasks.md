## 1. Remove log2 builtin and log10 alias

- [x] 1.1 In `builtin_functions.dart`, remove the `log2Fn` constant and its entry in `registerBuiltinFunctions`
- [x] 1.2 In `builtin_functions.dart`, remove `aliases: ['log10']` from `logFn`
- [x] 1.3 Update the `registerBuiltinFunctions` doc comment to reflect 12 (not 14) registered functions

## 2. Add logB parser desugaring

- [x] 2.1 In `parser.dart`, add a `_isLogN` helper (or inline check) in `_identifierOrFunction` that detects identifiers matching `/^log(\d+)$/` with a suffix integer ≥ 2
- [x] 2.2 Insert the logB check before the function-registry lookup so `log2(x)` is desugared before any fallthrough to unit or exponent logic
- [x] 2.3 Parse the argument list for `logB(x)` using the existing `_arguments()` path; enforce exactly one argument (throw `ParseException` for zero or multiple args)
- [x] 2.4 Synthesise `BinaryOpNode(FunctionNode("ln", [argNode]), TokenType.divide, NumberNode(math.log(B)))` and return it

## 3. Tests — remove obsolete cases

- [x] 3.1 Remove or update any tests that call `log2(x)` via the registered builtin function directly
- [x] 3.2 Remove or update any tests that look up `"log2"` or `"log10"` via `findFunction` and expect a non-null result

## 4. Tests — new logB behaviour

- [x] 4.1 Parser unit test: `log2(8)` produces the expected `BinaryOpNode(FunctionNode("ln", …), divide, NumberNode(ln(2)))` AST shape
- [x] 4.2 Evaluator/integration tests for correct results: `log2(8) == 3`, `log10(1000) == 3`, `log16(256) == 2`, `log256(65536) == 2`
- [x] 4.3 Test that `log(100) == 2` still works (plain log unchanged)
- [x] 4.4 Test that `log(x)` and `log10(x)` produce equal results for a sample value
- [x] 4.5 Test that `log2` without `(` is parsed as a plain identifier (not a function call)
- [x] 4.6 Test that `log2(0)` and `log2(-1)` throw `EvalException` (ln domain violation)
- [x] 4.7 Test that `findFunction("log2")` returns `null` in a `withPredefinedUnits()` repository
- [x] 4.8 Test that `findFunction("log10")` returns `null` in a `withPredefinedUnits()` repository
