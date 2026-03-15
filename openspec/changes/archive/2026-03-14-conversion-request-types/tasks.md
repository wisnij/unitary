## 1. AST Restructure

- [x] 1.1 Add `sealed abstract class ExpressionNode extends ASTNode` with abstract `evaluate(EvalContext) → Quantity` to `ast.dart`
- [x] 1.2 Change `NumberNode`, `UnitNode`, `BinaryOpNode`, `UnaryOpNode` to extend `ExpressionNode` instead of `ASTNode`
- [x] 1.3 Rename `FunctionNode` → `FunctionCallNode` (class name, constructor, `toString()`, all references in `ast.dart` and `parser.dart`)
- [x] 1.4 Change `FunctionCallNode` to extend `ExpressionNode`
- [x] 1.5 Mark `ASTNode` as `sealed`
- [x] 1.6 Remove `evaluate()` from `ASTNode`; it now lives only on `ExpressionNode`
- [x] 1.7 Add `class FunctionNameNode extends ASTNode` with `final String name` and `final bool inverse` fields and no `evaluate()`
- [x] 1.8 Remove `FunctionDefinitionRequestNode` (superseded by `FunctionNameNode`)
- [x] 1.9 Write tests for `FunctionNameNode` construction and field access
- [x] 1.10 Verify all existing tests pass after AST changes

## 2. parse() → parseExpression() Migration

- [x] 2.1 Add `parseExpression(String input) → ExpressionNode` to `ExpressionParser` alongside the existing `parse()`, implemented identically
- [x] 2.2 Update `ExpressionParser.evaluate()` to call `parseExpression()` internally
- [x] 2.3 Update all call sites of `parse()` in production code to `parseExpression()`
- [x] 2.4 Update all call sites of `parse()` in test code to `parseExpression()`
- [x] 2.5 Remove the old `parse()` method from `ExpressionParser`
- [x] 2.6 Verify no remaining references to `ExpressionParser.parse(` exist in the codebase
- [x] 2.7 Verify all existing tests pass

## 3. parseQuery() Entry Point

- [x] 3.1 Write tests for `parseQuery()`: bare known-function name returns `FunctionNameNode(name, false)`
- [x] 3.2 Write tests for `parseQuery()`: `~funcName` returns `FunctionNameNode(name, true)`
- [x] 3.3 Write tests for `parseQuery()`: non-function identifier returns `UnitNode` (delegates to `parseExpression()`)
- [x] 3.4 Write tests for `parseQuery()`: multi-token input delegates to `parseExpression()`
- [x] 3.5 Write tests for `parseQuery()`: no repository — all inputs delegate to `parseExpression()`
- [x] 3.6 Implement `parseQuery(String input) → ASTNode` on `ExpressionParser`: lex the input; if exactly one identifier token that is a known function, return `FunctionNameNode(name, false)`; if `~` followed by one known-function identifier, return `FunctionNameNode(name, true)`; otherwise call `parseExpression()`

## 4. UnitaryFunction Definition Strings

- [x] 4.1 Write tests for `DefinedFunction.definitionExpression` and `inverseExpression`
- [x] 4.2 Write tests for `BuiltinFunction.definitionExpression` and `inverseExpression` returning `null`
- [x] 4.3 Write tests for `PiecewiseFunction.definitionExpression` and `inverseExpression` returning `null`
- [x] 4.4 Add abstract getters `String? get definitionExpression` and `String? get inverseExpression` to `UnitaryFunction`
- [x] 4.5 Implement getters on `DefinedFunction`: return `forward` and `inverse` respectively
- [x] 4.6 Implement getters on `BuiltinFunction`: return `null` for both
- [x] 4.7 Implement getters on `PiecewiseFunction`: return `null` for both

## 5. Freeform Provider and State

- [x] 5.1 Add `FunctionDefinitionResult(functionName: String, definitionExpression: String?)` to `freeform_state.dart`
- [x] 5.2 Add `InverseExpressionResult(functionName: String, inverseExpression: String?)` to `freeform_state.dart`
- [x] 5.3 Write provider tests: bare function name input → `FunctionDefinitionResult`
- [x] 5.4 Write provider tests: bare inverse function name input → `InverseExpressionResult`
- [x] 5.5 Write provider tests: expression input + function name output → `ConversionSuccess` via `callInverse()`
- [x] 5.6 Write provider tests: expression input + `~funcName` output → `EvaluationError`
- [x] 5.7 Write provider tests: function name output with no inverse → `EvaluationError`
- [x] 5.8 Replace `evaluateSingle()` and `evaluateConversion()` on `FreeformNotifier` with a single `evaluate(String input, String output)` method that calls `parseQuery()` on each field and dispatches on the result types per the design dispatch table
- [x] 5.9 Update `freeform_screen.dart` to call `evaluate(input, output)` instead of the two removed methods

## 6. Result Display

- [x] 6.1 Extend the exhaustive `switch` in `ResultDisplay` to handle `FunctionDefinitionResult`: display function name and `definitionExpression` (or `"<built-in>"` when null)
- [x] 6.2 Extend `ResultDisplay` to handle `InverseExpressionResult`: display function name and `inverseExpression` (or `"no inverse defined"` when null)
- [x] 6.3 Write widget tests for `ResultDisplay` rendering `FunctionDefinitionResult` with a non-null string
- [x] 6.4 Write widget tests for `ResultDisplay` rendering `FunctionDefinitionResult` with null (built-in placeholder)
- [x] 6.5 Write widget tests for `ResultDisplay` rendering `InverseExpressionResult` with a non-null string
- [x] 6.6 Write widget tests for `ResultDisplay` rendering `InverseExpressionResult` with null

## 7. Final Verification

- [x] 7.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 7.2 Run `flutter analyze` and confirm no linting errors
- [x] 7.3 Confirm no references to `FunctionDefinitionRequestNode` remain in the codebase
- [x] 7.4 Confirm no references to `ExpressionParser.parse(` remain in the codebase
- [x] 7.5 Confirm no references to `FunctionNode` (the old name) remain in the codebase
