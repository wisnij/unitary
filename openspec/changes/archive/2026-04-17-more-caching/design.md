## Context

Unit resolution walks the definition chain for a unit (potentially through
`ExpressionParser` → `UnitNode.evaluate()` → recursive `resolveUnit()` calls)
to produce a `Quantity` in primitive base units.  `UnitRepository` already
maintains `_resolvedQuantityCache` to memoize these results, but the cache is
only consulted in `buildBrowseCatalog()` and `findConformable()`.  The hot
evaluation path — `UnitNode.evaluate()` and `reduce()` — bypasses it entirely.

The free function `resolveUnit()` in `unit_resolver.dart` is the sole
implementation of resolution logic.  It is called by `UnitRepository`
internally, by `UnitNode.evaluate()`, by `reduce()`, and by
`unit_entry_detail_screen.dart`, as well as directly from tests.

## Goals / Non-Goals

**Goals:**

- Move `resolveUnit()` logic into `UnitRepository` so resolution and caching
  are co-located.
- Expose a public `resolveUnit()` method that is the single entry point for all
  callers; caching is invisible to them.
- Eliminate the three duplicate inline cache blocks in `buildBrowseCatalog()`
  and `findConformable()`.
- Fix the pre-existing cache-key collision between a `PrefixUnit` and a
  same-named `DerivedUnit` (20 affected IDs, including `m`, `T`, and `h`).
- Delete `unit_resolver.dart`.
- Migrate all call sites (production and test) to `repo.resolveUnit()`.

**Non-Goals:**

- No other behavioral changes; conversion results are identical.
- No pre-warming of the cache at startup (deferred to a future phase).

## Decisions

### 1. Private `_resolveUnit()` + public `resolveUnit()` on `UnitRepository`

The free function body becomes `UnitRepository._resolveUnit(Unit, [Set<String>? visited])`.
The public `resolveUnit(Unit, [Set<String>? visited])` wraps it:

```
resolveUnit(unit, [visited]):
  key = _cacheKey(unit)
  cached = cache[key]
  if cached != null:
    return cached
  result = _resolveUnit(unit, visited)  // throws on failure; not caught here
  cache[key] = result
  return result
```

**Alternative considered:** a standalone `_resolveUnitCached()` helper that
both `buildBrowseCatalog` and `findConformable` call — rejected because it
still leaves the public call sites (`ast.dart`, `unit_service.dart`,
`unit_entry_detail_screen.dart`) unable to benefit without an ad-hoc workaround.
A public method on the repo is cleaner and keeps caching entirely internal.

### 2. Cache hit bypasses `visited` check

When a cache hit occurs the `visited` set is not consulted.  This is safe
because a cached `Quantity` (non-null) means the unit was previously resolved
successfully — it cannot be circular with respect to itself.  The `visited` set
is only needed to catch cycles *within an active resolution chain*, and a
cached unit is by definition not mid-chain.

**Alternative considered:** always checking `visited` even on cache hits —
rejected as unnecessary overhead that adds complexity without correctness
benefit.

### 3. Failed resolutions are not cached

Only successful resolutions are stored in `_resolvedQuantityCache`.  When
`_resolveUnit()` throws, the exception propagates directly out of `resolveUnit()`
without touching the cache.  A subsequent call for the same failing unit will
re-attempt resolution and throw again.

`buildBrowseCatalog` and `findConformable` wrap their `resolveUnit()` calls in
try/catch and treat a caught exception as `null` (unit excluded from results) —
the same semantics as before, but without relying on the cache to store the
failure.

**Alternative considered:** caching failures as `null` to avoid re-resolution
on repeat calls — rejected because unit definitions are static and failures are
rare, so the retry overhead is negligible, and this approach preserves the
original exception type on every call rather than substituting a generic
`EvalException` on the second call.

### 4. Cache key: `"${id}-"` for prefixes, `id` for all other units

20 IDs (including `m`, `T`, and `h`) are shared between a `PrefixUnit` and a
`DerivedUnit`.  With a flat `unit.id` key, whichever is cached first poisons
the entry for the other — e.g., resolving `"mm"` (millimeter) would return the
cached result for meter instead of the milli prefix, producing a wrong quantity.

The `visited` set already uses `"${unit.id}-"` as the key for `PrefixUnit` to
avoid the same collision during cycle detection.  The cache adopts the same
convention via a private helper:

```dart
String _cacheKey(Unit unit) =>
    unit is PrefixUnit ? '${unit.id}-' : unit.id;
```

This aligns the two namespacing schemes, makes the convention easy to find, and
fixes the collision with no API impact.

**Alternative considered:** `"prefix:${unit.id}"` — rejected in favour of
staying consistent with the `visited` set convention already in the codebase.

## Risks / Trade-offs

**Repeated re-resolution of failing units** → Because failures are not cached,
a unit that always fails to resolve will be re-attempted on every call to
`resolveUnit()`.  In practice this is negligible: unit definitions are static,
failures are rare, and the resolution chain fails fast (e.g. immediately on
cycle detection).

**Cache key migration** → Existing code paths (`buildBrowseCatalog`,
`findConformable`) currently populate the cache with unqualified `unit.id`
keys.  After this change those same paths go through the new `resolveUnit()`
method which uses `_cacheKey()`.  Since the cache is never persisted between
repository constructions there are no stale entries to migrate.

## Open Questions

*(none)*
