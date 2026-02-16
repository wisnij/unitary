Phase 1: Core Domain - Expression Parser
========================================

> **Status: COMPLETE** (February 4, 2026)
>
> All components implemented with 372 passing tests. See implementation details below.


Overview
--------

**Goal:** Build the expression parsing and evaluation engine: Lexer, Parser, AST,
and Evaluator.

**Deliverable:** A working pipeline that evaluates arithmetic expressions with
unit identifiers, e.g.:

- `5 * 3 + 2` → `Quantity(17, dimensionless)`
- `2^-3` → `Quantity(0.125, dimensionless)`
- `5 m * 3` → `Quantity(15, {m: 1})`
- `sqrt(9 m^2)` → `Quantity(3, {m: 1})`
- `1|2 m` → `Quantity(0.5, {m: 1})`

**Scope boundaries:**

- No unit repository or unit definitions — all identifiers are treated as
  primitive units.
- No unit conversion or reduction — those require the repository (Phase 2).
- Implicit multiplication is implemented and testable with numbers and bare
  unit identifiers.
- Functions and affine-unit-specific behavior (standalone detection, prefix
  restrictions, definition request nodes) are defined as stubs or throw
  `UnimplementedError` where they depend on unit definitions.

---


Design Decisions
----------------

These decisions were made during the Phase 1 design review:

1. **Identifier classification (no repository):** Any identifier followed by `(`
   is lexed as a function; any other identifier is lexed as a unit.  This allows
   testing lexer and parser behavior before full unit definitions exist.

2. **High-precedence division (`|`):** Modeled after GNU Units.  `1|2 m` means
   `(1/2) * m`, since `1/2 m` would mean `1 / (2*m)` due to implicit
   multiplication's higher precedence.  Both operands of `|` must be numeric
   literals; any other expression is a parse error.

3. **Unary minus precedence:** Unary `-` binds tighter than `^`, matching GNU
   Units.  This means `-2^3` = `(-2)^3` = `-8` and `2^-3` = `2^(-3)` =
   `0.125`.  Note: `-2^2` = `(-2)^2` = `4`, which differs from standard
   mathematical convention (`-(2^2) = -4`).

4. **Exponentiation operators:** Both `^` and `**` are recognized as
   exponentiation, with identical semantics.

5. **AST node classes:** All node types are defined in Phase 1 (including
   `AffineUnitNode`, `DefinitionRequestNode`, etc.) so the parser's structure
   is complete.  Nodes that depend on unit definitions throw
   `UnimplementedError` during evaluation.

6. **Evaluator returns Quantity:** The evaluator returns `Quantity` objects from
   Phase 1 onward.  `Dimension` and `Quantity` are implemented fully, with all
   unit identifiers treated as primitive (creating their own dimension).  This
   avoids an interface change in Phase 2.

7. **Dimension exponents are `int`:** The `Dimension.units` map is
   `Map<String, int>`.  Dimension exponents are always integers by definition;
   the `Quantity.power()` validation with `Rational` enforces this.

8. **Rational class:** Implemented in Phase 1.  It is self-contained and needed
   for dimensional exponent validation during `power()`.

9. **Exception hierarchy:** All application exceptions share a `UnitaryException`
   base class with `LexException`, `ParseException`, `EvalException`, and
   `DimensionException` subclasses.

10. **Implicit multiplication scope:** Implemented in Phase 1 and testable
    without units — `2 3` parses as `2 * 3 = 6`.  Features that depend on unit
    definitions (affine syntax validation, prefix restrictions, standalone
    detection) are deferred.

---


Operator Precedence
-------------------

From lowest to highest binding:

| Level | Operators               | Associativity  | Notes                                                       |
|-------|-------------------------|----------------|-------------------------------------------------------------|
| 1     | `+`, `-`                | Left           | Addition, subtraction                                       |
| 2     | `*`, `×`, `·`, `/`, `÷` | Left           | Explicit multiplication, division                           |
| 3     | *(juxtaposition)*       | Left           | Implicit multiplication (no operator token)                 |
| 4     | `^`, `**`               | Right          | Exponentiation                                              |
| 5     | `\|`                    | Left           | High-precedence division; operands must be numeric literals |
| 6     | unary `+`, `-`          | Right (prefix) | Unary plus/minus                                            |
| 7     | function call           | —              | `sin(x)`, `sqrt(x)`, etc.                                   |
| 8     | primary                 | —              | Numbers, unit identifiers, parenthesized expressions        |

