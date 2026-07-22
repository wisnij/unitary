## Why

The July 2026 code review (doc/code_review_2026-07.md, finding F1) flagged that `UserSettings` (`lib/features/settings/models/user_settings.dart`) imports `package:flutter/material.dart` solely for the `themeMode` field's `ThemeMode` type. This drags Flutter transitively into the worksheet engine (`lib/features/worksheet/services/worksheet_engine.dart`, which only reads `settings.precision`/`settings.notation`), so `computeWorksheet()` cannot run under plain `dart` and its benchmark has to live under `flutter test` (`test/tool/worksheet_benchmark_test.dart`) instead of the standalone `tool/benchmark.dart` script — a workaround already documented as a "deferred refactor" in `doc/performance.md`.

## What Changes

- Replace `ThemeMode` in `UserSettings` with a project-owned `ThemePreference` enum (`system`/`dark`/`light`), removing the Flutter import from `user_settings.dart`.
- Map `ThemePreference` → Flutter's `ThemeMode` at the single UI consumption point in `lib/app.dart` (feeding `MaterialApp.themeMode`).
- Update `SettingsRepository` and `SettingsNotifier` to use `ThemePreference` throughout; both lose their now-unneeded `package:flutter/material.dart` import as a direct consequence. Storage format is unchanged — the same `"system"/"dark"/"light"` strings are persisted.
- Update `settings_screen.dart`'s theme radio group to bind to `ThemePreference` instead of `ThemeMode` (this file remains Flutter UI code, as expected).
- Move the `computeWorksheet()` benchmark cases (`worksheet-compute-length`, `worksheet-compute-temperature`) from `test/tool/worksheet_benchmark_test.dart` into `tool/benchmark.dart`'s `buildDefaultCases()`, now that the import chain is pure Dart; delete the Flutter-hosted companion test (its correctness-smoke-test role is already covered by the 14 dedicated tests in `test/features/worksheet/services/worksheet_engine_test.dart`).
- Update `doc/performance.md` to remove the "deferred refactor" note and the companion-benchmark workaround description, and record the new unified `tool/benchmark.dart` numbers.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `benchmark-tool`: the requirement describing the Flutter-forced companion benchmark (`test/tool/worksheet_benchmark_test.dart` run via `flutter test`) is replaced — `computeWorksheet()` is now benchmarked as ordinary cases inside `tool/benchmark.dart`, covered by the existing "Full run covers all cases" scenario. No other benchmark-tool requirements change.

## Impact

- `lib/features/settings/models/user_settings.dart` — new `ThemePreference` enum, field type change; no more Flutter import.
- `lib/features/settings/data/settings_repository.dart`, `lib/features/settings/state/settings_provider.dart` — type updates; both drop their Flutter import.
- `lib/features/settings/presentation/settings_screen.dart` — `RadioGroup`/`RadioListTile` generic type updates only; still Flutter UI code.
- `lib/app.dart` — new `ThemePreference` → `ThemeMode` mapping at the `MaterialApp.themeMode` call site.
- `tool/benchmark.dart` — two new benchmark cases; drops the "computeWorksheet lives separately" doc comment.
- `test/tool/worksheet_benchmark_test.dart` — deleted.
- Test files referencing `UserSettings.themeMode`/`ThemeMode` values (`user_settings_test.dart`, `settings_repository_test.dart`, `settings_provider_test.dart`, `settings_screen_test.dart`) — mechanical rename to `ThemePreference`; `freeform_integration_test.dart`'s assertion on `MaterialApp.themeMode` (the actual Flutter widget property) is unaffected.
- No storage/migration impact: persisted preference strings are unchanged, so existing installs keep their saved theme choice.
- No new dependencies.
