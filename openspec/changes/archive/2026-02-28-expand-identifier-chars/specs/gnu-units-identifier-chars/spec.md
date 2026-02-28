## ADDED Requirements

### Requirement: Identifier start character set
A lexer identifier token SHALL start with any character that is not whitespace (as matched by `\s` in a Dart `RegExp`), not an ASCII digit (`0`–`9`), not a period (`.`), and not an identifier-excluded character (see the excluded-characters requirement). This includes ASCII letters, underscore, Unicode characters, and non-excluded punctuation such as `%`, `°`, and `'`.

#### Scenario: ASCII letter starts an identifier
- **WHEN** the input `m` is lexed
- **THEN** a single identifier token with lexeme `m` is produced

#### Scenario: Underscore starts an identifier
- **WHEN** the input `_foo` is lexed
- **THEN** an identifier token with lexeme `_foo` is produced

#### Scenario: Percent sign starts an identifier
- **WHEN** the input `%` is lexed
- **THEN** an identifier token with lexeme `%` is produced

#### Scenario: Degree symbol starts an identifier
- **WHEN** the input `°C` is lexed
- **THEN** an identifier token with lexeme `°C` is produced

#### Scenario: Unicode letter starts an identifier
- **WHEN** the input `Ω` is lexed
- **THEN** an identifier token with lexeme `Ω` is produced

#### Scenario: Digit does not start an identifier
- **WHEN** the input `2` is lexed
- **THEN** a number token (not an identifier token) is produced

#### Scenario: Period does not start an identifier
- **WHEN** the input `.5` is lexed
- **THEN** a number token `.5` is produced (period begins a decimal number, not an identifier)

---

### Requirement: Identifier body character set
After the start character, a lexer identifier token SHALL consume any sequence of characters that are not whitespace (as matched by `\s` in a Dart `RegExp`) and not identifier-excluded characters (see the excluded-characters requirement). This includes digits, periods, underscores, Unicode characters, and non-excluded punctuation.

#### Scenario: Digit allowed in identifier body
- **WHEN** the input `log2` is lexed
- **THEN** an identifier token with lexeme `log2` is produced

#### Scenario: Percent sign allowed in identifier body
- **WHEN** the input `foo%` is lexed
- **THEN** an identifier token with lexeme `foo%` is produced

#### Scenario: Period allowed in identifier body when not at end
- **WHEN** the input `m.per.s` is lexed
- **THEN** an identifier token with lexeme `m.per.s` is produced

#### Scenario: Unicode character allowed in identifier body
- **WHEN** the input `kΩ` is lexed
- **THEN** an identifier token with lexeme `kΩ` is produced

---

### Requirement: Identifier-excluded characters terminate identifier scanning
The following characters SHALL not appear in an identifier and SHALL terminate identifier scanning when encountered. A character in this set that immediately follows an identifier SHALL not be included in the identifier token.

Operator characters (also recognised as tokens by the lexer):
`+`, `-` (and Unicode dash variants `‒` U+2012, `–` U+2013, `−` U+2212), `*`, `·` U+00B7, `×` U+00D7, `⋅` U+22C5, `⨉` U+2A09, `/`, `÷` U+00F7, `|`, `⁄` U+2044, `^`, `(`, `)`, `,`

Additional excluded characters (not operator tokens, but not valid in unit names):
`[`, `]`, `{`, `}`, `<`, `=`, `>`, `~`, `;`

#### Scenario: Plus sign terminates identifier
- **WHEN** the input `meter+second` is lexed
- **THEN** three tokens are produced: identifier `meter`, plus, identifier `second`

#### Scenario: Slash terminates identifier
- **WHEN** the input `km/hr` is lexed
- **THEN** three tokens are produced: identifier `km`, divide, identifier `hr`

#### Scenario: Left parenthesis terminates identifier
- **WHEN** the input `sin(` is lexed
- **THEN** two tokens are produced: identifier `sin`, left-paren

#### Scenario: Square bracket terminates identifier
- **WHEN** the input `foo[` is lexed
- **THEN** the identifier token `foo` is produced (and `[` is processed separately)

#### Scenario: Equals sign terminates identifier
- **WHEN** the input `a=b` is lexed
- **THEN** the identifier token `a` is produced (and `=` is processed separately)

---

### Requirement: Trailing period is a lex error
An identifier whose body ends with a period (`.`) — that is, where the character immediately following the identifier is not an identifier body character (or is end of input) and the last consumed character is `.` — SHALL cause a `LexException` to be thrown. There is no valid syntactic context in which such a token could appear.

#### Scenario: Identifier ending with period throws
- **WHEN** the input `meter.` is lexed (period not followed by a digit or identifier body character)
- **THEN** a `LexException` is thrown

#### Scenario: Period in the middle of an identifier is not an error
- **WHEN** the input `m.per.s` is lexed
- **THEN** an identifier token with lexeme `m.per.s` is produced (no error)

---

### Requirement: Trailing underscore is a lex error
An identifier whose body ends with an underscore (`_`) — that is, where the character immediately following the identifier is not an identifier body character (or is end of input) and the last consumed character is `_` — SHALL cause a `LexException` to be thrown. There is no valid syntactic context in which such a token could appear.

#### Scenario: Identifier ending with underscore throws
- **WHEN** the input `foo_` is lexed
- **THEN** a `LexException` is thrown

#### Scenario: Identifier ending with multiple underscores throws
- **WHEN** the input `foo__` is lexed
- **THEN** a `LexException` is thrown

#### Scenario: Underscore in the middle of an identifier is not an error
- **WHEN** the input `foo_bar` is lexed
- **THEN** an identifier token with lexeme `foo_bar` is produced (no error)

#### Scenario: Underscore at the start of an identifier is not an error
- **WHEN** the input `_foo` is lexed
- **THEN** an identifier token with lexeme `_foo` is produced (no error)

#### Scenario: Underscore-preceded digits are not affected
- **WHEN** the input `u_235` is lexed
- **THEN** an identifier token with lexeme `u_235` is produced (digit suffix after underscore; last char is `5`, not `_`)
