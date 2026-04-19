## Why

`UnitRepository._resolvedQuantityCache` exists to avoid re-resolving the full
unit definition chain (which can involve parsing and evaluating a recursive
expression tree) every time a unit is needed.  However, it is currently only
consulted in `buildBrowseCatalog()` and `findConformable()`.  Every call to
`UnitNode.evaluate()`, `reduce()`, and `unit_entry_detail_screen.dart` resolves
units from scratch on each invocation, even for the same unit.  Since unit
definitions are immutable after repository construction, the cache should be
used everywhere units are resolved.

## What Changes

- Move the free function `resolveUnit()` from `unit_resolver.dart` into
  `UnitRepository` as a private implementation method `_resolveUnit()`.
- Add a public `resolveUnit()` method on `UnitRepository` that checks the
  cache before delegating to `_resolveUnit()`, and stores the result
  afterwards — replacing the three identical inline cache blocks in
  `buildBrowseCatalog()` and `findConformable()`.
- Delete `unit_resolver.dart` (now empty).
- Update `UnitNode.evaluate()` (in `ast.dart`) to call `repo.resolveUnit()`
  instead of the free function.
- Update `reduce()` (in `unit_service.dart`) to call `repo.resolveUnit()`
  instead of the free function.
- Update `unit_entry_detail_screen.dart` to call `repo.resolveUnit()`
  instead of the free function.
- Update tests that call the free function directly to call
  `repo.resolveUnit()` instead.

No behavioral changes.  All existing tests should continue to pass.

## Capabilities

### New Capabilities

- `unit-resolution-cache`: Semantics and contract of `UnitRepository.resolveUnit()`:
  what it stores, when entries are valid, and the guarantee that caching is
  transparent to callers.

### Modified Capabilities

*(none — no existing spec-level requirements change)*

## Impact

- `lib/core/domain/models/unit_repository.dart` — private `_resolveUnit()`
  method (logic from free function) and public `resolveUnit()` method (cache
  wrapper); three duplicate inline cache blocks removed
- `lib/core/domain/services/unit_resolver.dart` — deleted
- `lib/core/domain/parser/ast.dart` — `UnitNode.evaluate()` uses
  `repo.resolveUnit()` instead of the free function
- `lib/core/domain/services/unit_service.dart` — `reduce()` uses
  `repo.resolveUnit()` instead of the free function
- `lib/features/browser/presentation/unit_entry_detail_screen.dart` — uses
  `repo.resolveUnit()` instead of the free function
- `test/core/domain/models/unit_test.dart`,
  `test/core/domain/models/unit_repository_test.dart`,
  `test/core/domain/data/predefined_units_test.dart` — call `repo.resolveUnit()`
  instead of the free function
- No new dependencies; no API or schema changes
