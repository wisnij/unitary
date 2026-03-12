# Inverse Function Operator

## Purpose

Define the `~` operator that invokes the inverse of a named function in the
expression grammar, matching GNU Units syntax.


## Requirements

### Requirement: INVERSE lexer token

The lexer SHALL recognise `~` as a distinct token with type `INVERSE`.  It
SHALL NOT be consumed as part of an identifier.

#### Scenario: Tilde produces INVERSE token
- **WHEN** the lexer scans the input `~`
- **THEN** it emits exactly one token of type `INVERSE` with lexeme `"~"`

#### Scenario: Tilde before identifier does not merge into identifier
- **WHEN** the lexer scans `~tempF`
- **THEN** it emits an `INVERSE` token followed by an `identifier` token `"tempF"`, not a single identifier `"~tempF"`

#### Scenario: Tilde in the middle of input
- **WHEN** the lexer scans `5 * ~tempF(300 K)`
- **THEN** the token stream contains an `INVERSE` token immediately before the `identifier` token `"tempF"`

---

### Requirement: Inverse function call grammar

The parser's `function` production SHALL accept an optional `INVERSE` token
before the function name:

```
function = INVERSE? IDENTIFIER LPAR arguments RPAR
```

When `INVERSE` is present, the resulting `FunctionNode` SHALL have
`inverse == true`.  When absent, `inverse == false`.

#### Scenario: Normal function call parses with inverse false
- **WHEN** the parser parses `tempF(212)`
- **THEN** a `FunctionNode` is produced with `name == "tempF"` and `inverse == false`

#### Scenario: Inverse function call parses with inverse true
- **WHEN** the parser parses `~tempF(300 K)`
- **THEN** a `FunctionNode` is produced with `name == "tempF"` and `inverse == true`

#### Scenario: Inverse operator on a multi-argument function
- **WHEN** the parser parses `~foo(1, 2)`
- **THEN** a `FunctionNode` is produced with `name == "foo"`, `inverse == true`, and two arguments

#### Scenario: Tilde without a following function call is a parse error
- **WHEN** the parser encounters `~42`
- **THEN** a `ParseException` is thrown

---

### Requirement: FunctionNode inverse field

`FunctionNode` SHALL expose an `inverse` boolean field (default `false`).

#### Scenario: Default construction has inverse false
- **WHEN** a `FunctionNode` is constructed without specifying `inverse`
- **THEN** `inverse` is `false`

#### Scenario: Construction with inverse true
- **WHEN** a `FunctionNode` is constructed with `inverse == true`
- **THEN** `inverse` is `true`

---

### Requirement: FunctionNode evaluates inverse via callInverse

When `FunctionNode.inverse` is `true`, `evaluate()` SHALL call
`func.callInverse(args)` instead of `func.call(args)`.

#### Scenario: Inverse call dispatches to callInverse
- **WHEN** a `FunctionNode` with `inverse == true` is evaluated
- **THEN** the result equals the value returned by `func.callInverse(args)`

#### Scenario: Normal call dispatches to call
- **WHEN** a `FunctionNode` with `inverse == false` is evaluated
- **THEN** the result equals the value returned by `func.call(args)`

#### Scenario: Inverse of a non-invertible function throws
- **WHEN** a `FunctionNode` with `inverse == true` is evaluated for a function whose `hasInverse` is `false`
- **THEN** an `EvalException` is thrown identifying the function by name

#### Scenario: End-to-end inverse function call
- **WHEN** the expression `~tempF(300 K)` is parsed and evaluated with a repository containing `tempF`
- **THEN** the result is the Fahrenheit equivalent of 300 K (approximately 80.33 °F expressed as a dimensionless value)
