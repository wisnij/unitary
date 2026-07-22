## Context

`UserSettings.themeMode` is typed as Flutter's `ThemeMode` enum. This is the only reason `lib/features/settings/models/user_settings.dart` imports `package:flutter/material.dart`, and that import propagates through `lib/features/worksheet/services/worksheet_engine.dart` (which takes a `UserSettings` parameter) into the pure-logic worksheet engine. The resulting Flutter dependency in `computeWorksheet()`'s import chain is why its benchmark currently lives under `flutter test` (`test/tool/worksheet_benchmark_test.dart`) rather than the standalone-VM `tool/benchmark.dart` script — documented as a known workaround in `openspec/specs/benchmark-tool/spec.md` and a "deferred refactor" in `doc/performance.md`. Code review finding F1 recommends breaking this coupling.

## Goals / Non-Goals

**Goals:**

- Remove `package:flutter/material.dart` from `user_settings.dart`, making the whole `worksheet_engine → user_settings` import chain pure Dart.
- Preserve the persisted preference format exactly (`"system"/"dark"/"light"` strings), so no migration is needed and existing users' saved theme choice survives the upgrade unchanged.
- Fold the `computeWorksheet()` benchmark into `tool/benchmark.dart` alongside the other core-domain hot paths, and retire the Flutter-hosted companion test.

**Non-Goals:**

- No change to the Settings screen's visible behavior, radio button layout, or labels.
- No change to `SettingsRepository`'s persistence keys or `SharedPreferences` schema.
- Not addressing the other Flutter-in-core-adjacent findings from the review (F2: Riverpod provider location, F3: `UnitRepository` query-builder extraction) — those are separate, unrelated findings.

## Decisions

- **New enum name: `ThemePreference`, not a broader "settings enum" or reuse of an existing type.** It names exactly what it represents (the user's stored preference, as distinct from Flutter's runtime `ThemeMode`), and using the same three case names (`system`, `dark`, `light`) as `ThemeMode` keeps the mapping trivial and the intent obvious at every call site.
- **Enum lives in `user_settings.dart` itself**, next to `Notation` and `EvaluationMode`, which already follow this pattern (small settings-related enums colocated with the model that uses them). No new file needed.
- **Mapping point: `lib/app.dart`, inline in `build()`.** This is the single place a `ThemeMode` is actually needed (feeding `MaterialApp.themeMode`), matching the review's suggested fix. A private local helper (`ThemeMode _toFlutterThemeMode(ThemePreference)` or an inline `switch` expression) is enough — no need for a shared extension type or a new file, since there is exactly one call site.
- **`settings_repository.dart` and `settings_provider.dart` naturally lose their Flutter imports too.** This wasn't explicitly called out as in-scope by the review, but it falls out mechanically from following `ThemePreference` through every file that currently imports `material.dart` only for `ThemeMode`— leaving the import in place after the type using it is gone would be dead weight the linter would flag as unused. Confirmed by inspection: neither file uses anything else from `material.dart`.
- **`settings_screen.dart` keeps referencing (now `ThemePreference`) values directly** — this file is legitimately Flutter UI code (`RadioGroup`, `RadioListTile`), so no decoupling is needed or attempted there.
- **Benchmark cases move into `buildDefaultCases()` in `tool/benchmark.dart`, not a separate function.** They're conceptually identical to the existing cases (fixed `sharedRepo`/`sharedParser`, `BenchmarkCase` with a 20-iteration `iteration` closure) and belong in the same list so `--filter worksheet` and the full run both pick them up automatically.
- **Delete `test/tool/worksheet_benchmark_test.dart` outright** rather than slimming it to a pure correctness check. Its stated purpose (per its own doc comment) was working around the Flutter-import problem; once that's gone, its only remaining value — a smoke test that `computeWorksheet()` doesn't error on real templates — is already covered more thoroughly by the 14 existing tests in `test/features/worksheet/services/worksheet_engine_test.dart`. Keeping a near-duplicate file would just be more surface to maintain.

## Risks / Trade-offs

- **Widespread mechanical rename**: five `lib/` files and five `test/` files reference `ThemeMode` in the settings context. The risk is a missed call site causing a type error, which `flutter analyze` catches immediately — not a runtime risk.
- **Benchmark numbers move files**: anyone with a saved `--baseline` JSON from the old `tool/benchmark.dart` won't have `worksheet-compute-*` entries to compare against; the tool already reports baseline case mismatches gracefully (`benchmark-tool` spec's "Baseline case mismatch" scenario) rather than failing, so this is a non-issue.
- **`freeform_integration_test.dart`'s `materialApp.themeMode` assertion** checks the real Flutter widget property (set via the `app.dart` mapping), not the settings model — verified unaffected, but worth double-checking after the change since it's easy to conflate the two `themeMode`-named things.

## Migration Plan

No data migration: `SettingsRepository` persists `ThemePreference` under the same key (`themeMode`) with the same three string values, so `load()` on an upgraded app reads an existing user's stored preference identically to before. No rollback concerns beyond normal code revert.
