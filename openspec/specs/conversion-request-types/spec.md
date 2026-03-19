# Conversion Request Types

## Purpose

TBD

## Requirements

### Requirement: ASTNode is a sealed class

`ASTNode` SHALL be declared `sealed`.  All direct subtypes SHALL be declared in
the same library file (`ast.dart`).  Exhaustive `switch` statements over
`ASTNode` SHALL be enforced by the Dart compiler.

#### Scenario: Exhaustive switch on ASTNode compiles without wildcard

- **WHEN** a `switch` statement covers every direct subtype of `ASTNode`
- **THEN** the Dart analyzer accepts it without a wildcard or default arm

#### Scenario: Switch on ASTNode missing a subtype is a compile error

- **WHEN** a `switch` statement over `ASTNode` omits a direct subtype
- **THEN** the Dart analyzer reports a non-exhaustive switch error

### Requirement: ExpressionNode is a sealed abstract subtype of ASTNode

`ExpressionNode` SHALL be declared `sealed abstract` and SHALL extend `ASTNode`.
It SHALL declare `evaluate(EvalContext) → Quantity` as its abstract method.
All node types that produce a `Quantity` when evaluated SHALL extend
`ExpressionNode`: `NumberNode`, `UnitNode`, `BinaryOpNode`, `UnaryOpNode`,
`FunctionCallNode`.

#### Scenario: ExpressionNode supports exhaustive switch

- **WHEN** a `switch` statement covers every direct subtype of `ExpressionNode`
- **THEN** the Dart analyzer accepts it without a wildcard or default arm

#### Scenario: evaluate() is not callable on non-expression nodes

- **WHEN** code attempts to call `evaluate()` on a `FunctionNameNode` or
  `DefinitionRequestNode` at compile time
- **THEN** the Dart analyzer reports a type error

### Requirement: FunctionNode is renamed to FunctionCallNode

The class previously named `FunctionNode` SHALL be renamed `FunctionCallNode`.
Its behavior, fields (`name`, `arguments`, `inverse`), and `toString()` output
SHALL be updated to reflect the new name.  All references throughout the
codebase SHALL use the new name.

#### Scenario: FunctionCallNode evaluates a forward function call

- **WHEN** `FunctionCallNode("tempF", [NumberNode(32)], inverse: false)` is
  evaluated with a repository
- **THEN** the result is equivalent to `tempF(32)`

#### Scenario: FunctionCallNode evaluates an inverse function call

- **WHEN** `FunctionCallNode("tempF", [NumberNode(273.15)], inverse: true)` is
  evaluated with a repository
- **THEN** the result is the inverse of `tempF` applied to `273.15`

### Requirement: FunctionNameNode represents a bare function name

`FunctionNameNode` SHALL extend `ASTNode` directly (not `ExpressionNode`).
It SHALL have two fields: `name` (String) and `inverse` (bool).  It SHALL NOT
have an `evaluate()` method.  It represents a bare function identifier with no
argument list, as written by the user.

#### Scenario: FunctionNameNode is constructed for a bare forward name

- **WHEN** `FunctionNameNode("tempC", false)` is constructed
- **THEN** `node.name == "tempC"` and `node.inverse == false`

#### Scenario: FunctionNameNode is constructed for a bare inverse name

- **WHEN** `FunctionNameNode("tempC", true)` is constructed
- **THEN** `node.name == "tempC"` and `node.inverse == true`

### Requirement: FunctionDefinitionRequestNode is removed

The stub class `FunctionDefinitionRequestNode` SHALL be deleted.
`FunctionNameNode` supersedes it.

#### Scenario: FunctionDefinitionRequestNode does not exist in the codebase

- **WHEN** the codebase is searched for `FunctionDefinitionRequestNode`
- **THEN** no matches are found

### Requirement: parseExpression() replaces parse() on ExpressionParser

`ExpressionParser` SHALL expose `parseExpression(String input) → ExpressionNode`
as the expression-only entry point.  The method SHALL only return
`ExpressionNode` subtypes.  The old `parse()` method SHALL be removed.  All
former call sites of `parse()` SHALL be updated to call `parseExpression()` or
`parseQuery()` as appropriate.

#### Scenario: parseExpression returns an ExpressionNode for a numeric literal

- **WHEN** `parseExpression("42")` is called
- **THEN** the result is a `NumberNode` (an `ExpressionNode`)

#### Scenario: parseExpression returns an ExpressionNode for a unit expression

