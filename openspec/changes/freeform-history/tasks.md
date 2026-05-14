## 1. Data Model and Repository

- [ ] 1.1 Create `lib/features/freeform/data/freeform_history_repository.dart` with `FreeformHistoryEntry` value class (`from`, `to` string fields; `toJson`/`fromJson`)
- [ ] 1.2 Implement `FreeformHistoryRepository`: SharedPreferences key `'freeformHistory'`, `load()` returning `List<FreeformHistoryEntry>` (empty list on missing or malformed data), `save(List<FreeformHistoryEntry>)`, constant `maxEntries = 100`
- [ ] 1.3 Write repository tests: empty list on first launch, malformed JSON falls back to empty, save/load round-trip preserves order, entries beyond cap are dropped on save

## 2. History State

- [ ] 2.1 Create `lib/features/freeform/state/freeform_history_provider.dart` with `freeformHistoryRepositoryProvider` (must-override) and `FreeformHistoryNotifier` (non-`autoDispose`) that loads history in `build()`
- [ ] 2.2 Implement `FreeformHistoryNotifier.record(String from, String to)`: trim both values, remove any existing entry with the same (from, to) pair, prepend new entry, truncate to `maxEntries`, save to repository
- [ ] 2.3 Write notifier tests: `build()` restores persisted history, `record()` prepends entries, `record()` deduplicates (moves existing pair to top), `record()` drops oldest when cap is exceeded

## 3. Hook Recording into Evaluation

- [ ] 3.1 In `FreeformNotifier.evaluate()`, call `ref.read(freeformHistoryProvider.notifier).record(input, output)` immediately after any state assignment that is not `EvaluationIdle` or `EvaluationError`
- [ ] 3.2 Write tests confirming `evaluate()` records on each success subtype (`EvaluationSuccess`, `ConversionSuccess`, `UnitDefinitionResult`, `FunctionDefinitionResult`, `FunctionConversionResult`, `ReciprocalConversionSuccess`) and does not record on error or idle

## 4. UI

- [ ] 4.1 Add `_restoreHistoryEntry(FreeformHistoryEntry entry)` to `_FreeformScreenState`: set both controllers, cancel any pending debounce, call `_evaluate()` immediately
- [ ] 4.2 Build a `_HistorySection` widget (or inline in `build()`): section label ("History"), `ListView` of `ListTile`s with primary text = `entry.from` and secondary text = `entry.to` (or `—` if empty); each tile calls `_restoreHistoryEntry` on tap
- [ ] 4.3 Add history section to `FreeformScreen.build()` body below the result display, watching `freeformHistoryProvider`; render only when the history list is non-empty
- [ ] 4.4 Write widget tests: history section absent when list is empty, present when non-empty, tapping entry populates both fields and triggers evaluation

## 5. Wiring

- [ ] 5.1 In `lib/main.dart`, load `FreeformHistoryRepository` from SharedPreferences and add `freeformHistoryRepositoryProvider.overrideWithValue(...)` alongside the existing worksheet override

## 6. Documentation

- [ ] 6.1 Update `README.md` and `doc/design_progress.md` to reflect the freeform history feature
