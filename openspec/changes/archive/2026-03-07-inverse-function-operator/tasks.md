## 1. Lexer

- [x] 1.1 Add `inverse` to the `TokenType` enum in `token.dart`
- [x] 1.2 Move `~` in `_identifierExcludedChars` in `lexer.dart` from the non-operator section to the operator section
- [x] 1.3 Add `case '~':` in `_scanToken` to emit a `TokenType.inverse` token
- [x] 1.4 Write lexer tests: `~` alone, `~` before identifier, `~` in a full expression

## 2. Parser

- [x] 2.1 Update the grammar comment in `parser.dart` to reflect `INVERSE? IDENTIFIER LPAR arguments RPAR`
- [x] 2.2 In the function-parsing branch, consume an optional `TokenType.inverse` token before reading the identifier
- [x] 2.3 Pass the `inverse` flag when constructing `FunctionNode`
- [x] 2.4 Write parser tests: normal call (`inverse == false`), inverse call (`inverse == true`), multi-argument inverse, `~` without following call raises `ParseException`

## 3. AST

- [x] 3.1 Add `inverse: bool` field to `FunctionNode` (default `false`)
- [x] 3.2 Update `FunctionNode` constructor to accept `inverse`
- [x] 3.3 In `FunctionNode.evaluate()`, dispatch to `func.callInverse(args)` when `inverse == true`
- [x] 3.4 Update `FunctionNode.toString()` to include the `inverse` flag
- [x] 3.5 Write AST/evaluator tests: inverse dispatch, normal dispatch, non-invertible function throws, end-to-end `~double(10)`
