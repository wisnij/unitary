## ADDED Requirements


### Requirement: Piecewise entry parsing
The importer library SHALL recognise a definition whose name token contains `[`
as a piecewise-linear function definition.  It SHALL parse:

- `id` — the name text before `[`
- `outputUnit` — the text between `[` and `]`
- `noerror` — `true` if the first token of the definition text is the literal
  string `"noerror"`; `false` otherwise
- `points` — the remaining tokens of the definition text, interpreted as
  alternating x and y `double` values forming a list of `(x, y)` pairs

The entry SHALL be produced with `type: "piecewise"` and SHALL NOT be placed in
the `"unsupported"` section.

#### Scenario: Piecewise definition is detected and parsed
- **WHEN** the unit name contains `[` (e.g., `gasmark[degR]`)
- **THEN** `type` is `"piecewise"`, `id` is `"gasmark"`, and `outputUnit` is `"degR"`

#### Scenario: Control points are parsed as (x, y) pairs
- **WHEN** the definition text (after stripping `noerror`) contains an even
  number of numeric tokens
- **THEN** `points` is a list of `[x, y]` pairs in the order they appear

#### Scenario: noerror flag is detected
- **WHEN** the first token of the definition text is `"noerror"`
- **THEN** `noerror` is `true` and `"noerror"` is not included in the points

#### Scenario: noerror flag is absent
- **WHEN** the definition text does not begin with `"noerror"`
- **THEN** `noerror` is `false` and all tokens are parsed as control-point values

---

### Requirement: Piecewise function code generation
The codegen library SHALL emit a `registerPiecewiseFunctions(UnitRepository
repo)` function for entries with `"type": "piecewise"`.  For each such entry,
it SHALL:

- Resolve the output unit at registration time via
  `ExpressionParser(repo: repo).evaluate(outputUnit)`
- Construct a `PiecewiseFunction` with `id`, `outputFactor` (resolved value),
  `outputDimension` (resolved dimension), `noerror`, and `points`
- Register it via `repo.registerFunction(...)`

`registerPiecewiseFunctions` SHALL be called from
`UnitRepository.withPredefinedUnits()` after `registerPredefinedUnits` and
`registerBuiltinFunctions`.

#### Scenario: Piecewise function is emitted correctly
- **WHEN** an entry has `"type": "piecewise"`
- **THEN** the output contains a `PiecewiseFunction(id: '<id>', ...)` call
  registered via `repo.registerFunction()`
- **AND** the output unit is resolved at registration time, not hardcoded

#### Scenario: Piecewise entries are not emitted as unit registrations
- **WHEN** an entry has `"type": "piecewise"`
- **THEN** no `repo.register(...)` call is emitted for that entry


## MODIFIED Requirements


