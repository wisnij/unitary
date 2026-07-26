## Why

Phase 9's "Comprehensive testing" task and code review finding F9 both call
for an `integration_test/` suite — none exists today. The existing ~2000
widget tests never execute the real `main()` entry point, never exercise the
real (non-mocked) `SharedPreferences` plugin, and never verify that persisted
data actually survives a full reconstruction of the app's provider graph.
Those gaps are exactly the seams a `flutter test`-based widget test
structurally cannot cover, and they're the highest-value target for a first
integration-test pass: the boot sequence in `main.dart` (five
must-override providers, pre-first-frame currency-rate rehydration) has zero
automated coverage today.

## What Changes

- Add the `integration_test` Flutter SDK package as a dev dependency.
- Add `integration_test/` with three coverage groups, all run against the
  Chrome (web) target so no Android/iOS emulator is required:
  - **Boot sequence**: drive the real `app.main()` and confirm the app
    reaches the Freeform screen with every must-override provider resolved,
    and that a currency rate stored before launch is applied to the unit
    repository before the first frame (the `main.dart` rehydration loop).
  - **Restart/persistence**: call `app.main()` a second time within the same
    test session (same real, `localStorage`-backed `SharedPreferences`) and
    confirm worksheet source values, settings, and freeform history survive
    a full provider-graph reconstruction.
  - **Currency refresh**: exercise the manual-refresh flow end to end
    (status update, unit-repository update, a conversion reflecting the new
    rate) against a mocked HTTP client (`package:http/testing.dart`), never
    the real Frankfurter API.
- Wire `flutter test integration_test/ -d chrome` into CI alongside the
  existing widget-test job.
- Add a small helper for seeding/clearing the *real* `SharedPreferences`
  plugin from within an integration test (distinct from the existing
  `TestRepositories`/`pumpApp` widget-test harness, which relies on the
  mocked plugin and therefore doesn't apply here).

**Explicitly out of scope** (left for later, as discussed): Android/iOS
emulator runs, on-device frame-timing/performance assertions (already
covered as a manual procedure in `doc/performance.md`), and testing the
currency-refresh cooldown timer's expiry-then-re-enable behavior (a
pre-existing coverage gap, unrelated to this change — worth its own
follow-up).

## Capabilities

### New Capabilities

- `integration-test-harness`: web-target `integration_test/` suite covering
  app boot, cross-restart persistence, and the currency-refresh flow, plus
  the CI wiring and real-`SharedPreferences` seeding helper that support it.

### Modified Capabilities

(none — this change adds test coverage and CI wiring; no product-level
requirement changes)

## Impact

- **New dependency**: `integration_test` (Flutter SDK package, no external
  pub dependency or version to track).
- **New directory**: `integration_test/` (test code) plus a small helper
  module alongside it for real-prefs seeding.
- **CI**: `.github/actions/test/action.yml` (or a new sibling action/job)
  gains a Chrome-targeted integration-test step.
- **No changes to `lib/`** — the boot-sequence and restart tests rely on
  seeding a fresh `updatedAt` in stored currency rates before boot so
  `maybeRefresh()`'s staleness check short-circuits, avoiding any real
  network call without touching `main.dart`.
