## Context

Phase 7 added `FreeformRepository`, which persists the "Convert from" and "Convert to"
text fields to `SharedPreferences` and restores them in `FreeformScreen.initState()`.
In practice, restoring stale expressions is more disorienting than helpful.  Worksheet
state persistence (active template + per-template source values) is well-received and
remains untouched.

## Goals / Non-Goals

**Goals:**

- Remove all freeform input persistence code
- Freeform screen always starts with empty fields
- Leave worksheet persistence fully intact

**Non-Goals:**

- Changing any other persistence behavior (settings, worksheet values)
- Changing freeform evaluation or display logic

## Decisions

**Delete `FreeformRepository` entirely** rather than adding a toggle.  The repository
has only one consumer (`FreeformScreen`) and only one concern (persisting two strings).
Keeping it behind a flag would add complexity with no current benefit.

**Clear persisted keys from `SharedPreferences` at startup** (via a one-time migration)
rather than leaving orphaned data in storage.  This keeps the preferences store clean
and avoids confusion if freeform persistence is ever re-introduced in the future.
Concretely: delete keys `freeformInput` and `freeformOutput` from `SharedPreferences`
on first launch after this change.  Since the keys are simply absent going forward,
no version flag is needed — the deletion is idempotent.

Alternative considered: leave orphaned keys in place and simply stop reading them.
Simpler to implement, but leaves stale data indefinitely.

## Risks / Trade-offs

- **Data loss** — users who had saved freeform expressions lose them on upgrade.
  Acceptable: the feature is being removed intentionally.
- **No rollback path** — once keys are deleted they cannot be recovered.  Acceptable
  given the motivation (the persistence was actively unwanted).

## Migration Plan

1. On app launch in `main()`, after `SharedPreferences.getInstance()`, call
   `prefs.remove('freeformInput')` and `prefs.remove('freeformOutput')`.
2. Remove `FreeformRepository`, its provider, and the `ProviderScope` override.
3. Remove persistence wiring from `FreeformScreen.initState()`.
4. Delete repository source and test files.
