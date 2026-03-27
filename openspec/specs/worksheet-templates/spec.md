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
| Length | `length` | millimeters: mm, centimeters: cm, inches: in, feet: ft, yards: yd, meters: m, kilometers: km, miles: mi, nautical miles: nmi — all `UnitRow` |
| Mass | `mass` | milligrams: mg, grams: g, ounces: oz, pounds: lb, kilograms: kg, stone: stone, short tons: uston, metric tons: t, long tons: brton — all `UnitRow` |
| Time | `time` | milliseconds: ms, seconds: s, minutes: min, hours: hr, days: d, weeks: wk, years: year — all `UnitRow` |
| Temperature | `temperature` | kelvin: K (`UnitRow`), celsius: tempC (`FunctionRow`), fahrenheit: tempF (`FunctionRow`), réaumur: tempreaumur (`FunctionRow`), rankine: degR (`UnitRow`) |
| Volume | `volume` | milliliters: mL, teaspoons: tsp, tablespoons: tbsp, fluid ounces: floz, cups: cup, pints: pt, quarts: qt, liters: L, gallons: gal, barrels: bbl — all `UnitRow` |
| Area | `area` | sq centimeters: cm^2, sq inches: in^2, sq feet: ft^2, sq meters: m^2, acres: acre, hectares: ha, sq kilometers: km^2, sq miles: mi^2 — all `UnitRow` |
| Speed | `speed` | km/hour: km/hr, feet/sec: ft/s, miles/hour: mph, knots: knot, meters/sec: m/s, Mach (STP): mach, km/sec: km/s, light speed: c — all `UnitRow` |
| Pressure | `pressure` | pascals: Pa, mmHg: mmHg, kilopascals: kPa, pounds/sq inch: psi, bar: bar, atmospheres: atm — all `UnitRow` |
| Energy | `energy` | electron volts: eV, ergs: erg, joules: J, calories: cal, kilojoules: kJ, BTU: BTU, kilocalories: kcal, kilowatt-hours: kWh, tons of TNT: ton tnt — all `UnitRow` |
| Digital Storage | `digital-storage` | bits: bit, bytes: B, kibibytes: KiB, mebibytes: MiB, gibibytes: GiB, tebibytes: TiB — all `UnitRow` |

#### Scenario: Registry returns all 10 templates
- **WHEN** the predefined template registry is accessed
- **THEN** it returns exactly 10 templates with distinct ids

#### Scenario: Length template rows
- **WHEN** the `length` template is retrieved from the registry
- **THEN** it has 9 rows, all `UnitRow`, with expressions m, cm, mm, km, in, ft, yd, mi, nmi

#### Scenario: Temperature template mixed kinds
- **WHEN** the `temperature` template is retrieved from the registry
- **THEN** it has 5 rows: K (`UnitRow`), tempC (`FunctionRow`), tempF (`FunctionRow`), tempreaumur (`FunctionRow`), degR (`UnitRow`)

#### Scenario: Speed template compound expressions
- **WHEN** the `speed` template is retrieved from the registry
- **THEN** it contains rows with compound expressions including `"m/s"` and `"km/hr"`, as well as `"mach"`, `"km/s"`, and `"c"` (speed of light)

#### Scenario: Digital storage template binary units
- **WHEN** the `digital-storage` template is retrieved from the registry
- **THEN** all rows use binary (IEC) unit expressions: bit, B, KiB, MiB, GiB, TiB
