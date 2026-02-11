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

~~~~ dart
/// Represents a unit of measurement.
///
/// Each unit has a unique [id] (its primary short name), a list of [aliases]
/// (alternative names), and a [definition] that describes how to convert
/// values of this unit to/from primitive base units.
class Unit {
  /// Primary identifier (e.g., 'm', 'ft', 'kg').
  final String id;

  /// Alternative names (e.g., ['meter', 'metre'] for 'm').
  /// Does NOT need to include regular plurals — those are handled by
  /// the repo's plural stripping fallback.  Irregular plurals (e.g.,
  /// 'feet' for 'foot') must be listed explicitly.
  final List<String> aliases;

  /// Human-readable description (e.g., 'SI base unit of length').
  final String? description;

  /// How this unit converts to/from base units.
  final UnitDefinition definition;

  const Unit({
    required this.id,
    this.aliases = const [],
    this.description,
    required this.definition,
  });

  /// All recognized names for this unit: id + aliases.
  List<String> get allNames => [id, ...aliases];
}
~~~~

**Tests:** `test/core/domain/models/unit_test.dart`

- Construct Unit with various fields, verify allNames.
- Const construction works.
- Default aliases is empty list.


### Step 2: UnitDefinition Hierarchy

**File:** `lib/core/domain/models/unit_definition.dart`

~~~~ dart
/// Base class for unit definitions.
///
/// Provides the conversion contract: every definition can produce a Quantity
/// representing the given value in this unit, reduced to primitive base units.
abstract class UnitDefinition {
  const UnitDefinition();

  /// Convert [value] in this unit to a Quantity in primitive base units.
  /// May recurse through [repo] for chained definitions.
  ///
  /// Returns a Quantity whose value is the equivalent in base units and
  /// whose dimension is expressed in primitive unit IDs.
  Quantity toQuantity(double value, UnitRepository repo);

  /// Whether this is a primitive (base) unit definition.
  bool get isPrimitive;
}
~~~~

**PrimitiveUnitDefinition:**

~~~~ dart
/// A primitive (base) unit that defines a fundamental dimension.
///
/// The unit's ID becomes its own dimension key.  For example, the meter
/// unit (id: 'm') has dimension {m: 1}.  The value is returned unchanged.
class PrimitiveUnitDefinition extends UnitDefinition {
  /// The unit ID, used as the dimension key.  Set during registration.
  late final String _unitId;

  PrimitiveUnitDefinition();

  /// Called by UnitRepository during registration to bind the unit ID.
  void bind(String unitId) => _unitId = unitId;

  @override
  Quantity toQuantity(double value, UnitRepository repo) =>
      Quantity(value, Dimension({_unitId: 1}));

  @override
  bool get isPrimitive => true;
}
~~~~

**LinearDefinition:**

~~~~ dart
/// A unit defined as a linear multiple of another unit.
///
/// For example: 1 foot = 0.3048 meters, so feet has
/// LinearDefinition(factor: 0.3048, baseUnitId: 'm').
///
/// Chains are supported: 1 yard = 3 feet could be
/// LinearDefinition(factor: 3, baseUnitId: 'ft'), and resolution
/// recurses through feet to meters.
class LinearDefinition extends UnitDefinition {
  /// How many of [baseUnitId] equal one of this unit.
  /// i.e., 1 <this unit> = [factor] <baseUnit>
  final double factor;

  /// The ID of the unit this is defined in terms of.
  final String baseUnitId;

  const LinearDefinition({
    required this.factor,
    required this.baseUnitId,
  });

  @override
  Quantity toQuantity(double value, UnitRepository repo) {
    final baseUnit = repo.getUnit(baseUnitId);
    return baseUnit.definition.toQuantity(value * factor, repo);
  }

  @override
  bool get isPrimitive => false;
}
~~~~

**Design note on `bind()`:** PrimitiveUnitDefinition needs its unit's ID to
produce the correct dimension (e.g., `{m: 1}` for meters).  The repo calls
`bind(unitId)` during registration.  An alternative is passing unitId as a
constructor parameter, but `bind()` avoids requiring the ID in two places
(Unit.id and definition constructor).

