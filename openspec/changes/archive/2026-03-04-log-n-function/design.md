## Context

The evaluator has a `log` builtin (base-10) and a separate `log2` builtin, with
`log10` registered as an alias of `log`.  These cover only two bases.  GNU Units
handles arbitrary-base logarithms with the `logB(x)` shorthand, where B is any
integer ≥ 2; the expression evaluates to `log(x) / log(B)`.

The parser already has a parallel pattern for trailing-digit exponent shorthand
on unit names (`_identifierOrFunction`): it strips trailing digits from the
identifier token and synthesises a `BinaryOpNode` without adding a new AST node
type.  The same strategy applies here.

The lexer tokenises `log2`, `log10`, `log256` as single `identifier` tokens —
the digit run is already attached to the name — so no lexer changes are needed.

## Goals / Non-Goals

**Goals:**

- Recognise `logB(x)` in the parser for any integer B ≥ 2 and desugar it to the
  AST `log(x) / log(B)`.
- Keep `log(x)` (no suffix) as base-10 (unchanged behaviour).
- Remove the `log10` alias and the `log2` builtin, since `log10(x)` and
  `log2(x)` are now handled by the general mechanism.

**Non-Goals:**

- Non-integer bases (e.g. `log1.5`).  These are not supported by GNU Units and
  would require a two-argument function syntax.
- Base 0 or base 1 — degenerate cases with no mathematical meaning.
- Prefix-qualified forms (`kilolog2`).  Prefixes on functions are already
  rejected by the parser.

## Decisions

### D1: Parse in `_identifierOrFunction`, before the function-registry lookup

The identifier token for `log2(x)` arrives as the string `"log2"`.  The
registry lookup for `"log2"` currently finds the explicit `log2` builtin; after
that builtin is removed, it will find nothing, and the parser would fall through
to treating `log2` as a unit name.

The fix: before the registry lookup, inspect the identifier.  If it matches
`/^log(\d+)$/` where the numeric suffix parses as an integer ≥ 2, synthesise
the AST immediately and return — no registry lookup needed.

Ordering matters:

1. **logB check first** (new): if name starts with `"log"` and has an integer
   suffix ≥ 2, and the next token is `(`, synthesise `log(x) / log(B)`.
2. **Registry lookup** (existing): `findFunction(name)` handles plain `log(x)`.
3. **Affine-unit check** (existing).
4. **Trailing-digit-exponent** (existing): strips digits and makes `unit^N`.
5. **Plain unit** (existing fallback).

The logB check must precede the trailing-digit-exponent check, because both
would otherwise match `log2` (the exponent check would try `log^2` which is
wrong).

**Alternative considered: register `log2`, `log4`, … as explicit aliases.**
Rejected — infinitely many valid bases, and any registered alias would shadow
the general mechanism for that base.

**Alternative considered: two-argument `log(x, B)` function.**
Rejected — contradicts GNU Units syntax and breaks backward compatibility with
single-argument `log(x)` = log10.

### D2: Synthesised AST uses natural log change-of-base

`log_B(x) = ln(x) / ln(B)`.  The synthesised AST is:

```
BinaryOpNode(
  FunctionNode("ln", [argNode]),
  TokenType.divide,
  NumberNode(math.log(B)),   // math.log is natural log in Dart
)
```

`math.log(B)` (= `ln(B)`) is computed once at parse time as a constant
`NumberNode`, so evaluation is a single natural-log call plus one division.

This is preferable to `log(x) / log(B)` (base-10 formulation), which would
require two divisions: `math.log(x) / math.ln10` inside the `log` builtin, then
another division by the precomputed `math.log(B) / math.ln10`.  Using `ln`
directly reduces that to one division.

**Alternative considered: `log(x) / (math.log(B) / math.ln10)` constant.**
Also one division at eval time, but needlessly involves base-10 intermediates
and couples the desugaring to the `log` builtin's implementation detail.

### D3: Base validation at parse time

If the suffix does not parse as an integer ≥ 2, throw `ParseException` with a
clear message.  Base 0 and 1 are degenerate; the rule "suffix must be integer
≥ 2" is simple and matches GNU Units.

Pattern match: name starts with `"log"`, remainder is all ASCII digits, and
the integer value is ≥ 2.  A suffix of `"0"` or `"1"` falls through to the
trailing-digit-exponent path (digits ending in 0 or 1 are already treated as
part of the identifier by existing rules — so `log0(x)` and `log1(x)` would
end up as unit lookups, which is acceptable since those are meaningless bases).

### D4: Remove `log2` builtin and `log10` alias

After this change, `log2(x)` is handled by the parser desugaring, so the
`log2Fn` builtin in `builtin_functions.dart` is dead code.  Keeping it would
leave a stale registration, and since registration checks for collisions, it
would not conflict — but it is misleading.  Remove it.

Similarly, the `log10` alias on `logFn` becomes redundant; `log10(x)` is now
desugared to `log(x) / log(10)` = `log(x)`, which is numerically identical to
calling `log` directly.  Remove the alias.

## Risks / Trade-offs

- **`log0`, `log1` become opaque unit lookups** → Acceptable: these are not
  valid mathematical bases, and the existing trailing-digit rules already treat
  trailing-0/1 identifiers as names.  If needed, an explicit error could be
  added later.
- **Very large base literals** (e.g. `log99999999999`) → `int.parse` on a
  64-bit Dart runtime handles up to 2^63−1; any valid logarithm base fits.
  `math.log(B) / math.ln10` may lose precision for astronomically large B, but
  this is an edge case of negligible practical concern.
- **Compile-time constant in AST** → The `NumberNode(math.log(B))` value is
  computed once at parse time.  If the evaluator ever moves to arbitrary
  precision, the constant in the desugared AST will not automatically follow.
  Acceptable for the current `double`-precision implementation.

## Open Questions

None.
