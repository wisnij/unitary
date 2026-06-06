## 1. Dependencies

- [ ] 1.1 Add `http` package to `pubspec.yaml`

## 2. Dynamic Unit Layer

- [ ] 2.1 Write tests for dynamic registration: shadowing a compiled unit, duplicate registration replaces silently, registering a new ID, lookup priority
- [ ] 2.2 Write tests for dynamic removal: fallback to compiled unit, removal of dynamic-only unit, removing a non-existent ID is a no-op
- [ ] 2.3 Write tests for cache invalidation: cached resolution is discarded after `registerDynamic`
- [ ] 2.4 Write tests for `allDynamicUnits` getter
- [ ] 2.5 Add `_dynamicUnits: Map<String, Unit>` and `_dynamicLookup: Map<String, Unit>` fields to `UnitRepository`
- [ ] 2.6 Implement `registerDynamic(Unit unit)`: update both dynamic maps for `unit.id` and all aliases, clear `_resolvedQuantityCache`
- [ ] 2.7 Implement `unregisterDynamic(String id)`: remove from dynamic maps by looking up the unit's aliases
- [ ] 2.8 Implement `allDynamicUnits` getter
- [ ] 2.9 Update `_findExact` and `findUnitWithPrefix` to check `_dynamicLookup` before `_unitLookup`

## 3. Currency Detection

- [ ] 3.1 Implement `CurrencyDescriptor` value class (`isoCode`, `unitId`, `expressionTemplate`, `originalUnit`)
- [ ] 3.2 Write tests for `buildCurrencyDescriptors()`: EUR maps to `euro`, XAU maps to `goldprice` with `troyounce` template, USD/US$ excluded, RSI and FIT excluded
- [ ] 3.3 Implement `UnitRepository.buildCurrencyDescriptors()`: collect all names matching `[A-Z]{3}`, resolve each, keep those with dimension `{US$: 1}`, exclude `US$` primitive
- [ ] 3.4 Apply hardcoded precious metals overrides: XAU→`goldprice`, XAG→`silverprice`, XPT→`platinumprice` with `{rate} US$/troyounce` template
- [ ] 3.5 Cache the descriptor list after first call

## 4. Rate Persistence

- [ ] 4.1 Create `lib/features/currency/data/` directory with `currency_rate_repository.dart`
- [ ] 4.2 Implement `CurrencyRateEntry` value class (`rate: double`, `date: String`)
- [ ] 4.3 Implement `CurrencyRates` value class (`updatedAt: DateTime`, `rates: Map<String, CurrencyRateEntry>`) with JSON serialisation
- [ ] 4.4 Write tests for `CurrencyRateRepository`: save/load round-trip, partial update preserves absent currencies, `lastUpdatedForUnit` direct key match, `lastUpdatedForUnit` indirect via descriptor, `lastUpdatedForUnit` returns null for non-currency unit
- [ ] 4.5 Implement `CurrencyRateRepository.load()`: read `currencyRates` from SharedPreferences, deserialise, return `null` if absent or malformed
- [ ] 4.6 Implement `CurrencyRateRepository.save(CurrencyRates rates)`: serialise and write to SharedPreferences
- [ ] 4.7 Implement `CurrencyRateRepository.lastUpdatedForUnit(String unitId, List<CurrencyDescriptor> descriptors)`: direct lookup, then descriptor fallback

## 5. Currency Service

- [ ] 5.1 Create `lib/features/currency/domain/currency_service.dart`
- [ ] 5.2 Write tests for `fetchRates()` using a mock HTTP client: rate inversion applied correctly, unknown API codes ignored, partial response leaves unaffected stored rates unchanged, network failure leaves existing rates intact
- [ ] 5.3 Implement `CurrencyService.fetchRates()`: GET `https://api.frankfurter.dev/v2/rates?base=USD`, parse response array, invert rates (`1.0 / frankfurterRate`), apply to `UnitRepository` via `registerDynamic`, persist via `CurrencyRateRepository.save()`
- [ ] 5.4 Implement `CurrencyService.maybeRefresh()`: check `updatedAt` against 24-hour threshold; if stale or absent, call `fetchRates()` as a fire-and-forget unawaited future

## 6. Riverpod Providers and Startup Wiring

- [ ] 6.1 Create `currencyRateRepositoryProvider` (must-override, wired in `main.dart` and tests)
- [ ] 6.2 Create `currencyServiceProvider`
- [ ] 6.3 Create `currencyStatusProvider` (`StateNotifierProvider` for last-updated timestamp, fetch-in-progress flag, and cooldown expiry)
- [ ] 6.4 Apply stored rates to `UnitRepository` at startup: load from `CurrencyRateRepository`, call `registerDynamic` for each entry before first frame
- [ ] 6.5 Call `CurrencyService.maybeRefresh()` fire-and-forget in app init after repository is ready

## 7. Settings UI — Currency Section

- [ ] 7.1 Implement `CurrencyStatusNotifier`: manages `updatedAt`, `isFetching`, and `cooldownExpiry`; exposes `refresh()` method that enforces 60-second cooldown
- [ ] 7.2 Write widget tests for currency settings section: shows `updatedAt` after successful fetch, shows "using default rates" on first launch, shows spinner during fetch, disables button and shows countdown during cooldown, re-enables button after cooldown
- [ ] 7.3 Add currency section to `SettingsScreen`: display `updatedAt` timestamp or "Using built-in rates" if no fetch has occurred
- [ ] 7.4 Add manual refresh button to currency section: calls `currencyStatusNotifier.refresh()`, disabled with countdown label during cooldown, shows spinner while `isFetching` is true

## 8. Completion

- [ ] 8.1 Run `flutter test --reporter failures-only` and fix any failures
- [ ] 8.2 Run `flutter analyze` and fix any linting errors
- [ ] 8.3 Update `doc/design_progress.md` and `README.md` to reflect Phase 8 completion