- **WHEN** `parseExpression("5 km + 3 m")` is called with a repository
- **THEN** the result is a `BinaryOpNode` (an `ExpressionNode`)

#### Scenario: parse() no longer exists

- **WHEN** the codebase is searched for calls to `ExpressionParser.parse(`
- **THEN** no matches are found

### Requirement: parseQuery() is the general entry point on ExpressionParser

`ExpressionParser` SHALL expose `parseQuery(String input) → ASTNode`.  It
SHALL detect bare identifiers in the following priority order, then fall back
to `parseExpression()`:

1. **Function name**: a bare identifier (optionally preceded by `~`) that
   resolves to a registered function → returns `FunctionNameNode`.
2. **Unit or prefix+unit**: a bare identifier where `findUnitWithPrefix(name)`
   returns a `UnitMatch` with a non-null `unit` field → returns
   `DefinitionRequestNode(name)`.
3. **Bare prefix**: a bare identifier where `findPrefix(name)` returns a
   non-null `PrefixUnit` → returns `DefinitionRequestNode(name)`.
4. **Otherwise**: delegates to `parseExpression()` and returns the resulting
   `ExpressionNode`.

A "bare identifier" means the token stream consists of exactly one
`TokenType.identifier` token (plus EOF), with no preceding `~` for cases 2
and 3.  If no repository is present, all inputs are delegated to
`parseExpression()`.

#### Scenario: parseQuery returns FunctionNameNode for a bare forward function name

- **WHEN** `parseQuery("tempC")` is called with a repository that has `tempC`
  registered as a function
- **THEN** the result is `FunctionNameNode("tempC", false)`

#### Scenario: parseQuery returns FunctionNameNode for a bare inverse function name

- **WHEN** `parseQuery("~tempC")` is called with a repository that has `tempC`
  registered as a function
- **THEN** the result is `FunctionNameNode("tempC", true)`

#### Scenario: parseQuery returns DefinitionRequestNode for a bare unit name

- **WHEN** `parseQuery("meter")` is called with a repository where `meter` is a
  unit but not a function
- **THEN** the result is `DefinitionRequestNode("meter")`

#### Scenario: parseQuery returns DefinitionRequestNode for a bare prefix+unit name

- **WHEN** `parseQuery("km")` is called with a repository where `km` splits into
  prefix `k` and unit `m`
- **THEN** the result is `DefinitionRequestNode("km")`

#### Scenario: parseQuery returns DefinitionRequestNode for a bare prefix alias

- **WHEN** `parseQuery("kilo")` is called with a repository where `kilo` is a
  prefix alias and no unit named `kilo` is registered
- **THEN** the result is `DefinitionRequestNode("kilo")`

#### Scenario: Function name takes priority over unit name in parseQuery

- **WHEN** `parseQuery("abs")` is called with a repository where `abs` is both
  a function and a unit
- **THEN** the result is `FunctionNameNode("abs", false)`

#### Scenario: Unit name takes priority over prefix name in parseQuery

- **WHEN** `parseQuery("M")` is called with a repository where `M` is both a
  unit name and a prefix name
- **THEN** the result is `DefinitionRequestNode("M")` (unit wins)

#### Scenario: parseQuery delegates non-unit, non-prefix, non-function input to parseExpression

- **WHEN** `parseQuery("5 km")` is called
- **THEN** the result is an `ExpressionNode` (same as `parseExpression("5 km")`)

#### Scenario: parseQuery without a repository delegates all input to parseExpression

- **WHEN** `parseQuery("meter")` is called with no repository
- **THEN** the result is a `UnitNode("meter")` (an `ExpressionNode`)

### Requirement: UnitaryFunction exposes display strings for its definition and inverse

`UnitaryFunction` SHALL declare three abstract getters:

- `List<String> get params` — the formal parameter names, used for display.
  `DefinedFunction` returns its actual parameter name list.  `BuiltinFunction`
  MAY optionally accept an explicit list at construction time; when none is
  provided it falls back to generic names (`x`, `y`, `z`, …) based on `arity`.
  `PiecewiseFunction` (always arity 1) returns `['x']`.
- `String? get definitionDisplay` — a presentation label for the forward
  definition, shown as-is in the UI.  Not guaranteed to be a parseable
  expression.
- `String? get inverseDisplay` — a presentation label for the inverse
  definition, shown as-is in the UI.  Implementations that have no inverse
  SHALL return `'no inverse defined'`.  `null` is reserved for cases where
  the inverse is not representable as any display string.

