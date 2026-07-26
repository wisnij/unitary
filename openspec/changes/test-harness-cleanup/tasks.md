## 1. `TestRepositories` helper

- [x] 1.1 Write `test/helpers/repository_overrides_test.dart` (red first):
  default construction exposes all four repositories and an `overrides` list
  of length 4; `initialPrefs` seeds the underlying `SharedPreferences` (e.g.
  assert `settings.load()` reflects a seeded `precision` value); each
  `Override.origin` in `overrides` matches the corresponding provider.
- [x] 1.2 Implement `test/helpers/repository_overrides.dart`:
  `TestRepositories` class with `settings`, `worksheet`, `freeformHistory`,
  `currencyRate` fields, async `create({Map<String, Object> initialPrefs =
  const {}})` factory, and an `overrides` getter.
- [x] 1.3 Run `flutter test test/helpers/repository_overrides_test.dart` and
  confirm it passes.

## 2. `pumpApp` helper

- [x] 2.1 Write `test/helpers/pump_app_test.dart` (red first): pumping a
  minimal widget that reads a must-override provider succeeds with no setup;
  a caller-supplied override for a provider with a default takes precedence;
  a `TestRepositories` passed via `repos:` is the one used (verify a
  pre-seeded value on it is visible after pumping).
- [x] 2.2 Implement `test/helpers/pump_app.dart`: async `pumpApp(WidgetTester
  tester, Widget child, {TestRepositories? repos, List<Override> overrides =
  const []})`, merging `repos.overrides` (defaulting to a fresh
  `TestRepositories.create()`) with `overrides` keyed by `Override.origin` so
  caller overrides win, then `tester.pumpWidget(ProviderScope(overrides:
  merged, child: MaterialApp(home: child)))`.
- [x] 2.3 Run `flutter test test/helpers/pump_app_test.dart` and confirm it
  passes.
- [x] 2.4 (unplanned) `Override` isn't re-exported by `flutter_riverpod`;
  added `riverpod` as an explicit `dev_dependency` in `pubspec.yaml` (already
  resolved transitively at 3.2.1) per user confirmation, and imported
  `Override` from `package:riverpod/misc.dart`.

## 3. Migrate provider-container tests (no widget tree)

- [x] 3.1 Migrate `test/features/settings/state/settings_provider_test.dart`
  to build its `ProviderContainer` overrides from `TestRepositories`
  (including the mid-test reseeded-prefs case).
- [x] 3.2 Migrate `test/features/worksheet/state/worksheet_provider_test.dart`
  the same way (note: this file also uses a separate `UnitRepository`
  variable named `repo` for `registerDynamic` calls — leave that untouched,
  only the must-override providers move to `TestRepositories`). Also added a
  `prefs` field to `TestRepositories` (with its own red-first test) to cover
  a test that writes malformed raw JSON directly to `SharedPreferences`.
- [x] 3.3 Run `flutter test --reporter failures-only test/features/settings/state/settings_provider_test.dart test/features/worksheet/state/worksheet_provider_test.dart`.

## 4. Migrate simple widget tests (single/default provider set, no reseeding)

- [x] 4.1 Migrate `test/widget_test.dart` (uses manual `ProviderScope` since
  `UnitaryApp` is itself a `MaterialApp`; `pumpApp` would double-wrap it).
- [x] 4.2 Migrate `test/features/worksheet/presentation/worksheet_screen_test.dart`
  (kept its local `buildApp()`, sourced from `repos.overrides`, since it's
  reused across 13 call sites).
- [x] 4.3 Migrate `test/features/worksheet/presentation/worksheet_screen_banner_test.dart`
  (same `buildApp()`-preservation pattern, plus the `currencyStatusProvider`
  override).
- [x] 4.4 Migrate `test/features/worksheet/presentation/worksheet_two_pane_test.dart`
  (single call site — inlined into `pumpApp` directly, `buildApp()` removed).
- [x] 4.5 Migrate `test/features/worksheet/presentation/worksheet_rebuild_scope_test.dart`
  (`pumpApp` at both call sites, `buildApp()` removed).
- [x] 4.6 Migrate `test/features/freeform/presentation/freeform_rebuild_scope_test.dart`
  (same).
- [x] 4.7 Migrate `test/features/freeform/presentation/freeform_two_pane_test.dart`
  (kept its `seed()` helper, now calling `.save()` on `repos.freeformHistory`;
  `pump()` now calls `pumpApp(..., repos: repos)`).
- [x] 4.8 Migrate `test/features/freeform/freeform_integration_test.dart`
  (manual `ProviderScope`, same `UnitaryApp` double-`MaterialApp` reason as
  4.1).
- [x] 4.9 Migrate `test/features/browser/presentation/browser_two_pane_test.dart`
  (single call site — inlined into `pumpApp` with `unitRepositoryProvider`/
  `browserProvider` passed via `overrides:`).
