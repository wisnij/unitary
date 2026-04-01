# Delta: conversion-request-types

## ADDED Requirements

### Requirement: ReciprocalConversionSuccess is an EvaluationResult subtype

A new subtype of `EvaluationResult` SHALL be added:

```
ReciprocalConversionSuccess({
  required String reciprocalInputLabel,
  required String formattedResult,
  required String formattedReciprocal,
  required String outputUnit,
})
```

`reciprocalInputLabel` is the pre-formatted display string for the inverted
input (e.g. `"1 / mph"` or `"1 / (mile/hour)"`).  `formattedResult` is the
primary value line (e.g. `"= 2.2369363 s/m"`).  `formattedReciprocal` is the
secondary value line (e.g. `"= (1 / 0.44704) s/m"`).  `outputUnit` is the raw
output unit string as entered by the user.

`ReciprocalConversionSuccess` SHALL participate in all exhaustive `switch`
statements over `EvaluationResult`, including in `ResultDisplay`.

#### Scenario: ReciprocalConversionSuccess stores all fields

- **WHEN** `ReciprocalConversionSuccess(reciprocalInputLabel: "1 / mph", formattedResult: "= 2.2369363 s/m", formattedReciprocal: "= (1 / 0.44704) s/m", outputUnit: "s/m")` is constructed
- **THEN** all four fields are accessible with the provided values

#### Scenario: Exhaustive switch over EvaluationResult must cover ReciprocalConversionSuccess

- **WHEN** a `switch` statement covers every direct subtype of `EvaluationResult` including `ReciprocalConversionSuccess`
- **THEN** the Dart analyzer accepts it without a wildcard or default arm

#### Scenario: Exhaustive switch missing ReciprocalConversionSuccess is a compile error

- **WHEN** a `switch` statement over `EvaluationResult` omits `ReciprocalConversionSuccess`
- **THEN** the Dart analyzer reports a non-exhaustive switch error
