Phase 2: Unit System Foundation
===============================

> **Status: COMPLETE**
>
> 492 tests passing (373 Phase 1 + 119 Phase 2). Completed February 7, 2026.


Overview
--------

**Goal:** Build the unit definition system and integrate it with the evaluator
so that unit names resolve to real units with conversion factors.

**Deliverable:** A Dart API that converts "5 feet" to meters programmatically:

~~~~ dart
final repo = UnitRepository.withBuiltinUnits();
final parser = ExpressionParser(repo: repo);
final quantity = parser.evaluate('5 ft');
// quantity == Quantity(1.524, {m: 1})

final feet = repo.getUnit('ft');
final feetBase = feet.definition.toQuantity(1.0, repo);
final inFeet = quantity.value / feetBase.value;
// inFeet ≈ 5.0
~~~~

**Scope boundaries:**

- Only PrimitiveUnitDefinition and LinearDefinition — no affine (temperature)
  or compound (expression-based) definitions.
- No SI prefix splitting — prefixed units (km, mg, ms) are registered as
  explicit entries.
- No conversion syntax in the expression grammar — conversion is computed by
  reducing both quantities and dividing values.
- No constants (pi, c, e) as units.
- Backward compatible — all 372 Phase 1 tests pass unchanged.

---


Design Decisions
----------------

These decisions were made during the Phase 2 design review:

1. **Quantity stays pure:** Quantity remains a pure value object with `value`
   and `dimension` fields only.  No `displayUnit` field.  No dependency on
   UnitRepository.

2. **Evaluator does eager reduction:** When UnitNode.evaluate() encounters a
   unit name, it resolves it to base units immediately via the repo.  By the
   time arithmetic happens, all operands are in primitive base units.

3. **Recursive resolution at lookup time:** LinearDefinition.toQuantity() recurses
   through the definition chain each time.  No pre-flattening at repo load
   time.  Chain depths are small (typically 1 hop since definitions point
   directly to primitives).

4. **Hand-curated Dart code for unit definitions:** Units are registered via
   Dart code in a `registerBuiltinUnits()` function.  No JSON assets or
   database loading.  Compile-time type safety and easy testing.

5. **Flat alias map with plural stripping:** UnitRepository maintains a
   `Map<String, Unit>` keyed by every name and alias.  When a direct lookup
   fails, it tries removing 'es' then 's' as a plural fallback.  Irregular
   plurals (like "feet") must be explicit aliases.

6. **Conversion is computed by division:** To convert a quantity to a different
   unit, reduce both the quantity and the target unit to primitives, then divide
   their values.  No `to` or `->` syntax in the parser grammar.

7. **General-purpose reduce() utility:** A `reduce(Quantity, repo)` function
   handles reducing compound dimensions to primitives.  Useful for test code
   and callers outside the evaluator, even though the evaluator's eager
   reduction means it typically produces already-reduced quantities.

8. **Backward-compatible EvalContext:** `EvalContext.repo` is nullable.  When
   null, UnitNode falls back to Phase 1 behavior (raw dimension).  All
   existing tests continue to pass with `const EvalContext()`.

9. **Unknown units are permissive:** When a repo is present but a unit name is
   not found, UnitNode falls back to raw dimension behavior rather than
   throwing.  This avoids breaking expressions that reference units not yet in
   the hand-curated set.

---


Implementation Steps
--------------------


### Step 1: Unit Class

**File:** `lib/core/domain/models/unit.dart`

`Unit` has a primary `id`, a list of `aliases`, a `description`, and a
`definition` that describes how to convert to/from base units.  The `allNames`
getter returns id + aliases.  Regular plurals are handled by the repo's plural
stripping; irregular plurals (like "feet") must be explicit aliases.  Units are
const-constructible.

**Tests:** `test/core/domain/models/unit_test.dart`

- Construct Unit with various fields, verify allNames.
- Const construction works.
- Default aliases is empty list.


### Step 2: UnitDefinition Hierarchy

**File:** `lib/core/domain/models/unit_definition.dart`

`UnitDefinition` is the base class providing the conversion contract: every
definition can produce a `Quantity` representing the given value reduced to
primitive base units.

- **`PrimitiveUnitDefinition`** — the unit's ID becomes its own dimension key
  (e.g., meter → `{m: 1}`).  The repo calls `bind(unitId)` during registration
  to set the dimension key, avoiding requiring the ID in two places (Unit.id
  and definition constructor).

