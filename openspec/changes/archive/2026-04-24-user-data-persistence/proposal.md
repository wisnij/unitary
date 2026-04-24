## Why

Input data is lost every time the app is closed.  Users expect their last
entries to be waiting for them when they return — persisting the freeform
input fields and the active worksheet (plus each template's source values)
across sessions is the missing piece before the app feels production-ready.

## What Changes

**Worksheet persistence:**

- The active worksheet ID is saved to SharedPreferences on change and restored
  on launch.
- Each template's source-row text is saved to SharedPreferences (JSON map)
  whenever a value changes and restored on launch.
- `WorksheetNotifier` is initialized from persisted state instead of blanks.
- `WorksheetRepository` encapsulates all worksheet persistence I/O (mirrors the
  existing `SettingsRepository` pattern).

**Freeform persistence:**

- The "Convert from" and "Convert to" field text strings are saved to
  SharedPreferences whenever they change and restored on launch.
- `FreeformNotifier` gains storage of the raw input/output strings so they
  can be written through to the repository and read back at init time.
- `FreeformRepository` encapsulates freeform persistence I/O.
- `FreeformScreen` initializes its `TextEditingController`s from the
  persisted strings on first build.

**No new package dependencies** — SharedPreferences (already a dependency) is
sufficient for the amount of structured data being stored; sqflite is deferred
until a use case that truly requires relational queries (e.g. custom worksheets
in Phase 12).

## Capabilities

### New Capabilities

- `worksheet-persistence`: Cross-session persistence of worksheet state —
  active template selection and per-template source values — backed by
  SharedPreferences.
- `freeform-persistence`: Cross-session persistence of the freeform "Convert
  from" and "Convert to" field text values, backed by SharedPreferences.

### Modified Capabilities

*(none — settings persistence already works; favorite units deferred to
Phase 12)*

## Impact

- **`lib/features/worksheet/`**: new `data/worksheet_repository.dart`;
  `WorksheetNotifier` gains async init and write-through on state changes.
- **`lib/features/freeform/`**: new `data/freeform_repository.dart`;
  `FreeformNotifier` gains raw text state + write-through; `FreeformScreen`
  reads persisted strings for controller initialization.
- **`lib/features/settings/`**: no changes required.
- **`pubspec.yaml`**: no new dependencies.
- **`test/features/worksheet/`**: new repository tests + updated notifier
  tests for persistence init path.
- **`test/features/freeform/`**: new repository tests + updated notifier/screen
  tests for persistence init path.
