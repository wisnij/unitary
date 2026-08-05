Unitary - Core Architecture
===========================

This document describes the core technical architecture of Unitary as
implemented: data models, the expression parser/evaluator, and the key
subsystems built on them.

For terminology definitions, see [Terminology](terminology.md).
For implementation planning and phase history, see the
[Implementation Plan](implementation_plan.md).
For development practices, see
[Development Best Practices](best_practices.md).

---


Technology Stack
----------------

### Framework: Flutter

**Rationale:**

- Single codebase for Android and iOS (plus a web build used for CI deploys)
- Dart language similar to Kotlin (easier learning curve)
- Excellent performance (compiled to native code)
- Material Design built-in with regular updates
- Strong state management options
- Good offline-first capabilities
- Active community and extensive packages

**Alternatives Considered:**

- Native Kotlin (Android only) - limits iOS support
- React Native - ruled out per preference to avoid JS/TS
- Kotlin Multiplatform Mobile - still maturing, more complex setup

### Runtime Dependencies

- **flutter_riverpod** - state management
- **shared_preferences** - key-value persistence for all user data (settings,
  worksheet state, freeform history, currency rates)
- **http** - currency rate fetching (Frankfurter v2 API)
- **package_info_plus** - runtime version display in Settings
- **flutter_markdown_plus** - rendering the bundled license text
- **url_launcher** - opening external links from the About screen

`sqflite` (or similar) is deliberately deferred until a feature needs it
(custom worksheets, Phase 12); SharedPreferences has been sufficient for all
data shipped so far.


Architecture Overview
---------------------

### Layered Architecture

