# Worksheet Templates

## Purpose

Defines the data models and predefined template registry for worksheet mode.
Covers `WorksheetRow`, `WorksheetRowKind`, and `WorksheetTemplate`, along with
the full set of 10 predefined conversion templates.

## Requirements

### Requirement: WorksheetRow model
A `WorksheetRow` SHALL have a display `label` (String), an `expression` (String
parseable by `ExpressionParser`), and a `WorksheetRowKind`.

`WorksheetRowKind` is a sealed class with two variants:
- `UnitRow`: the expression evaluates to a `Quantity`; conversion is
  ratio-based (`value / unitQty.value`).
- `FunctionRow`: the expression is a bare function name registered in
  `UnitRepository`; conversion uses the function's `call()` (forward) and
  `callInverse()` (inverse).

#### Scenario: UnitRow construction
- **WHEN** a `WorksheetRow` is constructed with kind `UnitRow` and expression `"ft"`
- **THEN** its `label`, `expression`, and `kind` are accessible and `kind` is a `UnitRow`

#### Scenario: FunctionRow construction
- **WHEN** a `WorksheetRow` is constructed with kind `FunctionRow` and expression `"tempC"`
- **THEN** its `kind` is a `FunctionRow`

### Requirement: WorksheetTemplate model
A `WorksheetTemplate` SHALL have a unique `id` (String), a display `name`
(String), and a non-empty ordered list of `WorksheetRow` objects.

#### Scenario: Template construction
- **WHEN** a `WorksheetTemplate` is constructed with id `"length"`, name `"Length"`, and a list of rows
- **THEN** its `id`, `name`, and `rows` are accessible

### Requirement: Predefined worksheet templates
The application SHALL provide exactly 10 predefined `WorksheetTemplate`
instances accessible via a static registry.  Within each template, rows are
ordered from smallest to largest unit (where that ordering is well-defined).

The 10 templates and their rows:

| Template | id | Rows (label: expression, kind) |
|----------|-----|-------------------------------|
| Length | `length` | microns: µm, millimeters: mm, centimeters: cm, inches: in, feet: ft, yards: yd, meters: m, kilometers: km, miles: mi, nautical miles: nmi — all `UnitRow` |
| Mass | `mass` | micrograms: µg, milligrams: mg, grams: g, ounces: oz, pounds: lb, kilograms: kg, stone: stone, short tons: uston, metric tons: t, long tons: brton — all `UnitRow` |
| Time | `time` | nanoseconds: ns, microseconds: µs, milliseconds: ms, seconds: s, minutes: min, hours: hr, days: d, weeks: wk, years: yr, centuries: century — all `UnitRow` |
| Temperature | `temperature` | kelvin: K (`UnitRow`), celsius: tempC (`FunctionRow`), fahrenheit: tempF (`FunctionRow`), rankine: degR (`UnitRow`), réaumur: tempreaumur (`FunctionRow`), gas mark: gasmark (`FunctionRow`) |
| Volume | `volume` | milliliters: mL, teaspoons: tsp, tablespoons: tbsp, fluid ounces: floz, cups: cup, pints: pt, quarts: qt, liters: L, gallons: gal, barrels: bbl — all `UnitRow` |
| Area | `area` | sq millimeters: mm^2, sq centimeters: cm^2, sq inches: in^2, sq feet: ft^2, sq yards: yd^2, sq meters: m^2, acres: acre, hectares: ha, sq kilometers: km^2, sq miles: mi^2 — all `UnitRow` |
| Speed | `speed` | meters/minute: m/min, inches/sec: in/s, km/hour: km/hr, feet/sec: ft/s, miles/hour: mph, knots: knot, meters/sec: m/s, Mach (STP): mach, km/sec: km/s, light speed: c — all `UnitRow` |
| Pressure | `pressure` | pascals: Pa, millibars: mbar, mm mercury: mmHg, torr: torr, kilopascals: kPa, inches mercury: inHg, pounds/sq inch: psi, bar: bar, atmospheres: atm, megapascals: MPa — all `UnitRow` |
| Energy | `energy` | electron volts: eV, ergs: erg, joules: J, small calories: cal_th, kilojoules: kJ, BTU: BTU, watt-hours: Wh, food Calories: kcal, kilowatt-hours: kWh, tons of TNT: ton tnt — all `UnitRow` |
| Digital Storage | `digital-storage` | bits: bit, bytes: B, kilobytes: kB, kibibytes: KiB, megabytes: MB, mebibytes: MiB, gigabytes: GB, gibibytes: GiB, terabytes: TB, tebibytes: TiB — all `UnitRow` |

