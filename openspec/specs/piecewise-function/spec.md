## Purpose

TBD — piecewise-linear function evaluation support for GNU Units piecewise
definitions (e.g., `gasmark`).

---

## Requirements

### Requirement: PiecewiseFunction class
The system SHALL provide a `PiecewiseFunction` concrete subclass of
`UnitaryFunction` that evaluates piecewise-linear interpolation over a fixed
sequence of (x, y) control points.  It SHALL expose:

- `points: List<(double, double)>` — control points in ascending x order,
  where the first element of each record is x and the second is y; y values
  are in the output unit's space (not SI-scaled)
- `noerror: bool` — stored for fidelity to the GNU Units source; has no
  behavioral effect
- `arity` SHALL be `1`
- `hasInverse` SHALL be `true`

The constructor SHALL accept `outputUnit: Quantity`, which encodes the SI
conversion factor (`outputUnit.value`) and dimension (`outputUnit.dimension`)
of the output.  These are not stored as separate fields; they are derived from
`range!.quantity!` at evaluation time.

`range` SHALL be a `QuantitySpec` with `quantity: outputUnit`,
`min: Bound(yMin, closed: true)`, and `max: Bound(yMax, closed: true)`,
where `yMin` and `yMax` are the minimum and maximum y values across all control
points (computed by the constructor, not stored as fields).  Bounds are in raw
y-table space; `_validateSpec` normalises incoming values by dividing by
`outputUnit.value` before comparing.

#### Scenario: hasInverse is true
- **WHEN** `hasInverse` is checked on a `PiecewiseFunction` instance
- **THEN** it returns `true`

#### Scenario: arity is 1
- **WHEN** `arity` is checked on a `PiecewiseFunction` instance
- **THEN** it returns `1`

---

### Requirement: PiecewiseFunction forward evaluation
`PiecewiseFunction.evaluate()` SHALL accept a single dimensionless `Quantity`
argument whose value is a pure number, perform piecewise-linear interpolation
over the control points, and return a `Quantity` in the output unit's dimension.

The argument value SHALL be validated to lie within the closed interval
`[points.first.$1, points.last.$1]`.  Values outside this interval SHALL
cause `EvalException` to be thrown.

Interpolation within a segment `(x0, y0)→(x1, y1)` is:

```
y = y0 + (x − x0) / (x1 − x0) × (y1 − y0)
```

The return value SHALL be `Quantity(y × range!.quantity!.value, range!.quantity!.dimension)`.

#### Scenario: Exact control-point value is returned directly
- **WHEN** the input equals a control-point x value exactly
- **THEN** the result value is `points[i].$2 × range!.quantity!.value`

#### Scenario: Intermediate value is linearly interpolated
- **WHEN** the input lies strictly between two adjacent control points `x0` and `x1`
- **THEN** the result is the linear interpolation between `y0` and `y1`,
  multiplied by `range!.quantity!.value`, with dimension `range!.quantity!.dimension`

#### Scenario: Input below domain throws EvalException
- **WHEN** the input value is strictly less than `points.first.$1`
- **THEN** `EvalException` is thrown

#### Scenario: Input above domain throws EvalException
- **WHEN** the input value is strictly greater than `points.last.$1`
- **THEN** `EvalException` is thrown

#### Scenario: Input at lower boundary is accepted
- **WHEN** the input value equals `points.first.$1`
- **THEN** evaluation succeeds and returns `points.first.$2 × range!.quantity!.value`

#### Scenario: Input at upper boundary is accepted
- **WHEN** the input value equals `points.last.$1`
- **THEN** evaluation succeeds and returns `points.last.$2 × range!.quantity!.value`

---

### Requirement: PiecewiseFunction inverse evaluation
`PiecewiseFunction.evaluateInverse()` SHALL accept a single `Quantity` argument
conformable to the output dimension, find the x value in the control-point
domain whose forward evaluation produces the given y value, and return it as a
dimensionless `Quantity`.

The raw target y is computed as `yRaw = arg.value / range!.quantity!.value`.

`callInverse` validates the argument against `range` via `_validateSpec` before
`evaluateInverse` is entered, so `evaluateInverse` can assume `yRaw` is within
`[yMin, yMax]`.  The validation produces a precise out-of-range error without
scanning any segment.

A segment `(x0, y0)→(x1, y1)` contains `yRaw` when
`min(y0, y1) ≤ yRaw ≤ max(y0, y1)`.  The interpolated x for that segment is:

```
x = x0 + (yRaw − y0) / (y1 − y0) × (x1 − x0)
```

Because segments are ordered by ascending x, the first segment containing
`yRaw` always yields the smallest possible x.  `evaluateInverse` therefore
returns the result of the first matching segment immediately (early exit).
This is behaviourally equivalent to collecting all candidates and returning
the minimum, but without the allocation.

The return value is a dimensionless `Quantity`.

#### Scenario: Monotonic inverse returns the unique x
- **WHEN** `callInverse` is called on a monotonically increasing function with
  a y value that lies within the range
- **THEN** the result is the unique x whose forward evaluation produces that y

#### Scenario: Non-monotonic inverse returns the smallest x
- **WHEN** multiple segments contain the target y value
- **THEN** the result is the smallest candidate x across all matching segments

#### Scenario: y value below range minimum throws EvalException
- **WHEN** the target y value, after normalisation by `outputUnit.value`,
  is less than `yMin`
- **THEN** `EvalException` is thrown (by `callInverse`) before any segment
  is scanned

#### Scenario: y value above range maximum throws EvalException
- **WHEN** the target y value, after normalisation by `outputUnit.value`,
  is greater than `yMax`
- **THEN** `EvalException` is thrown (by `callInverse`) before any segment
  is scanned

#### Scenario: Inverse result is dimensionless
- **WHEN** `callInverse` succeeds
- **THEN** the returned `Quantity` has an empty dimension map

---

### Requirement: registerPiecewiseFunctions registers all piecewise functions
The system SHALL provide a top-level function
`registerPiecewiseFunctions(UnitRepository repo)` in the generated
`predefined_units.dart` that registers all `PiecewiseFunction` instances into
`repo`.

For each piecewise function, the output unit expression SHALL be resolved at
registration time by evaluating it via `ExpressionParser(repo: repo)`.  The
resulting `Quantity` is passed directly as `outputUnit` to the
`PiecewiseFunction` constructor.  `registerPiecewiseFunctions` SHALL be called
after `registerPredefinedUnits` and `registerBuiltinFunctions`, so all base
units are already present when output units are resolved.

`UnitRepository.withPredefinedUnits()` SHALL call `registerPiecewiseFunctions`
as part of its construction sequence.

#### Scenario: All piecewise functions available in standard repository
- **WHEN** a `UnitRepository` is created with `withPredefinedUnits()`
- **THEN** `findFunction("gasmark")` returns a non-null `PiecewiseFunction`

#### Scenario: Piecewise function range matches output unit
- **WHEN** a `PiecewiseFunction` for `gasmark` (output unit `degR`) is registered
- **THEN** its `range!.quantity!.dimension` equals the dimension of `degR`
  (i.e. `{'K': 1} — the kelvin primitive unit id`)
- **AND** its `range!.quantity!.value` equals the SI value of one `degR`
  (i.e. `5/9`)
