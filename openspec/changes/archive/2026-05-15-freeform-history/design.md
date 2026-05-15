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

- Record a (from, to, result) triple after every successful evaluation, in
  both real-time and on-submit modes.
- Persist the history list across sessions via SharedPreferences.
- Expose the list via an AppBar button that opens a modal bottom sheet;
  tapping an entry restores both fields and immediately re-evaluates.
- Deduplicate entries: identical (from, to) pairs move to the top instead of
  creating duplicates.
- Cap the list at a fixed maximum (100 entries) to bound storage size.

**Non-Goals:**

- History for worksheet mode (separate feature, separate screen).
- Per-entry timestamps or metadata beyond the (from, to, result) triple.
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
of `{from, to, result}` objects, ordered most-recent-first.  On load, any entry
with an invalid structure is silently dropped.  Malformed JSON falls back to an
empty list.  The `result` field defaults to `''` when loading entries that
predate its introduction (backward-compatible).

```json
[
  {"from": "5 km", "to": "mi", "result": "3.10686 mi"},
  {"from": "tempC(100)", "to": "tempF", "result": "tempF(212)"},
  {"from": "212 degF", "to": "", "result": "373.15 K"}
]
```

An empty `to` string is stored when the output field is blank.  An empty
`result` string is stored when no numeric result is meaningful (e.g.
`FunctionDefinitionResult`).

### 4. Repository shape

`FreeformHistoryRepository` mirrors the worksheet repository pattern:

```dart
class FreeformHistoryEntry {
  final String from;
  final String to;
  final String result; // formatted output; '' when not applicable
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

History is accessed via an **`Icons.history` button in the AppBar**, placed
to the left of the existing conformable-units (`Icons.balance`) button.  The
button is disabled when history is empty and enabled otherwise.

Tapping the button opens a **`DraggableScrollableSheet`** modal bottom sheet
(same pattern and sizing as the conformable-units modal).  Each entry is a
`ListTile`:
- Title text: `"${entry.from} = ${entry.result}"` when `result` is non-empty;
  just `entry.from` otherwise.
- Tapping an entry dismisses the modal, fills both controllers with `from` and
  `to`, and calls `_evaluate()` immediately (no debounce delay).

Rationale: a modal keeps the main screen uncluttered regardless of history
length, and the AppBar button placement mirrors the existing browse button so
the two related actions sit together.

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
`ref.read(freeformHistoryProvider.notifier).record(from, to, result)` after a
successful evaluation, where `result` is extracted from the current state by
`_extractResult()` — an exhaustive switch over the sealed `EvaluationResult`
class that strips the `"= "` prefix where present and formats
`FunctionConversionResult` as `"functionName(value)"`.

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