~~~~
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens & widgets, features/*/        │
│   presentation/, shared/ UI shell)      │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│           State Layer                   │
│  (Riverpod providers & notifiers,       │
│   features/*/state/)                    │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│           Core Domain Layer             │
│  (Models, parser/evaluator, unit        │
│   system — pure Dart, no Flutter)       │
└─────────────────────────────────────────┘
              ↕
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Repositories over SharedPreferences,  │
│   features/*/data/)                     │
└─────────────────────────────────────────┘
~~~~

The core domain layer is pure Dart: it has no Flutter dependency, which keeps
it runnable (and benchmarkable) under plain `dart` (see
[performance.md](performance.md)).  The one deliberate exception is
`unit_repository_provider.dart`, a small Riverpod provider colocated with the
repository it provides.


Core Components
---------------

### 1. Expression Parser & Evaluator

**Component Structure:**

~~~~
Lexer → Parser → AST → Evaluator
  ↓       ↓       ↓        ↓
Token   AST    Expression  Quantity
Stream  Nodes    Tree     (value + dimension)
~~~~

**Token Types** (`token.dart`):

`number` (3.14, 1.5e-10, .5), `identifier` (unit and function names),
operators (`plus`, `minus`, `times` for `*`/`×`/`·`, `divide` for `/`/`÷`/
`per`, `divideNum` for `|`/`⁄`, `exponent` for `^`/`**`), grouping
(`leftParen`, `rightParen`, `comma`), `inverse` (`~`, for inverse function
application), and `eof`.  Each token carries its type, lexeme text, optional
parsed literal value, and line/column for error reporting.

**Lexer** (`lexer.dart`):

- Converts the input string into a token stream
- Recognizes numbers (integers, decimals, leading decimal point, scientific
  notation), identifiers, operator symbols in their several spellings, and
  parentheses
- Treats all whitespace (including newlines) as token separators
- Tracks line and column numbers for detailed error reporting
- Does *not* interpret identifiers: whether an identifier is a unit, prefixed
  unit, function, or unknown is decided at parse/evaluation time via the
  `UnitRepository` (see prefix and plural handling under the unit system
  below)

**Parser** (`parser.dart`):

Recursive descent, building an AST from the token list.  Grammar, lowest to
highest precedence:

~~~~
expression  = sum / DIVIDE listProduct
sum         = opProduct ( (PLUS / MINUS) opProduct )*
opProduct   = listProduct ( (TIMES / DIVIDE) listProduct )*
listProduct = unary power*
unary       = ( PLUS / MINUS )? power
power       = primary ( EXPONENT unary )*  [folded right-to-left]
primary     = numexpr / LPAR expression RPAR / function / unit
numexpr     = NUMBER ( DIVIDENUM NUMBER )*
function    = INVERSE? IDENTIFIER LPAR arguments RPAR  [if known function]
unit        = IDENTIFIER                               [fallback]
arguments   = expression ( COMMA expression )*
~~~~

Notable properties:

- Implicit multiplication is handled at the `listProduct` level, giving it
  higher precedence than explicit `*` and `/`: `5 m / 2 s` parses as
  `(5*m) / (2*s)`
- A leading `/` forms a reciprocal (`/x` = `1/x`)
- `|` (numeric division) binds tighter than `^` and accepts only numeric
  literals as operands, so `2|3 kg` is two-thirds of a kilogram
- An identifier followed by `(` is parsed as a function call only if the
  repository knows a function by that name; otherwise it falls back to a unit
- `parseQuery()` additionally recognizes a *bare* function name (optionally
  with `~` or a trailing `(`) as a `FunctionNameNode`, used for definition
  lookup and as a conversion target (e.g. converting to `tempF`)

**AST Node Types** (`ast.dart`):

- `NumberNode` — numeric literal
- `UnitNode` — unit identifier (resolved via `UnitRepository` at evaluation
  time; unknown names throw `EvalException`)
- `BinaryOpNode` — binary operators (+, -, *, /, ^, |) including implicit
  multiplication
- `UnaryOpNode` — unary minus/plus
- `FunctionCallNode` — builtin and defined function calls, including inverse
  application via `~`
- `FunctionNameNode` — a bare function name used as a query or conversion
  target (not an expression)
- `DefinitionRequestNode` — a definition lookup query

**Evaluator:**

Each `ExpressionNode` evaluates itself against an `EvalContext` carrying the
`UnitRepository`, optional variable bindings (used by defined functions to
shadow unit names with parameter values), and the active unit-resolution
stack (`visited`, used for circular-definition detection).  Evaluation
performs full dimensional analysis and returns a `Quantity`.

The public entry point is `ExpressionParser` (`expression_parser.dart`),
which bundles lex → parse → evaluate behind `evaluate()`, `parseExpression()`,
and `parseQuery()`.

**Error Handling:**

All failures throw subclasses of `UnitaryException` (`errors.dart`):
`LexException`, `ParseException`, `EvalException`, `DimensionException`
(non-conformable operands), and `BoundsException` (function argument outside
its domain).  Lex and parse errors carry line/column positions.  NaN-producing
operations fail fast with clear messages rather than propagating NaN.

### 2. Unit System & Dimensional Analysis

**Dimension Model:**

`Dimension` represents a physical dimension as a map from primitive unit IDs to
integer exponents.  For example, velocity is `{m: 1, s: -1}` and force is
`{kg: 1, m: 1, s: -2}`.  A dimensionless quantity has an empty map.

Operations:

- `multiply(other)` — adds exponents (for multiplication)
- `divide(other)` — subtracts exponents (for division)
- `power(n)` — multiplies all exponents by n
- `powerRational(r)` — multiplies by rational exponent, validates divisibility
- `isConformableWith(other)` — checks dimensional equality
- `canonicalRepresentation()` — human-readable string like `kg m / s^2`

Zero exponents are stripped automatically.  Two dimensions are equal iff they
have the same unit-exponent pairs.

**Dimension labels:** the unit database ships a map of canonical dimension
representations to human-readable category names (e.g. `{m: 1, s: -2}` →
"Acceleration"), emitted as `predefinedDimensionLabels` and used by the unit
browser's dimension-grouped view.

**Prefix Support:**

Unit prefixes (kilo, mega, milli, etc.) are implemented as `PrefixUnit`
instances, a subclass of `DerivedUnit` with `isPrefix => true`.  Prefixes are
stored separately in `UnitRepository` via `registerPrefix()`, so prefix symbols
(like `m` for milli) can coexist with regular unit IDs (like `m` for meter).

The `findUnitWithPrefix(name)` method resolves names using this priority order:

1. Exact match in regular units (including plural stripping)
2. Prefix splitting — longest prefix first, remainder looked up as a regular
   unit (with plural stripping)
3. Standalone prefix match (prefix name with no remainder)
4. No match → returns empty `UnitMatch`

This means standalone `"m"` resolves to meter (step 1), while `"mm"` splits
into milli + meter (step 2).  Plural stripping has minimum-length guards, so
short names like `"ms"` are not mistaken for plurals (it resolves as
milli + second, not the plural of `"m"`).

**Unit Model:**

Each `Unit` has a primary `id`, a list of `aliases`, and a `description`.
The `allNames` getter returns id + aliases.  Plural forms (trailing "s", "es",
"ies") are handled automatically by the repository's plural stripping, so only
irregular plurals (like "feet" for "foot") need to be listed as explicit aliases.

Unit subclasses define how units convert to primitive base units:

- **`PrimitiveUnit`** — fundamental units that define their own dimension
  (e.g., meter → `{m: 1}`).  Optionally `isDimensionless` for units like
  radian and steradian.
- **`DerivedUnit`** — units defined by an expression string that is parsed
  and evaluated through the full pipeline (e.g., newton: `"kg m/s^2"`,
  mile: `"5280 ft"`).
- **`PrefixUnit`** — a `DerivedUnit` subclass for SI prefixes
  (e.g., kilo: `"1000"`, milli: `"0.001"`).

Unit resolution is handled by `UnitRepository.resolveUnit(unit)`, which
returns a `Quantity` representing 1 of that unit in primitive base units.  For
derived units, resolution evaluates the expression string through the full
lexer/parser/evaluator pipeline, which may recurse through other unit
definitions.  Resolution results are cached (`_resolvedQuantityCache`); the
cache is invalidated whenever dynamic units are registered or removed.
Re-entry for a unit already on the resolution stack throws immediately
(circular-definition detection); the stack keys use a trailing `-` to
distinguish prefixes from same-named units.

Examples of unit definitions:

~~~~
Primitive:  m (meter)           → Quantity(1.0, {m: 1})
Derived:    mi (mile)           → "5280 ft" → Quantity(1609.344, {m: 1})
Derived:    N (newton)          → "kg m/s^2" → Quantity(1.0, {kg: 1, m: 1, s: -2})
Prefix:     kilo                → "1000" → Quantity(1000.0, dimensionless)
~~~~

The repository also has a **dynamic unit layer** (`registerDynamic()` /
`unregisterDynamic()`): runtime definitions that shadow same-named compiled
units without mutating the static layer.  Currency rate updates are applied
through this layer.

**Quantity Model:**

`Quantity` represents a physical quantity: a numeric `value` (double) combined
with a `Dimension`.  All arithmetic operations maintain dimensional consistency:

- `add`/`subtract` — requires conformable dimensions, throws `DimensionException` if not
- `multiply`/`divide` — combines dimensions (adds/subtracts exponents)
- `power(exponent)` — for dimensioned quantities, requires rational exponent with
  integer-valued result dimensions; uses continued fractions to recover rational
  approximation from double exponents
- `negate`/`abs` — preserves dimension

NaN values are rejected at construction time (fail-fast).  Division by zero
throws `EvalException`.

The standalone `reduce()` utility (`unit_service.dart`) rewrites a quantity
whose dimension mentions non-primitive units into primitive base units.

### 3. Functions

`UnitaryFunction` (`function.dart`) is the abstract base for callable
functions: id, aliases, arity, domain/range specs (`QuantitySpec`, with
dimension and bounds checking), `call()`, and optional `callInverse()`.

- **`BuiltinFunction`** — wraps a Dart implementation; the trigonometric,
  logarithmic, and root functions (sin, cos, tan, asin, acos, atan, ln, log,
  exp, sqrt, cbrt, abs) are registered this way.
- **`DefinedFunction`** (`defined_function.dart`) — evaluates a forward
  expression string with parameter bindings, imported from the GNU Units
  database (e.g. `tempF`, `wiregauge`); single-parameter functions with an
  inverse expression support inverse application (`~tempF`).  Direct and
  mutual recursion are detected via the shared `visited` stack.

Functions are registered in and looked up from the `UnitRepository` alongside
units and prefixes; name collisions are rejected at registration time.

### 4. Unit Database

The unit catalog is imported from the GNU Units database at development time,
not parsed at runtime:

~~~~
definitions.units (GNU Units)
        │  tool/import_gnu_units.dart
        ▼
assets/units/units.json   ←  assets/units/units-supplementary.json
        │  tool/generate_predefined_units.dart
        ▼
lib/core/domain/data/predefined_units.dart  (generated Dart)
~~~~

- `units.json` holds the full merged database (7471 units, 125 prefixes, 88
  dimension labels) as data; `units-supplementary.json` holds project-owned
  additions and overrides.
- The generated `predefined_units.dart` registers everything into a
  `UnitRepository` in plain Dart (`registerPredefinedUnits()`,
  `registerDefinedFunctions()`), so app startup involves no JSON parsing or
  asset I/O for units.
- Pre-commit hooks re-run both tools when their inputs change, keeping the
  generated files in sync with the sources.

### 5. Worksheet System

- **Model** (`worksheet.dart`): `WorksheetTemplate` (id, name, rows, optional
  banner) with `WorksheetRow`s.  Each row has a label, an expression string
  (compound expressions like `m/s` or `ft^2` are supported), and a
  `WorksheetRowKind`: `UnitRow` for ratio-based conversion or `FunctionRow`
  for function forward/inverse application (used by non-zero-origin
  temperature scales).
- **Engine** (`worksheet_engine.dart`): `computeWorksheet()` takes the
  template, source row, and source value, and computes every other row's
  display value — unit-ratio math for `UnitRow`s, `call()`/`callInverse()`
  for `FunctionRow`s — returning per-row error strings on dimension mismatch.
  The engine is pure Dart and synchronous (~150–190 µs per full recompute).
- **Templates**: 12 predefined worksheets (Angle, Area, Currency, Digital
  Storage, Energy, Length, Mass, Pressure, Speed, Temperature, Time, Volume)
  in `predefined_worksheets.dart`.  The Currency template declares a banner
  showing rate freshness.
- **State**: `WorksheetNotifier` applies "last keystroke wins" source
  semantics (focus alone does not transfer which row drives the conversion)
  and keeps per-template value maps; the active template and each template's
  source cell persist across sessions via `WorksheetRepository`.

### 6. Currency Rate Management

- **Fetching** (`currency_service.dart`): Frankfurter v2 API
  (`https://api.frankfurter.dev/v2/rates?base=USD`, no API key), including
  precious metals (XAU/XAG/XPT).
- **Application**: `UnitRepository.buildCurrencyDescriptors()` identifies
  currency units in the catalog; fetched rates are applied through the
  repository's dynamic unit layer, shadowing the built-in compiled rates.
  Precious metals update intermediate price units (e.g. `goldprice`).
- **Storage** (`currency_rate_repository.dart`): rates persist in
  SharedPreferences with a per-currency date and a top-level `updatedAt`;
  stored rates are re-applied synchronously before the first frame, so
  currency conversions are live from launch even offline.
- **Refresh policy**: a 24-hour staleness check runs fire-and-forget after
  the first frame; Settings and the Currency worksheet share a manual
  refresh button with a 60-second cooldown.  Refresh failures surface in a
  dialog and never disturb stored rates.

### 7. UI Shell

`AppShell` (`shared/app_shell.dart`) owns top-level navigation and the
responsive layout decision, driven by a `WindowSizeClass` derived from window
width: compact (<600 dp, drawer + single pane), medium (600–1040 dp, drawer +
two panes), expanded (>1040 dp, persistent navigation rail + two panes).
Pages are kept alive in an `IndexedStack` and use a shared `TwoPaneLayout`
for their split views (freeform history pane, worksheet template list,
browser detail pane).


State Management
----------------

Riverpod throughout:

- `settingsProvider` (`SettingsNotifier`) — user settings, persisted via
  `SettingsRepository`
- `freeformProvider` / `freeformHistoryProvider` — freeform evaluation state
  and the persistent history of successful conversions
- `worksheetProvider` (`WorksheetNotifier`) — active template, per-template
  values, persisted source cells
- `browserProvider` (`BrowserNotifier`) — browse catalog, view mode, search,
  selection
- `currencyStatusProvider` — rate freshness, refresh in-flight/cooldown state
- `unitRepositoryProvider` — the shared `UnitRepository` singleton, with a
  version counter provider that dependents watch to react to dynamic-layer
  changes (e.g. recomputing worksheets after a rate refresh)

All persistence goes through small repository classes over SharedPreferences
(`SettingsRepository`, `WorksheetRepository`, `FreeformHistoryRepository`,
`CurrencyRateRepository`), each provided by a must-override provider wired in
`main.dart` (and by shared test helpers in `test/helpers/`).


Code Organization
-----------------

~~~~
lib/
├── main.dart                  # entry point; wires repositories, pre-frame rate load
├── app.dart                   # MaterialApp, theming
├── core/
│   └── domain/                # pure Dart, no Flutter
│       ├── models/            # Dimension, Quantity, Rational, Unit,
│       │                      #   UnitRepository, functions, browse/completion
│       ├── parser/            # token, lexer, parser, ast, expression_parser
│       ├── completion/        # token_at_cursor
│       ├── services/          # reduce()
│       ├── data/              # generated predefined_units.dart, builtin functions
│       └── errors.dart        # UnitaryException hierarchy
├── features/
│   ├── freeform/              # expression evaluation UI, completion, history
│   ├── worksheet/             # templates, engine, worksheet UI
│   ├── browser/               # unit catalog browser
│   ├── currency/              # rate fetching, storage, refresh UI
│   ├── settings/              # user settings
│   └── about/                 # about/license screens
│       (each: data/ · domain/ · models/ · presentation/ · services/ ·
│        state/ as needed)
├── shared/                    # app shell, responsive layout, drawer,
│                              #   formatters, reusable widgets
assets/
├── units/                     # units.json + units-supplementary.json (sources
│                              #   for the generated unit database)
└── icon/                      # app icon source (SVG) and rasterization
tool/                          # import/codegen/benchmark/icon tooling
test/                          # mirrors lib/ structure; test/helpers/ harness
integration_test/              # on-device/emulator end-to-end tests
~~~~

The `test/` tree mirrors `lib/` directory-for-directory.  `tool/` follows a
lib/exe split: each executable (`import_gnu_units.dart`,
`generate_predefined_units.dart`, `benchmark.dart`, `memory_report.dart`) has
a corresponding testable `*_lib.dart`.


Resources & References
----------------------

- Flutter documentation: <https://docs.flutter.dev>
- Material Design: <https://m3.material.io>
- GNU Units: <https://www.gnu.org/software/units/>
- Frankfurter exchange-rate API: <https://frankfurter.dev>
