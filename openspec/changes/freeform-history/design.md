# Design: Freeform History

## Context

The freeform screen evaluates expressions entered in two `TextField` widgets
("Convert from" / "Convert to").  Evaluation is triggered either by a 500 ms
debounce timer (real-time mode) or explicitly by the user pressing Enter or the
Evaluate button (on-submit mode).

`FreeformNotifier` owns evaluation state (`EvaluationResult`), and
`FreeformScreen` owns the two `TextEditingController`s.  SharedPreferences is
already used for settings and worksheet persistence.  No freeform field content
is currently persisted.

## Goals / Non-Goals

**Goals:**

- Record a (from, to) pair after every successful evaluation, in both
  real-time and on-submit modes.
- Persist the history list across sessions via SharedPreferences.
- Expose the list in the freeform screen so the user can tap an entry to
  restore both fields and immediately re-evaluate.
- Deduplicate entries: identical (from, to) pairs move to the top instead of
  creating duplicates.
- Cap the list at a fixed maximum (100 entries) to bound storage size.

**Non-Goals:**

- History for worksheet mode (separate feature, separate screen).
- Per-entry timestamps or metadata beyond the (from, to) pair.
- Editing or deleting individual history entries (out of scope for MVP).
- Syncing history across devices.

## Decisions

### 1. What counts as a "successful" evaluation?

All `EvaluationResult` subtypes except `EvaluationIdle` and `EvaluationError`
represent a successful evaluation and should add to history.  This includes
`UnitDefinitionResult` and `FunctionDefinitionResult`, which are valid
responses to deliberate user queries.

The input field must be non-empty (the notifier already returns `EvaluationIdle`
for empty input, so no extra guard is needed).

### 2. Where to record history entries

**Chosen: inside `FreeformNotifier.evaluate()`**, after the state assignment
that yields a successful result.

The notifier already receives both `input` and `output` strings as parameters.
Injecting the repository into the notifier (following the worksheet pattern)
keeps history persistence co-located with evaluation logic and avoids coupling
`FreeformScreen` to persistence.

Alternative considered: record in `FreeformScreen._evaluate()` after reading
`freeformProvider` state.  Rejected because it would scatter persistence
concerns across screen and notifier, and require the screen to distinguish
success vs. failure states.

### 3. Storage format

A single SharedPreferences key `'freeformHistory'` stores a JSON-encoded list
of `{from, to}` objects, ordered most-recent-first.  On load, any entry with
an invalid structure is silently dropped.  Malformed JSON falls back to an
empty list.

```json
[
  {"from": "5 km", "to": "mi"},
  {"from": "tempC(100)", "to": "tempF"},
  {"from": "212 degF", "to": ""}
]
```

An empty `to` string is stored when the output field is blank (single-field
evaluation).

### 4. Repository shape

`FreeformHistoryRepository` mirrors the worksheet repository pattern:

```dart
class FreeformHistoryEntry {
  final String from;
  final String to;
}

class FreeformHistoryRepository {
  static const prefsKey = 'freeformHistory';
  static const maxEntries = 100;

  List<FreeformHistoryEntry> load();
  Future<void> save(List<FreeformHistoryEntry> entries);
}
```

`FreeformNotifier` receives it via a required `freeformHistoryRepositoryProvider`
that must be overridden in the widget tree (following `worksheetRepositoryProvider`
precedent).

### 5. Deduplication strategy

When recording a new entry, the notifier:
1. Removes any existing entry with the same (from, to) pair (case-sensitive,
   trimmed).
2. Prepends the new entry.
3. Truncates to `maxEntries`.

This keeps the list ordered by most-recently-used and prevents duplicates.

### 6. UI placement and interaction

A scrollable history list is shown **below the result display**, inside the
existing `SingleChildScrollView` body.  It is only rendered when the history
list is non-empty.

Each entry is a `ListTile`:
- Primary text: the `from` value.
- Secondary text: the `to` value, or an em dash (`—`) if empty.
- Tapping fills both controllers and calls `_evaluate()` immediately (no
  debounce delay).

A "History" section header precedes the list.  No collapse/expand for the MVP.

Rationale: keeping it always-visible (when non-empty) is simpler than adding
collapsible state, and the list is bounded to 50 entries.

### 7. History loaded on startup

`FreeformNotifier` exposes a `List<FreeformHistoryEntry>` as a second
provider (or as a field of a combined state) so the screen can watch it
reactively.  The simplest approach is a separate
`freeformHistoryProvider` that holds `List<FreeformHistoryEntry>` and is
updated whenever the notifier saves.

Alternatively, history state can be stored directly inside `FreeformNotifier`
by expanding `EvaluationResult` into a combined `FreeformState` that holds
both the evaluation result and the history list.

**Chosen: separate `freeformHistoryProvider`** backed by
`FreeformHistoryNotifier` to keep concerns separated and avoid bloating the
existing `FreeformNotifier`.  `FreeformNotifier.evaluate()` calls
`ref.read(freeformHistoryProvider.notifier).record(from, to)` after a
successful evaluation.

## Risks / Trade-offs

- **SharedPreferences size**: 100 entries of typical expression length (~5–30
  chars each) amounts to well under 20 KB — negligible.
- **Stale entries after unit changes**: If the user reloads a history entry
  that references a unit removed or renamed in a future app version, evaluation
  will simply show an error, which is acceptable behavior.
- **Separate provider adds indirection**: Two providers (`freeformProvider`,
  `freeformHistoryProvider`) must both be overridden in tests that verify
  history persistence.  This is the same pattern already established by
  `worksheetRepositoryProvider`.

## Migration Plan

No migration needed.  On first launch the `'freeformHistory'` key is absent;
`load()` returns an empty list.  The existing `'freeformInput'`/`'freeformOutput'`
orphan keys (from the removed freeform-persistence feature) are unaffected.