`DefinedFunction` SHALL return its `forward` field from `definitionDisplay` and
its `inverse` field from `inverseDisplay` when `inverse` is non-null, or
`'no inverse defined'` when `inverse` is null.

`BuiltinFunction` SHALL return `'<built-in function $id>'` from
`definitionDisplay` and `'no inverse defined'` from `inverseDisplay`.

`PiecewiseFunction` SHALL return `'piecewise linear function'` from both
`definitionDisplay` and `inverseDisplay`.

#### Scenario: DefinedFunction returns forward expression string

- **WHEN** `definitionDisplay` is accessed on a `DefinedFunction` with
  `forward: "x * 9|5 + 32"`
- **THEN** the result is `"x * 9|5 + 32"`

#### Scenario: DefinedFunction returns inverse expression string when present

- **WHEN** `inverseDisplay` is accessed on a `DefinedFunction` with
  `inverse: "(x - 32) * 5|9"`
- **THEN** the result is `"(x - 32) * 5|9"`

#### Scenario: DefinedFunction returns fallback when no inverse defined

- **WHEN** `inverseDisplay` is accessed on a `DefinedFunction` with
  `inverse: null`
- **THEN** the result is `'no inverse defined'`

#### Scenario: BuiltinFunction returns built-in label for definitionDisplay

- **WHEN** `definitionDisplay` is accessed on a `BuiltinFunction` with
  `id: "sin"`
- **THEN** the result is `"<built-in function sin>"`

#### Scenario: BuiltinFunction returns fallback for inverseDisplay

- **WHEN** `inverseDisplay` is accessed on a `BuiltinFunction`
- **THEN** the result is `'no inverse defined'`

#### Scenario: BuiltinFunction uses explicit params when provided

- **WHEN** a `BuiltinFunction` is constructed with `params: ['y', 'x']`
- **THEN** `params` returns `['y', 'x']`

#### Scenario: BuiltinFunction falls back to generic params when none provided

- **WHEN** a `BuiltinFunction` with `arity: 1` is constructed without `params`
- **THEN** `params` returns `['x']`

#### Scenario: PiecewiseFunction returns piecewise label for both getters

- **WHEN** `definitionDisplay` or `inverseDisplay` is accessed on a
  `PiecewiseFunction`
- **THEN** the result is `"piecewise linear function"`

### Requirement: FreeformNotifier exposes a single evaluate() entry point

`FreeformNotifier` SHALL expose `evaluate(String input, String output)` as its
sole evaluation method.  The methods `evaluateSingle` and `evaluateConversion`
SHALL be removed.  `freeform_screen.dart` SHALL call `evaluate()` directly with
both field values (passing an empty string when the output field is empty).

#### Scenario: evaluate with empty input clears to idle

- **WHEN** `evaluate("", "")` is called
- **THEN** state becomes `EvaluationIdle`

#### Scenario: evaluate delegates to single-expression path when output is empty

- **WHEN** `evaluate("5 km", "")` is called
- **THEN** state reflects the evaluated result of `"5 km"`

#### Scenario: evaluate delegates to conversion path when both fields are expressions

- **WHEN** `evaluate("5 km", "miles")` is called
- **THEN** state reflects the conversion result

#### Scenario: evaluate produces an error when both fields are bare function names

- **WHEN** `evaluate("tempF", "tempC")` is called (both parse to `FunctionNameNode`)
- **THEN** state is `EvaluationError`

#### Scenario: DefinitionRequestNode in input with non-empty output falls back to conversion

- **WHEN** `evaluate("cal", "J")` is called and `cal` is a bare unit name
- **THEN** state reflects the conversion of `1 cal` to `J`

#### Scenario: DefinitionRequestNode in output field falls back to conversion

- **WHEN** `evaluate("5 km", "m")` is called and `m` parses as
  `DefinitionRequestNode`
- **THEN** state reflects the conversion of `5 km` to `m`

### Requirement: Bare function name input shows function definition

When the input field parses to `FunctionNameNode(f, inverse: false)` and the
output field is empty, the system SHALL display the forward definition of
function `f`.

The resulting state SHALL be `FunctionDefinitionResult`.  The display SHALL show
`f.definitionDisplay` when non-null, or `"<not available>"` as a fallback when
it is null.

#### Scenario: Defined function name input shows definition string

- **WHEN** `evaluate("tempF", "")` is called and `tempF` is a `DefinedFunction`
  with `forward: "x * 9|5 + 32"`
- **THEN** state is `FunctionDefinitionResult` with `label: "tempF(x) ="` and
  `expression: "x * 9|5 + 32"`

