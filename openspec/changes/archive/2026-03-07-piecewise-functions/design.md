## Context

28 entries in `units.json` have `type: "unsupported"` with `reason:
"piecewise_linear"` because the import pipeline rejects names of the form
`id[outputUnits]`.  These represent piecewise-linear lookup tables (e.g.
the gas mark scale, sugar concentration tables, wind-chill indices) that GNU
Units supports natively.

The existing `UnitaryFunction` hierarchy (`function.dart`) already provides
the extension point for new callable types.  The existing function registry in
`UnitRepository` already handles registration and lookup.  The codegen tool
(`generate_predefined_units_lib.dart`) already has a pattern for emitting
registration calls that are called from `withPredefinedUnits()`.

The raw definition syntax is:

```
name[outputUnit] [noerror] x1 y1 x2 y2 … xn yn
```

where x values are strictly ascending and the function is linearly interpolated
between adjacent (x, y) pairs.


## Goals / Non-Goals

**Goals:**

- Parse all 28 piecewise-linear definitions from `definitions.units` into
  `units.json` as `type: "piecewise"`.
- Implement `PiecewiseFunction` — a `UnitaryFunction` subclass that evaluates
  the lookup table forward and in reverse.
- Generate registration code so all 28 piecewise functions are available in
  `UnitRepository.withPredefinedUnits()`.
- Remove all 28 entries from `_knownEvalFailures` in `predefined_units_test.dart`.

**Non-Goals:**

- Nonlinear GNU Units functions (names containing `()`): still unsupported.
- Output unit expressions that involve affine (temperature-offset) conversions
  — the output unit is treated as a multiplicative scale only (same as a
  `DerivedUnit` expression), not as an absolute temperature offset.
- Extrapolation beyond the control-point range: out-of-range input always
  throws regardless of the `noerror` flag (see Decisions below).


## Decisions

### D1 — Resolve output unit at registration time, not codegen time

The codegen tool (`generate_predefined_units.dart`) reads `units.json` and
emits Dart code.  Resolving `"degR"` → factor + dimension at codegen time
would require bootstrapping a full `UnitRepository` from JSON inside the
codegen tool — circular with the very file it is generating.

Instead, the generated `registerPiecewiseFunctions(UnitRepository repo)` uses
`ExpressionParser(repo: repo).evaluate(outputUnit)` at registration time.  By
the time this function is called (after `registerPredefinedUnits`), all base
units are already present in the repo.  The resolved `Quantity` is passed
directly as `outputUnit` to the `PiecewiseFunction` constructor, which stores
it as `range!.quantity!`.  `PiecewiseFunction` never touches the repo again
during evaluation.

**Alternative considered:** lazy resolution inside `evaluate()`.  Rejected
because `UnitaryFunction.evaluate()` receives only `List<Quantity>` (no repo
or context), so there is nowhere to thread the repo reference without a
larger API change.

### D2 — `PiecewiseFunction` stores `(double, double)` control points

Control points are stored as a `List<(double, double)>` (Dart record list).
The x and y values are raw doubles taken directly from the definition; no
unit conversion is applied to them — they are in the units named by
`outputUnit` (for y) and dimensionless (for x).

The list is `const`-constructible in the generated code, keeping
`predefined_units.dart` as pure data.

The constructor accepts `outputUnit: Quantity` and derives `yMin`/`yMax`
by scanning all control points.  These are passed to the `UnitaryFunction`
superclass as `range`:

```dart
range: QuantitySpec(
  quantity: outputUnit,
  min: Bound(yMin, closed: true),
  max: Bound(yMax, closed: true),
)
```

Bounds are in raw y-table space (not SI-scaled).  `_validateSpec` normalises
incoming values by dividing by `outputUnit.value` before comparing against
the bounds.  `outputFactor` and `outputDimension` are not stored as separate
fields; they are read from `range!.quantity!` at evaluation time.

This gives two benefits:

1. **Forward direction**: `call()` validates the interpolated result against
   `range` automatically, catching any floating-point overshoot at segment
   boundaries.
2. **Inverse direction**: `callInverse()` validates the argument against
   `range` via `_validateSpec` before `evaluateInverse` is entered, producing
   a clear out-of-range error without a full O(n) segment scan.

### D3 — Forward evaluation: binary search + lerp

Given input x:

1. Validate x ∈ [points.first.$1, points.last.$1]; throw `EvalException` if
   not.
2. Binary search for the segment index i where
   `points[i].$1 ≤ x ≤ points[i+1].$1`.
3. Linear interpolation:
   `y = y0 + (x − x0) / (x1 − x0) × (y1 − y0)`.
