## MODIFIED Requirements

### Requirement: Redundant definition line is suppressed

When the definition expression of a `DerivedUnit` evaluates to a formatted
string equivalent to `formattedResult`, the provider SHALL set `definitionLine`
to `null` rather than displaying the same information twice.  Equivalence is
determined by stripping all whitespace from both strings before comparing;
strings that differ only in spacing SHALL be treated as identical.

#### Scenario: Derived unit whose expression equals formatted result omits definition line

- **WHEN** `evaluate("standardtemp", "")` is called and `standardtemp` has
  expression `"273.15 K"` which evaluates to `273.15 K`
- **THEN** state is `UnitDefinitionResult` with `aliasLine: null`,
  `definitionLine: null`, and `formattedResult: "= 273.15 K"`

#### Scenario: Derived unit whose expression matches formatted result up to spacing omits definition line

- **WHEN** `evaluate("mps", "")` is called and `mps` has expression `"1 m/s"`
  and the formatted result is `"= 1 m / s"`
- **THEN** state is `UnitDefinitionResult` with `aliasLine: null`,
  `definitionLine: null`, and `formattedResult: "= 1 m / s"`

#### Scenario: Derived unit whose expression differs meaningfully from formatted result shows definition line

- **WHEN** `evaluate("calorie_th", "")` is called and `calorie_th` has
  expression `"4.184 J"` and the formatted result is `"= 4.184 kg m² / s²"`
- **THEN** state is `UnitDefinitionResult` with `aliasLine: null`,
  `definitionLine: "= 4.184 J"`, and `formattedResult` containing the
  resolved base-unit quantity