- [x] 4.10 Migrate `test/shared/app_shell_test.dart` (kept its local
  `buildApp()`, sourced from `repos.overrides` plus the
  `unitRepositoryProvider` override).
- [x] 4.11 Migrate `test/shared/safe_area_test.dart` (same pattern; kept its
  `PackageInfo.setMockInitialValues` call).
- [x] 4.12 Run `flutter test --reporter failures-only` on all files touched in
  this group.

## 5. Migrate widget tests with per-test reseeding or pre-seeded data

- [x] 5.1 Migrate `test/features/settings/presentation/settings_screen_test.dart`,
  replacing the mid-test dark-mode reseed with a fresh
  `TestRepositories.create(initialPrefs: {'themeMode': 'dark'})`.
- [x] 5.2 Migrate `test/features/freeform/presentation/freeform_screen_test.dart`,
  replacing each inline on-submit-mode `SharedPreferences`
  reseed-and-rebuild block (6 occurrences) with
  `pumpApp(tester, FreeformScreen(...), repos: await
  TestRepositories.create(initialPrefs: {'evaluationMode': 'onSubmit'}))`.
- [x] 5.3 Migrate `test/features/about/presentation/about_screen_test.dart`
  (keep its `PackageInfo`/`FakeUrlLauncher` setup untouched; fixed a
  `directives_ordering` lint from moving `url_launcher_platform_interface`
  imports after `unitary` imports — blank-line-separated import groups still
  need to sort as one alphabetical package: block).
- [x] 5.4 Run `flutter test --reporter failures-only` on the three files
  touched in this group.

## 6. Migrate widget tests with module-level (non-`main()`) setup

- [x] 6.1 Migrate `test/features/browser/presentation/browser_screen_test.dart`
  (`_setUpRepos()` builds a `TestRepositories` into a top-level variable
  instead of a bare `SettingsRepository`).
- [x] 6.2 Migrate `test/features/browser/presentation/unit_entry_detail_screen_test.dart`
  (kept its `_buildSeededCurrencyRateRepo` helper, now building a
  `TestRepositories` and returning its pre-seeded `currencyRate`. Discovered
  and fixed a real bug here: `ProviderScope`/`ProviderContainer` overrides
  use *first*-occurrence-wins for duplicate providers in a raw list, not
  last — the opposite of what `pumpApp`'s explicit origin-keyed merge
  provides. An initial `[...repos.overrides, if (x != null)
  currencyRateRepositoryProvider.overrideWithValue(x)]` silently kept the
  unseeded default. Fixed by building `_buildScreen`'s override list
  explicitly (matching the original code's shape) instead of spreading
  `repos.overrides`. Audited all other migrated files for the same pattern —
  no other file spreads `repos.overrides` while also separately overriding
  one of the same 4 providers, so this was an isolated case.).
- [x] 6.3 Migrate `test/shared/widgets/app_drawer_test.dart`.
- [x] 6.4 Migrate `test/features/freeform/presentation/home_screen_test.dart`.
- [x] 6.5 Run `flutter test --reporter failures-only` on the four files
  touched in this group.

## 7. Final verification

- [x] 7.1 Run the full suite: `flutter test --reporter failures-only`. 2043
  tests passing (2035 baseline + 8 new helper tests).
- [x] 7.2 Run `flutter analyze` and remove any now-unused imports left behind
  by the migrations. Clean.
- [x] 7.3 Grep the 21 migrated files for leftover
  `SharedPreferences.setMockInitialValues`/`Repository(prefs)` boilerplate
  that should have moved to `TestRepositories`, confirming only the
  intentionally-kept cases remain (`PackageInfo` seeding, the
  non-must-override `UnitRepository` variables, `_buildSeededCurrencyRateRepo`).
  Zero hits — clean. This grep also surfaced that
  `test/features/freeform/state/freeform_provider_test.dart` was present in
  the original 21-file candidate list (confirmed via `grep -rl
  "settingsRepositoryProvider\.overrideWithValue" test/` during design) but
  was never assigned to a task group 3–6 — a real gap in task planning, not
  caught until this step. Migrated it here: `setUp` now uses
  `TestRepositories.create()` + `container = ProviderContainer(overrides:
  repos.overrides)`; one inline `ProviderContainer` with a custom
  `parserProvider` override also migrated. 55/55 tests pass, `flutter
  analyze` clean. All 21 originally-identified files are now migrated.
- [x] 7.4 Update `doc/code_review_2026-07.md`: mark F10 done (top-5 list,
  finding heading/status line, sequencing section).
- [x] 7.5 Add a dated entry to `doc/design_progress.md` (test count, new
  helper files, migrated-file count, design decisions) and bump "Last
  Updated"; cross-reference from `doc/code_review_2026-07.md`'s F10 entry.
