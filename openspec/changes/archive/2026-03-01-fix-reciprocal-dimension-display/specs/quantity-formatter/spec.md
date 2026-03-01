## ADDED Requirements

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
