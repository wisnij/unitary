## 1. Add resolution methods to UnitRepository

- [x] 1.1 Add private `_cacheKey(Unit unit)` helper returning `"${unit.id}-"` for `PrefixUnit` and `unit.id` for all other types
- [x] 1.2 Add private `_resolveUnit(Unit unit, [Set<String>? visited])` containing the logic currently in the free function `resolveUnit()` in `unit_resolver.dart` (cycle detection, primitive/derived dispatch, `ExpressionParser` delegation)
- [x] 1.3 Add public `resolveUnit(Unit unit, [Set<String>? visited])` that checks `_resolvedQuantityCache` via `_cacheKey()`, calls `_resolveUnit()` on miss, stores the result (or `null` on exception), and rethrows on failure

## 2. Replace inline cache blocks inside UnitRepository

- [x] 2.1 Replace the inline cache block in the units loop of `buildBrowseCatalog()` with a try/catch around `resolveUnit()`
- [x] 2.2 Replace the inline cache block in the prefixes loop of `buildBrowseCatalog()` with a try/catch around `resolveUnit()`
- [x] 2.3 Replace the inline cache block in `findConformable()` with a try/catch around `resolveUnit()`

## 3. Migrate external call sites

- [x] 3.1 Update `UnitNode.evaluate()` in `ast.dart` to call `context.repo.resolveUnit()` for both the unit and prefix lookups; remove the import of `unit_resolver.dart`
- [x] 3.2 Update `reduce()` in `unit_service.dart` to call `repo.resolveUnit()`; remove the import of `unit_resolver.dart`
- [x] 3.3 Update `unit_entry_detail_screen.dart` to call `repo.resolveUnit()`; remove the import of `unit_resolver.dart`

## 4. Migrate tests

- [x] 4.1 Update `test/core/domain/models/unit_test.dart` to call `repo.resolveUnit()` instead of the free function; remove the import of `unit_resolver.dart`
- [x] 4.2 Update `test/core/domain/models/unit_repository_test.dart` to call `repo.resolveUnit()` instead of the free function; remove the import of `unit_resolver.dart`
- [x] 4.3 Update `test/core/domain/data/predefined_units_test.dart` to call `repo.resolveUnit()` instead of the free function; remove the import of `unit_resolver.dart`
- [x] 4.4 Add a test covering the cache-key collision fix: register a `PrefixUnit` and a `DerivedUnit` with the same id `"m"`, resolve both via `repo.resolveUnit()`, and assert each returns its own correct `Quantity`

## 5. Delete free function

- [x] 5.1 Delete `lib/core/domain/services/unit_resolver.dart`

## 6. Verify

- [x] 6.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 6.2 Run `flutter analyze` and confirm no linting errors
