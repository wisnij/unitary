## 1. Lexer Implementation

- [x] 1.1 Add `_identifierExcludedChars` constant set containing all operator characters and Unicode variants from `_scanToken` (`+`, `-`, `‒`, `–`, `−`, `*`, `·`, `×`, `⋅`, `⨉`, `/`, `÷`, `|`, `⁄`, `^`, `(`, `)`, `,`) plus the additional excluded characters (`[`, `]`, `{`, `}`, `<`, `=`, `>`, `~`, `;`)
- [x] 1.2 Replace `_isAlpha` with `_isIdentifierStart`: returns true unless the character matches `\s`, is a digit, is `.`, or is in `_identifierExcludedChars`
- [x] 1.3 Replace `_isAlphaNumeric` with `_isIdentifierBody`: returns true unless the character matches `\s` or is in `_identifierExcludedChars`
- [x] 1.4 Update `_scanToken` default branch to call `_scanIdentifier` when `_isIdentifierStart(c)` is true (replacing the `_isAlpha(c)` check)
- [x] 1.5 Update `_scanIdentifier` body loop to use `_isIdentifierBody` instead of `_isAlphaNumeric`
- [x] 1.6 After the body loop in `_scanIdentifier`, check whether the last character of the scanned lexeme is `.` or `_`; if so, throw a `LexException` identifying the character and its position

## 2. Tests

- [x] 2.1 Add tests for new valid start characters: `%`, `°`, `Ω`, `'` (apostrophe)
- [x] 2.2 Add tests for new valid body characters: period in non-trailing position (`m.per.s`), `%` in body (`foo%`), Unicode in body (`kΩ`)
- [x] 2.3 Add tests that operator characters terminate an identifier (`meter+second`, `km/hr`, `sin(`)
- [x] 2.4 Add tests that additional excluded characters terminate an identifier (`foo[`, `a=b`, `x;y`)
- [x] 2.5 Add tests for trailing-period lex error: `meter.` (end of input), `meter. ` (before whitespace), `meter.+` (before operator)
- [x] 2.6 Add tests for trailing-underscore lex error: `foo_` (end of input), `foo_ ` (before whitespace), `foo__` (multiple underscores), `foo_+` (before operator)
- [x] 2.7 Verify that underscore in middle and at start remain valid: `foo_bar`, `_foo`, `u_235`
- [x] 2.8 Verify that existing tests still pass (no regressions in alphanumeric identifiers, `per` keyword, implicit multiplication, scientific notation edge cases)