**Tests:** `test/core/domain/models/unit_test.dart` (same file as Unit)

- PrimitiveUnitDefinition: after bind, toQuantity returns Quantity with
  the input value and dimension `{unitId: 1}`.
- LinearDefinition: toQuantity multiplies value by factor and recurses.
- Chain resolution: define yard = 3 ft, ft = 0.3048 m, m = primitive.
  Verify `yard.toQuantity(1.0, repo)` = Quantity(0.9144, {m: 1}).
- toQuantity returns primitive dimension regardless of chain depth.


### Step 3: UnitRepository

**File:** `lib/core/domain/models/unit_repository.dart`

~~~~ dart
/// Registry for unit definitions.  Provides lookup by name/alias with
/// automatic plural stripping fallback.
class UnitRepository {
  /// Maps every recognized name (id + aliases) to its Unit.
  final Map<String, Unit> _lookup = {};

  /// All registered units by their primary ID.
  final Map<String, Unit> _units = {};

  /// Creates an empty repository.
  UnitRepository();

  /// Creates a repository pre-loaded with the built-in unit set.
  factory UnitRepository.withBuiltinUnits() {
    final repo = UnitRepository();
    registerBuiltinUnits(repo);
    return repo;
  }

  /// Register a unit.  Adds the unit's id and all aliases to the
  /// lookup map.  Throws [ArgumentError] if any name collides with
  /// an existing entry.
  void register(Unit unit) {
    if (unit.definition is PrimitiveUnitDefinition) {
      (unit.definition as PrimitiveUnitDefinition).bind(unit.id);
    }

    _units[unit.id] = unit;

    for (final name in unit.allNames) {
      if (_lookup.containsKey(name)) {
        throw ArgumentError(
          "Unit name '$name' is already registered "
          "(for unit '${_lookup[name]!.id}')",
        );
      }
      _lookup[name] = unit;
    }
  }

  /// Look up a unit by any recognized name.
  ///
  /// Tries exact match first, then falls back to plural stripping
  /// (removes trailing 'es' or 's').  Returns null if not found.
  Unit? findUnit(String name) {
    // Exact match.
    final exact = _lookup[name];
    if (exact != null) return exact;

    // Plural stripping: try 'es' first, then 's'.
    if (name.length > 2 && name.endsWith('es')) {
      final stripped = name.substring(0, name.length - 2);
      final found = _lookup[stripped];
      if (found != null) return found;
    }
    if (name.length > 1 && name.endsWith('s')) {
      final stripped = name.substring(0, name.length - 1);
      final found = _lookup[stripped];
      if (found != null) return found;
    }

    return null;
  }

  /// Look up a unit by any recognized name, throwing if not found.
  Unit getUnit(String name) {
    final unit = findUnit(name);
    if (unit == null) {
      throw ArgumentError("Unknown unit: '$name'");
    }
    return unit;
  }

  /// All registered units (by primary ID).
  Iterable<Unit> get allUnits => _units.values;
}
~~~~

**Plural stripping order:** 'es' before 's'.  This handles "inches" → "inch"
correctly before trying "inche".  Regular plurals like "meters" → "meter" are
handled by the 's' fallback.  Irregular plurals like "feet" must be explicit
aliases since stripping 's' gives "feet" → "fee" (wrong).

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

