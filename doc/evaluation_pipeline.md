Evaluation Pipeline
===================


Overview
--------

~~~~
String → Lexer → Tokens → Parser → AST → Evaluator → Quantity
                                            ↑
                                       UnitRepository
                                    (alias lookup + chain
                                     resolution to primitives)
~~~~

The evaluation pipeline has four stages:

1. **Lexing:** Scan the input string character-by-character into tokens
   (numbers, identifiers, operators, etc.).
2. **Parsing:** Build an AST from the token stream using recursive descent
   with operator precedence.
3. **Evaluation:** Walk the AST bottom-up. Unit nodes resolve to primitive
   base units via the UnitRepository; arithmetic nodes combine values and
   dimensions.
4. **Result:** A single `Quantity` with a numeric value and a `Dimension`
   expressed entirely in primitive units.

The key insight is that unit resolution happens **eagerly at the leaves** — by
the time `BinaryOpNode.evaluate()` does arithmetic, both operands are already
expressed in primitive base units (`m`, `kg`, `s`).  The dimensional arithmetic
(multiply/divide dimension maps) then works without needing to know anything
about the original units.

---


Worked Example: `3e4 kilometers/week`
-------------------------------------

This example demonstrates prefix resolution (kilo), plural stripping
(kilometers → kilometer → kilo + meter), compound unit evaluation (week → days
→ seconds), and dimensional analysis throughout.


### Step 1: Lexing

The `Lexer` scans character-by-character and produces tokens:

~~~~
"3e4"        → Token(number, 30000.0)
" "          → whitespace consumed (not a token)
"kilometers" → Token(identifier, "kilometers")
"/"          → Token(divide)
"week"       → Token(identifier, "week")
             → Token(eof)
~~~~

`3e4` is parsed as scientific notation during number scanning: the `e` is
consumed as part of the number because it is immediately followed by digits.
`kilometers` and `week` are scanned as identifier tokens.


### Step 2: Parsing

The `Parser` builds an AST using recursive descent with 6 precedence levels.
The key decisions:

1. `3e4 kilometers` — a number followed by an identifier with no operator
   between them triggers **implicit multiplication**, which binds tighter than
   explicit `/`.
2. `/ week` is explicit division at a lower precedence level.

Resulting AST:

~~~~
BinaryOpNode(divide,
  BinaryOpNode(multiply,       ← implicit multiplication
    NumberNode(30000.0),
    UnitNode("kilometers")),
  UnitNode("week"))
~~~~

Note: implicit multiplication produces the same `BinaryOpNode` with
`TokenType.times` as an explicit `*` would.  The distinction only exists at
parse time (different precedence level), not in the AST.


### Step 3: Evaluation

The evaluator walks the tree bottom-up, with `EvalContext` carrying the
`UnitRepository`.

#### 3a: `NumberNode(30000.0)`

Returns `Quantity(30000.0, dimensionless)`.

#### 3b: `UnitNode("kilometers")`

This is where prefix-aware unit resolution happens.  The evaluator calls
`repo.findUnitWithPrefix("kilometers")`, which tries several strategies in
order:

1. **Exact match:** `findUnit("kilometers")` — checks the unit lookup map for
   an exact match on `"kilometers"`.  Not found.  Tries plural stripping:
   removes trailing `"s"` → `findUnit("kilometer")`.  Not found either (no
   unit is registered with id or alias `"kilometer"`).

2. **Prefix splitting** (longest prefix first): iterates over possible prefix
   lengths from longest to shortest.  Eventually tries prefix `"kilo"` with
   remainder `"meters"`:
   - Looks up `"kilo"` in the prefix map → finds the `PrefixUnit(id: 'kilo',
     expression: '1000')`.
   - Calls `findUnit("meters")` for the remainder → exact match fails, but
     plural stripping removes trailing `"s"` → `findUnit("meter")` finds the
     alias for primitive unit `m`.
   - Returns `UnitMatch(prefix: kilo, unit: m)`.

3. The evaluator resolves both parts via `resolveUnit`:
   - `resolveUnit(kilo)` — kilo is a `CompoundUnit` with expression `"1000"`,
     so the expression is evaluated through the parser: `Quantity(1000.0,
     dimensionless)`.
   - `resolveUnit(m)` — m is a `PrimitiveUnit`, so: `Quantity(1.0, {m: 1})`.
   - Multiply: `1000.0 × 1.0 = 1000.0` with dimension `{m: 1}`.

Result: **`Quantity(1000.0, {m: 1})`**

#### 3c: Implicit multiplication

~~~~
Quantity(30000.0, dimensionless) × Quantity(1000.0, {m: 1})
  → values multiply: 30000.0 × 1000.0 = 30000000.0
  → dimensions combine: {} × {m: 1} = {m: 1}
~~~~

Result: **`Quantity(30000000.0, {m: 1})`**

#### 3d: `UnitNode("week")`

1. `repo.findUnitWithPrefix("week")` — `findUnit("week")` finds an exact
   match on the unit id `week`.
2. `week` is a `CompoundUnit` with expression `"7 day"`.
3. `resolveUnit` evaluates the expression through the parser, which recurses
   through the definition chain:

   ~~~~
   week: "7 day"
     → 7 × day: "24 hour"
       → 7 × 24 × hour: "60 min"
         → 7 × 24 × 60 × min: "60 s"
           → 7 × 24 × 60 × 60 × s (primitive)
             → 604800.0, {s: 1}
   ~~~~

Result: **`Quantity(604800.0, {s: 1})`**

#### 3e: Division

~~~~
Quantity(30000000.0, {m: 1}) / Quantity(604800.0, {s: 1})
  → values divide: 30000000.0 / 604800.0 ≈ 49.603
  → dimensions: {m: 1} / {s: 1} = {m: 1, s: -1}
~~~~

**Final result: `Quantity(49.603..., {m: 1, s: -1})`** — about 49.6 meters
per second (~111 mph).