**Precedence examples:**

~~~~
5 + 3 * 2           = 5 + (3 * 2) = 11
5 m / 2 s           = (5*m) / (2*s) = 2.5 m/s
2^3^4               = 2^(3^4) = 2^81       (right-associative)
-2^3                = (-2)^3 = -8           (unary binds tighter than ^)
2^-3                = 2^(-3) = 0.125        (unary binds tighter than ^)
1|2 m               = (1/2) * m = 0.5 m     (| binds tighter than implicit mult)
3 m + 2 m           = (3*m) + (2*m) = 5 m
~~~~

---


Implementation Steps
--------------------


### Step 1: Exception Hierarchy

**File:** `lib/core/domain/errors.dart`

Define `UnitaryException` base class with `message`, `line`, and `column`
fields, and four subclasses: `LexException`, `ParseException`,
`EvalException`, `DimensionException`.

- All have a `message` field and optional `line`/`column` for source position.
- `DimensionException` additionally has optional `leftDimension` and
  `rightDimension` fields for diagnostic context.
- All override `toString()` to include position info when available.

**Tests:** `test/core/domain/errors_test.dart`

- Verify `toString()` formatting with and without position info.
- Verify all subclasses are caught by `catch (UnitaryException)`.


### Step 2: Rational Utility Class

**File:** `lib/core/domain/models/rational.dart`

A minimal rational number type used for recovering rational approximations from
`double` exponents.

**Fields:**

- `int numerator` — always in lowest terms
- `int denominator` — always positive, always in lowest terms

**Constructors:**

- `Rational(int numerator, int denominator)` — normalizes sign and reduces by
  GCD.  Throws `ArgumentError` if denominator is zero.
- `Rational.fromInt(int value)` — shorthand for `Rational(value, 1)`.
- `Rational.fromDouble(double value, {int maxDenominator = 100})` — continued
  fractions algorithm.  Throws `ArgumentError` on NaN or infinity.

**Methods:**

- `double toDouble()` — returns `numerator / denominator`.
- `toString()` — returns `'numerator/denominator'` or `'numerator'` if
  denominator is 1.
- `operator ==` and `hashCode` — cross-multiplication equality.

**No arithmetic operations needed yet** (just recovery and conversion).

**Tests:** `test/core/domain/models/rational_test.dart`

- Recovery: `0.5` → `1/2`, `0.333...` → `1/3`, `0.25` → `1/4`,
  `0.666...` → `2/3`, `0.2` → `1/5`.
- Integers: `3.0` → `3/1`, `0.0` → `0/1`.
- Negative values: `-0.5` → `-1/2`.
- Normalization: `Rational(2, 4)` → `1/2`, `Rational(-3, -6)` → `1/2`.
- Edge cases: denominator zero throws `ArgumentError`, NaN/infinity throw
  `ArgumentError`.
- Round-trip: `Rational.fromDouble(r.toDouble()) == r` for small rationals.


### Step 3: Dimension Class

**File:** `lib/core/domain/models/dimension.dart`

Represents a dimension as a product of primitive units with integer exponents.

**Fields:**

- `Map<String, int> units` — unmodifiable; zero exponents are
  stripped on construction.

**Constructors:**

- `Dimension(Map<String, int> exponents)` — strips zeros, makes unmodifiable.
- `Dimension.dimensionless()` — empty map.

**Methods:**

- `Dimension multiply(Dimension other)` — add exponents.
- `Dimension divide(Dimension other)` — subtract exponents.
- `Dimension power(int exponent)` — multiply all exponents by scalar.
- `Dimension powerRational(Rational exponent)` — multiply all exponents by
  `exponent.numerator`, then check divisibility by `exponent.denominator`.
  Throws `DimensionException` if any result is not evenly divisible.  Returns
  the `Dimension` with divided exponents.
- `bool isConformableWith(Dimension other)` — map equality.
- `bool get isDimensionless` — empty map check.
- `String canonicalRepresentation()` — sorted alphabetically, positive
  exponents in numerator, negative in denominator.  E.g., `kg * m / s^2`.
