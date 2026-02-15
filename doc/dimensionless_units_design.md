Unitary - Dimensionless Units Design
=====================================

This document describes the design for handling dimensionless units (radian and
steradian) in Unitary.  These units require special treatment because they carry
a dimension during expression evaluation but should be treated as dimensionless
when checking whether two expressions are conformable for conversion.

**Status:** Design Document (future enhancement)
**Created:** February 2026
**Related Documents:** [Architecture](architecture.md), [Terminology](terminology.md), [Quantity Arithmetic Design](quantity_arithmetic_design.md)

---


Table of Contents
-----------------

1. [Problem Statement](#problem-statement)
2. [Recommended Approach](#recommended-approach)
3. [Key Design Decisions](#key-design-decisions)
4. [Affected Code Paths](#affected-code-paths)
5. [Open Questions](#open-questions)

---


Problem Statement
-----------------

The SI system classifies radian and steradian as dimensionless derived units:

- **radian** - unit of plane angle
- **steradian** (sr) - unit of solid angle

These units are formally dimensionless (defined as ratios of like quantities:
arc length / radius for radian, area / radius^2 for steradian), but treating
them as *purely* dimensionless creates problems in expression evaluation:

### The dual nature of dimensionless units

**During evaluation, dimensionless units must carry a dimension** so that
dimensional analysis catches errors:

~~~~
radian + 1          ERROR: cannot add angle to dimensionless
radian + meter      ERROR: cannot add angle to length
radian + radian     OK: 2 radian
sin(pi/2 radian)    OK: dimensionless result
~~~~

If radian were fully dimensionless, `radian + 1` would silently produce `2`,
which is physically meaningless.

**During conversion, dimensionless units must be treated as dimensionless** so
that physically meaningful conversions work:

~~~~
radian/s -> Hz      OK: angular frequency is conformable with frequency
                    (both reduce to 1/s when radian is stripped)
sr * W/m^2 -> W/m^2 OK: radiance includes steradians
~~~~

If radian retained its dimension during conversion, `radian/s` would have
dimension `{radian: 1, s: -1}` while `Hz` would have dimension `{s: -1}`, and
they would be rejected as non-conformable.

### Concrete examples

| Expression                | Expected behavior                                          |
|---------------------------|------------------------------------------------------------|
| `1 radian + 1`            | Error: incompatible dimensions                             |
| `1 radian + 1 radian`     | `2 radian`                                                 |
| `2 * pi radian`           | `6.283... radian` (dimensionless scalar multiplication OK) |
| `radian/s` to `Hz`        | Conformable (1 radian/s = 1/(2*pi) Hz)                     |
| `1 sr * W/m^2` to `W/m^2` | Conformable (strip sr)                                     |
| `1 radian^2`              | `1 sr` (angle squared is solid angle)                      |

---


Recommended Approach
--------------------

### 1. `isDimensionless` flag on PrimitiveUnit

Add a boolean flag to `PrimitiveUnit` indicating that the unit is a
dimensionless unit:

~~~~ dart
class PrimitiveUnit extends Unit {
  final bool isDimensionless;

  const PrimitiveUnit({
    required super.id,
    super.aliases,
    super.description,
    this.isDimensionless = false,
  });

  @override
  bool get isPrimitive => true;
}
~~~~

Register radian and steradian with this flag:

~~~~ dart
PrimitiveUnit(
  id: 'radian',
  description: 'SI dimensionless unit of plane angle',
  isDimensionless: true,
)

PrimitiveUnit(
  id: 'sr',
  aliases: ['steradian'],
  description: 'SI dimensionless unit of solid angle',
  isDimensionless: true,
)
~~~~

### 2. `Dimension.removeDimensions()` method

Add a method to `Dimension` that returns a new `Dimension` with the specified
dimension entries removed.  This is used to strip dimensionless units when
checking conformability for conversion:

~~~~ dart
class Dimension {
  /// Returns this dimension with the specified dimension entries removed.
  ///
  /// Used for conversion conformability checking, where dimensionless
  /// units like radian and steradian are stripped before comparing.
  Dimension removeDimensions(Set<String> idsToRemove) {
    final filtered = Map<String, int>.from(components);
    filtered.removeWhere((id, _) => idsToRemove.contains(id));
    return Dimension(filtered);
  }
}
~~~~

### 3. Repository exposes dimensionless unit ID set

`UnitRepository` provides a set of dimensionless unit IDs, computed once at
registration time:

~~~~ dart
class UnitRepository {
  final Set<String> _dimensionlessIds = {};

  void register(Unit unit) {
    // ... existing registration logic ...
    if (unit is PrimitiveUnit && unit.isDimensionless) {
      _dimensionlessIds.add(unit.id);
    }
  }

  /// IDs of all dimensionless primitive units (radian, steradian, etc.).
  Set<String> get dimensionlessIds => Set.unmodifiable(_dimensionlessIds);
}
~~~~

### 4. Conversion service uses stripped dimension

The conversion path (currently the `reduce` function in `unit_service.dart`)
uses `removeDimensions()` when checking whether two quantities are conformable
for conversion, but NOT during normal arithmetic:

~~~~ dart
/// Check whether [from] can be converted to [targetUnit].
bool canConvert(Quantity from, Unit targetUnit, UnitRepository repo) {
  final targetQty = resolveUnit(targetUnit, repo);
  final dlIds = repo.dimensionlessIds;
  return from.dimension.removeDimensions(dlIds)
      == targetQty.dimension.removeDimensions(dlIds);
}
~~~~

---


Key Design Decisions
--------------------

### Strip dimensionless units regardless of exponent

When computing `removeDimensions()`, remove all matching entries regardless of
their exponent value.  This handles cases like:

- `radian/s` -> strip `radian^1` -> dimension `{s: -1}` (conformable with Hz)
- `sr * W/m^2` -> strip `sr^1` -> dimension `{kg: 1, s: -3}` (conformable
  with W/m^2)
- `radian^2/s` -> strip `radian^2` -> dimension `{s: -1}` (still works)

The alternative (only stripping exponent 1) would break for legitimate
higher-order angle expressions.

### Strict conformability (add/subtract) unchanged

The existing `Dimension.isConformableWith()` check (exact dimension equality)
remains unchanged for addition and subtraction.  This means:

- `1 radian + 1` remains an error (different dimensions)
- `1 radian + 1 radian` works (same dimensions)
- `1 radian + 1 sr` remains an error (different dimensions)

Dimensionless unit stripping applies **only** at the conversion boundary, not
during arithmetic.

### Stripping only at conversion boundary

Dimensionless dimensions are stripped only when the user explicitly requests a
conversion (e.g., `radian/s` to `Hz`).  During intermediate evaluation steps,
dimensionless units are tracked like any other dimension.  This preserves
dimensional analysis throughout expression evaluation and only relaxes the
check at the point where the user asks "are these two things the same kind of
quantity?"

This is the same approach GNU Units takes: `units 'radian/s' 'Hz'` succeeds,
but the radian is tracked internally.

---


Affected Code Paths
--------------------

### Already implemented

| File                                          | Function/class    | Change                                                   |
|-----------------------------------------------|-------------------|----------------------------------------------------------|
| `lib/core/domain/models/unit.dart`            | `PrimitiveUnit`   | `isDimensionless` field                                  |
| `lib/core/domain/models/dimension.dart`       | `Dimension`       | `removeDimensions()` method                              |
| `lib/core/domain/models/unit_repository.dart` | `UnitRepository`  | `dimensionlessIds` property                              |
| `lib/core/domain/data/builtin_units.dart`     | Unit registration | `radian` and `sr` registered as dimensionless primitives |

### Future (when conversion interface is built)

| File                                         | Function/class | Change                                                 |
|----------------------------------------------|----------------|--------------------------------------------------------|
| `lib/core/domain/services/unit_service.dart` | conversion     | Use `removeDimensions()` for conversion conformability |

---


Open Questions
--------------

1. **Degree (angle) handling**: Should `degree` (angle) also be marked as
   dimensionless, or should it be a derived unit defined in terms of radian?
   Defining it as `pi/180 radian` means it inherits dimensionless behavior
   through reduction, which seems correct.

2. **User-defined dimensionless units**: Should users be able to mark custom
   units as dimensionless?  This seems unlikely to be needed but could be
   supported trivially since it's just a flag.

3. **Display behavior**: When a conversion strips dimensionless units, should
   the UI indicate that angle dimensions were dropped?  For example,
   `radian/s -> Hz` could show a note like "(angle dimension dropped)".

4. **Conversion factor**: When converting `radian/s` to `Hz`, the conversion
   factor is `1/(2*pi)` (since `1 Hz = 2*pi radian/s`).  The stripping of the
   dimensionless dimension enables the conformability check, but the actual
   numeric conversion still needs to account for the `2*pi` factor correctly.
   This should happen naturally if `Hz` is defined as `1/s` and the radian
   dimension is simply dropped (1 radian/s = 1/s numerically when radian is
   dimensionless), giving `1 radian/s = 1 Hz` without the `2*pi` factor.
   Whether this is the desired behavior (as in GNU Units, where `radian` has
   value 1) or whether `Hz` should explicitly include the `2*pi` factor needs
   to be decided when implementing the conversion interface.

---

*Last Updated: February 14, 2026*