- **`LinearDefinition`** — a unit defined as a linear multiple of another unit,
  with a `factor` and `baseUnitId`.  Resolution recurses through the chain:
  e.g., yard (factor 3, base ft) → foot (factor 0.3048, base m) → meter
  (primitive).

**Tests:** `test/core/domain/models/unit_test.dart` (same file as Unit)

- PrimitiveUnitDefinition: after bind, toQuantity returns Quantity with
  the input value and dimension `{unitId: 1}`.
- LinearDefinition: toQuantity multiplies value by factor and recurses.
- Chain resolution: define yard = 3 ft, ft = 0.3048 m, m = primitive.
  Verify `yard.toQuantity(1.0, repo)` = Quantity(0.9144, {m: 1}).
- toQuantity returns primitive dimension regardless of chain depth.


### Step 3: UnitRepository

**File:** `lib/core/domain/models/unit_repository.dart`

`UnitRepository` is the registry for unit definitions.  It maintains a lookup
map keyed by every recognized name (id + aliases).  Registration binds
primitive units and checks for name collisions.

`findUnit(name)` tries exact match first, then falls back to plural stripping:
"ies" → "y", then "es", then "s" (with minimum length guards).  This handles
"inches" → "inch" and "meters" → "meter" automatically.  Irregular plurals
like "feet" must be explicit aliases.

`findUnitWithPrefix(name)` extends this with prefix-aware lookup (see
architecture.md for the full resolution order).

`getUnit(name)` is a throwing variant of `findUnit`.

A factory `UnitRepository.withBuiltinUnits()` creates a pre-loaded repository.

**Tests:** `test/core/domain/models/unit_repository_test.dart`

- Register and look up by id.
- Look up by alias.
- Plural stripping: "meters" → finds "meter" alias, "inches" → finds "inch"
  alias, "hours" → finds "hour" alias.
- Explicit irregular plural: "feet" → finds "feet" alias (not via stripping).
- Name collision: registering same name twice throws ArgumentError.
- findUnit returns null for unknown names.
- getUnit throws ArgumentError for unknown names.
- allUnits returns all registered units.
- factory `withBuiltinUnits()` creates a populated repository.
- Primitive binding: after registration, primitive's toQuantity works.


### Step 4: Built-in Unit Definitions

**File:** `lib/core/domain/data/builtin_units.dart`

Top-level function `registerBuiltinUnits(UnitRepository repo)` that registers
all hand-curated units.

#### Length Units (10)

| ID    | Aliases                        | Definition |
|-------|--------------------------------|------------|
| `m`   | meter, metre                   | Primitive  |
| `km`  | kilometer, kilometre           | 1000 m     |
| `cm`  | centimeter, centimetre         | 0.01 m     |
| `mm`  | millimeter, millimetre         | 0.001 m    |
| `um`  | micrometer, micrometre, micron | 1e-6 m     |
| `in`  | inch                           | 0.0254 m   |
| `ft`  | foot, feet                     | 0.3048 m   |
| `yd`  | yard                           | 0.9144 m   |
| `mi`  | mile                           | 1609.344 m |
| `nmi` | nautical_mile                  | 1852 m     |

#### Mass Units (6)

| ID   | Aliases           | Definition        |
|------|-------------------|-------------------|
| `kg` | kilogram          | Primitive         |
| `g`  | gram              | 0.001 kg          |
| `mg` | milligram         | 1e-6 kg           |
| `lb` | pound             | 0.45359237 kg     |
| `oz` | ounce             | 0.028349523125 kg |
| `t`  | tonne, metric_ton | 1000 kg           |

#### Time Units (6)

| ID     | Aliases     | Definition |
|--------|-------------|------------|
| `s`    | second, sec | Primitive  |
| `ms`   | millisecond | 0.001 s    |
| `min`  | minute      | 60 s       |
| `hr`   | hour        | 3600 s     |
| `day`  |             | 86400 s    |
| `week` | wk          | 604800 s   |

**Notes:**

- `kg` is the SI base unit of mass, not `g`.  This is correct per SI.
  When prefixes are added in Phase 3, "kilogram" will need special handling.
- `in` as a unit ID is fine — it's a string, not a Dart keyword.
- All non-primitive units use direct-to-primitive factors (e.g., mile → m
  directly, not mile → ft → m) to minimize floating-point chain errors.
- Conversion factors are from NIST/SI reference values.

**Tests:** `test/core/domain/data/builtin_units_test.dart`

