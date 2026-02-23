## ADDED Requirements

### Requirement: EOF produces human-readable error message

When the parser encounters an unexpected end-of-input, the resulting
`ParseException` message SHALL use the text `<end of input>` to identify the
offending token, not an internal implementation detail such as a Dart enum
name.

#### Scenario: Empty input yields `<end of input>` in message

- **WHEN** the parser is given an empty string `''`
- **THEN** a `ParseException` is thrown whose message contains `<end of input>`

#### Scenario: Trailing operator yields `<end of input>` in message

- **WHEN** the parser is given an expression ending in an operator (e.g. `5 +`)
- **THEN** a `ParseException` is thrown whose message contains `<end of input>`

#### Scenario: Non-EOF unexpected token still shows the lexeme

- **WHEN** the parser encounters an unexpected non-EOF token (e.g. `* 5`)
- **THEN** a `ParseException` is thrown whose message contains the literal
  lexeme of that token (e.g. `*`), not `<end of input>`
