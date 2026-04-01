# Capability: reciprocal-conversion

## Purpose

When a freeform conversion request is made and the input and output dimensions
are exact reciprocals of each other, the system performs the conversion on
`1/input` instead of returning a dimension-mismatch error, and presents the
result with a "reciprocal conversion" notice.

## Requirements

### Requirement: Dimension.isReciprocalOf detects reciprocal dimensions

`Dimension` SHALL expose `bool isReciprocalOf(Dimension other)` that returns
`true` when `this == other.power(-1)` (all exponents of `other` negated).  A
dimensionless dimension is its own reciprocal.

#### Scenario: isReciprocalOf returns true for reciprocal dimensions

- **WHEN** `Dimension({'s': 1, 'm': -1}).isReciprocalOf(Dimension({'m': 1, 's': -1}))` is called
- **THEN** the result is `true`

#### Scenario: isReciprocalOf returns false for non-reciprocal dimensions

- **WHEN** `Dimension({'m': 1}).isReciprocalOf(Dimension({'m': 1}))` is called
- **THEN** the result is `false`

#### Scenario: isReciprocalOf returns false for non-conformable, non-reciprocal dimensions

- **WHEN** `Dimension({'m': 1}).isReciprocalOf(Dimension({'kg': 1}))` is called
- **THEN** the result is `false`

#### Scenario: dimensionless dimension is its own reciprocal

- **WHEN** `Dimension.dimensionless.isReciprocalOf(Dimension.dimensionless)` is called
- **THEN** the result is `true`

### Requirement: FreeformNotifier detects reciprocal dimensions and performs reciprocal conversion

When `_evaluateConversion` determines that the input and output quantities are
not conformable, it SHALL additionally check whether their dimensions are
reciprocals (applying the same dimensionless-unit stripping used by
`_isConversionConformable`).  When reciprocal dimensions are detected, the
system SHALL compute `convertedValue = 1 / (inputQty.value * outputQty.value)`,
set `reciprocalValue = inputQty.value * outputQty.value`, and set state to
`ReciprocalConversionSuccess` rather than `EvaluationError`.

The conformability check (direct conversion) SHALL take priority: the
reciprocal path is only reached when the normal conversion fails.

#### Scenario: Reciprocal dimensions produce ReciprocalConversionSuccess

- **WHEN** `evaluate("mph", "s/m")` is called with `mph` and `s/m` as registered units
- **THEN** state is `ReciprocalConversionSuccess` (not `EvaluationError`)

#### Scenario: Conformable dimensions still produce ConversionSuccess

- **WHEN** `evaluate("mph", "m/s")` is called
- **THEN** state is `ConversionSuccess` (conformability check takes priority)

#### Scenario: Non-reciprocal, non-conformable dimensions still produce EvaluationError

- **WHEN** `evaluate("mph", "kg")` is called
- **THEN** state is `EvaluationError`

#### Scenario: Reciprocal conversion value is mathematically correct

- **WHEN** `evaluate("mph", "s/m")` is called
- **THEN** the `convertedValue` stored in state equals `1.0 / (mphInBaseUnits * smInBaseUnits)` which is approximately `2.2369363`

### Requirement: Reciprocal input label wraps expressions containing division in parentheses

`FreeformNotifier` SHALL construct the `reciprocalInputLabel` field of
`ReciprocalConversionSuccess` from the trimmed raw input string as follows:
when the trimmed input string contains a `/` character, it SHALL be wrapped in
parentheses; otherwise it SHALL be used as-is.  The label SHALL be formatted as
`"1 / <expr>"` or `"1 / (<expr>)"`.

#### Scenario: Simple unit name produces label without parentheses

- **WHEN** the input field contains `"mph"` and a reciprocal conversion is performed
- **THEN** `reciprocalInputLabel` is `"1 / mph"`

#### Scenario: Division-containing expression produces label with parentheses

- **WHEN** the input field contains `"mile/hour"` and a reciprocal conversion is performed
- **THEN** `reciprocalInputLabel` is `"1 / (mile/hour)"`

#### Scenario: Leading and trailing whitespace is trimmed before checking for division

- **WHEN** the input field contains `"  mph  "` and a reciprocal conversion is performed
- **THEN** `reciprocalInputLabel` is `"1 / mph"` (whitespace stripped, no parens)

### Requirement: ResultDisplay renders ReciprocalConversionSuccess with notice, label, and value lines

`ResultDisplay` SHALL render `ReciprocalConversionSuccess` as a column with
four items in order:

1. A "reciprocal conversion" notice line preceded by an `Icons.info_outline`
   icon, both in `colorScheme.tertiary`.
2. The `reciprocalInputLabel` (e.g. `"1 / mph"`) in `colorScheme.primary`,
   same font size as the secondary value line.
3. The `formattedResult` primary value line in `colorScheme.primary`, bold,
   same style as `ConversionSuccess`'s primary line.
4. The `formattedReciprocal` secondary value line in `colorScheme.onSurfaceVariant`,
   same style as `ConversionSuccess`'s secondary line.

The container border color SHALL be `colorScheme.primary`.

#### Scenario: ResultDisplay renders all four lines for ReciprocalConversionSuccess

- **WHEN** `ResultDisplay` receives `ReciprocalConversionSuccess` with label `"1 / mph"`, result `"= 2.2369363 s/m"`, and reciprocal `"= (1 / 0.44704) s/m"`
- **THEN** the widget displays the notice (with info icon), label, result, and reciprocal lines in that order

#### Scenario: Notice line uses tertiary color with info icon

- **WHEN** `ResultDisplay` receives a `ReciprocalConversionSuccess`
- **THEN** the notice text and leading info icon are both `colorScheme.tertiary`

#### Scenario: Container border uses primary color

- **WHEN** `ResultDisplay` receives a `ReciprocalConversionSuccess`
- **THEN** the container border color is `colorScheme.primary`

#### Scenario: Primary value line uses primary color and bold weight

- **WHEN** `ResultDisplay` receives a `ReciprocalConversionSuccess`
- **THEN** the `formattedResult` line is rendered with `colorScheme.primary` and `FontWeight.w500`