#### Scenario: Builtin function name input shows built-in label

- **WHEN** `evaluate("sin", "")` is called and `sin` is a `BuiltinFunction`
- **THEN** state is `FunctionDefinitionResult` with `label: "sin(x) ="` and
  `expression: "<built-in function sin>"`

### Requirement: Bare inverse function name input shows inverse expression

When the input field parses to `FunctionNameNode(f, inverse: true)` and the
output field is empty, the system SHALL display the inverse expression of
function `f`.

The resulting state SHALL be `FunctionDefinitionResult`.  The `label` field
SHALL be formatted as `"~f ="` (without parameter list).  The `expression`
field SHALL be `f.inverseDisplay`.

#### Scenario: Defined function with inverse shows inverse string

- **WHEN** `evaluate("~tempF", "")` is called and `tempF` has
  `inverse: "(x - 32) * 5|9"`
- **THEN** state is `FunctionDefinitionResult` with `label: "~tempF ="` and
  `expression: "(x - 32) * 5|9"`

#### Scenario: Function without inverse shows fallback message

- **WHEN** `evaluate("~sin", "")` is called and `sin` has no inverse
- **THEN** state is `FunctionDefinitionResult` with `label: "~sin ="` and
  `expression: "no inverse defined"`

### Requirement: Bare function name output applies inverse conversion

When the input field parses to an `ExpressionNode` and the output field parses
to `FunctionNameNode(f, inverse: false)`, the system SHALL evaluate the input
expression to a `Quantity`, then call `f.callInverse([inputQty])` and display
the numeric result.

#### Scenario: Function name output applies inverse to input quantity

- **WHEN** `evaluate("tempF(212)", "tempC")` is called
- **THEN** the input `tempF(212)` is evaluated, then `tempC.callInverse()` is
  applied, and the result is displayed as a `ConversionSuccess` (or equivalent
  numeric result state)

#### Scenario: Function without inverse in output field produces error

- **WHEN** `evaluate("5 km", "sin")` is called and `sin` has no inverse
- **THEN** state is `EvaluationError` with an appropriate message

### Requirement: Inverse-flagged function name in output field produces an error

When the output field parses to `FunctionNameNode(f, inverse: true)`, the
system SHALL set state to `EvaluationError` with a message indicating that
`~funcName` is not valid as a conversion target.

#### Scenario: ~funcName in output field is rejected

- **WHEN** `evaluate("5 km", "~tempC")` is called
- **THEN** state is `EvaluationError`

### Requirement: FunctionDefinitionResult is an EvaluationResult subtype

One new subtype of `EvaluationResult` SHALL be added:

- `FunctionDefinitionResult(label: String, expression: String?)`

`label` is a pre-formatted display string constructed by the provider (e.g.
`"tempF(x) ="` for a forward definition, `"~tempF ="` for an inverse).
`expression` holds the display string from `definitionDisplay` or
`inverseDisplay`; it is `null` only when the display is not representable
(see `UnitaryFunction.definitionDisplay` contract).

`FunctionDefinitionResult` SHALL participate in the existing exhaustive
`switch` in `ResultDisplay`.  `ResultDisplay` SHALL display `expression` when
non-null, or `"<not available>"` as a fallback when it is null.

#### Scenario: ResultDisplay renders FunctionDefinitionResult with a definition string

- **WHEN** `ResultDisplay` receives `FunctionDefinitionResult(label: "tempF(x) =", expression: "x * 9|5 + 32")`
- **THEN** the widget displays `"tempF(x) ="` and `"x * 9|5 + 32"`

#### Scenario: ResultDisplay renders FunctionDefinitionResult with null expression

- **WHEN** `ResultDisplay` receives `FunctionDefinitionResult(label: "unknown(x) =", expression: null)`
- **THEN** the widget displays the label and `"<not available>"`

#### Scenario: ResultDisplay renders inverse FunctionDefinitionResult

- **WHEN** `ResultDisplay` receives `FunctionDefinitionResult(label: "~tempF =", expression: "(x - 32) * 5|9")`
- **THEN** the widget displays `"~tempF ="` and `"(x - 32) * 5|9"`

#### Scenario: ResultDisplay renders inverse FunctionDefinitionResult with no-inverse message

- **WHEN** `ResultDisplay` receives `FunctionDefinitionResult(label: "~sin =", expression: "no inverse defined")`
- **THEN** the widget displays `"~sin ="` and `"no inverse defined"`
