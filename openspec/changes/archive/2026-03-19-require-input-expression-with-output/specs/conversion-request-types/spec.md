## MODIFIED Requirements

### Requirement: FreeformNotifier exposes a single evaluate() entry point

`FreeformNotifier` SHALL expose `evaluate(String input, String output)` as its
sole evaluation method.  The methods `evaluateSingle` and `evaluateConversion`
SHALL be removed.  `freeform_screen.dart` SHALL call `evaluate()` directly with
both field values (passing an empty string when the output field is empty).

When the output field is non-empty, the input field SHALL be parsed with
`parseExpression` rather than `parseQuery`.  Definition requests (bare unit
names, bare prefix names, bare function names) are only valid when the output
field is empty; when output is non-empty, the input is always treated as an
expression.

#### Scenario: evaluate with empty input clears to idle

- **WHEN** `evaluate("", "")` is called
- **THEN** state becomes `EvaluationIdle`

#### Scenario: evaluate delegates to single-expression path when output is empty

- **WHEN** `evaluate("5 km", "")` is called
- **THEN** state reflects the evaluated result of `"5 km"`

#### Scenario: evaluate delegates to conversion path when both fields are expressions

- **WHEN** `evaluate("5 km", "miles")` is called
- **THEN** state reflects the conversion result

#### Scenario: evaluate produces an error when input is a bare function name and output is non-empty

- **WHEN** `evaluate("tempF", "tempC")` is called
- **THEN** state is `EvaluationError` (input parses as `UnitNode("tempF")` via
  `parseExpression`, which fails evaluation because `tempF` is not a unit)

#### Scenario: bare unit name input with non-empty output converts as expression

- **WHEN** `evaluate("cal", "J")` is called and `cal` is a registered unit
- **THEN** state reflects the conversion of `1 cal` to `J` (input parsed via
  `parseExpression` as `UnitNode("cal")`, evaluating to `1 cal`)

#### Scenario: DefinitionRequestNode in output field falls back to conversion

- **WHEN** `evaluate("5 km", "m")` is called and `m` parses as
  `DefinitionRequestNode`
- **THEN** state reflects the conversion of `5 km` to `m`

#### Scenario: bare unit name input with function name output converts via inverse

- **WHEN** `evaluate("stdtemp", "tempF")` is called, `stdtemp` is a unit that
  evaluates to `273.15 K`, and `tempF` is a registered function with an inverse
- **THEN** state reflects applying `tempF`'s inverse to `273.15 K`, yielding `32`
