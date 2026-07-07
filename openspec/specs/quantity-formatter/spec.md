# Quantity Formatter

## Purpose

Specifies the behaviour of the quantity formatter module: `formatQuantity`,
the function responsible for converting a `Quantity` value into a
human-readable string suitable for display in the freeform evaluation UI, and
`formatSpeech`, which rewrites formatted display strings into a
speech-friendly form for screen-reader announcement.


## Requirements

### Requirement: formatQuantity strips leading one from reciprocal dimension strings
When the effective dimension string starts with `"1 /"`, `formatQuantity` SHALL
remove the leading `"1 "` prefix before concatenating the value and the dimension
label, so that quantities with purely reciprocal dimensions are displayed without
a redundant `1`.

#### Scenario: reciprocal dimension with value one
- **WHEN** formatting a quantity with value `1.0` and dimension `{'s': -1}` (canonical `"1 / s"`)
- **THEN** the result SHALL be `"1 / s"`, not `"1 1 / s"`

#### Scenario: reciprocal dimension with value greater than one
- **WHEN** formatting a quantity with value `2.0` and dimension `{'m': -1}` (canonical `"1 / m"`)
- **THEN** the result SHALL be `"2 / m"`, not `"2 1 / m"`

#### Scenario: mixed dimension is unchanged
- **WHEN** formatting a quantity whose canonical representation does not start with `"1 /"`
  (e.g., `"m / s"`, `"kg m / s^2"`, or a plain `"m"`)
- **THEN** the dimension label SHALL be used as-is, without modification

#### Scenario: dimensionless quantity is unchanged
- **WHEN** formatting a dimensionless quantity (canonical representation `"1"`)
- **THEN** the result SHALL contain only the formatted value with no unit label


### Requirement: formatQuantity accepts an optional dimension override
`formatQuantity` SHALL accept an optional named parameter `dimension` of type
`String?`.  When provided, this string SHALL be used as the dimension label
instead of `quantity.dimension.canonicalRepresentation()`.  The reciprocal
stripping rule SHALL apply to the provided string in the same way as to the
canonical representation.

#### Scenario: provided dimension string without leading one is used unchanged
- **WHEN** a caller passes `dimension: "km"` for any quantity
- **THEN** the result SHALL be `"<value> km"` without modification

#### Scenario: provided dimension string starting with "1 /" is stripped
- **WHEN** a caller passes `dimension: "1 / Hz"` for a quantity with value `3.0`
- **THEN** the result SHALL be `"3 / Hz"`, not `"3 1 / Hz"`

#### Scenario: omitted dimension parameter falls back to canonical representation
- **WHEN** no `dimension` argument is supplied
- **THEN** `formatQuantity` SHALL use `quantity.dimension.canonicalRepresentation()`
  as the dimension label (subject to the stripping rule above)


### Requirement: formatSpeech rewrites formatted strings into spoken form

The quantity formatter module SHALL provide a `formatSpeech` function that
rewrites an already-formatted display string into a speech-friendly form for
screen-reader announcement.  The rewrite SHALL apply exactly these
transformations, leaving all other content (including unit names) unchanged:

- `=` SHALL be spoken as "equals"
- `/` SHALL be spoken as "per"
- `^` SHALL be spoken as "to the power"
- `×` SHALL be spoken as "times"
- `*` SHALL be spoken as "times" (never emitted by the value formatters, but
  present in unit and function definition expressions that are spoken)
- `|` (numeric division) SHALL be spoken as "over" (also never emitted by the
  value formatters, but present in definition expressions, e.g. `1|2 m`;
  without the rewrite, default screen-reader punctuation verbosity skips the
  pipe entirely, losing the fraction structure)
- An exponent suffix in the signed form emitted by the value formatters — a
  digit immediately followed by `e`, a `+` or `-` sign, and digits (e.g.
  `1.5e+3`) — SHALL be spoken as "times 10 to the N" for positive exponents
  and "times 10 to the negative N" for negative exponents.

The function SHALL be a pure string transformation with no dependence on
evaluation state, and SHALL return strings without rewritable content
unchanged.

#### Scenario: Symbols worded

- **WHEN** `formatSpeech` is applied to `= 8 kg m / s^2`
- **THEN** the result is `equals 8 kg m per s to the power 2`

#### Scenario: Positive exponent spoken

- **WHEN** `formatSpeech` is applied to `1.5e+3 m`
- **THEN** the result is `1.5 times 10 to the 3 m`

#### Scenario: Negative exponent spoken

- **WHEN** `formatSpeech` is applied to `2.0e-6 s`
- **THEN** the result is `2.0 times 10 to the negative 6 s`

#### Scenario: Unsigned scientific-style text is not treated as an exponent

- **WHEN** `formatSpeech` is applied to a string containing `2e3` with no sign
  character (a form the value formatters never emit)
- **THEN** that substring is left unchanged

#### Scenario: Plain string passes through

- **WHEN** `formatSpeech` is applied to `42 meters`
- **THEN** the result is `42 meters`
