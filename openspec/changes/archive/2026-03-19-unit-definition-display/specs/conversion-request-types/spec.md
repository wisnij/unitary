## MODIFIED Requirements

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

### Requirement: FreeformNotifier exposes a single evaluate() entry point

`FreeformNotifier` SHALL expose `evaluate(String input, String output)` as its
sole evaluation method.  The methods `evaluateSingle` and `evaluateConversion`
SHALL be removed.  `freeform_screen.dart` SHALL call `evaluate()` directly with
both field values (passing an empty string when the output field is empty).

When `inputNode` is a `DefinitionRequestNode` and `outputNode` is non-null
(output field is non-empty), the input SHALL be re-parsed as a plain expression
via `parseExpression()` and the standard conversion path SHALL proceed.

When `outputNode` is a `DefinitionRequestNode` (bare unit or prefix name in
the output field), it SHALL be re-parsed as a plain expression via
`parseExpression()` before proceeding to the conversion path.

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
