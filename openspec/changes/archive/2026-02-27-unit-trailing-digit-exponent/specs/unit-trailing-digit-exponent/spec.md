## ADDED Requirements

### Requirement: Single trailing digit 2–9 is an exponent shorthand
A unit identifier that ends with a single digit in the range 2–9, where that digit is
not preceded by an underscore, SHALL be parsed as if the digit were an explicit exponent
using `^`. The identifier before the digit is used as the unit name and the digit as the
exponent value.

#### Scenario: Simple unit with trailing digit
- **WHEN** the expression `m2` is parsed
- **THEN** it produces the same AST as `m^2`

#### Scenario: Multi-character unit with trailing digit
- **WHEN** the expression `centimeters3` is parsed
- **THEN** it produces the same AST as `centimeters^3`

#### Scenario: Unit with trailing digit evaluates correctly
- **WHEN** the expression `5 m2` is evaluated with a unit repository
- **THEN** it produces the same `Quantity` as `5 m^2`

#### Scenario: Trailing digit applies only to the immediately preceding identifier
- **WHEN** the expression `m2 s2` is parsed
- **THEN** it produces the same AST as `m^2 * s^2` (each identifier handled independently)

---

### Requirement: Trailing digits 0 and 1 are part of the identifier name
A unit identifier that ends with digit 0 or 1 (including multi-digit trailing runs
ending in 0 or 1), where those digits are not preceded by an underscore, SHALL be
treated as part of the identifier name, not as an exponent.

#### Scenario: Identifier ending in 0
- **WHEN** the expression `x0` is parsed
- **THEN** it produces `UnitNode('x0')`, not an exponent expression

#### Scenario: Identifier ending in 1
- **WHEN** the expression `y1` is parsed
- **THEN** it produces `UnitNode('y1')`, not an exponent expression

#### Scenario: Multi-digit trailing run ending in 0
- **WHEN** the expression `x10` is parsed
- **THEN** it produces `UnitNode('x10')`, not an exponent expression

#### Scenario: Multi-digit trailing run ending in 1
- **WHEN** the expression `y21` is parsed
- **THEN** it produces `UnitNode('y21')`, not an exponent expression

#### Scenario: Long numeric suffix ending in 0
- **WHEN** the expression `k1250` is parsed
- **THEN** it produces `UnitNode('k1250')`, not an exponent expression

---

### Requirement: Multiple bare trailing digits ending in 2–9 are a parse error
A unit identifier that ends with two or more consecutive digits not preceded by an
underscore, where the last digit is in the range 2–9, SHALL cause a `ParseException`
to be thrown. The exception message SHALL describe the error and reference the
underscore convention for numeric suffixes.

#### Scenario: Two bare trailing digits ending in non-0/1
- **WHEN** the expression `u235` is parsed
- **THEN** a `ParseException` is thrown

#### Scenario: Two bare trailing digits ending in non-0/1 (variant)
- **WHEN** the expression `m23` is parsed
- **THEN** a `ParseException` is thrown

#### Scenario: Digit run not adjacent to underscore
- **WHEN** the expression `a_b123` is parsed (digit run `123` preceded by `b`, not `_`)
- **THEN** a `ParseException` is thrown

---

### Requirement: Digits preceded by underscore are always part of the identifier
Digits that immediately follow an underscore in a unit identifier SHALL always be
treated as part of the identifier name, regardless of count or value. This applies to
the entire digit run following the underscore.

#### Scenario: Single digit after underscore
- **WHEN** the expression `m_2` is parsed
- **THEN** it produces `UnitNode('m_2')`, not an exponent expression

#### Scenario: Multiple digits after underscore
- **WHEN** the expression `u_235` is parsed
- **THEN** it produces `UnitNode('u_235')`, not a parse error or exponent expression

#### Scenario: Digits in the middle of an identifier (not at end)
- **WHEN** the expression `a_123b` is parsed
- **THEN** it produces `UnitNode('a_123b')`, not an exponent expression or error

#### Scenario: Non-underscore digit embedded before a trailing alpha character
- **WHEN** the expression `m2s` is parsed
- **THEN** it produces `UnitNode('m2s')` as a single unit identifier (the `2` is not
  trailing, so no exponent rule applies)

---

### Requirement: Whitespace separates digit from identifier (implicit multiply, not exponent)
When a digit is separated from a preceding unit identifier by whitespace, it SHALL be
treated as implicit multiplication, not as an exponent. Exponent shorthand applies only
when the digit immediately follows the identifier with no intervening whitespace.

#### Scenario: Space between unit and digit
- **WHEN** the expression `m 2` is parsed
- **THEN** it produces the same AST as `m * 2` (implicit multiply), not `m^2`