- `operator ==` and `hashCode`.

**Tests:** `test/core/domain/models/dimension_test.dart`

- Dimensionless construction and `isDimensionless`.
- Multiply: `{m: 1} * {s: -1}` = `{m: 1, s: -1}`.
- Divide: `{m: 1} / {m: 1}` = dimensionless.
- Power: `{m: 1, s: -1}.power(2)` = `{m: 2, s: -2}`.
- `powerRational`: `{m: 2}.powerRational(Rational(1, 2))` = `{m: 1}`.
- `powerRational` error: `{m: 3}.powerRational(Rational(1, 2))` throws
  `DimensionException`.
- Zero exponent stripping: `{m: 1, s: 0}` becomes `{m: 1}`.
- `isConformableWith`: same dimensions match, different don't.
- Equality: `Dimension({m: 1}) == Dimension({m: 1})`.
- `canonicalRepresentation`: verify formatting.


### Step 4: Quantity Class

**File:** `lib/core/domain/models/quantity.dart`

The core data structure combining a numeric value with dimensional information.

**Fields:**

- `double value`
- `Dimension dimension`
- `Unit? displayUnit` — always `null` in Phase 1.

**Constructors:**

- `Quantity(double value, Dimension dimension, {Unit? displayUnit})` — validates
  that value is not NaN (throws `EvalException`).  Infinity is allowed.
- `Quantity.dimensionless(double value)` — shorthand.

**Arithmetic methods:**

- `Quantity add(Quantity other)` — requires conformable dimensions, else throws
  `DimensionException`.  Returns `Quantity(value + other.value, dimension)`.
- `Quantity subtract(Quantity other)` — same constraint as add.
- `Quantity multiply(Quantity other)` — multiplies values and dimensions.
- `Quantity divide(Quantity other)` — checks zero divisor (throws
  `EvalException`), divides values and dimensions.
- `Quantity negate()` — negates value, preserves dimension and displayUnit.
- `Quantity abs()` — absolute value, preserves dimension and displayUnit.
- `Quantity power(num exponent)` — see algorithm below.

**Operator overloads:** `+`, `-` (binary), `*`, `/`, unary `-`.

**Power algorithm:**

1. `exponent == 0` → return `Quantity.dimensionless(1.0)`.
2. `exponent == 1` → return `this`.
3. If dimensionless: check for negative base with fractional exponent (throw
   `EvalException`).  Compute `pow(value, exponent)`.
4. If dimensioned:
   a. Convert exponent to `Rational` (if `int`, trivial; if `double`, use
      `Rational.fromDouble()`).
   b. Verify recovered rational is close to original double (within `1e-10`).
   c. Call `dimension.powerRational(rational)` — this validates integrality
      and throws `DimensionException` if not.
   d. Check for negative base with fractional exponent.
   e. Return `Quantity(pow(value, exponent), newDimension)`.

**Query methods:**

- `bool get isDimensionless`
- `bool get isZero`
- `bool get isPositive`
- `bool get isNegative`
- `bool isConformableWith(Quantity other)`
- `bool approximatelyEquals(Quantity other, {double tolerance})` — relative
  tolerance for large values, absolute for small.

**Stubs (Phase 2):**

- `Quantity convertTo(Unit targetUnit, UnitRepository repo)` → throws
  `UnimplementedError`.
- `Quantity reduceToPrimitives(UnitRepository repo)` → throws
  `UnimplementedError`.
- `String format(DisplaySettings settings)` → basic `toString()` for now.

**Tests:** `test/core/domain/models/quantity_test.dart`

- Addition of conformable quantities.
- Addition of non-conformable throws `DimensionException`.
- Subtraction.
- Multiplication combines dimensions.
- Division combines dimensions.
- Division by zero throws `EvalException`.
- Negate, abs.
- Power with integer exponent.
- Power with fractional exponent: `Quantity(4, {m: 2}).power(0.5)` =
  `Quantity(2, {m: 1})`.
- Power with invalid dimension: `Quantity(8, {m: 3}).power(0.5)` throws
  `DimensionException`.