- All units register without collision.
- Spot-check conversion factors:
  - 1 ft → 0.3048 m
  - 1 mi → 1609.344 m
  - 1 in → 0.0254 m
  - 1 yd → 0.9144 m
  - 1 km → 1000 m
  - 1 lb → 0.45359237 kg
  - 1 oz → 0.028349523125 kg
  - 1 hr → 3600 s
  - 1 min → 60 s
  - 1 day → 86400 s
- Alias resolution:
  - "meter" → unit "m"
  - "metre" → unit "m"
  - "foot" → unit "ft"
  - "feet" → unit "ft"
  - "mile" → unit "mi"
  - "kilogram" → unit "kg"
- Plural stripping:
  - "meters" → unit "m" (via "meter" + strip "s")
  - "inches" → unit "in" (via "inch" + strip "es")
  - "pounds" → unit "lb" (via "pound" + strip "s")
- toQuantity dimension for each unit returns the correct primitive dimension:
  - Length units → {m: 1}
  - Mass units → {kg: 1}
  - Time units → {s: 1}


### Step 5: reduce() Utility

**File:** `lib/core/domain/services/unit_service.dart`

**`reduce(Quantity, UnitRepository)`:**

Reduces a quantity to primitive base units.  For each non-primitive unit name
in the dimension, resolves it through the repository's `toQuantity()` chain,
adjusting the value by `pow(baseValue, exponent)` and replacing the dimension
entry with the resolved primitive entries.  Primitive and unknown unit names
are kept as-is.

Example: `reduce(Quantity(5.0, {ft: 1}), repo)` → `Quantity(1.524, {m: 1})`

**Tests:** `test/core/domain/services/unit_service_test.dart`

reduce() tests:

- Quantity already in primitives → no-op (value and dimension unchanged).
- Single non-primitive: `Quantity(5.0, {ft: 1})` → `Quantity(1.524, {m: 1})`.
- Compound dimension: `Quantity(60.0, {mi: 1, hr: -1})` →
  `Quantity(26.8224, {m: 1, s: -1})`.
- With exponents: `Quantity(1.0, {ft: 2})` → `Quantity(0.3048^2, {m: 2})`.
- Mixed primitive/non-primitive: `Quantity(5.0, {ft: 1, kg: 1})` →
  `Quantity(1.524, {m: 1, kg: 1})`.
- Unknown unit name → kept as-is in dimension.


### Step 6: Evaluator Integration

**Modified file:** `lib/core/domain/parser/ast.dart`

**EvalContext changes:**

`EvalContext` gains a nullable `repo` field.  When null, `UnitNode` falls back
to Phase 1 behavior (raw dimension `{unitName: 1}`).  When a repo is present,
`UnitNode.evaluate()` resolves the unit name through the repository and returns
the base-unit quantity.  Unknown unit names also fall back to raw dimension.

**Backward compatibility:** `const EvalContext()` produces null repo.  All 372
existing Phase 1 tests are unaffected.

**Tests in** `test/core/domain/parser/evaluator_test.dart` (add new group):

- `5 ft` with repo → `Quantity(1.524, {m: 1})`.
- `5 feet` with repo → same result (alias resolution).
- `5 ft + 3 m` → `Quantity(4.524, {m: 1})`.
- `5 ft * 2 s` → `Quantity(3.048, {m: 1, s: 1})`.
- `5 ft / 2 s` → `Quantity(0.762, {m: 1, s: -1})`.
- `(3 ft)^2` → `Quantity(0.83612736, {m: 2})`.
- `sqrt(9 ft^2)` → `Quantity(0.9144, {m: 1})`.
- Unknown unit with repo falls back to raw dimension.
- No repo (null) preserves Phase 1 behavior — verify with a few existing cases.


### Step 7: ExpressionParser Integration

**Modified file:** `lib/core/domain/parser/expression_parser.dart`

`ExpressionParser` gains an optional `repo` parameter.  It provides `evaluate`
(lex → parse → evaluate), `parse` (lex → parse → AST), and `tokenize`
(lex → tokens) methods.

**Tests:** `test/core/domain/parser/expression_parser_test.dart` (add or extend)

- End-to-end with repo: `ExpressionParser(repo: repo).evaluate('5 ft')`.
- End-to-end without repo: `ExpressionParser().evaluate('5 m')` → Phase 1
  behavior.
- Deliverable test: evaluate `'5 ft'` → `Quantity(1.524, {m: 1})`, then
  convert back to feet and miles by dividing by the base quantity.


### Step 8: Update Documentation

