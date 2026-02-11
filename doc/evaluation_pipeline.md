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


Worked Example: `3e6 yard/week`
-------------------------------

### Step 1: Lexing

The `Lexer` scans character-by-character and produces tokens:

~~~~
"3e6"   → Token(number, 3000000.0)
" "     → whitespace consumed (not a token)
"yard"  → Token(identifier, "yard")
"/"     → Token(divide)
"week"  → Token(identifier, "week")
        → Token(eof)
~~~~

`3e6` is parsed as scientific notation during number scanning.  `yard` and
`week` are scanned as identifier tokens (not recognized as built-in functions,
so they are unit names).


### Step 2: Parsing

The `Parser` builds an AST using recursive descent with 6 precedence levels.
The key decisions:

1. `3e6 yard` — a number followed by an identifier with no operator between
   them triggers **implicit multiplication**, which binds tighter than
   explicit `/`.
2. `/ week` is explicit division at a lower precedence level.

Resulting AST:

~~~~
BinaryOpNode(divide,
  BinaryOpNode(multiply,       ← implicit multiplication
    NumberNode(3000000.0),
    UnitNode("yard")),
  UnitNode("week"))
~~~~

Note: implicit multiplication produces the same `BinaryOpNode` with
`TokenType.multiply` as an explicit `*` would.  The distinction only exists at
parse time (different precedence level), not in the AST.


### Step 3: Evaluation

The evaluator walks the tree bottom-up, with `EvalContext` carrying the
`UnitRepository`.

#### 3a: `NumberNode(3000000.0)`

Returns `Quantity(3000000.0, dimensionless)`.

#### 3b: `UnitNode("yard")`

This is where unit resolution happens:

1. `repo.findUnit("yard")` — exact lookup in the alias map finds unit `yd`.
2. `yd`'s definition is `LinearDefinition(factor: 3.0, baseUnitId: 'ft')`.
3. `definition.toQuantity(1.0, repo)` **recurses** through the definition
   chain, computing both the base value and dimension in a single pass:

   ~~~~
   yd.toQuantity(1.0)
     → ft.toQuantity(1.0 * 3.0 = 3.0)            # ft = 12 inch
       → in.toQuantity(3.0 * 12.0 = 36.0)        # in = 2.54 cm
         → cm.toQuantity(36.0 * 2.54 = 91.44)    # cm = 0.01 m
           → m.toQuantity(91.44 * 0.01 = 0.9144) # m is primitive
             → returns Quantity(0.9144, {m: 1})
   ~~~~

Result: **`Quantity(0.9144, {m: 1})`**

#### 3c: Implicit multiplication

~~~~
Quantity(3000000.0, dimensionless) * Quantity(0.9144, {m: 1})
  → values multiply: 3000000.0 * 0.9144 = 2743200.0
  → dimensions combine: {} * {m: 1} = {m: 1}
~~~~

Result: **`Quantity(2743200.0, {m: 1})`**

#### 3d: `UnitNode("week")`

1. `repo.findUnit("week")` — exact match on id `week`.
2. Definition: `LinearDefinition(factor: 7, baseUnitId: 'day')`.
3. Chain resolution via `toQuantity(1.0, repo)`:

   ~~~~
   week.toQuantity(1.0)
     → day.toQuantity(1.0 * 7 = 7.0)               # day = 24 hour
       → hr.toQuantity(7.0 * 24 = 168.0)           # hr = 60 min
         → min.toQuantity(168.0 * 60 = 10080.0)    # min = 60 s
           → s.toQuantity(10080.0 * 60 = 604800.0) # primitive
             → returns Quantity(604800.0, {s: 1})
   ~~~~

Result: **`Quantity(604800.0, {s: 1})`**

#### 3e: Division

~~~~
Quantity(2743200.0, {m: 1}) / Quantity(604800.0, {s: 1})
  → values divide: 2743200.0 / 604800.0 ≈ 4.5357
  → dimensions: {m: 1} / {s: 1} = {m: 1, s: -1}
~~~~

**Final result: `Quantity(4.5357..., {m: 1, s: -1})`** — about 4.54 meters
per second.
