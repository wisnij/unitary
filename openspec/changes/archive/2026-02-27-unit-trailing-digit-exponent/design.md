## Context

The expression parser uses a standard Lexer → Parser → AST → Evaluator pipeline. The
lexer (`lexer.dart`) produces tokens; identifiers like `m2` or `centimeters3` are scanned
as a single `TokenType.identifier` token containing the full alphanumeric string. The
parser (`parser.dart`) builds an AST via recursive descent. Unit identifiers are resolved
in `_identifierOrFunction()`, which checks — in order — for built-in functions, affine
units, and finally falls through to `UnitNode(name)`.

GNU Units source files routinely use `m2` for m², `ft3` for ft³, etc. Several imported
unit definitions currently fail evaluation because our parser treats these as unknown
unit names.

## Goals / Non-Goals

**Goals:**
- Trailing digit 2–9 on an identifier becomes an exponent: `m2` → `m^2`.
- Trailing digit 0 or 1 (and multi-digit runs ending in 0/1) remain part of the
  identifier name: `k1250`, `y21`, `x0` are valid unit IDs.
- Multi-digit bare trailing runs ending in 2–9 are a parse error.
- Digits after `_` are always part of the identifier name (existing behavior).
- Six previously-failing builtin-unit definitions (`k1250`, `k1400`, `K_apex1961`,
  `K_apex1971`, `naturalgas_HHV`, `naturalgas_LHV`) now resolve successfully.

**Non-Goals:**
- No changes to the lexer — tokenization is unchanged.
- No Unicode superscript support (e.g. `m²`).
- No changes to how explicit `^` exponentiation works.
- No changes to prefix handling or plural stripping.

## Decisions

### Decision 1: Parser-only check in `_identifierOrFunction()`

**Chosen:** Inspect the identifier's lexeme inside `_identifierOrFunction()` — after the
function and affine-unit checks — for a trailing digit run, then apply the rules.

**Alternatives considered:**

*A. Lexer modification with synthetic `^` injection* — The lexer would stop identifier
scanning at a bare digit and emit a synthetic `exponent` (`^`) token. Simple for the
parser (no changes), but the lexer emits a token that has no corresponding source
character, violating the expectation that every token corresponds to source text.

*B. Lexer stops + parser adjacency check* — Lexer stops identifier at a bare digit
(no synthetic token); parser checks column adjacency between an `identifier` token and
the following `number` token to distinguish `m2` (exponent) from `m 2` (multiply). This
requires the parser to be whitespace-aware via token positions — fragile and unusual for
a recursive-descent grammar.

*C. Parser lexeme inspection (chosen)* — The lexer is unchanged; `m2` remains a single
`identifier(m2)` token. The parser inspects the lexeme string in `_identifierOrFunction`.
This keeps all logic in one place, requires no token structure changes, and handles the
0/1 carve-out cleanly.

### Decision 2: Digits 0 and 1 are identifier suffixes, not exponents

**Chosen:** Last digit 0 or 1 (regardless of how many trailing digits) → part of the
identifier name, not an exponent.

**Rationale:** Common scientific unit names include year suffixes (`K_apex1961`),
version suffixes (`ipv4classA`, `S10`), and isotope identifiers (`k1250`). Raising a
unit to the power 0 or 1 is trivial/identity, so the loss of exponent shorthand for
those digits is inconsequential. Treating them as name parts avoids breaking existing
unit identifiers in the database.

### Decision 3: Multi-digit bare trailing runs ending in 2–9 are a `ParseException`

**Chosen:** Throw `ParseException` with a helpful message pointing to the start of the
bad digit run.

**Rationale:** The alternative (treating `u235` as `u * 235` via implicit multiply) would
silently produce wrong results and is far more surprising than an error. The error message
guides users to the `_`-prefix convention (`u_235`).

## Risks / Trade-offs

- **Existing identifiers ending in 2–9** — Any unit name in the database that ends with a
  digit 2–9 (not after `_`) will now be parsed as an exponent, potentially changing
  behavior or causing an "unknown unit" error for the base. A regression test
  (`builtin_units_test.dart`) already verifies all registered units resolve; this will
  catch any such regressions automatically.

- **`log2` function** — The identifier `log2` (currently lexed as one token) will now
  parse as `log^2` instead of unknown-unit `log2`. If `log2` is later added as a
  built-in evaluator function, the function-check step runs before the digit-suffix
  check, so `log2(x)` will correctly be parsed as a function call. Standalone `log2`
  (without parens) will parse as `log^2` where `log` is an unknown unit — an evaluation
  error, not a silent wrong result.

- **`m2.5` edge case** — `m2.5` lexes as `identifier(m2)` followed by `.` then `5`
  (which would fail as a leading-dot number without a preceding digit). In practice this
  is `m2 .5` which would be a lex error. The user would write `m^2.5` explicitly.

## Open Questions

*(none)*