- Update `doc/implementation_plan.md`: mark Phase 2 tasks with [x], add
  completion date and test count.
- Update `doc/design_progress.md`: mark unit system items as complete.
- Update `README.md`: update Current Progress section.

---


File Summary
------------

### New production code

| File                                          | Contents                                                        |
|-----------------------------------------------|-----------------------------------------------------------------|
| `lib/core/domain/models/unit.dart`            | `Unit` class                                                    |
| `lib/core/domain/models/unit_definition.dart` | `UnitDefinition`, `PrimitiveUnitDefinition`, `LinearDefinition` |
| `lib/core/domain/models/unit_repository.dart` | `UnitRepository` class with alias lookup                        |
| `lib/core/domain/services/unit_service.dart`  | `reduce()` function                                             |
| `lib/core/domain/data/builtin_units.dart`     | `registerBuiltinUnits()` function                               |

### Modified production code

| File                                            | Changes                                                          |
|-------------------------------------------------|------------------------------------------------------------------|
| `lib/core/domain/parser/ast.dart`               | `EvalContext` gains `repo`; `UnitNode.evaluate()` resolves units |
| `lib/core/domain/parser/expression_parser.dart` | `ExpressionParser` gains optional `repo` parameter               |

### New test code

| File                                                | Contents                                   |
|-----------------------------------------------------|--------------------------------------------|
| `test/core/domain/models/unit_test.dart`            | Unit class, UnitDefinition hierarchy       |
| `test/core/domain/models/unit_repository_test.dart` | Registration, lookup, plural stripping     |
| `test/core/domain/services/unit_service_test.dart`  | reduce() algorithm                         |
| `test/core/domain/data/builtin_units_test.dart`     | Built-in unit registration and conversions |

### Modified test code

| File                                          | Changes                         |
|-----------------------------------------------|---------------------------------|
| `test/core/domain/parser/evaluator_test.dart` | Add unit-aware evaluation tests |

---


Implementation Order
--------------------

Each step's tests should be written and passing before proceeding to the next:

1. **Unit + UnitDefinition** (no dependencies on other new code)
2. **UnitRepository** (depends on Unit, UnitDefinition)
3. **Built-in unit definitions** (depends on Unit, UnitDefinition, UnitRepository)
4. **reduce()** (depends on UnitRepository)
5. **Evaluator integration** — modify EvalContext and UnitNode (depends on
   UnitRepository; verify backward compatibility with existing tests)
6. **ExpressionParser integration** — wire repo through (depends on all above;
   write deliverable test)
7. **Documentation updates**

---


Risks and Mitigations
---------------------

### Risk 1: Alias/plural collisions

**Scenario:** Plural stripping produces false matches.

**Mitigation:** Stripping is a simple fallback.  False positives are unlikely
in the unit domain.  If one arises, add the problematic form as an explicit
alias on the correct unit (or as a non-matching explicit alias on a sentinel).

### Risk 2: Circular unit definitions

**Scenario:** Unit A defined in terms of B, and B in terms of A.

**Mitigation:** Hand-curated set is small and manually verified.  All
non-primitive units point directly to primitives (no chains), so cycles are
structurally impossible in Phase 2.  For Phase 8 (GNU Units import), add
cycle detection during loading.

### Risk 3: Floating-point precision in chained conversions

**Scenario:** Chains accumulate more error than direct conversion.

**Mitigation:** All non-primitive units in the built-in set use direct-to-
primitive factors (e.g., mile = 1609.344 m, not mile = 5280 ft).  No chains
through non-primitive intermediaries in the built-in set.

### Risk 4: Backward compatibility with Phase 1 tests

**Scenario:** Changing EvalContext or UnitNode breaks existing tests.

**Mitigation:** EvalContext.repo is nullable with null default.  UnitNode
falls back to Phase 1 behavior when repo is null.  Verified by running all
372 existing tests.

---


Open Decisions for Phase 3
--------------------------

- AffineDefinition (temperature with offsets) and the `tempF(60)` syntax
- CompoundDefinition (expression-based units like Newton = kg*m/s^2)
- SI prefix splitting in the lexer (`km` → `kilo` + `m`)
- Physical constants as units (pi, c, e)
- Definition request node evaluation (standalone `meter` → show definition)
- Conversion syntax in the expression grammar (`5 ft to meters`)
- DimensionRegistry (dimension → human-readable category names)

---

*This document captures all design decisions and implementation details for
Phase 2 as agreed during the design review session of February 6, 2026.*
