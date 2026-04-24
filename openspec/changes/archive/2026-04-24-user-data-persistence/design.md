## Context

The app already persists user settings via `SettingsRepository` + `SharedPreferences`,
initialized synchronously from `main()` before `runApp`.  Worksheet values and
freeform input fields are in-memory only (Riverpod state and `TextEditingController`s
respectively); both are lost on every app restart.

The established pattern is: construct repositories in `main()` after `await
SharedPreferences.getInstance()`, override repository providers in `ProviderScope`,
and have notifiers call `ref.watch(repositoryProvider).load()` synchronously in
`build()`.

## Goals / Non-Goals

**Goals:**

- Persist the active worksheet template ID and each template's source-row text
  across sessions.
- Persist the freeform "Convert from" and "Convert to" field text across sessions.
- Follow the existing `SettingsRepository` / `ProviderScope` override pattern so
  the persistence layer is consistent and testable.

**Non-Goals:**

- sqflite or any relational database — deferred to Phase 12 (custom worksheets).
- Persisting computed (non-source) worksheet cell values — they are always
  re-derived from the source value on load.
- Favorite units — deferred to Phase 12.
- Freeform evaluation history.

## Decisions

### 1. Storage backend: SharedPreferences

SharedPreferences is already a dependency and sufficient for the key-value
data being persisted.  Adding sqflite now would introduce schema migration
concerns, a new dependency, and platform-native setup for no benefit at this
scale.

*Alternatives considered:* sqflite (overkill until relational queries are
needed), `hive` (another new dep, no advantage here).

### 2. Freeform text: widget-level repository access, no new provider

The "Convert from" and "Convert to" strings are already tracked by
`TextEditingController`s owned by `_FreeformScreenState`.  Adding a parallel
Riverpod text-state layer would duplicate what the controllers already hold.

Instead:

- `FreeformScreen.initState()` calls `ref.read(freeformRepositoryProvider).load()`
  to obtain saved strings and pre-populates the controllers; a
  `WidgetsBinding.addPostFrameCallback` then calls `evaluate()` so the result
  display is populated immediately.
- `_onInputChanged` / `_onOutputChanged` call
  `ref.read(freeformRepositoryProvider).save(input, output)` on every keystroke
  (fire-and-forget `Future`; write latency is imperceptible).

This is the minimum change: the `freeformProvider` state type (`EvaluationResult`)
is untouched.

*Alternatives considered:* (A) wrap `EvaluationResult` in a new state class
holding text — breaks all existing consumers; (B) new `freeformTextProvider`
that holds `(input, output)` strings — adds a provider but gains nothing since
the widget already tracks the strings.

### 3. Worksheet source data: persist per-template `(rowIndex, text)`

The only data needed to reconstruct a worksheet is the source row index and
its raw text.  Computed cells are always re-derived by `computeWorksheet()`.

Persisted shape (JSON in a single SharedPreferences key):

```json
{
  "activeWorksheetId": "length",
  "sources": {
    "length": { "rowIndex": 2, "text": "5 ft" },
    "mass":   { "rowIndex": 0, "text": "70 kg" }
  }
}
```

`WorksheetRepository.load()` returns a `WorksheetPersistState` with this shape.
`WorksheetNotifier.build()` reads it, runs `computeWorksheet()` for each persisted
template to build the initial `worksheetValues` map, and sets `worksheetId` to
the saved active template (falling back to `'length'` if missing).

*Alternatives considered:* persisting the full computed cell list — wastes space
and couples persistence to the display format.

### 4. Write-through timing: on every state change, fire-and-forget

`WorksheetNotifier.onRowChanged()` already updates state and runs the engine;
it will additionally call `ref.read(worksheetRepositoryProvider).save(state)`
(the full `WorksheetPersistState`, not the full `WorksheetState`).  `selectWorksheet`
also saves the new active ID.

No debounce is applied: SharedPreferences writes are fast and the data is small.

### 5. Initialization: follow the existing `main()` override pattern

Both new repositories are constructed in `main()` after `SharedPreferences.getInstance()`
and injected via `ProviderScope` overrides, exactly as `SettingsRepository` is today.

```dart
final prefs = await SharedPreferences.getInstance();
// existing
final settingsRepo  = SettingsRepository(prefs);
// new
final worksheetRepo = WorksheetRepository(prefs);
final freeformRepo  = FreeformRepository(prefs);

runApp(ProviderScope(
  overrides: [
    settingsRepositoryProvider.overrideWithValue(settingsRepo),
    worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
    freeformRepositoryProvider.overrideWithValue(freeformRepo),
  ],
  child: const UnitaryApp(),
));
```

## Risks / Trade-offs

**Worksheet engine in `build()`** → `WorksheetNotifier.build()` now calls
`computeWorksheet()` up to N times (once per persisted template) at app startup.
In practice N ≤ 10 and each call is a handful of `ExpressionParser.evaluate()`
invocations.  If profiling shows startup impact, the solution is lazy engine
runs (only for the active template at startup; defer others to first navigation).

**SharedPreferences JSON key grows unboundedly** → The sources map gains one
entry per template the user has ever edited.  With 10 fixed templates the map
is at most 10 entries; this is not a concern.

**Stale source text after unit database changes** → If a unit is renamed between
versions, a persisted expression like `"5 feets"` will restore as an error row
instead of a value.  The engine already handles this gracefully (per-row error
string, other rows blank); no special migration is needed.

**`FreeformRepository.save()` called on every keystroke** → SharedPreferences is
backed by `NSUserDefaults` / `SharedPreferences` XML and writes asynchronously;
per-keystroke fire-and-forget is standard Flutter practice and adds no observable
latency.

## Open Questions

*(none — all decisions resolved above)*