- Power: negative base with fractional exponent throws `EvalException`.
- NaN in constructor throws `EvalException`.
- Infinity is allowed.
- `approximatelyEquals` with tolerance.
- Dimensionless convenience constructor.
- Operator overloads.


### Step 5: Token Types and Token Class

**File:** `lib/core/domain/parser/token.dart`

**`TokenType` enum:** `number`, `unit`, `plus`, `minus`, `multiply`, `divide`,
`divideHigh` (`|`), `power` (`^`/`**`), `leftParen`, `rightParen`, `comma`,
`function`, `eof`.

**`Token` class:** Fields: `type` (TokenType), `lexeme` (original source text),
`literal` (parsed value — `double` for numbers, `String` for identifiers),
`line`, `column`.

**Tests:** Tested indirectly through lexer tests.


### Step 6: Lexer

**File:** `lib/core/domain/parser/lexer.dart`

Converts an input string to `List<Token>`.

**Class structure:** `Lexer` takes a source string and maintains scanning state
(`_start`, `_current`, `_line`, `_column`, `_tokens`).  Entry point is
`scanTokens()` which returns `List<Token>`.

**`scanTokens()` loop:**

For each iteration:

1. Skip whitespace (spaces, tabs; newlines increment line counter and reset
   column).
2. Record `_start = _current`.
3. Read the next character and dispatch:
   - `+` → `plus`
   - `-` → `minus`
   - `*` → peek next: if `*`, consume both → `power`; else → `multiply`
   - `/` → `divide`
   - `|` → `divideHigh`
   - `^` → `power`
   - `(` → `leftParen`
   - `)` → `rightParen`
   - `,` → `comma`
   - `×`, `·` → `multiply`
   - `÷` → `divide`
   - digit or `.` followed by digit → `scanNumber()`
   - alpha or `_` → `scanIdentifier()`
   - else → throw `LexException`
4. After adding the token, call `_insertImplicitMultiply()`.
5. After the loop, add `eof` token.

**`_scanNumber()`:**

Handle all number formats:

- Leading decimal: `.5`, `.25`
- Integer: `42`
- Decimal: `3.14`, `0.5`
- Scientific notation: `1.5e-10`, `3E8`, `2e+5`
- Error on malformed scientific notation (`1.5e` with no digits after)

Store parsed `double` as the token literal.

**`_scanIdentifier()`:**

- Read while alphanumeric or `_`.
- Look ahead (without consuming) to see if next non-whitespace character is `(`.
  - If yes → emit `TokenType.function` with identifier string as literal.
  - If no → emit `TokenType.unit` with identifier string as literal.

Note: the lookahead for `(` does not consume whitespace between the identifier
and the paren.  `sin(x)` and `sin (x)` are both function calls.  However, the
whitespace between `sin` and `(` triggers implicit multiplication logic, so
we must check for function lookahead *before* implicit multiplication insertion.

**Implementation note:** The simplest approach is to *not* insert implicit
multiply after an identifier if the next non-whitespace character is `(` and
the identifier was classified as a function.  Since function classification
already checks for the `(`, this is consistent: the function token is emitted,
and no implicit multiply is inserted before `(`.

**`_insertImplicitMultiply()`:**

After adding a token, check whether an implicit multiply should be inserted
*before the next token*.  This is checked at the *start* of the next scan
iteration (before scanning the next token), by looking at the last emitted
token and the upcoming character:

Insert implicit `multiply` when:

- Previous token is `number`, `unit`, or `rightParen`
- AND next character starts a `number` (digit or `.`), identifier
  (alpha/`_`), or `(`
