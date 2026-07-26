## 1. `TestRepositories` helper

- [ ] 1.1 Write `test/helpers/repository_overrides_test.dart` (red first):
  default construction exposes all four repositories and an `overrides` list
  of length 4; `initialPrefs` seeds the underlying `SharedPreferences` (e.g.
  assert `settings.load()` reflects a seeded `precision` value); each
  `Override.origin` in `overrides` matches the corresponding provider.
- [ ] 1.2 Implement `test/helpers/repository_overrides.dart`:
  `TestRepositories` class with `settings`, `worksheet`, `freeformHistory`,
  `currencyRate` fields, async `create({Map<String, Object> initialPrefs =
  const {}})` factory, and an `overrides` getter.
- [ ] 1.3 Run `flutter test test/helpers/repository_overrides_test.dart` and
  confirm it passes.

## 2. `pumpApp` helper

- [ ] 2.1 Write `test/helpers/pump_app_test.dart` (red first): pumping a
  minimal widget that reads a must-override provider succeeds with no setup;
  a caller-supplied override for a provider with a default takes precedence;
  a `TestRepositories` passed via `repos:` is the one used (verify a
  pre-seeded value on it is visible after pumping).
- [ ] 2.2 Implement `test/helpers/pump_app.dart`: async `pumpApp(WidgetTester
  tester, Widget child, {TestRepositories? repos, List<Override> overrides =
  const []})`, merging `repos.overrides` (defaulting to a fresh
  `TestRepositories.create()`) with `overrides` keyed by `Override.origin` so
  caller overrides win, then `tester.pumpWidget(ProviderScope(overrides:
  merged, child: MaterialApp(home: child)))`.
- [ ] 2.3 Run `flutter test test/helpers/pump_app_test.dart` and confirm it
  passes.

## 3. Migrate provider-container tests (no widget tree)

- [ ] 3.1 Migrate `test/features/settings/state/settings_provider_test.dart`
  to build its `ProviderContainer` overrides from `TestRepositories`
  (including the mid-test reseeded-prefs case).
- [ ] 3.2 Migrate `test/features/worksheet/state/worksheet_provider_test.dart`
  the same way (note: this file also uses a separate `UnitRepository`
  variable named `repo` for `registerDynamic` calls — leave that untouched,
  only the must-override providers move to `TestRepositories`).
- [ ] 3.3 Run `flutter test --reporter failures-only test/features/settings/state/settings_provider_test.dart test/features/worksheet/state/worksheet_provider_test.dart`.

## 4. Migrate simple widget tests (single/default provider set, no reseeding)

- [ ] 4.1 Migrate `test/widget_test.dart`.
- [ ] 4.2 Migrate `test/features/worksheet/presentation/worksheet_screen_test.dart`.
- [ ] 4.3 Migrate `test/features/worksheet/presentation/worksheet_screen_banner_test.dart`.
- [ ] 4.4 Migrate `test/features/worksheet/presentation/worksheet_two_pane_test.dart`.
- [ ] 4.5 Migrate `test/features/worksheet/presentation/worksheet_rebuild_scope_test.dart`.
- [ ] 4.6 Migrate `test/features/freeform/presentation/freeform_rebuild_scope_test.dart`.
- [ ] 4.7 Migrate `test/features/freeform/presentation/freeform_two_pane_test.dart`
  (keep its `seed()` helper, now calling `.save()` on `repos.freeformHistory`).
- [ ] 4.8 Migrate `test/features/freeform/freeform_integration_test.dart`.
- [ ] 4.9 Migrate `test/features/browser/presentation/browser_two_pane_test.dart`.
- [ ] 4.10 Migrate `test/shared/app_shell_test.dart` (keep its
  `unitRepositoryProvider` override passed via `pumpApp`'s `overrides:`
  parameter).
- [ ] 4.11 Migrate `test/shared/safe_area_test.dart` (same note re:
  `unitRepositoryProvider`; keep its `PackageInfo.setMockInitialValues` call).
- [ ] 4.12 Run `flutter test --reporter failures-only` on all files touched in
  this group.

## 5. Migrate widget tests with per-test reseeding or pre-seeded data

- [ ] 5.1 Migrate `test/features/settings/presentation/settings_screen_test.dart`,
  replacing the mid-test dark-mode reseed with a fresh
  `TestRepositories.create(initialPrefs: {'themeMode': 'dark'})`.
- [ ] 5.2 Migrate `test/features/freeform/presentation/freeform_screen_test.dart`,
  replacing each inline on-submit-mode `SharedPreferences`
  reseed-and-rebuild block with `TestRepositories.create(initialPrefs:
  {'evaluationMode': 'onSubmit'})` + `pumpApp(..., repos: repos)`.
- [ ] 5.3 Migrate `test/features/about/presentation/about_screen_test.dart`
  (keep its `PackageInfo`/`FakeUrlLauncher` setup untouched).
- [ ] 5.4 Run `flutter test --reporter failures-only` on the three files
  touched in this group.

## 6. Migrate widget tests with module-level (non-`main()`) setup

- [ ] 6.1 Migrate `test/features/browser/presentation/browser_screen_test.dart`
  (`_setUpSettings()` builds a `TestRepositories` into a top-level variable
  instead of a bare `SettingsRepository`).
- [ ] 6.2 Migrate `test/features/browser/presentation/unit_entry_detail_screen_test.dart`
  (keep its `_buildSeededCurrencyRateRepo` helper, now building a
  `TestRepositories` with a pre-seeded `currencyRate` and passing it via
  `repos:`).
- [ ] 6.3 Migrate `test/shared/widgets/app_drawer_test.dart`.
- [ ] 6.4 Migrate `test/features/freeform/presentation/home_screen_test.dart`.
- [ ] 6.5 Run `flutter test --reporter failures-only` on the four files
  touched in this group.

## 7. Final verification

- [ ] 7.1 Run the full suite: `flutter test --reporter failures-only`.
- [ ] 7.2 Run `flutter analyze` and remove any now-unused imports left behind
  by the migrations.
- [ ] 7.3 Grep the 21 migrated files for leftover
  `SharedPreferences.setMockInitialValues`/`Repository(prefs)` boilerplate
  that should have moved to `TestRepositories`, confirming only the
  intentionally-kept cases remain (`PackageInfo` seeding, the
  non-must-override `UnitRepository` variables, `_buildSeededCurrencyRateRepo`).
- [ ] 7.4 Update `doc/code_review_2026-07.md`: mark F10 done (top-5 list,
  finding heading/status line, sequencing section).
- [ ] 7.5 Add a dated entry to `doc/design_progress.md` (test count, new
  helper files, migrated-file count, design decisions) and bump "Last
  Updated"; cross-reference from `doc/code_review_2026-07.md`'s F10 entry.
