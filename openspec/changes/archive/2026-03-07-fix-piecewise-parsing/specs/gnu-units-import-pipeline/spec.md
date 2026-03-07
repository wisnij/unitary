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

#### Scenario: Piecewise linear unit is parsed (not unsupported)
- **WHEN** the unit name contains `[` (piecewise linear table syntax, e.g.,
  `gasmark[degR]`)
- **THEN** `type` is `"piecewise"` (see "Piecewise entry parsing" requirement)
- **AND** the entry is NOT placed in the unsupported section

#### Scenario: Piecewise linear unit with parenthesized output is parsed (not unsupported)
- **WHEN** the unit name contains both `[` and `(` (e.g., `plategauge[(oz/ft^2)/(480*lb/ft^3)]`)
- **THEN** `type` is `"piecewise"` — the `[` check takes priority over the `(` check
- **AND** the entry is NOT placed in the unsupported section

#### Scenario: Unsupported (nonlinear) unit is detected
- **WHEN** the unit name contains `(` but NOT `[` (function-argument syntax, e.g.,
  `tempC(x)`)
- **THEN** `type` is `"unsupported"` and `reason` is `"nonlinear_definition"`

#### Scenario: Source metadata is recorded
- **WHEN** any entry is parsed
- **THEN** the entry records `gnuUnitsSource` (the normalized source line
  after comment stripping and whitespace normalization) and `source` with
  `file` (the provided filename) and `line` (the 1-based line number of the
  first line of the entry)
