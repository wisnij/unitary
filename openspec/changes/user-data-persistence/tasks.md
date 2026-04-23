## 1. WorksheetRepository

- [ ] 1.1 Write tests for `WorksheetRepository`: load returns defaults when prefs are empty, load restores saved active ID and sources map, save round-trips correctly, load falls back to "length" when saved ID is unrecognised
- [ ] 1.2 Create `WorksheetPersistState` model: `activeWorksheetId` (String) + `sources` (Map of templateId → `(rowIndex: int, text: String)`)
- [ ] 1.3 Create `lib/features/worksheet/data/worksheet_repository.dart` with `load()` → `WorksheetPersistState` and `save(WorksheetPersistState)` backed by a single JSON-encoded SharedPreferences key
- [ ] 1.4 Verify all new tests pass

## 2. WorksheetNotifier persistence wiring

- [ ] 2.1 Write tests for `WorksheetNotifier` persistence: build initialises from non-empty persist state (correct active ID, engine re-runs seeding other rows), onRowChanged writes through updated sources, selectWorksheet writes through updated active ID, engine error on restore is caught per-row and does not throw
- [ ] 2.2 Add `worksheetRepositoryProvider` (must-override pattern, same as `settingsRepositoryProvider`) to `worksheet_provider.dart`
- [ ] 2.3 Update `WorksheetNotifier.build()` to call `ref.watch(worksheetRepositoryProvider).load()` and for each entry in `sources` run `computeWorksheet()` synchronously to seed the initial `worksheetValues`; set `worksheetId` from the persisted active ID
- [ ] 2.4 Update `WorksheetNotifier.onRowChanged()` to call `ref.read(worksheetRepositoryProvider).save(...)` after updating state (fire-and-forget)
- [ ] 2.5 Update `WorksheetNotifier.selectWorksheet()` to call `ref.read(worksheetRepositoryProvider).save(...)` after updating state (fire-and-forget)
- [ ] 2.6 Verify all new and existing worksheet tests pass

## 3. FreeformRepository

- [ ] 3.1 Write tests for `FreeformRepository`: load returns empty strings when prefs are empty, load restores saved input and output text, save round-trips correctly, load returns empty string for each field independently when only one key is present
- [ ] 3.2 Create `lib/features/freeform/data/freeform_repository.dart` with `load()` → `({String input, String output})` and `save(String input, String output)` using two separate SharedPreferences keys
- [ ] 3.3 Verify all new tests pass

## 4. FreeformScreen persistence wiring

- [ ] 4.1 Write widget tests for `FreeformScreen` persistence: controllers pre-populated from repository on first build, result display populated without user interaction when input is non-empty, both fields empty when repository returns empty strings
- [ ] 4.2 Add `freeformRepositoryProvider` (must-override pattern) to `freeform_provider.dart` (or a new `freeform_repository_provider.dart`)
- [ ] 4.3 Update `FreeformScreen.initState()` to read from `freeformRepositoryProvider`, set controller text, and call `_evaluate()` when input is non-empty
- [ ] 4.4 Update `_onInputChanged()` and `_onOutputChanged()` to call `ref.read(freeformRepositoryProvider).save(...)` (fire-and-forget) on every change
- [ ] 4.5 Verify all new and existing freeform tests pass

## 5. main() wiring

- [ ] 5.1 Construct `WorksheetRepository(prefs)` and `FreeformRepository(prefs)` in `main()` after `SharedPreferences.getInstance()`
- [ ] 5.2 Add `worksheetRepositoryProvider.overrideWithValue(worksheetRepo)` and `freeformRepositoryProvider.overrideWithValue(freeformRepo)` to the `ProviderScope` overrides list
- [ ] 5.3 Run `flutter analyze` — no new warnings or errors

## 6. Full test suite and documentation

- [ ] 6.1 Run `flutter test --reporter failures-only` — all tests pass
- [ ] 6.2 Update `doc/design_progress.md` — mark Phase 7 complete, record test count
- [ ] 6.3 Update `README.md` — mark Phase 7 complete, update test count and last-updated date