### Requirement: GNU Units file parsing
The importer library SHALL parse a GNU Units definitions file string into a list
of typed entries. It SHALL handle blank lines, `#` comments (including inline),
line continuations (`\` at end of line), and `!` directives. Each parsed entry
SHALL record its source filename and 1-based line number.

#### Scenario: Blank lines and comments are ignored
- **WHEN** the input contains blank lines or lines whose first non-whitespace
  character is `#`
- **THEN** no entries are produced for those lines

#### Scenario: Inline comments are stripped
- **WHEN** a definition line contains a `#` character after the unit content
- **THEN** the definition is the text before the `#`, trimmed of whitespace

#### Scenario: Line continuation joins lines
- **WHEN** a line ends with `\`
- **THEN** the backslash and the following newline are removed and parsing
  continues as if the two lines were one

#### Scenario: Conditional directive blocks are evaluated
- **WHEN** a `!utf8` / `!endutf8` block is encountered
- **THEN** its contents are included (UTF-8 is enabled)

#### Scenario: Locale directives match our locale
- **WHEN** a `!locale en_US` / `!endlocale` block is encountered
- **THEN** its contents are included; other locale blocks are skipped

#### Scenario: Var directives are evaluated against settings
- **WHEN** a `!var VARNAME values...` / `!endvar` block is encountered
- **THEN** its contents are included only if the effective variable value is in
  the listed values; `!varnot VARNAME values...` includes contents when the
  variable is NOT in the list
- **AND** the effective settings are `UNITS_SYSTEM=si` and `UNITS_ENGLISH=US`

#### Scenario: Non-definition directive lines produce no entries
- **WHEN** a `!set`, `!message`, `!prompt`, or `!include` directive is
  encountered
- **THEN** no unit entry is produced for that line

#### Scenario: Prefix entry is detected
- **WHEN** the unit name token ends with `-` (e.g., `kilo-`)
- **THEN** the `-` is stripped from the id, `type` is set to `"prefix"`, and
  `definition` is set to the remaining text on the line

#### Scenario: Primitive unit is detected
- **WHEN** the definition token is exactly `!`
- **THEN** `type` is `"primitive"` and `isDimensionless` is `false`

#### Scenario: Dimensionless primitive is detected
- **WHEN** the definition token is `!dimensionless`
- **THEN** `type` is `"primitive"` and `isDimensionless` is `true`

#### Scenario: Alias is detected
- **WHEN** the definition is a single bare identifier AND that identifier is
  already in the set of all unit IDs collected from the file
- **THEN** `type` is `"alias"` and `target` is that identifier
- **AND** if the definition is a single bare identifier but NOT in the known
  ID set (e.g., `kilometer` which is a prefix+unit compound), `type` is
  `"derived"` instead

#### Scenario: Derived unit is detected
- **WHEN** the definition is anything other than `!`, `!dimensionless`, a
  known-alias identifier, or a piecewise / nonlinear pattern
- **THEN** `type` is `"derived"` and `definition` holds the expression text

#### Scenario: Unsupported (nonlinear) unit is detected
- **WHEN** the unit name contains `(` (function-argument syntax, e.g.,
  `tempC(x)`)
- **THEN** `type` is `"unsupported"` and `reason` is `"nonlinear_definition"`

#### Scenario: Piecewise linear unit is parsed (not unsupported)
- **WHEN** the unit name contains `[` (piecewise linear table syntax, e.g.,
  `gasmark[degR]`)
- **THEN** `type` is `"piecewise"` (see "Piecewise entry parsing" requirement)
- **AND** the entry is NOT placed in the unsupported section

#### Scenario: Source metadata is recorded
- **WHEN** any entry is parsed
- **THEN** the entry records `gnuUnitsSource` (the normalized source line
  after comment stripping and whitespace normalization) and `source` with
  `file` (the provided filename) and `line` (the 1-based line number of the
  first line of the entry)

---

### Requirement: Serialize parsed entries to JSON
The importer library SHALL serialize a list of parsed GNU entries into a JSON
map with three sections: `"units"`, `"prefixes"`, and `"unsupported"`. The
output SHALL contain only importer-owned fields; no pass-through fields
(description, aliases, category) are included.

#### Scenario: Parsed entries are placed in the correct section
- **WHEN** `entriesToJson()` is called with a list of entries
- **THEN** prefix-namespace entries (whose source name ended with `-`) appear
  under `"prefixes"`, unsupported entries appear under `"unsupported"`, and
  all other entries (including piecewise) appear under `"units"`

#### Scenario: Importer-owned fields are included
- **WHEN** an entry of any type is serialized
- **THEN** the output includes `type`, `gnuUnitsSource`, and `source`
  (`file` + `line`)
- **AND** `definition` is included for all types except `"unsupported"` and
  `"piecewise"`
- **AND** `isDimensionless` is included for `"primitive"` entries
- **AND** `target` is included for `"alias"` entries
- **AND** `reason` is included for `"unsupported"` entries
- **AND** `outputUnit`, `noerror`, and `points` are included for `"piecewise"`
  entries; `yMin` and `yMax` are not serialized (they are recomputed by the
  `PiecewiseFunction` constructor from `points`)

#### Scenario: Pass-through fields are not emitted
- **WHEN** `entriesToJson()` produces output
- **THEN** the output does not contain `description`, `aliases`, or `category`
  fields

---

### Requirement: Dart code generation from JSON
The codegen library SHALL read a `units.json` map and produce a valid
`predefined_units.dart` source string with `const` Dart unit objects and
piecewise function registrations.

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

#### Scenario: Affine unit is emitted correctly
- **WHEN** an entry has `"type": "affine"`
- **THEN** the output contains
  `const AffineUnit(id: '<id>', factor: <factor>, offset: <offset>, baseUnitId: '<baseUnitId>', ...)` registered via `repo.register()`

#### Scenario: Unsupported and alias entries are omitted from unit registration
- **WHEN** an entry has `"type": "unsupported"` or `"type": "alias"`
- **THEN** no unit registration is emitted for that entry

#### Scenario: Piecewise entries are not emitted as unit registrations
- **WHEN** an entry has `"type": "piecewise"`
- **THEN** no `repo.register(...)` call is emitted for that entry
- **AND** the entry is handled by `registerPiecewiseFunctions` instead

#### Scenario: Alias entries are folded into canonical unit aliases
- **WHEN** entries of `"type": "alias"` point (possibly via a chain) to a
  canonical non-alias entry
- **THEN** each alias `id` is appended to the canonical unit's `aliases` list
  in the generated constructor

#### Scenario: Alias resolution is namespace-separated
- **WHEN** the same id appears as a unit alias target and as a prefix alias
  target (e.g., `m` is both meter in units and milli in prefixes)
- **THEN** alias chains are resolved within each namespace independently;
  unit aliases never bleed into prefix aliases and vice versa

#### Scenario: Flat registration functions are emitted
- **WHEN** any code is generated
- **THEN** `registerPredefinedUnits(repo)` calls exactly two private functions:
  `_registerUnits(repo)` and `_registerPrefixes(repo)`
- **AND** all unit entries (primitive, derived, affine) appear inside
  `_registerUnits`, and all prefix entries appear inside `_registerPrefixes`
- **AND** a separate top-level `registerPiecewiseFunctions(repo)` function is
  emitted for piecewise registrations
- **AND** no per-category private functions are emitted

#### Scenario: Aliases and description are included when present
- **WHEN** an entry has a non-empty `"aliases"` list or non-empty `"description"`
- **THEN** the generated constructor includes `aliases: [...]` and/or
  `description: '...'` as named parameters

#### Scenario: Generated file has a do-not-edit header
- **WHEN** any code is generated
- **THEN** the file begins with a comment marking it as generated code
