# Unit Definition Display

## Purpose

TBD

## Requirements

### Requirement: UnitRepository exposes findPrefix

`UnitRepository` SHALL expose `findPrefix(String name) → PrefixUnit?`.  It
SHALL return the `PrefixUnit` whose `id` or any alias equals `name`, applying
the same plural-stripping fallback used by `findUnit`.  It SHALL return `null`
when no prefix matches.

#### Scenario: findPrefix returns prefix by canonical id

- **WHEN** `findPrefix("kilo")` is called and `kilo` is registered as a prefix
- **THEN** the result is the `PrefixUnit` with `id == "kilo"`

#### Scenario: findPrefix returns prefix by alias

- **WHEN** `findPrefix("k")` is called and `k` is an alias for prefix `kilo`
- **THEN** the result is the `PrefixUnit` with `id == "kilo"`

#### Scenario: findPrefix returns null for unknown name

- **WHEN** `findPrefix("notaprefix")` is called
- **THEN** the result is `null`

#### Scenario: findPrefix returns null for a unit name that is not a prefix

- **WHEN** `findPrefix("meter")` is called and `meter` is a unit but not a prefix
- **THEN** the result is `null`

### Requirement: UnitDefinitionResult is an EvaluationResult subtype

One new subtype of `EvaluationResult` SHALL be added:

```dart
class UnitDefinitionResult extends EvaluationResult {
  final String? aliasLine;
  final String? definitionLine;
  final String formattedResult;
}
```

`aliasLine` is a pre-formatted string (prefixed with `"= "`) shown in small
muted text above the result when the input was not the canonical identifier,
or when the input resolved as a prefix+unit or bare prefix with an alias.
`definitionLine` is a pre-formatted string (prefixed with `"= "`) showing the
unit's definition expression in small muted text; it is `null` for primitive
units, prefix+unit matches, and bare prefixes.  `formattedResult` is a
pre-formatted string (prefixed with `"= "`) showing the fully-resolved
quantity, formatted with the user's current precision and notation settings.

`UnitDefinitionResult` SHALL participate in the exhaustive `switch` in
`ResultDisplay`.

#### Scenario: UnitDefinitionResult is constructed with all fields

- **WHEN** `UnitDefinitionResult(aliasLine: "= calorie_th", definitionLine: "= 4.184 J", formattedResult: "= 4.184 kg m² / s²")` is constructed
- **THEN** all three fields are accessible with the provided values

#### Scenario: UnitDefinitionResult is constructed with null header fields

- **WHEN** `UnitDefinitionResult(aliasLine: null, definitionLine: null, formattedResult: "= 1 m")` is constructed
- **THEN** `aliasLine` and `definitionLine` are null and `formattedResult` is `"= 1 m"`

### Requirement: Bare unit alias input shows canonical ID and definition

When the input field is a bare unit name that is an alias (not the canonical
`unit.id`) and the output field is empty, the provider SHALL produce
`UnitDefinitionResult` where:

- `aliasLine` is `"= <unit.id>"` (the canonical unit ID)
- `definitionLine` is `"= <DerivedUnit.expression>"` when the unit is a
  `DerivedUnit`, or `null` when it is a `PrimitiveUnit`
- `formattedResult` is the fully-resolved quantity formatted with user settings

#### Scenario: Alias for derived unit shows canonical id and definition expression

- **WHEN** `evaluate("cal", "")` is called and `cal` is an alias for `calorie_th`
  which has expression `"4.184 J"`
- **THEN** state is `UnitDefinitionResult` with `aliasLine: "= calorie_th"`,
  `definitionLine: "= 4.184 J"`, and `formattedResult` containing the resolved
  base-unit quantity

#### Scenario: Alias for primitive unit shows canonical id only

- **WHEN** `evaluate("meter", "")` is called and `meter` is an alias for
  primitive unit `m`
- **THEN** state is `UnitDefinitionResult` with `aliasLine: "= m"`,
  `definitionLine: null`, and `formattedResult: "= 1 m"`

### Requirement: Bare canonical unit ID input shows definition only

When the input field is a bare unit name that equals the canonical `unit.id`
(not an alias) and the output field is empty, the provider SHALL produce
`UnitDefinitionResult` where:

- `aliasLine` is `null`
- `definitionLine` is `"= <DerivedUnit.expression>"` when the unit is a
  `DerivedUnit`, or `null` when it is a `PrimitiveUnit`
- `formattedResult` is the fully-resolved quantity formatted with user settings

#### Scenario: Canonical derived unit id shows definition expression only

- **WHEN** `evaluate("calorie_th", "")` is called and `calorie_th` has
  expression `"4.184 J"`
- **THEN** state is `UnitDefinitionResult` with `aliasLine: null`,
  `definitionLine: "= 4.184 J"`, and `formattedResult` containing the resolved
  base-unit quantity

#### Scenario: Canonical primitive unit id shows resolved quantity only

