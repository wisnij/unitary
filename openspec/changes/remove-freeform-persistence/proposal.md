## Why

Persisting freeform input fields between sessions proved awkward in practice: users
expect the freeform screen to start blank, and restoring stale expressions creates
more confusion than convenience.  Worksheet persistence (last-selected template and
per-template source values) remains useful and is unaffected.

## What Changes

- Remove save/restore of "Convert from" and "Convert to" text fields in freeform mode
- Delete `FreeformRepository` and its provider, as they are no longer needed
- Remove `freeformRepositoryProvider` override from `main()`
- Freeform screen starts with empty input fields on every launch

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `freeform-persistence`: requirement changes — freeform inputs are no longer persisted
  between sessions; only worksheet state continues to be persisted

## Impact

- `lib/features/freeform/data/freeform_repository.dart` — deleted
- `lib/features/freeform/` providers and screen — persistence wiring removed
- `main.dart` — `FreeformRepository` construction and override removed
- Tests for `FreeformRepository` and freeform persistence — deleted or updated
- No new dependencies; no API or public interface changes
