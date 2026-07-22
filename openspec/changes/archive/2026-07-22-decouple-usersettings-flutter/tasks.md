## 1. Core model

- [x] 1.1 Add `ThemePreference` enum (`system`, `dark`, `light`) to `lib/features/settings/models/user_settings.dart`, alongside `Notation`/`EvaluationMode`; change `UserSettings.themeMode`'s type from `ThemeMode` to `ThemePreference` (constructor default, `copyWith`, `==`, `hashCode`, `toString`); remove the `package:flutter/material.dart` import
- [x] 1.2 Update `test/features/settings/models/user_settings_test.dart`: replace every `ThemeMode.*` reference with `ThemePreference.*` (constructor defaults, `copyWith`, equality, `toString` cases, and the `for (final m in ThemeMode.values)` loop)

## 2. Repository

- [x] 2.1 Update `lib/features/settings/data/settings_repository.dart`: `_loadThemeMode`/`_themeModeToString`/`_themeModeFromString` switch over `ThemePreference` instead of `ThemeMode`, keeping the same `"system"/"dark"/"light"` string values; remove the now-unused `package:flutter/material.dart` import
- [x] 2.2 Update `test/features/settings/data/settings_repository_test.dart`: replace `ThemeMode.*` with `ThemePreference.*` in all save/load round-trip and fallback tests; assertions on the persisted string values (`'dark'`, `'light'`, `'system'`) are unchanged

## 3. Provider

- [x] 3.1 Update `lib/features/settings/state/settings_provider.dart`: `SettingsNotifier.updateThemeMode` takes `ThemePreference`; remove the now-unused `package:flutter/material.dart` import
- [x] 3.2 Update `test/features/settings/state/settings_provider_test.dart`: replace `ThemeMode.*` with `ThemePreference.*` in the three `updateThemeMode` tests

## 4. Settings screen (UI)

- [x] 4.1 Update `lib/features/settings/presentation/settings_screen.dart`: change `RadioGroup<ThemeMode>`/`RadioListTile<ThemeMode>` to `RadioGroup<ThemePreference>`/`RadioListTile<ThemePreference>`, and the three `value:` arguments from `ThemeMode.system/dark/light` to `ThemePreference.system/dark/light`
- [x] 4.2 Update `test/features/settings/presentation/settings_screen_test.dart`: replace `ThemeMode.*` with `ThemePreference.*` in the three radio-selection tests (the `SharedPreferences.setMockInitialValues({'themeMode': 'dark'})` seed data is unchanged — it's the persisted string, not the type)

## 5. App-level mapping

- [x] 5.1 In `lib/app.dart`, add a small `ThemePreference` → `ThemeMode` mapping (e.g. a private switch expression) and use it for `MaterialApp.themeMode: ...` instead of passing `settings.themeMode` directly
- [x] 5.2 Confirm `test/features/freeform/freeform_integration_test.dart`'s assertion on `materialApp.themeMode` (`ThemeMode.dark`, checking the real Flutter widget property) still passes unchanged — no edit expected, just verification

## 6. Benchmark migration

- [x] 6.1 Add `worksheet-compute-length` and `worksheet-compute-temperature` `BenchmarkCase`s to `buildDefaultCases()` in `tool/benchmark.dart`, mirroring the logic currently in `test/tool/worksheet_benchmark_test.dart` (import `computeWorksheet`, `predefinedWorksheets`, `UserSettings`; reuse the existing `sharedRepo`/`sharedParser`)
- [x] 6.2 Update `tool/benchmark.dart`'s file-level doc comment to remove the note that `computeWorksheet()` lives in a separate Flutter-hosted companion
- [x] 6.3 Delete `test/tool/worksheet_benchmark_test.dart`

## 7. Documentation

- [x] 7.1 In `doc/performance.md`: remove the "Companion worksheet benchmark — `flutter test`, debug JIT" section and its numbers table, and the "Deferred refactor: decouple `UserSettings` from Flutter" follow-up bullet; add the new `worksheet-compute-*` rows to whatever section now documents `tool/benchmark.dart`'s output, with freshly measured numbers
- [x] 7.2 Add a dated entry to `doc/design_progress.md`'s implementation-progress log for this change (matching the project's established entry format), and bump the "Last Updated" date
- [x] 7.3 In `doc/code_review_2026-07.md`, mark finding F1 as done (heading suffix, top-five recommendation strikethrough, and sequencing-section strikethrough), matching how F6 was marked previously

## 8. Verify

- [x] 8.1 Run `flutter analyze` — no issues, and specifically confirm no unused-import warnings on `settings_repository.dart`/`settings_provider.dart`
- [x] 8.2 Run `flutter test --reporter failures-only` — all tests pass
- [x] 8.3 Run `dart run tool/benchmark.dart --filter worksheet-compute` directly (standalone VM, no `flutter test`) and confirm both cases execute and print timings, proving the import chain is now Flutter-free
- [x] 8.4 Spot-check `grep -rn "flutter" lib/features/settings/models/user_settings.dart lib/features/worksheet/services/worksheet_engine.dart` returns nothing
