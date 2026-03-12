## REMOVED Requirements

### Requirement: Dart code generation from JSON — Affine unit scenario
**Reason**: `AffineUnit` is removed; affine units are superseded by defined
functions, which are already covered by existing scenarios.  No affine entries
exist in `units.json`.
**Migration**: None — temperature conversions are handled as defined functions.

#### Scenario: Affine unit is emitted correctly
- **WHEN** an entry has `"type": "affine"`
- **THEN** the output contains
  `const AffineUnit(id: '<id>', factor: <factor>, offset: <offset>, baseUnitId: '<baseUnitId>', ...)` registered via `repo.register()`

## MODIFIED Requirements

### Requirement: Dart code generation from JSON
The codegen library SHALL read a `units.json` map and produce a valid
`predefined_units.dart` source string with `const` Dart unit objects,
piecewise function registrations, and defined function registrations.

#### Scenario: Primitive unit is emitted correctly
- **WHEN** an entry has `"type": "primitive"`
- **THEN** the output contains `const PrimitiveUnit(id: '<id>', ...)` registered
  via `repo.register()`; `isDimensionless: true` is included only when the
  JSON field is `true`

#### Scenario: Derived unit is emitted correctly
- **WHEN** an entry has `"type": "derived"`
- **THEN** the output contains
  `const DerivedUnit(id: '<id>', expression: '<definition>', ...)` registered
  via `repo.register()`

#### Scenario: Prefix unit is emitted correctly
- **WHEN** an entry has `"type": "prefix"`
- **THEN** the output contains
  `const PrefixUnit(id: '<id>', expression: '<definition>', ...)` registered
  via `repo.registerPrefix()`

#### Scenario: Unsupported and alias entries are omitted from unit registration
- **WHEN** an entry has `"type": "unsupported"` or `"type": "alias"`
- **THEN** no unit registration is emitted for that entry

#### Scenario: Piecewise entries are not emitted as unit registrations
- **WHEN** an entry has `"type": "piecewise"`
- **THEN** no `repo.register(...)` call is emitted for that entry
- **AND** the entry is handled by `registerPiecewiseFunctions` instead

#### Scenario: defined_function entries are not emitted as unit registrations
- **WHEN** an entry has `"type": "defined_function"`
- **THEN** no `repo.register(...)` call is emitted for that entry
- **AND** the entry is handled by `registerDefinedFunctions` instead

#### Scenario: Alias entries are folded into canonical unit aliases
- **WHEN** entries of `"type": "alias"` point (possibly via a chain) to a
  canonical non-alias entry
- **THEN** each alias `id` is appended to the canonical unit's `aliases` list
  in the generated constructor

#### Scenario: function_alias entries are folded into canonical function aliases
- **WHEN** entries of `"type": "function_alias"` point to a canonical
  `defined_function` entry
- **THEN** each alias `id` is appended to the target function's `aliases` list
  in the generated `DefinedFunction` constructor

#### Scenario: Alias resolution is namespace-separated
- **WHEN** the same id appears as a unit alias target and as a prefix alias
  target (e.g., `m` is both meter in units and milli in prefixes)
- **THEN** alias chains are resolved within each namespace independently;
  unit aliases never bleed into prefix aliases and vice versa

#### Scenario: Flat registration functions are emitted
- **WHEN** any code is generated
- **THEN** `registerPredefinedUnits(repo)` calls exactly two private functions:
  `_registerUnits(repo)` and `_registerPrefixes(repo)`
- **AND** all unit entries (primitive, derived) appear inside `_registerUnits`,
  and all prefix entries appear inside `_registerPrefixes`
- **AND** a separate top-level `registerPiecewiseFunctions(repo)` function is
  emitted for piecewise registrations
- **AND** a separate top-level `registerDefinedFunctions(repo)` function is
  emitted for defined_function registrations
- **AND** no per-category private functions are emitted

#### Scenario: Aliases and description are included when present
- **WHEN** an entry has a non-empty `"aliases"` list or non-empty `"description"`
- **THEN** the generated constructor includes `aliases: [...]` and/or
  `description: '...'` as named parameters
