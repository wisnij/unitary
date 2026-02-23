## Context

`parser.dart` builds a "Unexpected token" error message using:

```dart
'Unexpected token: ${token.lexeme.isEmpty ? token.type : token.lexeme}'
```

The EOF token has an empty lexeme, so the condition falls through to
`token.type`, which calls `TokenType.eof.toString()` → `"TokenType.eof"`.
This is a raw Dart enum string — an implementation detail invisible and
meaningless to users.

## Goals / Non-Goals

**Goals:**

- Replace `TokenType.eof` in the error message with the user-visible string
  `<end of input>`.
- Cover the fix with new test assertions.

**Non-Goals:**

- Improving any other error message.
- Changing error types, line/column reporting, or the exception hierarchy.
- Localising error messages.

## Decisions

**Check `token.type == TokenType.eof` instead of `token.lexeme.isEmpty`.**

The old guard (`lexeme.isEmpty`) was an indirect proxy for EOF; the explicit
type check is clearer and won't break if a future token type also has an empty
lexeme for unrelated reasons.

```dart
// Before
'Unexpected token: ${token.lexeme.isEmpty ? token.type : token.lexeme}'

// After
'Unexpected token: ${token.type == TokenType.eof ? '<end of input>' : token.lexeme}'
```

No alternatives were seriously considered — the fix is a straight substitution.

## Risks / Trade-offs

- **Snapshot tests on exact message text** — Any test that currently asserts
  the string `"TokenType.eof"` will break. A quick grep confirms no such
  assertions exist today; new tests will assert `<end of input>` instead.
