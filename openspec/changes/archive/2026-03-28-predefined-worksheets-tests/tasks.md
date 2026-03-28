## 1. Cross-template tests

- [x] 1.1 Add a `setUpAll` that builds a shared `ExpressionParser` from `UnitRepository.withPredefinedUnits()`
- [x] 1.2 Add a cross-template test `'every row kind matches parseQuery result'` that iterates all rows in all predefined templates, calls `parseQuery(row.expression)`, and asserts `FunctionNameNode` → `FunctionRow` / anything else → `UnitRow`
- [x] 1.3 Add a cross-template test `'all-UnitRow templates are ordered smallest to largest'` that, for each template where every row is a `UnitRow`, evaluates each expression, and asserts non-decreasing `.value` with expression-string tiebreaker

## 2. Per-template containsAll fixes

- [x] 2.1 **Mass** — expand `containsAll` to cover all 10 expressions: `µg`, `mg`, `g`, `oz`, `lb`, `kg`, `stone`, `uston`, `t`, `brton`
- [x] 2.2 **Speed** — expand `containsAll` to cover all 10 expressions: `m/min`, `in/s`, `km/hr`, `ft/s`, `mph`, `knot`, `m/s`, `mach`, `km/s`, `c`
- [x] 2.3 **Temperature** — remove the 6 individual per-row kind tests; add a single `containsAll` over all 6 expressions: `K`, `tempC`, `tempF`, `degR`, `tempreaumur`, `gasmark`
- [x] 2.4 **Energy** — replace the individual `contains('Wh')` check with a `containsAll` over all 10 expressions: `eV`, `erg`, `J`, `cal_th`, `kJ`, `BTU`, `Wh`, `kcal`, `kWh`, `ton tnt`
- [x] 2.5 **Area** — replace the two individual `contains` checks with a `containsAll` over all 10 expressions: `mm^2`, `cm^2`, `in^2`, `ft^2`, `yd^2`, `m^2`, `acre`, `ha`, `km^2`, `mi^2`
- [x] 2.6 **Pressure** — add a `containsAll` over all 10 expressions: `Pa`, `mbar`, `mmHg`, `torr`, `kPa`, `inHg`, `psi`, `bar`, `atm`, `MPa`
- [x] 2.7 **Volume** — add a `containsAll` over all 10 expressions: `mL`, `tsp`, `tbsp`, `floz`, `cup`, `pt`, `qt`, `L`, `gal`, `bbl`

## 3. Verification

- [x] 3.1 Run `flutter test test/features/worksheet/data/predefined_worksheets_test.dart --reporter failures-only` and confirm all tests pass
- [x] 3.2 Run `flutter analyze` and confirm no lint errors
