Log-N Function
==============

Purpose
-------

Define the parser's recognition and desugaring of `logB(x)` syntax for any
integer base B ≥ 2, following the GNU Units convention where `logB(x)` is
shorthand for `ln(x) / ln(B)`.


## ADDED Requirements

### Requirement: Parser recognises logB(x) syntax
The parser SHALL recognise an identifier of the form `log<B>` (where `<B>` is a
run of ASCII digits representing an integer ≥ 2) followed by `(` as an
arbitrary-base logarithm expression.

It SHALL desugar this to the AST:

```
BinaryOpNode(
  FunctionNode("ln", [argNode]),
  TokenType.divide,
  NumberNode(math.log(B)),
)
```

where `math.log(B)` is computed once at parse time (Dart's `math.log` is the
natural logarithm, so this equals `ln(B)`).

This check SHALL occur before both the function-registry lookup and the
trailing-digit-exponent check, so that `log2(x)` is never mistakenly parsed as
`log^2 * (x)`.

#### Scenario: log2(x) evaluates as base-2 logarithm
- **WHEN** the expression `log2(8)` is evaluated
- **THEN** the result is `3.0` (dimensionless), within floating-point tolerance

#### Scenario: log10(x) evaluates as base-10 logarithm
- **WHEN** the expression `log10(1000)` is evaluated
- **THEN** the result is `3.0` (dimensionless), within floating-point tolerance

#### Scenario: log16(x) evaluates as base-16 logarithm
- **WHEN** the expression `log16(256)` is evaluated
- **THEN** the result is `2.0` (dimensionless), within floating-point tolerance

#### Scenario: log256(x) evaluates as base-256 logarithm
- **WHEN** the expression `log256(65536)` is evaluated
- **THEN** the result is `2.0` (dimensionless), within floating-point tolerance

#### Scenario: logB(x) and ln(x)/ln(B) are numerically equivalent
- **WHEN** the expression `log7(49)` is evaluated
- **THEN** the result equals `ln(49) / ln(7)`, within floating-point tolerance

---

### Requirement: log(x) with no suffix remains base-10
The plain `log` identifier (with no integer suffix) SHALL continue to be looked
up in the function registry and evaluate as a base-10 logarithm, unchanged from
existing behaviour.

#### Scenario: log(100) is base-10
- **WHEN** the expression `log(100)` is evaluated
- **THEN** the result is `2.0` (dimensionless), within floating-point tolerance

#### Scenario: log and log10 produce equal results
- **WHEN** `log(x)` and `log10(x)` are evaluated for the same positive `x`
- **THEN** both results are equal, within floating-point tolerance

---

### Requirement: logB requires integer base ≥ 2
If the suffix following `log` consists entirely of ASCII digits but represents
an integer less than 2, the identifier SHALL NOT be treated as an arbitrary-base
logarithm.  Specifically:

- A suffix of `"0"` or `"1"` ends with `0` or `1`, so existing trailing-digit
  rules treat the full token as an identifier name; these fall through to unit
  lookup without a parse error.
- The parser SHALL NOT produce a `logB` desugaring for bases 0 or 1.

#### Scenario: log0 is not treated as a logB expression
- **WHEN** the expression `log0(x)` appears in input
- **THEN** it is NOT desugared as a logarithm; it is treated as identifier `log0`

#### Scenario: log1 is not treated as a logB expression
- **WHEN** the expression `log1(x)` appears in input
- **THEN** it is NOT desugared as a logarithm; it is treated as identifier `log1`

---

### Requirement: logB requires a following argument list
The `logB` desugaring SHALL only trigger when the identifier is immediately
followed by `(`.  If no `(` follows, the token is treated as a plain unit
identifier (subject to trailing-digit-exponent and other normal rules).

#### Scenario: logB without parentheses is not a function call
- **WHEN** the expression `log2` appears without a following `(`
- **THEN** it is parsed as a plain identifier, not a function call

---

### Requirement: logB(x) argument obeys ln domain constraints
Because the desugared form calls `ln(x)` internally, the argument SHALL be
subject to the same domain constraint as `ln`: a positive dimensionless value.
The `ln` builtin enforces this at evaluation time.

#### Scenario: logB of a non-positive value is rejected
- **WHEN** `log2(0)` is evaluated
- **THEN** `EvalException` is thrown (ln domain violation)

#### Scenario: logB of a negative value is rejected
- **WHEN** `log2(-4)` is evaluated
- **THEN** `EvalException` is thrown (ln domain violation)
