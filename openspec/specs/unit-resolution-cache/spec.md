# Unit Resolution Cache

## Purpose

Cache resolved base-unit `Quantity` values inside `UnitRepository` so that repeated
unit resolutions skip the full resolution chain.  Move the free-function `resolveUnit`
into `UnitRepository` as a public method and delete the standalone free function.

## Requirements

### Requirement: UnitRepository exposes resolveUnit
`UnitRepository` SHALL provide a public `resolveUnit(Unit unit, [Set<String>? visited])` method
that resolves a unit to its base-unit `Quantity` representation (equivalent to 1 of the given
unit expressed in primitive base units).  The resolution logic previously in the free function
`resolveUnit()` in `unit_resolver.dart` SHALL be moved into this method.

#### Scenario: Primitive unit resolves to identity quantity
- **WHEN** `repo.resolveUnit()` is called on a `PrimitiveUnit` with id `"m"`
- **THEN** it returns `Quantity(1.0, Dimension({"m": 1}))`

#### Scenario: Derived unit resolves through expression
- **WHEN** `repo.resolveUnit()` is called on a `DerivedUnit` whose expression is `"1000 m"`
- **THEN** it returns `Quantity(1000.0, Dimension({"m": 1}))`

#### Scenario: Circular definition throws EvalException
- **WHEN** `repo.resolveUnit()` is called on a unit whose definition directly or indirectly
  references itself
- **THEN** it throws an `EvalException` with a message indicating a circular unit definition

#### Scenario: Unknown unit type throws UnsupportedError
- **WHEN** `repo.resolveUnit()` is called on a `Unit` subtype that is neither `PrimitiveUnit`
  nor `DerivedUnit`
- **THEN** it throws `UnsupportedError`

### Requirement: Resolution results are cached
`UnitRepository.resolveUnit()` SHALL cache successfully resolved `Quantity` values.  The
cache key SHALL be `"${unit.id}-"` for `PrefixUnit` instances and `unit.id` for all other
unit types, matching the convention used by the `visited` cycle-detection set.  On subsequent
calls for the same unit, the cached value SHALL be returned without re-executing the
resolution chain.  Failed resolutions SHALL NOT be cached; every call for a unit that cannot
be resolved SHALL throw independently, allowing callers to handle errors without retrying
being suppressed.

#### Scenario: Second call returns cached value
- **WHEN** `repo.resolveUnit()` is called twice for the same unit
- **THEN** both calls return equal `Quantity` values and the resolution chain is only
  executed once

#### Scenario: Failed resolution throws on every call
- **WHEN** `repo.resolveUnit()` is called on a unit whose resolution throws
- **AND** `repo.resolveUnit()` is called again for the same unit
- **THEN** both calls throw

#### Scenario: Prefix and same-named unit cached independently
- **WHEN** a `PrefixUnit` with id `"m"` (milli) and a `DerivedUnit` with id `"m"` (meter)
  are both registered in the repository
- **AND** `repo.resolveUnit()` is called on each
- **THEN** each returns its own correct `Quantity` and neither result is affected by the other

### Requirement: Caching is transparent to callers
The caching behaviour SHALL be an internal implementation detail of `UnitRepository`.
Callers of `repo.resolveUnit()` SHALL observe identical results whether the value comes
from the cache or from a fresh resolution.  The `visited` cycle-detection set SHALL still
be accepted as an optional parameter and threaded through to the resolution chain when a
cache miss occurs.

#### Scenario: Cache hit returns same quantity as fresh resolution
- **WHEN** a unit is resolved via `repo.resolveUnit()` after the cache has been populated
- **THEN** the returned `Quantity` is equal to what a fresh resolution would have produced

#### Scenario: visited parameter threaded on cache miss
- **WHEN** `repo.resolveUnit()` is called with a non-empty `visited` set and the unit is
  not yet cached
- **THEN** the `visited` set is forwarded to the recursive resolution so that cycles
  within the current resolution chain are still detected

### Requirement: Free function resolveUnit is removed
The top-level free function `resolveUnit(Unit, UnitRepository, [Set<String>?])` in
`unit_resolver.dart` SHALL be deleted.  All former call sites SHALL use
`repo.resolveUnit()` instead.

#### Scenario: No import of unit_resolver needed at call sites
- **WHEN** a file needs to resolve a unit to its base-unit Quantity
- **THEN** it calls `repo.resolveUnit()` and does not import `unit_resolver.dart`
