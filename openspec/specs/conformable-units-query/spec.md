# Spec: Conformable Units Query

## Purpose

Provide a `ConformableEntry` data class and a `UnitRepository.findConformable`
method that, given a target dimension, return all registered units and functions
whose resolved dimension matches that target, sorted case-insensitively by name.

---

## Requirements

### Requirement: ConformableEntry data class

A `ConformableEntry` class SHALL be defined with the following fields:

- `name` (`String`): the primary registration name (unit/function ID or alias)
- `definitionExpression` (`String?`): the definition expression of the
  underlying `DerivedUnit`, or `null` for non-derived entries
- `functionLabel` (`String?`): a bracketed type label for function entries, or
  `null` for unit entries
- `aliasFor` (`String?`): the primary ID of the unit or function this name is
  an alias for, or `null` if this entry is not an alias

`definitionExpression` and `functionLabel` SHALL be mutually exclusive: at
most one is non-null for any given entry.  `aliasFor` is independent and MAY
be non-null alongside either `definitionExpression` or `functionLabel`.

#### Scenario: ConformableEntry constructed for a derived unit

- **WHEN** `ConformableEntry(name: 'cal', definitionExpression: '4.184 J', functionLabel: null)` is constructed
- **THEN** `name` is `'cal'`, `definitionExpression` is `'4.184 J'`, `functionLabel` is `null`, and `aliasFor` is `null`

#### Scenario: ConformableEntry constructed for a function

- **WHEN** `ConformableEntry(name: 'tempC', definitionExpression: null, functionLabel: '[function]')` is constructed
- **THEN** `name` is `'tempC'`, `definitionExpression` is `null`, `functionLabel` is `'[function]'`, and `aliasFor` is `null`

#### Scenario: ConformableEntry constructed for a primitive unit

- **WHEN** `ConformableEntry(name: 'm', definitionExpression: null, functionLabel: null)` is constructed
- **THEN** `name` is `'m'`, `definitionExpression` is `null`, `functionLabel` is `null`, and `aliasFor` is `null`

#### Scenario: ConformableEntry constructed for an alias

- **WHEN** `ConformableEntry(name: 'metre', aliasFor: 'm')` is constructed
- **THEN** `name` is `'metre'`, `aliasFor` is `'m'`, and `definitionExpression` and `functionLabel` are `null`

### Requirement: UnitRepository.findConformable returns conformable units

`UnitRepository` SHALL expose a `findConformable(Dimension target)` method that
returns a `List<ConformableEntry>` containing one entry for every registered
primary unit (excluding `PrefixUnit`) whose resolved dimension equals `target`,
plus one entry for each alias of every such unit.

Units that throw during resolution SHALL be silently excluded from the result
(along with their aliases).

The returned list SHALL be sorted case-insensitively by `name`.

#### Scenario: Units with matching dimension are returned

- **WHEN** `findConformable` is called with the length dimension
- **THEN** the result contains entries for `m`, `ft`, `km`, and other registered
  length units, sorted case-insensitively by name

#### Scenario: Units with non-matching dimension are excluded

- **WHEN** `findConformable` is called with the length dimension
- **THEN** the result contains no entries for mass units such as `kg` or `lb`

#### Scenario: Prefix units are excluded

- **WHEN** `findConformable` is called with any dimension
- **THEN** the result contains no `PrefixUnit` entries

#### Scenario: Unresolvable units are excluded

- **WHEN** `findConformable` is called and a registered unit throws during
  resolution
- **THEN** that unit is absent from the result and no exception is propagated

#### Scenario: Results are sorted case-insensitively

- **WHEN** `findConformable` returns a list containing entries named `'Torr'`,
  `'atm'`, and `'Pa'`
- **THEN** the order is `'atm'`, `'Pa'`, `'Torr'` (case-insensitive ascending)

### Requirement: findConformable entries for derived units carry the definition expression

For a `DerivedUnit` in the result of `findConformable`, the `ConformableEntry`
SHALL have `definitionExpression` set to the unit's `expression` field and
`functionLabel` set to `null`.

#### Scenario: Derived unit entry has definition expression

- **WHEN** `findConformable` returns an entry for `calorie_th` (a `DerivedUnit`
  with expression `'4.184 J'`)
