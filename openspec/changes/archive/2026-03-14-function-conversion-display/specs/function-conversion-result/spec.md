## ADDED Requirements

### Requirement: FunctionConversionResult is an EvaluationResult subtype

A new subtype of `EvaluationResult` SHALL be added:

```
FunctionConversionResult({required String functionName, required String formattedValue})
```

`functionName` is the name of the function as entered by the user in the output
field (e.g. `"tempC"` or an alias such as `"tempcelsius"`).  It reflects the
user's input verbatim, not the function's canonical id.  `formattedValue` is the formatted result of the inverse call,
including the canonical dimension label when the result is dimensioned (e.g.
`"20"` for a dimensionless result, `"2.0000006 m"` for a length result).

`FunctionConversionResult` SHALL participate in all exhaustive `switch`
statements over `EvaluationResult`.

#### Scenario: FunctionConversionResult stores name and value

- **WHEN** `FunctionConversionResult(functionName: "tempC", formattedValue: "20")` is constructed
- **THEN** `result.functionName == "tempC"` and `result.formattedValue == "20"`

### Requirement: FreeformNotifier produces FunctionConversionResult for function-name output

When the output field parses to `FunctionNameNode(f, inverse: false)` and the
inverse application of function `f` to the evaluated input quantity succeeds,
`FreeformNotifier.evaluate` SHALL set state to
`FunctionConversionResult(functionName: <name as entered in the output field>, formattedValue: <formatted result>)`.
It SHALL NOT set state to `EvaluationSuccess` or `ConversionSuccess` in this
case.  The `functionName` field SHALL be the user's verbatim input (e.g. an
alias), not the canonical function id.

#### Scenario: Function name output produces FunctionConversionResult with dimensionless result

- **WHEN** `evaluate("tempF(68)", "tempC")` is called and `tempC` is a registered function with an inverse
- **THEN** state is `FunctionConversionResult` with `functionName: "tempC"` and `formattedValue` equal to the formatted inverse result (e.g. `"20"`)

#### Scenario: Function name output includes dimension label when result is dimensioned

- **WHEN** `evaluate("stdatmTH(2 m)", "stdatmT")` is called and `stdatmT` is a registered function with an inverse that returns a length
- **THEN** state is `FunctionConversionResult` with `functionName: "stdatmT"` and `formattedValue` containing the unit label (e.g. `"2.0000006 m"`)

#### Scenario: Function alias in output field uses the alias as the display name

- **WHEN** `evaluate("tempF(68)", "tempcelsius")` is called and `tempcelsius` is an alias for a registered function with an inverse
- **THEN** state is `FunctionConversionResult` with `functionName: "tempcelsius"` (not the canonical id)

#### Scenario: Function without inverse in output field still produces error

- **WHEN** `evaluate("5 km", "sin")` is called and `sin` has no inverse
- **THEN** state is `EvaluationError`

### Requirement: ResultDisplay renders FunctionConversionResult as functionName(value)

`ResultDisplay` SHALL render `FunctionConversionResult` by composing
`functionName` and `formattedValue` into the string `"functionName(formattedValue)"`
(e.g. `"tempC(20)"`).  The string SHALL be displayed with the same primary-color,
bold styling used for `EvaluationSuccess`.  No reciprocal row SHALL be shown.

#### Scenario: ResultDisplay renders FunctionConversionResult with composed string

- **WHEN** `ResultDisplay` receives `FunctionConversionResult(functionName: "tempC", formattedValue: "20")`
- **THEN** the widget displays the text `"tempC(20)"` in the primary result style

#### Scenario: ResultDisplay renders FunctionConversionResult with dimensioned value

- **WHEN** `ResultDisplay` receives `FunctionConversionResult(functionName: "stdatmT", formattedValue: "2.0000006 m")`
- **THEN** the widget displays the text `"stdatmT(2.0000006 m)"` in the primary result style

#### Scenario: ResultDisplay does not show a reciprocal row for FunctionConversionResult

- **WHEN** `ResultDisplay` receives `FunctionConversionResult(functionName: "tempC", formattedValue: "20")`
- **THEN** no secondary/reciprocal line is rendered
