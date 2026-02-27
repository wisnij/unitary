## Why

Unit identifiers in expression input often follow scientific notation conventions where a
trailing digit denotes an exponent (e.g. `m2` for m², `ft3` for ft³). Without this
support, users must write `m^2` explicitly, and GNU Units definitions that use this
shorthand fail to resolve.

## What Changes

- A trailing digit (2–9) directly appended to a unit identifier is now treated as an
  exponent shorthand: `m2` parses identically to `m^2`.
- Trailing digits 0 and 1 are treated as part of the identifier name, not exponents,
  allowing unit names like `x0`, `y1`, `x10`, `k1250`.
- Multiple trailing bare digits (not after `_`) that end in 2–9 are a **BREAKING**
  parse error: `u235` and `a123` now raise a `ParseException`.
- Digits preceded directly by `_` anywhere in the identifier (e.g. `u_235`, `m_2`)
  remain part of the identifier name unchanged.
- Six entries are removed from `_knownEvalFailures` in the builtin units regression
  test: `k1250`, `k1400`, `K_apex1961`, `K_apex1971`, `naturalgas_HHV`,
  `naturalgas_LHV` (their definitions use `m2`/`ft3` shorthand which now resolves).

## Capabilities

### New Capabilities

- `unit-trailing-digit-exponent`: Parsing rule that interprets a trailing digit 2–9 on a
  unit identifier as an exponent shorthand, with defined behavior for digits 0–1 (part of
  name) and bare multi-digit sequences ending in 2–9 (parse error).

### Modified Capabilities

*(none — no existing spec-level requirements change)*

## Impact

- `lib/core/domain/parser/parser.dart` — `_identifierOrFunction()` gains the digit-suffix
  check.
- `test/core/domain/parser/parser_test.dart` — new test group.
- `test/core/domain/parser/evaluator_test.dart` — new integration tests.
- `test/core/domain/data/builtin_units_test.dart` — remove six `_knownEvalFailures`
  entries.
- No lexer changes. No new dependencies.