- **THEN** the entry has `definitionExpression: '4.184 J'` and `functionLabel: null`

### Requirement: findConformable entries for primitive units have no secondary label

For a `PrimitiveUnit` in the result of `findConformable`, the `ConformableEntry`
SHALL have both `definitionExpression` and `functionLabel` set to `null`.

#### Scenario: Primitive unit entry has no secondary fields

- **WHEN** `findConformable` returns an entry for `m` (a `PrimitiveUnit`)
- **THEN** the entry has `definitionExpression: null` and `functionLabel: null`

### Requirement: findConformable includes aliases with aliasFor set

For every conformable unit or function, `findConformable` SHALL also include one
`ConformableEntry` for each of its registered aliases.  Each alias entry SHALL
have:

- `name` set to the alias string
- `aliasFor` set to the primary ID of the unit or function
- `definitionExpression` copied from the primary entry (i.e. the target's
  `expression` if it is a `DerivedUnit`, otherwise `null`)
- `functionLabel` copied from the primary entry (i.e. the function-type label
  if the target is a function, otherwise `null`)

Alias entries sort among the other entries by their alias `name`.

#### Scenario: Unit alias entry has aliasFor set

- **WHEN** `findConformable` returns entries for a `PrimitiveUnit` `m` that has
  alias `'metre'`
- **THEN** the result contains an entry with `name: 'metre'`, `aliasFor: 'm'`,
  `definitionExpression: null`, and `functionLabel: null`

#### Scenario: Derived unit alias carries the target expression

- **WHEN** `findConformable` returns entries for a `DerivedUnit` `byte`
  (expression `'8 bit'`) that has alias `'B'`
- **THEN** the result contains an entry with `name: 'B'`, `aliasFor: 'byte'`,
  and `definitionExpression: '8 bit'`

#### Scenario: Function alias carries the function label

- **WHEN** `findConformable` returns entries for a `UnitaryFunction` `tempC`
  (label `'[function]'`) that has alias `'celsius'`
- **THEN** the result contains an entry with `name: 'celsius'`,
  `aliasFor: 'tempC'`, and `functionLabel: '[function]'`

#### Scenario: Alias entries sort by alias name

- **WHEN** a conformable unit `m` has aliases `'meter'` and `'metre'`
- **THEN** the entries for `'meter'` and `'metre'` appear sorted by those names
  among all other entries

### Requirement: UnitRepository.findConformable returns conformable functions

`findConformable` SHALL also include one entry for every registered primary
function whose `range.quantity.dimension` equals `target`, plus one entry for
each alias of every such function.

Functions with no `range`, or whose `range.quantity` is `null`, SHALL be
excluded.

The function-type label SHALL be:
- `'[piecewise linear function]'` for `PiecewiseFunction` instances
- `'[function]'` for all other `UnitaryFunction` instances

#### Scenario: Function with matching range dimension is included

- **WHEN** `findConformable` is called with the temperature dimension and
  `tempC` is a function with `range.quantity` in Kelvin
- **THEN** the result contains an entry for `tempC` with
  `functionLabel: '[function]'` and `definitionExpression: null`

#### Scenario: PiecewiseFunction with matching range dimension gets piecewise label

- **WHEN** `findConformable` returns an entry for a `PiecewiseFunction` whose
  range dimension matches `target`
- **THEN** the entry has `functionLabel: '[piecewise linear function]'`

#### Scenario: Function with no range is excluded

- **WHEN** a function has `range: null`
- **THEN** it is absent from all `findConformable` results regardless of `target`

#### Scenario: Function with null range quantity is excluded

- **WHEN** a function has `range` present but `range.quantity` is `null`
- **THEN** it is absent from all `findConformable` results regardless of `target`

#### Scenario: Function with non-matching range dimension is excluded

- **WHEN** `findConformable` is called with the length dimension and a function
  has a range dimension of temperature
- **THEN** that function is absent from the result

### Requirement: findConformable results are stable across repeated calls

Calling `findConformable` more than once with the same `target` SHALL return
equivalent results.  Unit resolution work MAY be cached after the first call.

#### Scenario: Repeated calls return equivalent lists

- **WHEN** `findConformable(target)` is called twice with the same `target`
- **THEN** both calls return lists with identical entries in identical order
