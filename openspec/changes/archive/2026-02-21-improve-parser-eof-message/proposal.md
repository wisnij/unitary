## Why

When the parser reaches end-of-input unexpectedly (e.g., empty input or a
trailing operator like `5 +`), the error message shows `TokenType.eof` — a raw
Dart enum value that is meaningless to users. It should say `<end of input>`
instead.

## What Changes

- The "Unexpected token" message in `parser.dart` will use `<end of input>`
  when the offending token is EOF, instead of falling through to the enum's
  `toString()` representation.

## Capabilities

### New Capabilities

- `parser-error-messages`: Human-readable text in parser error messages,
  specifically the "Unexpected token" case for EOF.

### Modified Capabilities

_(none — no existing specs to update)_

## Impact

- `lib/core/domain/parser/parser.dart` — one-line fix to the error-message
  string interpolation
- `test/core/domain/parser/parser_test.dart` — new assertions on error message
  text for EOF scenarios