~~~~ dart
/// Reduce a quantity to primitive base units.
///
/// Each non-primitive unit name in the quantity's dimension is resolved
/// through the repository using toQuantity(), and the resulting value
/// and dimension are combined.
///
/// If the dimension already contains only primitive unit names, the
/// quantity is returned unchanged.  Unknown unit names are kept as-is.
///
/// Example:
///   reduce(Quantity(5.0, Dimension({ft: 1})), repo)
///   → Quantity(1.524, Dimension({m: 1}))
Quantity reduce(Quantity quantity, UnitRepository repo) {
  double value = quantity.value;
  final newDimension = <String, int>{};

  for (final entry in quantity.dimension.units.entries) {
    final unitName = entry.key;
    final exponent = entry.value;

    final unit = repo.findUnit(unitName);
    if (unit == null || unit.definition.isPrimitive) {
      // Already primitive or unknown — keep as-is.
      newDimension[unitName] =
          (newDimension[unitName] ?? 0) + exponent;
      continue;
    }

    // Resolve to base units using toQuantity.
    final baseQuantity = unit.definition.toQuantity(1.0, repo);
    value *= math.pow(baseQuantity.value, exponent);

    // Replace with primitive dimension entries.
    for (final baseEntry in baseQuantity.dimension.units.entries) {
      newDimension[baseEntry.key] =
          (newDimension[baseEntry.key] ?? 0) +
          baseEntry.value * exponent;
    }
  }

  return Quantity(value, Dimension(newDimension));
}
~~~~

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

~~~~ dart
class EvalContext {
  /// Unit repository for resolving unit names.  Null means Phase 1
  /// behavior (all identifiers treated as raw dimensions).
  final UnitRepository? repo;

  const EvalContext({this.repo});
}
~~~~

**UnitNode.evaluate() changes:**

~~~~ dart
class UnitNode extends ASTNode {
  final String unitName;

  const UnitNode(this.unitName);

  @override
  Quantity evaluate(EvalContext context) {
    final repo = context.repo;
    if (repo == null) {
      // No repo: Phase 1 behavior (raw dimension).
      return Quantity(1.0, Dimension({unitName: 1}));
    }

    final unit = repo.findUnit(unitName);
    if (unit == null) {
      // Unknown unit: fall back to raw dimension.
      return Quantity(1.0, Dimension({unitName: 1}));
    }

    // Resolve to base units using toQuantity.
    return unit.definition.toQuantity(1.0, repo);
  }

  @override
  String toString() => 'UnitNode($unitName)';
}
~~~~

**Backward compatibility:** When repo is null, the behavior is identical to
Phase 1.  `const EvalContext()` produces null repo.  All 372 existing tests
use `const EvalContext()` implicitly through ExpressionParser and are unaffected.

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

~~~~ dart
class ExpressionParser {
  /// Optional unit repository for unit-aware evaluation.
  final UnitRepository? repo;

  ExpressionParser({this.repo});

  /// Lex, parse, and evaluate an expression string.
  Quantity evaluate(String input) {
    final ast = parse(input);
    return ast.evaluate(EvalContext(repo: repo));
  }

  /// Lex and parse an expression string, returning the AST.
  ASTNode parse(String input) {
    final tokens = tokenize(input);
    return Parser(tokens).parse();
  }

  /// Lex an expression string, returning the token list.
  List<Token> tokenize(String input) {
    return Lexer(input).scanTokens();
  }
}
~~~~

**Tests:** `test/core/domain/parser/expression_parser_test.dart` (add or extend)

- End-to-end with repo: `ExpressionParser(repo: repo).evaluate('5 ft')`.
- End-to-end without repo: `ExpressionParser().evaluate('5 m')` → Phase 1
  behavior.

**Deliverable test:**

~~~~ dart
test('Phase 2 deliverable: convert 5 feet to meters', () {
  final repo = UnitRepository.withBuiltinUnits();
  final parser = ExpressionParser(repo: repo);

  // Evaluate "5 ft" — produces Quantity in base units (meters)
  final quantity = parser.evaluate('5 ft');
  expect(quantity.value, closeTo(1.524, 1e-10));
  expect(quantity.dimension, Dimension({'m': 1}));

  // Convert to feet by dividing by the base quantity for 1 foot
  final feet = repo.getUnit('ft');
  final feetBase = feet.definition.toQuantity(1.0, repo);
  final inFeet = quantity.value / feetBase.value;
  expect(inFeet, closeTo(5.0, 1e-10));

  // Convert to miles similarly
  final miles = repo.getUnit('mi');
  final milesBase = miles.definition.toQuantity(1.0, repo);
  final inMiles = quantity.value / milesBase.value;
  expect(inMiles, closeTo(5.0 * 0.3048 / 1609.344, 1e-10));
});
~~~~


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
