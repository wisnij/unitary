## ADDED Requirements

### Requirement: Nonlinear definition import produces defined_function entries
The importer library SHALL parse a GNU Units nonlinear unit definition line
(unit name containing `(` but not `[`) into a `GnuEntry` with
`type: "defined_function"` rather than `"unsupported"`.

It SHALL extract the following fields using regex-based field extraction (the
optional fields `units=`, `domain=`, `range=`, and `noerror` are
space-delimited tokens that, if present, appear in that order before the
forward expression):

- `id` — the name text before `(`
- `params` — comma-separated parameter names inside the `()`; empty list for a
  zero-arg alias form
- `domainUnits` — unit expression strings extracted from the bracket content of
  `units=[u1,u2,...]` (comma-split of the part before `;`); empty list if
  `units=` is absent or has no domain portion
- `rangeUnit` — unit expression string after `;` in `units=[...;rangeUnit]`;
  `null` if absent
- `domainBounds` — interval strings, one per param, parsed by greedy
  bracket-pair consumption from the `domain=` token; empty list if `domain=`
  is absent
- `rangeBounds` — interval string parsed from the `range=` token; `null` if
  absent
- `noerror` — `true` if the literal token `noerror` is present before the
  expression; `false` otherwise
- `forward` — expression text after all optional tokens, trimmed; the text
  before `;` if an inverse is present
- `inverse` — expression text after `;` in the definition body; `null` if no
  `;` is present

A zero-arg definition `name() target` (no optional fields, single-token body
that is an identifier) SHALL be treated as a function alias: the importer SHALL
emit a `GnuEntry` with `type: "function_alias"` and `target` set to the
identifier.

#### Scenario: Basic single-param function is parsed
- **WHEN** the input line is `circlearea(r) units=[m;m^2] range=[0,) pi r^2 ; sqrt(circlearea/pi)`
- **THEN** `type` is `"defined_function"`, `id` is `"circlearea"`,
  `params` is `["r"]`, `domainUnits` is `["m"]`, `rangeUnit` is `"m^2"`,
  `rangeBounds` is `"[0,)"`, `forward` is `"pi r^2"`,
  `inverse` is `"sqrt(circlearea/pi)"`

#### Scenario: Multi-param function with domain bounds is parsed
- **WHEN** the input line is
  `windchill(T,speed) units=[K,mph] domain=[170,283.15],[3,) ...`
- **THEN** `id` is `"windchill"`, `params` is `["T", "speed"]`,
  `domainUnits` is `["K", "mph"]`,
  `domainBounds` is `["[170,283.15]", "[3,)"]`

#### Scenario: Domain bounds with no separator between bracket-pairs are parsed
- **WHEN** the `domain=` value is `(0,)(0,)` (two adjacent bracket-pairs with
  no comma between them)
- **THEN** `domainBounds` is `["(0,)", "(0,)"]`

#### Scenario: Function without units= has empty domain/range unit lists
- **WHEN** the definition has no `units=` token
- **THEN** `domainUnits` is `[]` and `rangeUnit` is `null`

#### Scenario: Function without inverse has null inverse field
- **WHEN** the definition body contains no `;` character
- **THEN** `inverse` is `null`

#### Scenario: noerror token is detected
- **WHEN** the `noerror` literal is present before the forward expression
- **THEN** `noerror` is `true` and `"noerror"` is not included in `forward`

#### Scenario: Zero-arg alias form produces function_alias entry
- **WHEN** the input line is `tempcelsius() tempC`
- **THEN** `type` is `"function_alias"`, `id` is `"tempcelsius"`,
  `target` is `"tempC"`

---

### Requirement: defined_function entries are serialized to JSON
The importer SHALL serialize `defined_function` entries into the `"units"`
section of the output JSON (not `"unsupported"`).  Each entry SHALL include:
`type`, `params`, `forward`, `inverse` (omitted if `null`), `domainUnits`,
`domainBounds`, `rangeUnit` (omitted if `null`), `rangeBounds` (omitted if
`null`), `noerror`, `gnuUnitsSource`, and `source`.

`function_alias` entries SHALL be serialized under their target function's
`aliases` key (via the same alias-folding mechanism used for unit aliases).

#### Scenario: defined_function entry appears in units section
- **WHEN** `entriesToJson()` processes a `defined_function` entry
- **THEN** the entry appears under `"units"` with all required fields
- **AND** it does NOT appear under `"unsupported"`

#### Scenario: Inverse field is omitted when null
- **WHEN** a `defined_function` entry has no inverse
- **THEN** the serialized JSON object has no `"inverse"` key

---

### Requirement: Codegen emits registerDefinedFunctions
The codegen library SHALL emit a `registerDefinedFunctions(UnitRepository repo)`
top-level function for entries with `"type": "defined_function"`.  For each
such entry, it SHALL emit a block that:

1. Resolves each domain unit string via
   `ExpressionParser(repo: repo).evaluate(unitString)` to obtain the
   `QuantitySpec.quantity` for that domain argument.
2. Resolves the range unit string (if present) similarly.
3. Constructs a `DefinedFunction` with `id`, `aliases`, `params`, `forward`,
   `inverse` (if present), `domain` (list of `QuantitySpec`), `range`
   (optional `QuantitySpec`), and `noerror`.
4. Registers it via `repo.registerFunction(...)`.

`registerDefinedFunctions` SHALL be called from
`UnitRepository.withPredefinedUnits()` after `registerPredefinedUnits`,
`registerBuiltinFunctions`, and `registerPiecewiseFunctions`.

#### Scenario: defined_function entry is emitted correctly
- **WHEN** an entry has `"type": "defined_function"` with params, forward, and
  inverse
- **THEN** the output contains a `DefinedFunction(id: '...', params: [...],
  forward: '...', inverse: '...', ...)` call registered via
  `repo.registerFunction()`

#### Scenario: defined_function entries are not emitted as unit registrations
- **WHEN** an entry has `"type": "defined_function"`
- **THEN** no `repo.register(...)` call is emitted for that entry

#### Scenario: Domain units are resolved at registration time
- **WHEN** the entry has `domainUnits: ["m"]`
- **THEN** the emitted code contains
  `ExpressionParser(repo: repo).evaluate('m')` to resolve the unit at startup,
  not a hardcoded numeric factor

#### Scenario: All defined functions available in standard repository
- **WHEN** a `UnitRepository` is created with `withPredefinedUnits()`
- **THEN** `findFunction("circlearea")` returns a non-null `DefinedFunction`
- **AND** `findFunction("tempC")` returns a non-null `DefinedFunction`
- **AND** `findFunction("windchill")` returns a non-null `DefinedFunction`
