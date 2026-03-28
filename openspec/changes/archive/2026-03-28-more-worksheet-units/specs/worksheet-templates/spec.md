## MODIFIED Requirements

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
