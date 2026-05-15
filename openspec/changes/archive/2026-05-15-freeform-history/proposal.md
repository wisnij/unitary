## Why

Freeform mode has no memory — every session starts blank, and users must retype
expressions they've used before.  A persistent history of successful conversions
lets users quickly revisit past work without re-entering expressions.

## What Changes

- A history of successful freeform conversions is recorded and persisted across
  sessions via SharedPreferences.
- Each history entry captures the pair of (From, To) field values at the moment
  a successful conversion was produced.
- Entries are saved only after the expression actually evaluates: after the
  debounce timer fires in real-time mode, or when the user submits in on-submit
  mode.  Partial / in-progress input is never saved.
- Only successful evaluations (no error state) produce history entries.
- The freeform screen exposes the history list; tapping an entry restores both
  fields and immediately re-evaluates the conversion.
- History entries are deduplicated: re-submitting an identical (From, To) pair
  moves it to the top rather than creating a duplicate.
- A maximum number of entries is kept (oldest entries dropped when the limit is
  exceeded).

## Capabilities

### New Capabilities

- `freeform-history`: Persistent freeform conversion history — recording,
  storage, display, and restoration of successful (From, To) expression pairs.

### Modified Capabilities

- `freeform-persistence`: The existing spec states freeform fields are
  intentionally not persisted.  This change introduces a new form of freeform
  persistence (history entries rather than live field state), so the spec must
  be updated to reflect that history is now stored via SharedPreferences.

## Impact

- `lib/features/freeform/` — new history repository, updated state notifier to
  record entries on successful evaluation, new history UI widget
- `lib/features/freeform/data/` — new `FreeformHistoryRepository` (SharedPreferences)
- `openspec/specs/freeform-persistence/spec.md` — update to reflect that history
  entries (not raw field text) are now persisted for freeform mode
- No new package dependencies; SharedPreferences already in use
