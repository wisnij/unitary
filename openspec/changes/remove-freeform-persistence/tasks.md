## 1. Remove FreeformRepository

- [ ] 1.1 Delete `lib/features/freeform/data/freeform_repository.dart`
- [ ] 1.2 Delete `test/features/freeform/data/freeform_repository_test.dart`

## 2. Clean Up Providers and App Wiring

- [ ] 2.1 Remove `freeformRepositoryProvider` declaration from `freeform_provider.dart`
- [ ] 2.2 Remove freeform repository construction and `ProviderScope` override from `main.dart`
- [ ] 2.3 Add one-time key cleanup in `main()`: call `prefs.remove('freeform_from')` and `prefs.remove('freeform_to')` after `SharedPreferences.getInstance()`

## 3. Remove Persistence Wiring from FreeformScreen

- [ ] 3.1 Remove `freeformRepositoryProvider` read and controller restore logic from `FreeformScreen.initState()`
- [ ] 3.2 Remove `addPostFrameCallback` deferred re-evaluation that was added for persistence restore
- [ ] 3.3 Remove any `freeformRepositoryProvider` watch/read calls from `FreeformNotifier`

## 4. Update Tests

- [ ] 4.1 Remove or update freeform screen tests that asserted on persistence/restore behavior
- [ ] 4.2 Ensure remaining freeform tests pass (fields start empty, idle state on launch)
- [ ] 4.3 Run `flutter test --reporter failures-only` — all tests pass
- [ ] 4.4 Run `flutter analyze` — no linting errors

## 5. Update Documentation

- [ ] 5.1 Update `README.md` and `doc/design_progress.md` to reflect that freeform persistence has been removed
