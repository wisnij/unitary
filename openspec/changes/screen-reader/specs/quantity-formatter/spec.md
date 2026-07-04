# Quantity Formatter (delta)

## ADDED Requirements

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