- **WHEN** `evaluate("m", "")` is called and `m` is a primitive unit
- **THEN** state is `UnitDefinitionResult` with `aliasLine: null`,
  `definitionLine: null`, and `formattedResult: "= 1 m"`

### Requirement: Prefix+unit input shows decomposed canonical form

When the input field is a bare identifier that resolves as a known prefix
combined with a known unit (with all aliases and plural forms resolved) and
the output field is empty, the provider SHALL produce `UnitDefinitionResult`
where:

- `aliasLine` is `"= <prefix.id> <unit.id>"` (canonical IDs, space-separated)
- `definitionLine` is `null`
- `formattedResult` is the fully-resolved quantity formatted with user settings

#### Scenario: Prefix+unit alias input shows canonical decomposition

- **WHEN** `evaluate("kmeters", "")` is called and it resolves as prefix `kilo`
  (alias `k`) plus unit `m` (alias `meter`)
- **THEN** state is `UnitDefinitionResult` with `aliasLine: "= kilo m"`,
  `definitionLine: null`, and `formattedResult` containing `m`

#### Scenario: Canonical prefix+unit input shows canonical decomposition

- **WHEN** `evaluate("km", "")` is called and it resolves as prefix `kilo`
  (alias `k`) plus unit `m`
- **THEN** state is `UnitDefinitionResult` with `aliasLine: "= kilo m"`,
  `definitionLine: null`, and `formattedResult: "= 1000 m"`

### Requirement: Bare prefix alias input shows canonical prefix ID and value

When the input field is a bare identifier that resolves as a prefix alias (not
the canonical `prefix.id`) with no following unit, and the output field is
empty, and no unit with the same name is registered, the provider SHALL produce
`UnitDefinitionResult` where:

- `aliasLine` is `"= <prefix.id>"`
- `definitionLine` is `null`
- `formattedResult` is the evaluated scalar value of the prefix formatted with
  user settings

#### Scenario: Prefix alias input shows canonical id and scalar value

- **WHEN** `evaluate("M", "")` is called and `M` is an alias for prefix
  `mega` with value `1000000`, and no unit named `M` is registered
- **THEN** state is `UnitDefinitionResult` with `aliasLine: "= mega"`,
  `definitionLine: null`, and `formattedResult` starting with `"= "`

### Requirement: Bare canonical prefix ID input shows scalar value only

When the input field is a bare identifier that equals the canonical `prefix.id`
with no following unit, and the output field is empty, and no unit with the
same name is registered, the provider SHALL produce `UnitDefinitionResult`
where:

- `aliasLine` is `null`
- `definitionLine` is `null`
- `formattedResult` is the evaluated scalar value of the prefix formatted with
  user settings

#### Scenario: Canonical prefix id input shows scalar value only

- **WHEN** `evaluate("kilo", "")` is called and `kilo` is the canonical prefix
  id with value `1000` and no unit named `kilo` is registered
- **THEN** state is `UnitDefinitionResult` with `aliasLine: null`,
  `definitionLine: null`, and `formattedResult: "= 1000"`

### Requirement: Unit name takes priority over prefix name for definition display

When an identifier resolves as both a registered unit name and a registered
prefix name, the unit definition SHALL be displayed.  The prefix check in
`parseQuery()` is only reached when the unit check returns no match.

#### Scenario: Identifier that is both a unit and a prefix shows unit definition

- **WHEN** `evaluate("M", "")` is called and `M` is registered as both a unit
  and a prefix
- **THEN** state is `UnitDefinitionResult` reflecting the unit's definition, not
  the prefix's scalar value

### Requirement: ResultDisplay renders UnitDefinitionResult

`ResultDisplay` SHALL render `UnitDefinitionResult` as a column containing:

- `aliasLine` text at fontSize 14 in `onSurfaceVariant` color, when non-null,
  followed by a 4 px spacer
- `definitionLine` text at fontSize 14 in `onSurfaceVariant` color, when
  non-null, followed by a 4 px spacer
- `formattedResult` text at fontSize 20, `FontWeight.w500`, in `primary` color

The container border color SHALL be `colorScheme.primary`.

#### Scenario: ResultDisplay renders all three lines

- **WHEN** `ResultDisplay` receives `UnitDefinitionResult(aliasLine: "= calorie_th", definitionLine: "= 4.184 J", formattedResult: "= 4.184 kg m² / s²")`
- **THEN** the widget displays all three lines in order, with the first two in
  small muted text and the last in large primary text

#### Scenario: ResultDisplay renders definition line and result only

- **WHEN** `ResultDisplay` receives `UnitDefinitionResult(aliasLine: null, definitionLine: "= 4.184 J", formattedResult: "= 4.184 kg m² / s²")`
- **THEN** the widget displays two lines: the definition line in small muted
  text and the result in large primary text

#### Scenario: ResultDisplay renders result only when both header lines are null

- **WHEN** `ResultDisplay` receives `UnitDefinitionResult(aliasLine: null, definitionLine: null, formattedResult: "= 1 m")`
- **THEN** the widget displays only the result line in large primary text