- AND if next character starts an identifier, the previous token is not a
  function (this case shouldn't arise since functions are followed by `(`)

Do NOT insert when:

- Previous token is an operator, `leftParen`, `comma`, or `eof`
- Next character is an operator, `)`, `,`, or end of input

The implicit multiply token uses lexeme `""` (empty string, since it has no
source text) and the same line/column as the upcoming token.

**Tests:** `test/core/domain/parser/lexer_test.dart`

- Number tokens: integers, decimals, leading decimal, scientific notation.
- Operator tokens: all operators including `**` as power.
- Unicode operators: `×`, `·`, `÷`.
- Identifier classification: `sin(x)` → function + paren + unit + paren;
  `m` → unit.
- Implicit multiplication:
  - `5m` → `number(5), multiply, unit(m)`
  - `2 3` → `number(2), multiply, number(3)`
  - `m s` → `unit(m), multiply, unit(s)`
  - `)(` → `rightParen, multiply, leftParen`
  - `5(2+3)` → `number(5), multiply, leftParen, ...`
- No implicit multiply after operators: `5 + 3` → `number, plus, number`.
- Function calls: `sin(0.5)` → `function(sin), leftParen, number, rightParen`
  (no implicit multiply between function and paren).
- Function with space: `sin (0.5)` → same as above.
- Line/column tracking.
- Error cases: unknown character, malformed scientific notation.


### Step 7: AST Node Classes

**File:** `lib/core/domain/parser/ast.dart`

All AST nodes extend `ASTNode`, which defines a single method
`evaluate(EvalContext context)` returning a `Quantity`.

**Fully implemented for Phase 1:**

- **`NumberNode`** — holds `double value`.  Evaluates to
  `Quantity.dimensionless(value)`.

- **`UnitNode`** — holds `String unitName`.  Evaluates to
  `Quantity(1.0, Dimension({unitName: 1}))`.

- **`BinaryOpNode`** — holds `ASTNode left`, `ASTNode right`,
  `TokenType operator`.  Evaluates by evaluating both children then applying
  the corresponding `Quantity` arithmetic method.

- **`UnaryOpNode`** — holds `ASTNode operand`, `TokenType operator` (`plus` or
  `minus`).  Evaluates operand; if `minus`, calls `negate()`.

- **`FunctionNode`** — holds `String name`, `List<ASTNode> arguments`.
  Evaluates arguments and dispatches to built-in function implementations:
  - `sin`, `cos`, `tan`: require 1 dimensionless argument, return dimensionless.
  - `asin`, `acos`, `atan`: require 1 dimensionless argument (with domain
    checks), return dimensionless.
  - `sqrt`: 1 argument, delegates to `arg.power(0.5)`.
  - `ln`, `log`: require 1 dimensionless positive argument, return dimensionless.
    (`ln` and `log` are synonymous: natural logarithm.)
  - `exp`: require 1 dimensionless argument, return dimensionless.
  - `abs`: 1 argument, returns `arg.abs()`.
  - Unknown function name → `EvalException`.

**Defined as stubs (Phase 2+):**

- **`AffineUnitNode`** — holds unit info and argument `ASTNode`.  `evaluate()`
  throws `UnimplementedError`.

- **`DefinitionRequestNode`** — holds unit identifier string.  `evaluate()`
  throws `UnimplementedError`.

- **`FunctionDefinitionRequestNode`** — holds function name string.
  `evaluate()` throws `UnimplementedError`.

**`EvalContext` class:** Empty for Phase 1.  Will hold `UnitRepository` in
Phase 2.

**Tests:** AST nodes are tested indirectly through parser and evaluator tests.
Direct tests can verify evaluation of individual nodes in isolation.


### Step 8: Parser

**File:** `lib/core/domain/parser/parser.dart`

Recursive descent parser consuming a `List<Token>` and producing an `ASTNode`.
Maintains a `_current` index into the token list.  Entry point is `parse()`.

**Grammar (recursive descent methods):**

~~~~
parse()             → expression, expect EOF
expression()        → addition
addition()          → multiplication ( ('+' | '-') multiplication )*
multiplication()    → implicit ( ('*' | '×' | '·' | '/' | '÷') implicit )*
implicit()          → exponentiation ( exponentiation )*
                      // lookahead: continue if next token starts a primary
                      // (number, unit, function, leftParen)
exponentiation()    → highDivision ( ('^' | '**') unary )?
                      // right-associative: recurse into unary, not exponentiation
highDivision()      → unary ( '|' unary )*
                      // after parsing, validate both operands are NumberNode
unary()             → ('-' | '+') unary | call
call()              → primary ( '(' arguments ')' )?
                      // only consumes parens if primary produced a FunctionNode
                      // stub or if the token was TokenType.function
primary()           → NUMBER | UNIT | '(' expression ')' | FUNCTION
~~~~

**Implicit multiplication detail:**

The `implicit()` method parses one `exponentiation()`, then checks if the next
token could start another primary expression.  The tokens that can start a
primary are: `number`, `unit`, `function`, `leftParen`.  If the next token is
one of these, parse another `exponentiation()` and wrap in
`BinaryOpNode(multiply)`.  Repeat.

Note: this means implicit multiplication is already handled by the *parser*
via grammar rules.  The lexer's `_insertImplicitMultiply()` is an alternative
approach.  **We should use one or the other, not both.**

**Chosen approach: lexer-based implicit multiplication.**  The lexer inserts
synthetic `multiply` tokens, so the parser's `multiplication()` rule handles
both explicit and implicit multiplication uniformly.  The `implicit()` grammar
level is therefore *not needed as a separate method* — instead, implicit
multiply tokens are just regular `multiply` tokens at level 2.

Wait — this collapses levels 2 and 3, losing the precedence distinction.  The
whole point of implicit multiplication being higher precedence is so that
`5 m / 2 s` = `(5*m) / (2*s)`, not `((5*m) / 2) * s`.

**Revised approach: parser-based implicit multiplication.**  The lexer does
*not* insert implicit multiply tokens.  Instead, the parser has two distinct
grammar levels:

- Level 2 (`multiplication`): handles explicit `*`, `/` tokens.
- Level 3 (`implicit`): handles juxtaposition by checking if the next token
  could start a new sub-expression.

This keeps the precedence distinction.  The lexer is responsible only for
tokenizing; the parser handles all precedence.

~~~~
multiplication()    → implicit ( ('*' | '/' | '÷') implicit )*
implicit()          → exponentiation+
                      // multiple exponentiations in sequence = implicit multiply
~~~~

In `implicit()`, after parsing the first `exponentiation()`, check if the next
token is `number`, `unit`, `function`, or `leftParen`.  If so, parse another
`exponentiation()` and combine with `BinaryOpNode(TokenType.times, ...)`.
Repeat.  The `times` and `divide` tokens with `×`, `·` are handled at
level 2.

**High-precedence division validation:**

After parsing a `highDivision()` chain (e.g., `1|2|3`), validate that all
operands in the chain are `NumberNode`.  If any operand is not a `NumberNode`,
throw `ParseException`.  This is checked after building the AST node, so the
error message can reference the offending operand.

**Function call parsing:**

In `call()`, if `primary()` returned a node from a `function` token, expect
`(`, parse comma-separated `expression()` nodes, expect `)`.  Wrap in
`FunctionNode`.  If `primary()` returned a `unit` or `number`, return as-is
(no function call).

**Error handling:**

- `consume(TokenType expected, String message)` — advance if match, else throw
  `ParseException` with the message and current token's position.
- Unexpected token at end of expression → `ParseException`.
- Missing closing `)` → `ParseException`.

**Tests:** `test/core/domain/parser/parser_test.dart`

Test by examining AST structure (not evaluation results — that's the evaluator's
job).  Tests should verify:

- Simple arithmetic: `1 + 2` → `BinaryOp(+, Number(1), Number(2))`.
- Precedence: `1 + 2 * 3` → `BinaryOp(+, 1, BinaryOp(*, 2, 3))`.
- Implicit multiplication: `5 m` → `BinaryOp(*, Number(5), Unit(m))`.
- Implicit > explicit: `5 m / 2 s` → `BinaryOp(/, BinaryOp(*, 5, m), BinaryOp(*, 2, s))`.
- Right-associative exponentiation: `2^3^4` → `BinaryOp(^, 2, BinaryOp(^, 3, 4))`.
- `**` as exponentiation: `2**3` → same as `2^3`.
- Unary: `-5` → `UnaryOp(-, Number(5))`.
- Unary precedence: `-2^3` → `BinaryOp(^, UnaryOp(-, 2), Number(3))`.
- High-precedence division: `1|2` → `BinaryOp(|, Number(1), Number(2))`.
- `|` validation: `m|2` → `ParseException`.
- Function call: `sin(0.5)` → `Function(sin, [Number(0.5)])`.
- Multi-argument function: `atan2(1, 2)` → `Function(atan2, [Number(1), Number(2)])`.
- Parentheses: `(1 + 2) * 3` → `BinaryOp(*, BinaryOp(+, 1, 2), Number(3))`.
- Implicit multiply with parens: `(2)(3)` → `BinaryOp(*, 2, 3)`.
- Complex expression: `2 m^2 / s` → verify correct tree.
- Error: missing `)` → `ParseException`.
- Error: unexpected EOF → `ParseException`.
- Error: unexpected token → `ParseException`.


### Step 9: Evaluator

Evaluation is performed by calling `evaluate(context)` on the root `ASTNode`.
Each node type implements its own evaluation logic (visitor-less, method-based).

**File:** Logic is in `lib/core/domain/parser/ast.dart` (the `evaluate` methods
on each node class).

**`NumberNode.evaluate()`:** Return `Quantity.dimensionless(value)`.

**`UnitNode.evaluate()`:** Return `Quantity(1.0, Dimension({unitName: 1}))`.

**`BinaryOpNode.evaluate()`:**

1. Evaluate left and right children.
2. Dispatch on operator:
   - `plus` → `left.add(right)`
   - `minus` → `left.subtract(right)`
   - `multiply` → `left.multiply(right)`
   - `divide` → `left.divide(right)`
   - `divideHigh` → `left.divide(right)` (same arithmetic as `/`; the
     operand restriction is enforced at parse time)
   - `power` → `left.power(right.value)` — right operand must be
     dimensionless (throw `DimensionException` if not) and its `value` is
     passed as the numeric exponent.

**`UnaryOpNode.evaluate()`:** Evaluate operand.  If `minus`, call `negate()`.
If `plus`, return as-is.

**`FunctionNode.evaluate()`:** Evaluate arguments, then dispatch on function
name.  Built-in functions for Phase 1:

| Function | Args | Dimension constraint            | Result dimension | Notes            |
|----------|------|---------------------------------|------------------|------------------|
| `sin`    | 1    | dimensionless                   | dimensionless    |                  |
| `cos`    | 1    | dimensionless                   | dimensionless    |                  |
| `tan`    | 1    | dimensionless                   | dimensionless    |                  |
| `asin`   | 1    | dimensionless, value in [-1, 1] | dimensionless    |                  |
| `acos`   | 1    | dimensionless, value in [-1, 1] | dimensionless    |                  |
| `atan`   | 1    | dimensionless                   | dimensionless    |                  |
| `sqrt`   | 1    | any (delegates to power)        | derived          | `arg.power(1/2)` |
| `cbrt`   | 1    | any (delegates to power)        | derived          | `arg.power(1/3)` |
| `ln`     | 1    | dimensionless, positive         | dimensionless    | natural log      |
| `log`    | 1    | dimensionless, positive         | dimensionless    | synonym for `ln` |
| `exp`    | 1    | dimensionless                   | dimensionless    |                  |
| `abs`    | 1    | any                             | same as input    | `arg.abs()`      |

Unknown function names throw `EvalException`.

Wrong argument count throws `EvalException`.

**Tests:** `test/core/domain/parser/evaluator_test.dart`

Test via the full pipeline (parse string → evaluate → check result):

- Pure arithmetic: `5 * 3 + 2` → 17, `10 / 4` → 2.5, `2^10` → 1024.
- `**` operator: `2**10` → 1024.
- Unary: `-5 + 3` → -2, `--5` → 5.
- Precedence: `2 + 3 * 4` → 14, `-2^3` → -8, `2^-3` → 0.125.
- High-precedence division: `1|2` → 0.5, `1|3` → 0.333..., `3|4|5` → verify
  left-to-right.
- Implicit multiplication: `2 3` → 6, `2 3 4` → 24.
- Unit identifiers: `5 m` → `Quantity(5, {m: 1})`.
- Unit arithmetic: `5 m * 3` → `Quantity(15, {m: 1})`,
  `5 m + 3 m` → `Quantity(8, {m: 1})`.
- Unit errors: `5 m + 3 s` → throws `DimensionException`.
- Dimension multiplication: `5 m * 3 s` → `Quantity(15, {m: 1, s: 1})`.
- Dimension division: `10 m / 2 s` → `Quantity(5, {m: 1, s: -1})`.
- Exponentiation with units: `(3 m)^2` → `Quantity(9, {m: 2})`.
- `sqrt` with units: `sqrt(9 m^2)` → `Quantity(3, {m: 1})`.
- `sqrt` dimension error: `sqrt(9 m^3)` → throws `DimensionException`.
- Trig functions: `sin(0)` → 0, `cos(0)` → 1.
- Trig domain error: `asin(2)` → throws `EvalException`.
- Trig dimension error: `sin(5 m)` → throws `DimensionException`.
- `ln`/`log`: `ln(1)` → 0, `log(1)` → 0.
- Log domain error: `ln(0)` → throws `EvalException`, `ln(-1)` → throws.
- Division by zero: `1 / 0` → throws `EvalException`.
- Complex: `1|2 m` → `Quantity(0.5, {m: 1})`, `5 m / 2 s` →
  `Quantity(2.5, {m: 1, s: -1})`.
- Parentheses: `(2 + 3) * 4` → 20.
- Nested functions: `abs(sin(0))` → 0.


### Step 10: Top-Level API

**File:** `lib/core/domain/parser/expression_parser.dart`

Convenience class that ties the pipeline together.  Provides three methods:

- `evaluate(String input)` — lex, parse, and evaluate, returning a `Quantity`.
- `parse(String input)` — lex and parse, returning the `ASTNode` (useful for
  testing parser output without evaluation).
- `tokenize(String input)` — lex only, returning `List<Token>` (useful for
  testing lexer output).

---


File Summary
------------

### Production code (`lib/core/domain/`)

| File                            | Contents                                                                                    |
|---------------------------------|---------------------------------------------------------------------------------------------|
| `errors.dart`                   | `UnitaryException`, `LexException`, `ParseException`, `EvalException`, `DimensionException` |
| `models/rational.dart`          | `Rational` class with continued fractions recovery                                          |
| `models/dimension.dart`         | `Dimension` class with dimensional arithmetic                                               |
| `models/quantity.dart`          | `Quantity` class with arithmetic and validation                                             |
| `parser/token.dart`             | `TokenType` enum and `Token` class                                                          |
| `parser/lexer.dart`             | `Lexer` class                                                                               |
| `parser/ast.dart`               | All `ASTNode` subclasses and `EvalContext`                                                  |
| `parser/parser.dart`            | `Parser` class (recursive descent)                                                          |
| `parser/expression_parser.dart` | `ExpressionParser` convenience API                                                          |

### Test code (`test/core/domain/`)

| File                         | Contents                            |
|------------------------------|-------------------------------------|
| `errors_test.dart`           | Exception hierarchy and formatting  |
| `models/rational_test.dart`  | Rational recovery and normalization |
| `models/dimension_test.dart` | Dimensional arithmetic              |
| `models/quantity_test.dart`  | Quantity arithmetic and validation  |
| `parser/lexer_test.dart`     | Tokenization                        |
| `parser/parser_test.dart`    | AST construction and precedence     |
| `parser/evaluator_test.dart` | End-to-end expression evaluation    |

---


Implementation Order
--------------------

The steps above are listed in dependency order.  Each step's tests should be
written and passing before proceeding to the next:

1. Exception hierarchy (no dependencies)
2. Rational (depends on exceptions only for argument validation)
3. Dimension (depends on exceptions)
4. Quantity (depends on Dimension, Rational, exceptions)
5. Token types (no dependencies)
6. Lexer (depends on Token, exceptions)
7. AST nodes (depends on Quantity, Dimension, Token, exceptions)
8. Parser (depends on AST, Token, exceptions)
9. Evaluator (logic is in AST nodes; tested end-to-end through parser)
10. Top-level API (depends on Lexer, Parser, AST)

---


Open Decisions for Phase 2
--------------------------

The following items are explicitly deferred to Phase 2 or later:

- Unit repository and unit lookup by name/alias
- Prefix splitting (`km` → `kilo` + `m`)
- Plural handling (`meters` → `meter`)
- Unit conversion and reduction to primitives
- Affine unit syntax validation (parentheses required)
- Standalone token detection and definition request nodes
- Prefix restrictions on functions and affine units
- `DisplaySettings` and formatted output
- Temperature handling (absolute vs. difference units)

---

*This document captures all design decisions and implementation details for
Phase 1 as agreed during the design review session of February 1, 2026.*
