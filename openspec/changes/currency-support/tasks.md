## 1. Dependencies

- [x] 1.1 Add `http` package to `pubspec.yaml`

## 2. Dynamic Unit Layer

- [x] 2.1 Write tests for dynamic registration: shadowing a compiled unit, duplicate registration replaces silently, registering a new ID, lookup priority
- [x] 2.2 Write tests for dynamic removal: fallback to compiled unit, removal of dynamic-only unit, removing a non-existent ID is a no-op
- [x] 2.3 Write tests for cache invalidation: cached resolution is discarded after `registerDynamic`
- [x] 2.4 Write tests for `allDynamicUnits` getter
- [x] 2.5 Add `_dynamicUnits: Map<String, Unit>` and `_dynamicLookup: Map<String, Unit>` fields to `UnitRepository`
- [x] 2.6 Implement `registerDynamic(Unit unit)`: update both dynamic maps for `unit.id` and all aliases, clear `_resolvedQuantityCache`
- [x] 2.7 Implement `unregisterDynamic(String id)`: remove from dynamic maps by looking up the unit's aliases
- [x] 2.8 Implement `allDynamicUnits` getter
- [x] 2.9 Update `_findExact` and `findUnitWithPrefix` to check `_dynamicLookup` before `_unitLookup`

## 3. Currency Detection

- [x] 3.1 Implement `CurrencyDescriptor` value class (`isoCode`, `unitId`, `expressionTemplate`, `originalUnit`)
- [x] 3.2 Write tests for `buildCurrencyDescriptors()`: EUR maps to `euro`, XAU maps to `goldprice` with `troyounce` template, USD/US$ excluded, RSI and FIT excluded
- [x] 3.3 Implement `UnitRepository.buildCurrencyDescriptors()`: collect all names matching `[A-Z]{3}`, resolve each, keep those with dimension `{US$: 1}`, exclude `US$` primitive
- [x] 3.4 Apply hardcoded precious metals overrides: XAU→`goldprice`, XAG→`silverprice`, XPT→`platinumprice` with `{rate} US$/troyounce` template
- [x] 3.5 Cache the descriptor list after first call

## 4. Rate Persistence

- [x] 4.1 Create `lib/features/currency/data/` directory with `currency_rate_repository.dart`
- [x] 4.2 Implement `CurrencyRateEntry` value class (`rate: double`, `date: String`)
- [x] 4.3 Implement `CurrencyRates` value class (`updatedAt: DateTime`, `rates: Map<String, CurrencyRateEntry>`) with JSON serialisation
- [x] 4.4 Write tests for `CurrencyRateRepository`: save/load round-trip, partial update preserves absent currencies, `lastUpdatedForUnit` direct key match, `lastUpdatedForUnit` indirect via descriptor, `lastUpdatedForUnit` returns null for non-currency unit
- [x] 4.5 Implement `CurrencyRateRepository.load()`: read `currencyRates` from SharedPreferences, deserialise, return `null` if absent or malformed
- [x] 4.6 Implement `CurrencyRateRepository.save(CurrencyRates rates)`: serialise and write to SharedPreferences
- [x] 4.7 Implement `CurrencyRateRepository.lastUpdatedForUnit(String unitId, List<CurrencyDescriptor> descriptors)`: direct lookup, then descriptor fallback

## 5. Currency Service

- [x] 5.1 Create `lib/features/currency/domain/currency_service.dart`
- [x] 5.2 Write tests for `fetchRates()` using a mock HTTP client: rate inversion applied correctly, unknown API codes ignored, partial response leaves unaffected stored rates unchanged, network failure leaves existing rates intact
- [x] 5.3 Implement `CurrencyService.fetchRates()`: GET `https://api.frankfurter.dev/v2/rates?base=USD`, parse response array, invert rates (`1.0 / frankfurterRate`), apply to `UnitRepository` via `registerDynamic`, persist via `CurrencyRateRepository.save()`
- [x] 5.4 Implement `CurrencyService.maybeRefresh()`: check `updatedAt` against 24-hour threshold; if stale or absent, call `fetchRates()` as a fire-and-forget unawaited future

## 6. Riverpod Providers and Startup Wiring

- [x] 6.1 Create `currencyRateRepositoryProvider` (must-override, wired in `main.dart` and tests)
- [x] 6.2 Create `currencyServiceProvider`
- [x] 6.3 Create `currencyStatusProvider` (`StateNotifierProvider` for last-updated timestamp, fetch-in-progress flag, and cooldown expiry)
- [x] 6.4 Apply stored rates to `UnitRepository` at startup: load from `CurrencyRateRepository`, call `registerDynamic` for each entry before first frame
- [x] 6.5 Call `CurrencyService.maybeRefresh()` fire-and-forget in app init after repository is ready

## 7. Settings UI — Currency Section

- [x] 7.1 Implement `CurrencyStatusNotifier`: manages `updatedAt`, `isFetching`, and `cooldownExpiry`; exposes `refresh()` method that enforces 60-second cooldown
- [x] 7.2 Write widget tests for currency settings section: shows `updatedAt` after successful fetch, shows "using default rates" on first launch, shows spinner during fetch, disables button and shows countdown during cooldown, re-enables button after cooldown
- [x] 7.3 Add currency section to `SettingsScreen`: display `updatedAt` timestamp or "Using built-in rates" if no fetch has occurred
- [x] 7.4 Add manual refresh button to currency section: calls `currencyStatusNotifier.refresh()`, disabled with countdown label during cooldown, shows spinner while `isFetching` is true

## 8. Completion

- [x] 8.1 Run `flutter test --reporter failures-only` and fix any failures
- [x] 8.2 Run `flutter analyze` and fix any linting errors
- [x] 8.3 Update `doc/design_progress.md` and `README.md` to reflect Phase 8 completion