#### Scenario: Registry returns all 10 templates
- **WHEN** the predefined template registry is accessed
- **THEN** it returns exactly 10 templates with distinct ids

#### Scenario: Length template rows
- **WHEN** the `length` template is retrieved from the registry
- **THEN** it has 10 rows, all `UnitRow`, with expressions µm, mm, cm, in, ft, yd, m, km, mi, nmi

#### Scenario: Time template rows
- **WHEN** the `time` template is retrieved from the registry
- **THEN** it has 10 rows, all `UnitRow`, with expressions ns, µs, ms, s, min, hr, d, wk, yr, century

#### Scenario: Temperature template mixed kinds
- **WHEN** the `temperature` template is retrieved from the registry
- **THEN** it has 6 rows: K (`UnitRow`), tempC (`FunctionRow`), tempF (`FunctionRow`), degR (`UnitRow`), tempreaumur (`FunctionRow`), gasmark (`FunctionRow`)

#### Scenario: Speed template compound expressions
- **WHEN** the `speed` template is retrieved from the registry
- **THEN** it contains rows with compound expressions including `"m/min"`, `"in/s"`, `"m/s"`, and `"km/hr"`, as well as `"mach"`, `"km/s"`, and `"c"` (speed of light)

#### Scenario: Energy template small and food calories
- **WHEN** the `energy` template is retrieved from the registry
- **THEN** the row with expression `"cal_th"` has label `"small calories"` and the row with expression `"kcal"` has label `"food Calories"`

#### Scenario: Digital storage template SI and IEC units interleaved
- **WHEN** the `digital-storage` template is retrieved from the registry
- **THEN** it has 10 rows with SI decimal units (kB, MB, GB, TB) interleaved with IEC binary units (KiB, MiB, GiB, TiB) in magnitude order: bit, B, kB, KiB, MB, MiB, GB, GiB, TB, TiB

### Requirement: Each row's kind is consistent with its expression as parsed by the registry

For every row in every predefined template, the `kind` field SHALL be consistent
with how `ExpressionParser.parseQuery(row.expression)` classifies the expression
against the live `UnitRepository`:

- `FunctionNameNode` → row kind SHALL be `FunctionRow`
- Any other node type (`DefinitionRequestNode`, any `ExpressionNode`) → row kind SHALL be `UnitRow`

#### Scenario: UnitRow expression resolves to a non-function node

- **WHEN** `parseQuery` is called with the `expression` of a `UnitRow` from any predefined template
- **THEN** the result is NOT a `FunctionNameNode`

#### Scenario: FunctionRow expression resolves to a FunctionNameNode

- **WHEN** `parseQuery` is called with the `expression` of a `FunctionRow` from any predefined template
- **THEN** the result IS a `FunctionNameNode`

### Requirement: All-UnitRow templates are ordered smallest to largest

For any predefined template whose rows are all `UnitRow`, evaluating each row's
expression with `ExpressionParser.evaluate` SHALL yield `Quantity` values in
non-decreasing order.  When two adjacent rows produce the same `Quantity.value`,
their expression strings SHALL be in non-decreasing lexicographic order.

#### Scenario: All-UnitRow template rows are in ascending magnitude order

- **WHEN** each row expression in an all-`UnitRow` template is evaluated to a `Quantity`
- **THEN** the resulting `.value` sequence is non-decreasing from first to last row

#### Scenario: Equal-magnitude rows are ordered by expression string

- **WHEN** two adjacent rows in an all-`UnitRow` template evaluate to the same `Quantity.value`
- **THEN** the earlier row's expression string is lexicographically ≤ the later row's expression string

### Requirement: Volume template rows

The `volume` template SHALL contain exactly the following expressions (in
smallest-to-largest order): `mL`, `tsp`, `tbsp`, `floz`, `cup`, `pt`, `qt`,
`L`, `gal`, `bbl` — all `UnitRow`.

#### Scenario: Volume template expressions

- **WHEN** the `volume` template is retrieved from the registry
- **THEN** its rows contain all of: `mL`, `tsp`, `tbsp`, `floz`, `cup`, `pt`, `qt`, `L`, `gal`, `bbl`

### Requirement: Pressure template rows

The `pressure` template SHALL contain exactly the following expressions (in
smallest-to-largest order): `Pa`, `mbar`, `torr`, `mmHg`, `kPa`, `inHg`,
`psi`, `bar`, `atm`, `MPa` — all `UnitRow`.

#### Scenario: Pressure template expressions

- **WHEN** the `pressure` template is retrieved from the registry
- **THEN** its rows contain all of: `Pa`, `mbar`, `mmHg`, `torr`, `kPa`, `inHg`, `psi`, `bar`, `atm`, `MPa`
