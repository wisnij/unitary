Plan: Implement Quantity Evaluation & Comparison Logic
======================================================


Overview
--------

Implement the core domain layer for Unitary: Dimension, Rational, Unit/UnitDefinition stubs, UnitRepository, and the Quantity class with full arithmetic, comparison, and conversion logic. All pure Dart — no Flutter dependency.

**Workflow:** For each code step, write the unit tests FIRST, then implement the code to make them pass.


Files to Create (in order)
--------------------------

### Step 0: Project scaffold

- **`pubspec.yaml`** — Minimal Dart package with `test` dev dependency
- Create `lib/core/domain/models/` and `test/core/domain/models/` directories
- Run `dart pub get`

### Step 1: `lib/core/domain/models/errors.dart`

- `DimensionException extends Exception` — conformability failures
- `EvalException extends Exception` — computation failures (div-by-zero, NaN, etc.)
- No dependencies, no dedicated tests (validated through other tests)

### Step 2: `test/core/domain/models/dimension_test.dart` THEN `lib/core/domain/models/dimension.dart`

- `Dimension` with `Map<String, int> units` (unmodifiable, zeros stripped in constructor)
- `Dimension.dimensionless` — empty map
- `multiply(other)`, `divide(other)` — add/subtract exponent maps
- `power(num)` — multiply exponents, validate results are integral, throw `DimensionException` if not
- `isDimensionless`, `isConformableWith(other)`, `canonicalRepresentation()`
- `==` / `hashCode` — deep map equality with sorted deterministic hash

### Step 3: `test/core/domain/models/rational_test.dart` THEN `lib/core/domain/models/rational.dart`

- `Rational(numerator, denominator)` — int pair
- `Rational.fromDouble(value, {maxDenominator = 100})` — continued fractions algorithm
- Handles NaN/infinity (throws `ArgumentException`), negatives, exact integers
- `toDouble()`, `==` (cross-multiply), `hashCode`, `toString()`

### Step 4: `lib/core/domain/models/display_settings.dart`

- `NotationStyle` enum (plain, scientific, engineering)
- `DisplaySettings` data class (precision, notation, showDimension, useDisplayUnit)

### Step 5: `test/core/domain/models/unit_test.dart` THEN `lib/core/domain/models/unit.dart`

- `UnitLookup` abstract interface (breaks circular dep with repository)
- `Unit` class (id, aliases, description, definition)
- `UnitDefinition` abstract class with `toQuantity(value, repo)` returning a `Quantity` in primitive units
- `PrimitiveUnitDefinition` — identity; `toQuantity` returns `Quantity(value, Dimension({unitId: 1}))`
- `LinearDefinition` — factor-based conversion; `toQuantity` recurses through the definition chain to produce a `Quantity` in primitive units.
- `AffineDefinition` — `(value + offset) * factor` for absolute temperature; offset + linear base
- Tests use a simple `UnitLookup` stub built from a `Map<String, Unit>`

### Step 6: `lib/core/domain/models/unit_repository.dart`

- `UnitRepository implements UnitLookup`
- `registerUnit(unit)`, `getUnit(id)` (throws on missing), `tryGetUnit(id)`
- Tested indirectly through unit and quantity tests

### Step 7: `test/core/domain/models/quantity_test.dart` THEN `lib/core/domain/models/quantity.dart` — THE MAIN DELIVERABLE

**Constructors:**

- `Quantity(value, dimension, {displayUnit})` — validates NaN (fail-fast)
- `Quantity.dimensionless(value)`, `Quantity.fromUnit(value, unit, repo)`

**Arithmetic:**

- `+` / `-` — require conformable dimensions; **reduce both operands to primitives first** (necessary for correctness when operands use different units, e.g. `5 km + 3 mi`). Result has no displayUnit. Requires `UnitLookup` parameter.
- `*` — multiply raw values and dimensions; does NOT reduce. No displayUnit on result.
- `/` — check zero, divide raw values and dimensions; does NOT reduce. No displayUnit on result.
- `negate()` / `abs()` — preserve dimension and displayUnit
- `power(num)` — does NOT reduce; rational recovery via `Rational.fromDouble` for dimensioned quantities; validate dimension exponents divisible by denominator; build new int exponent map directly

**Key principle:** `*`, `/`, `power`, `negate`, `abs` work on the stored `value` field directly without reduction. `+` and `-` reduce both operands first since values must be in the same base units for the arithmetic to be meaningful. Explicit reduction also available via `reduceToPrimitives()`.

**Comparison:**

- `isConformableWith(other)` — dimension equality
- `approximatelyEquals(other, {tolerance})` — reduces both to primitives first, then compares
- `compareTo(other)` — reduces both to primitives first, then compares; throws `DimensionException` if not conformable
- `==` / `hashCode` — exact value + dimension (excludes displayUnit)

**Query:** `isDimensionless`, `isZero`, `isPositive`, `isNegative`

**Conversion:**

- `reduceToPrimitives(repo)` — converts to primitive representation via unit's `toQuantity`

### Step 8: `lib/core/domain/models/models.dart`

- Barrel export of all model files


Key Design Decisions
--------------------

- **`+`/`-` reduce operands; `*`/`/` do not** — addition/subtraction need common base units for correctness; multiplication/division operate on raw values.  `^` reduces its left operand if it is not dimensionless and its right operand is a rational with denominator greater than 1.
- **Tests first** — write test file before implementation for each step
- **LinearDefinition uses expression stub** — a `Quantity Function(UnitLookup)` closure that will be replaced by parsed expressions when the parser is ready
- Dimension exponents are `int`, not `num`
- `UnitLookup` interface in `unit.dart` breaks the circular dependency
- `Quantity.==` excludes `displayUnit` (mathematical equality)
- `Quantity.power` computes new exponents via integer division after rational validation
- Errors extend `Exception` (not `Error`) per Dart exception semantics


Verification
------------

1. `dart pub get` succeeds
2. `dart test` — all tests pass
3. Key test scenarios:
   - `5m + 3m = 8m`, `5m + 3s` throws
   - `5m * 3s = 15 m·s`, `10m / 2s = 5 m/s`
   - `+`/`-` reduce: `Quantity(5, dim, displayUnit: km) + Quantity(3, dim, displayUnit: mi)` produces value in base meters
   - `*`/`/` do NOT reduce: `Quantity(5, dim, displayUnit: km) * Quantity(2, ...)` keeps raw value=10
   - `(4 m^2)^0.5 = 2m`, `(5 m^3)^0.5` throws
   - `Rational.fromDouble(0.5)` = 1/2
   - 5 km converts to 5000 m, round-trips accurately
   - Affine: 0°C = 273.15 K
   - NaN in constructor throws, infinity allowed
   - `compareTo` reduces before comparing
