## Context

The lexer currently uses two helper predicates — `_isAlpha` and `_isAlphaNumeric` — to decide what characters can form an identifier token. Both are defined by explicit inclusion lists (`A-Z`, `a-z`, `_`, `0-9`). This excludes Unicode letters, non-ASCII symbols, and non-operator punctuation such as `%`, `°`, and `'` that are legitimate in GNU Units unit names.

The change must preserve all existing behaviour of the `unit-trailing-digit-exponent` spec (single-digit exponent shorthand, underscore-protected digits, multi-digit errors) because those rules operate on the post-scan lexeme, not on the character-level scan loop.

The only file that needs to change is `lib/core/domain/parser/lexer.dart`.

## Goals / Non-Goals

**Goals:**

- Allow any non-whitespace, non-excluded character as an identifier body character.
- Allow any non-digit, non-period, non-comma, non-excluded character as an identifier start character.
- Reject identifiers whose body ends with `.` or `_` with an immediate `LexException`.
- Preserve every existing identifier behaviour: `per` keyword, trailing-digit exponent shorthand, underscore-protected numeric suffixes.

**Non-Goals:**

- Changes to the parser, evaluator, or unit repository (no unit names need to change at this stage).
- Grapheme-cluster–aware Unicode handling (BMP code-unit iteration is sufficient).
- Changing the set of reserved operator characters.

## Decisions

### Decision: Negation-based predicates replace explicit inclusion lists

**Problem:** The explicit inclusion list `[a-zA-Z_]` / `[a-zA-Z0-9_]` requires enumerating every allowed character, which is impractical for Unicode.

**Decision:** Replace `_isAlpha` with `_isIdentifierStart` and `_isAlphaNumeric` with `_isIdentifierBody`, both defined by exclusion:
- `_isIdentifierStart(c)` — true unless `c` is whitespace, a digit, `.`, or an identifier-excluded character.
- `_isIdentifierBody(c)` — true unless `c` is whitespace or an identifier-excluded character.

Period is excluded from identifier *start* (it dispatches to `_scanNumber`) but is allowed in the identifier *body*; the trailing-character error rule rejects it if it ends the token.

**Alternative considered:** Explicit Unicode range inclusion (letter categories `Lu`, `Ll`, `Lt`, `Lm`, `Lo`, `Nd`, etc. via `RegExp`). Rejected because it would still exclude valid non-letter symbols like `%` and `°`, and adds regex overhead with no benefit.

### Decision: Identifier-excluded characters as a constant set

A single `const Set<String> _identifierExcludedChars` constant lists every character that may not appear in an identifier. `_isIdentifierStart` and `_isIdentifierBody` both delegate to this set.

The set has two groups:

- **Operator characters** — every character handled by the switch in `_scanToken` and its Unicode variants:
  `+`, `-`, `‒`, `–`, `−`, `*`, `·`, `×`, `⋅`, `⨉`, `/`, `÷`, `|`, `⁄`, `^`, `(`, `)`, `,`

- **Additional excluded characters** — not operators but disallowed in unit names:
  `[`, `]`, `{`, `}`, `<`, `=`, `>`, `~`, `;`

Keeping both groups in one set simplifies the predicates and makes it easy to add further exclusions in the future.

### Decision: Trailing period or underscore is an immediate lex error

**Problem:** After scanning the maximal body, the lexeme may end with `.` or `_`, which are disallowed as the final character.

**Decision:** After the body scan loop, check the last character of the scanned lexeme. If it is `.` or `_`, throw a `LexException` immediately with a message identifying the character and its position.

No walk-back or re-scanning is needed. There is no syntactic context in which an identifier ending with `.` or `_` is followed by a character that is not part of the identifier body yet still forms valid syntax — so erroring immediately is both simpler and gives a more actionable message than a secondary error at the re-scanned character.

**Alternative considered:** Strip trailing `.`/`_` and push the characters back into the input stream for re-scanning. Rejected because the re-scanned `.` would produce a confusing "Unexpected character" error unconnected to the identifier, and the re-scanned `_` would silently become a spurious additional identifier token.

## Risks / Trade-offs

**Risk: Legitimate intermediate input ending with `_` or `.` triggers an error.** → During real-time evaluation, a user typing `m.per.` would see a transient error before completing the expression. This is the same behaviour as any other transient lex error (e.g., trailing operator) and is handled gracefully by the UI's debounce. Mitigation: none needed.

**Risk: `_` or `.` alone cannot form a valid identifier.** → `_` is a valid start character but ends with `_`, so it would immediately error. `.` is not a valid start character and would dispatch to number parsing (then error if not followed by a digit). Neither is a real unit name; both produce clear lex errors. Mitigation: none needed.

## Open Questions

None — all design choices above are resolved.