4. Return `Quantity(y × range!.quantity!.value, range!.quantity!.dimension)`.

Edge case: if x exactly equals a control-point x value, the binary search
lands on that point directly and the interpolation factor is 0, so the stored
y value is returned without rounding.

### D4 — Inverse evaluation: bounds check in callInverse, early-exit scan

Given target value `yTarget` (a `Quantity` conformable to the output
dimension):

1. `callInverse` validates `yTarget` against `range` via `_validateSpec`
   before `evaluateInverse` is entered.  `_validateSpec` normalises the value
   (`yRaw = yTarget.value / range!.quantity!.value`) and throws `EvalException`
   if it falls outside `[yMin, yMax]`.  This avoids a full O(n) scan for
   clearly out-of-range inputs.
2. `evaluateInverse` computes `yRaw = args[0].value / range!.quantity!.value`.
3. Scan every adjacent segment `(x0, y0)→(x1, y1)`.  A segment _contains_
   `yRaw` when `min(y0, y1) ≤ yRaw ≤ max(y0, y1)`.
4. For the first containing segment, interpolate and return immediately:
   `x = x0 + (yRaw − y0) / (y1 − y0) × (x1 − x0)`.
5. If no segment contains `yRaw` (unreachable in practice given step 1),
   throw `EvalException`.

A linear scan (O(n)) is acceptable: the longest piecewise table in the
database has ~100 points; performance is not a concern.

**Why first match = smallest x?** Segments are ordered by ascending x.  The
first segment whose y range contains `yRaw` always yields the smallest
candidate x, so returning immediately on the first match is equivalent to
collecting all candidates and returning the minimum — without the allocation.

**Why smallest x?** GNU Units specifies that non-monotonic inverses return the
smallest matching x; we follow this for consistency.  `noerror` is a separate
linting annotation with no effect on this behaviour (see D5).

### D5 — `noerror` is stored but has no behavioral effect

In GNU Units, `noerror` suppresses the warning that `units --check` prints for
non-monotonic piecewise functions; it is a linting annotation and does not
constrain any runtime computation.  We have no equivalent units-check tool, so
the flag is a no-op in our system.  It is preserved in the JSON and the Dart
model for fidelity to the source data only.

### D6 — `registerPiecewiseFunctions` lives in `predefined_units.dart`

The generated file already contains `registerPredefinedUnits`.  Adding a
second generated function `registerPiecewiseFunctions` keeps all generated
registration code in one place.  `UnitRepository.withPredefinedUnits()` calls
it after `registerBuiltinFunctions`:

```dart
factory UnitRepository.withPredefinedUnits() {
  final repo = UnitRepository();
  registerPredefinedUnits(repo);
  registerBuiltinFunctions(repo);
  registerPiecewiseFunctions(repo);  // new
  return repo;
}
```

`registerPiecewiseFunctions` imports and uses `ExpressionParser` to resolve
each output unit, so `predefined_units.dart` gains an import of
`../parser/parser.dart`.

### D7 — JSON schema for piecewise entries

```json
"gasmark": {
  "type": "piecewise",
  "outputUnit": "degR",
  "noerror": false,
  "points": [[0.0625, 634.67], [0.125, 659.67], "..."],
  "gnuUnitsSource": "gasmark[degR] .0625 634.67 ...",
  "source": { "file": "tool/gnu_units/definitions.units", "line": 1194 }
}
```

`yMin` and `yMax` are not serialised; they are recomputed from `points` by the
`PiecewiseFunction` constructor.

The key is the bare `id` (without `[outputUnit]`).  `points` is a flat-paired
array of `[x, y]` sub-arrays.  This replaces the current `"type": "unsupported"`
entry keyed on `"gasmark[degR]"`.


## Risks / Trade-offs

**Output unit resolution fails at registration time** → Piecewise functions
whose `outputUnit` expression is not a registered unit (e.g. complex
expressions involving unsupported syntax) will throw at
`UnitRepository.withPredefinedUnits()` time.  Mitigation: validate all 28
output unit strings in tests before merging.  If a string cannot be resolved,
it can be moved to a `units-supplementary.json` override.

**Non-monotonic inverse has multiple valid segments** → D4's linear scan
returns the smallest x, which may differ from GNU Units' own answer in edge
cases.  The user spec mandates this behaviour, so it is not a defect.

**`predefined_units.dart` imports parser** → Creates a new dependency from
generated data code into the parsing layer.  The parser already depends on the
domain models, so this is a one-directional new edge in the dep graph, not a
cycle.  Acceptable for now.


## Open Questions

None.
