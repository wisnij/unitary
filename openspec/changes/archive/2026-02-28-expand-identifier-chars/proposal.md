## Why

The lexer currently restricts identifiers to ASCII alphanumerics and underscores (`[a-zA-Z_][a-zA-Z0-9_]*`), but GNU Units allows unit names with a much wider character set — including Unicode characters, `%`, `'`, `"`, and other punctuation not used as operators. Without this expansion, the parser cannot recognize common units like `%` (percent), `Ω` (ohm symbol), `°` (degree symbol), or multi-component names used in the GNU Units database.

## What Changes

- The lexer identifier start characters are expanded from `[a-zA-Z_]` to any character that is not whitespace, not a digit, not a period, and not an identifier-excluded character.
- The lexer identifier body characters are expanded from `[a-zA-Z0-9_]` to any character that is not whitespace and not an identifier-excluded character (digits remain allowed as before).
- The identifier-excluded set covers all existing operator characters plus `[`, `]`, `{`, `}`, `<`, `=`, `>`, `~`, `;`.
- Identifiers may not end with a period (`.`) or an underscore (`_`); a trailing instance of either is an immediate lex error.
- The existing trailing-digit rules (exponent shorthand, underscore-preceded digits, multi-digit errors) are **unchanged**.

## Capabilities

### New Capabilities

- `gnu-units-identifier-chars`: Defines valid start characters, body characters, and prohibited trailing characters for lexer identifier tokens, including Unicode and non-operator punctuation.

### Modified Capabilities

<!-- None -->

## Impact

- `lib/core/domain/parser/lexer.dart` — `_isAlpha`, `_isAlphaNumeric`, and `_scanIdentifier` methods
- `test/core/domain/parser/lexer_test.dart` — new tests for expanded and restricted character cases
- Existing identifier behaviour (alphanumeric names, underscore prefix, trailing-digit exponent rules) is fully preserved
