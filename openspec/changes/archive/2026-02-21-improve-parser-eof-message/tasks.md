## 1. Tests

- [x] 1.1 In `parser_test.dart`, add an assertion on the error message for empty-input: verify it contains `<end of input>`
- [x] 1.2 In `parser_test.dart`, add an assertion on the error message for trailing-operator input (`5 +`): verify it contains `<end of input>`
- [x] 1.3 In `parser_test.dart`, add an assertion on the error message for unexpected-non-EOF token (`* 5`): verify it contains `*` (existing behavior, regression guard)

## 2. Implementation

- [x] 2.1 In `parser.dart`, change the error-message interpolation from `token.lexeme.isEmpty ? token.type : token.lexeme` to `token.type == TokenType.eof ? '<end of input>' : token.lexeme`

## 3. Verification

- [x] 3.1 Run `flutter test test/core/domain/parser/parser_test.dart --reporter failures-only` — all tests pass
- [x] 3.2 Run `flutter test --reporter failures-only` — all 868+ tests pass
