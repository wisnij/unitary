Code Review: Architecture & Tech Debt (July 2026)
=================================================

A full-repo review (lib/, test/, tool/, doc/, CI/config) conducted July 17,
2026, at the start of Phase 9 wrap-up, looking for architecture improvements
and tech debt worth paying off before the MVP release.  Generated files
(`lib/core/domain/data/predefined_units.dart`, `doc/api/`) were excluded.

Baseline at time of review: clean working tree at commit `108ddb2`,
`flutter analyze` clean, all 2036 tests passing.


Summary
-------

The codebase is in very good structural health.  Layering is clean, lint
hygiene is essentially perfect, the test tree mirrors the source tree, and
the known deferred items are all accurately tracked.  Nothing found here is
urgent; the highest-value items are small.

**Top five recommendations:**

1. **F1** — ~~Decouple `UserSettings` from Flutter (small change, unlocks a
   pure-Dart worksheet benchmark and cleans the model layer).~~ **Done**
   (July 22, 2026).
2. **F4** — Fix the dynamic-unit-layer inconsistencies in `UnitRepository`
   before Phase 11 (user-defined units) turns them into real bugs.
3. **F10** — ~~Consolidate the widget-test harness boilerplate; it is the
   single biggest friction multiplier for future work.~~ **Done**
   (July 26, 2026).
4. **F12/F13** — ~~Do the README rewrite and doc audit now (both already
   Phase 9 tasks); the README has outright broken links.~~ **Done**
   (August 5, 2026, together with F14/F15).
5. **F6** — ~~Delete the leftover `findConformable` debug instrumentation
   (two-minute fix).~~ **Done** (July 19, 2026).


Findings
--------

Each finding: category, evidence, impact, effort (S/M/L), suggested fix.
Known-deferred items from the implementation plan are included and
re-ranked alongside new findings.

### F1: `UserSettings` couples the pure-logic layer to Flutter — DONE

- **Status:** ✅ **Completed** July 22, 2026
  (`openspec/changes/decouple-usersettings-flutter/`); `UserSettings.themeMode`
  now uses a project-owned `ThemePreference` enum, `user_settings.dart` no
  longer imports Flutter, and `computeWorksheet()`'s benchmark cases moved
  into `tool/benchmark.dart`.
- **Category:** architecture · **Effort:** S · **Known-deferred item**
- **Evidence:** `lib/features/settings/models/user_settings.dart:1` imports
  `package:flutter/material.dart` solely for `ThemeMode` (line 26).  The
  worksheet engine (`lib/features/worksheet/services/worksheet_engine.dart:6`)
  imports it but uses only `settings.precision` and `settings.notation`
  (lines 139–141).
- **Impact:** `computeWorksheet()` cannot run under plain `dart`, forcing its
  benchmark to live in `test/tool/worksheet_benchmark_test.dart` instead of
  `tool/benchmark.dart` (documented in [performance.md](performance.md)).
- **Fix:** replace `ThemeMode` in `UserSettings` with a project-owned
  three-value enum (e.g. `ThemePreference`) and map it to `ThemeMode` at the
  single consumption point in `lib/app.dart`; `SettingsRepository` already
  serializes it as the strings `"system"/"dark"/"light"`, so storage is
  unaffected.  This makes the whole
  `worksheet_engine → user_settings` chain pure Dart, and the benchmark can
  move into `tool/benchmark.dart`.  (Alternative — narrowing the engine's
  parameter to `precision`/`notation` — helps less, because `Notation` lives
  in the same Flutter-tainted file.)

### F2: Riverpod provider inside `core/domain/models/`

- **Category:** architecture · **Effort:** S
- **Evidence:** `lib/core/domain/models/unit_repository_provider.dart` (27
  lines) imports `package:flutter_riverpod` — the only state-management
  dependency anywhere under `lib/core/`.
- **Impact:** blemish rather than defect: `flutter_riverpod` transitively
  depends on Flutter, so the core layer is not formally framework-free, and
  the file sits oddly among pure data models.
- **Fix:** move the file to `lib/shared/state/` (or accept it in place with a
  comment).  Mechanical change; ~10 import sites.

### F3: `UnitRepository` has outgrown its name and is accreting query builders

- **Category:** architecture · **Effort:** M
- **Evidence:** `lib/core/domain/models/unit_repository.dart` (778 lines)
  carries the registry (units/prefixes/functions/dynamic layer), resolution +
  cache, *and* four presentation-facing query builders:
  `buildBrowseCatalog()` (line 415), `findConformable()` (552),
  `suggestCompletions()` (625), and `buildCurrencyDescriptors()` (709).  The
  doc comment at lines 56–58 already records the rename debt ("despite the
  name, this registry also holds UnitaryFunction objects").
- **Impact:** the class is still cohesive around its private maps, so this is
  not yet a god object — but each new feature (browse, completion, currency)
  has added a builder here, and the trend will continue with Phase 11/12.
  The three alias-fan-out loops in `buildBrowseCatalog` are near-identical
  copies.
- **Fix:** when next touching this file, extract the query builders into
  separate collaborators (e.g. `BrowseCatalogBuilder`,
  `CompletionSuggester`) that take the repository, and do the rename
  (e.g. `SymbolRegistry`).  Not worth a standalone change now; bundle with
  Phase 11 custom-units work, which must touch registration anyway.

### F4: Dynamic unit layer is inconsistently consulted

- **Category:** correctness (latent) · **Effort:** S
- **Evidence:** in `unit_repository.dart`, `buildBrowseCatalog()` merges
  `{..._units, ..._dynamicUnits}` (line 420), but `findConformable()`
  iterates only `_units.values` (line 555) and `suggestCompletions()`
  iterates only `_unitLookup` (line 654).  Separately, `registerDynamic()` /
  `unregisterDynamic()` clear `_resolvedQuantityCache` (lines 215, 227) but
  never invalidate the `_currencyDescriptors` cache (line 99).
- **Impact:** currently benign — the dynamic layer only ever *shadows*
  compiled currency units with the same names, so nothing is missing from
  conformable/completion results and the descriptor set never changes.  But
  Phase 11 user-defined units will register genuinely *new* dynamic units,
  which would then be invisible to conformable search and completion, and a
  user-defined currency would be missed by descriptor detection.
- **Fix:** make all three query paths use the merged view (a private
  `_mergedUnits` getter), and clear `_currencyDescriptors` in
  `registerDynamic`/`unregisterDynamic`.  Cheap to do now; add tests
  asserting a dynamically registered unit appears in all three query results.

### F5: Freeform eval state still lives in widget `State` (deferred refactor)

- **Category:** architecture · **Effort:** L · **Known-deferred item**
- **Evidence:** `_FreeformScreenState`
  (`lib/features/freeform/presentation/freeform_screen.dart:40–416`) owns the
  controllers, focus tracking, debounce timer, and evaluation triggering; the
  AppShell/AppBar centralization from responsive-layouts remains blocked on
  it.
- **Assessment:** **keep deferred.**  The July 17 rebuild-scoping change
  removed the performance motivation (keystrokes now rebuild zero screen
  subtree widgets), and the file is better factored than its 685-line count
  suggests — over half is private leaf widgets (`_KeyPanel`,
  `_HistoryModal/_HistoryList/_HistoryPane`, `_ConformableUnitsModal`).  The
  remaining benefits (AppBar centralization, unit-testable debounce logic)
  don't currently justify the regression risk in the focus/debounce/
  completion-overlay interplay.  Revisit only when a feature change has to
  rework freeform state anyway.

### F6: Leftover debug instrumentation in `_showConformableModal` — DONE

- **Status:** ✅ **Completed** July 19, 2026
- **Category:** debt · **Effort:** S (trivial)
- **Evidence:** `freeform_screen.dart:183–191` — a `kDebugMode`-gated
  `Stopwatch` + `debugPrint('findConformable took …')` around the
  `findConformable` call, left over from the July performance measurement.
- **Impact:** prints noise into every test run that opens the conformable
  modal (visible in the `flutter test` output for this review) and is dead
  weight in release builds.
- **Fix:** delete it.  The measurement lives on in `tool/benchmark.dart` and
  `doc/performance.md`.

### F7: Fast-scroll thumb drag rebuilds the whole overlay every frame

- **Category:** performance · **Effort:** M · **Known-deferred item**
- **Evidence:** `lib/shared/widgets/fast_scroll_bar.dart` —
  `_onDragUpdate` calls `setState` (line 264) *and then* `jumpTo` (line 267),
  which re-fires the scroll listener `_onScroll`, whose own `setState`
  (line 216) runs unconditionally even when the fraction is unchanged: two
  full `_FastScrollBarState` rebuilds per drag frame.  Matches the
  over-budget 120 Hz drag frames recorded in
  [performance.md](performance.md).
- **Fix direction:** hold `_thumbFraction` in a `ValueNotifier<double>` and
  scope the thumb/peek-panel `Positioned`s under a `ValueListenableBuilder`
  (or `AnimatedBuilder`) so drags reposition without rebuilding the `Stack`
  or re-running `LayoutBuilder`; short-circuit `_onScroll` when the fraction
  and `_hasScrollableContent` are unchanged; keep the list `child` behind a
  `RepaintBoundary`.  As already planned, this change is where the
  `integration_test` frame-timing harness (`traceAction`) should be built to
  verify the fix on-device.

### F8: Worksheet AppBar dropdown overflows at very narrow widths

- **Category:** UI bug · **Effort:** S · **Known-deferred item**
- **Evidence:** `WorksheetDropdown`
  (`lib/features/worksheet/presentation/worksheet_screen.dart:446–473`) —
  `selectedItemBuilder` renders the selected name in unconstrained
  `titleLarge` text; "Digital Storage" overflows at ≲410 dp (noted during
  responsive-layouts, still unfixed).
- **Fix:** wrap the selected-item `Text` in a `FittedBox(fit: scaleDown)` or
  give it `overflow: TextOverflow.ellipsis` inside a `Flexible`; add a
  narrow-width widget test.

### F9: No integration tests — DONE (August 2, 2026)

- **Category:** testing · **Effort:** M · **Already a Phase 9 task**
- **Evidence:** no `integration_test/` directory exists; the 82 test files
  are unit/widget-level only.
- **Fix:** create `integration_test/` with the three flows already named in
  the implementation plan: (1) type an expression → see the converted
  result; (2) switch worksheet template → per-template source values persist
  and restore; (3) trigger a currency refresh (against a faked HTTP layer) →
  conversions reflect updated rates.  Build the frame-timing harness here as
  part of the F7 fix rather than as a separate effort.
- **Resolution:** `integration_test/` added with `boot_test.dart` (the real
  `main()` entry point, including pre-first-frame currency-rate
  rehydration), `restart_test.dart` (worksheet/settings/history persistence
  across a simulated restart against the real `SharedPreferences` plugin),
  and `currency_refresh_test.dart` (manual refresh flow against a mocked
  HTTP client) — 8 scenarios, all passing repeatedly on a real Android
  emulator and running unconditionally in CI for every workflow using
  `./.github/actions/test`.  A web/Chrome path was tried first and abandoned
  as an unresolved upstream Flutter/DWDS bug.  Along the way a real
  production bug was found and fixed (`FastScrollBar` crash on a degenerate
  zero-height layout pass).  The frame-timing harness (`traceAction`) was
  *not* built here — it stays with the F7 fix as originally planned, and
  now has a suite to live in.  See
  `openspec/changes/archive/2026-08-02-integration-tests/` for the full
  design record.

### F10: Widget-test harness boilerplate is repeated across ~28 files — DONE (July 26, 2026)

- **Category:** testing · **Effort:** M (mechanical)
- **Evidence:** ~28 test files each hand-roll
  `ProviderScope(overrides: [settingsRepositoryProvider…,
  freeformHistoryRepositoryProvider…, …], child: MaterialApp(home: …))`
  (e.g. `test/features/freeform/presentation/freeform_screen_test.dart`),
  because four repository providers are must-override
  (`settings`, `worksheet`, `freeformHistory`, `currencyRate`).
- **Impact:** every new must-override provider forces edits across dozens of
  test files — this pattern has already grown four times and Phase 11/12
  will add more.  It is the largest single source of future friction found
  in this review.
- **Fix:** add a `test/helpers/` harness (e.g.
  `pumpApp(tester, widget, {overrides})`) that supplies default in-memory
  repositories for all must-override providers and merges per-test
  overrides.  Migrate opportunistically — new tests use it immediately; old
  tests can be converted file-by-file.
- **Resolution:** `test/helpers/repository_overrides.dart` (`TestRepositories`,
  bundling default in-memory instances of all four repositories plus a
  computed `overrides` list) and `test/helpers/pump_app.dart` (`pumpApp`,
  merging caller overrides over the defaults keyed by `Override.origin` so a
  caller-supplied override for an already-defaulted provider wins). All 21
  files matching the pattern were migrated in one pass rather than left to
  grow a second coexisting convention. See `openspec/changes/archive/`
  (`test-harness-cleanup`) for the full design record, including a real
  Riverpod gotcha found during migration: `ProviderContainer`/`ProviderScope`
  don't resolve a duplicate-provider override by list order at all — they
  throw `AssertionError: Tried to override a provider twice within the same
  container` in `kDebugMode` the instant two overrides share an `origin`.
  `pumpApp`'s explicit origin-keyed merge avoids ever constructing such a
  list; one file that bypassed `pumpApp` initially built one and hit the
  crash (its symptom — ordinary-looking `expect()` failures from an
  unbuilt widget tree — made it easy to first misdiagnose as a silent
  wrong-default bug) and was fixed.

### F11: Coverage is measured in CI but the 80% criterion is not enforced — DONE (August 13, 2026)

- **Category:** testing · **Effort:** S
- **Evidence:** `.github/actions/test/action.yml` runs
  `flutter test --coverage`, converts to cobertura, uploads the artifact,
  and prints a summary — but nothing fails the build below a threshold.  The
  MVP success criterion is ">80% for parser and core domain logic".
- **Fix:** add a threshold step scoped to `lib/core/` (filter `lcov.info` to
  `lib/core/` paths and fail below 80%, e.g. with a short `dart run` script
  or `lcov --summary`).  Scoping matters: a repo-wide threshold would be
  dominated by UI files and the generated units file.
- **Resolution:** `tool/check_coverage.dart` + `_lib` + 27 tests, wired into
  `.github/actions/test/action.yml` after the report upload (so a failure
  still leaves a downloadable artifact) and before the emulator steps (so it
  fails fast).  No new dependencies — `cobertura` exposes only `convert` and
  `show`.  The existing coverage steps are unchanged.

  Two parts of the fix above were **not** followed, both deliberately.

  First, **the scope is all of `lib/` at 90%, not `lib/core/` at 80%.**  The
  "dominated by UI files" claim was measured and is false for this codebase:
  non-core code is covered *better* than core, 96.23% vs 95.16%, so there is
  no dilution to avoid.  The generated units file genuinely does distort, but
  an exact-path exclusion handles it at any scope, so it never required
  narrowing.  Narrowing would only have shrunk what the gate protects —
  notably `worksheet_engine.dart` (pure conversion logic under `features/`,
  and at 87.30% the least-covered logic file in the project).  Baseline at
  introduction: ~95.9% (3332/3474 on the measured run; the suite's line coverage
  drifts by about a line between runs).

  Second, **files absent from the report are pinned by a bidirectionally
  checked allowlist** rather than assumed untested.  An LCOV report omits a
  file either because no test loads it or because it has no executable lines
  to instrument, and cannot distinguish the two:
  `predefined_worksheets.dart` has a dedicated test file and appears zero
  times in `lcov.info`, being 224 lines of `const` data.  See
  `openspec/changes/ci-coverage-threshold/` for the full design record.

### F12: README describes the pre-implementation project and has broken links — DONE (August 5, 2026)

- **Category:** docs · **Effort:** M · **Already a Phase 9 task**
- **Evidence:** `README.md:268` links `design_progress.md` and
  `README.md:324` links `implementation_plan.md` without the `doc/` prefix —
  both 404 from the repo root.  "Project Structure" still says `lib/` is
  "not yet created"; "Planned Dependencies" lists `http` (shipped in
  Phase 8) and `sqflite`/`hive`/`dio` speculatively; the roadmap and status
  sections partially duplicate `implementation_plan.md`.
- **Fix:** the planned Phase 9 rewrite; fold in the two link fixes, describe
  the shipped app, and link out to `doc/` rather than duplicating status.
- **Resolution:** rewritten from scratch with a larger scope than the fix
  above: user-facing first (install options — release APK, hosted web app,
  build from source — then a feature tour with example conversions verified
  against the real engine), developers second (build/test instructions,
  curated `doc/` links).  All design-phase framing (roadmap, "planned"
  features, design-session history) dropped in favor of links to
  `implementation_plan.md`; the intro paragraphs and License section were
  preserved verbatim.

### F13: Design-doc audit — keep / update / archive classification — DONE (August 5, 2026)

- **Category:** docs · **Effort:** S–M · **Executes the Phase 9 audit task**
- **Resolution:** executed as classified below.  The four completed phase
  plans moved to `doc/archive/` with all live links updated
  (`implementation_plan.md`, `design_progress.md`; `openspec/` archives left
  as historical records).  `architecture.md` got a full pass against the
  shipped code: real dependency list, grammar/token/AST descriptions matching
  the parser, shipped descriptions for the unit database pipeline, functions,
  worksheets, currency, and UI shell, the actual source tree, and removal of
  its duplicated (and by now contradictory) copy of the phase plan.
  `best_practices.md` was updated in place (structure pointer, Riverpod 3
  patterns, actual persistence repositories, shared test harness +
  integration suite, real branch naming, `performance.md` pointer).
  `evaluation_pipeline.md` was verified against the code (lookup order,
  prefix splitting, the `week` definition chain) and kept unchanged.

  | Document                                                                                | Verdict            | Notes                                                                                                                                                         |
  |-----------------------------------------------------------------------------------------|--------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
  | `implementation_plan.md`, `design_progress.md`, `performance.md`                        | keep               | actively maintained (updated this week)                                                                                                                       |
  | `requirements.md`                                                                       | keep               | requirements remain accurate; timeless by nature                                                                                                              |
  | `terminology.md`                                                                        | keep               | small, still correct                                                                                                                                          |
  | `quantity_arithmetic_design.md`                                                         | keep               | core design reference, linked from README                                                                                                                     |
  | `dimensionless_units_design.md`                                                         | keep               | matches shipped behavior                                                                                                                                      |
  | `architecture.md`                                                                       | **update**         | broken link to `dev_best_practices.md` (file is `best_practices.md`); written pre-implementation (last touched March) — needs a pass against the shipped code |
  | `best_practices.md`                                                                     | **update** (light) | verify guidance still matches practice (last touched February)                                                                                                |
  | `evaluation_pipeline.md`                                                                | **verify**         | pipeline unchanged since February, likely still accurate; confirm and keep                                                                                    |
  | `phase1_plan.md`, `phase2_plan.md`, `phase4_plan.md`, `quantity_implementation_plan.md` | **archive**        | completed phase plans with status banners; move to `doc/archive/` (README/design_progress links need updating to match)                                       |

### F14: Stale statements in tracking docs — DONE (August 5, 2026)

- **Category:** docs · **Effort:** S
- **Evidence:** two known inaccuracies worth fixing while editing anyway:
  the Phase 6 notes still describe a "500 ms debounce" for worksheet
  recompute (the path is synchronous — already flagged by the performance
  work but not yet corrected at its source), and `design_progress.md`
  describes the circular-definition visited keys as `"prefix:<id>"` while
  the code uses a `'-'` suffix (`unit_repository.dart:353`,
  `_cacheKey`).
- **Resolution:** both corrected at source: the Phase 6 notes in
  `implementation_plan.md` and `design_progress.md` now describe the
  synchronous per-keystroke recompute, and the visited-key description now
  matches `_cacheKey`'s trailing-`-` convention.

### F15: No `CONTRIBUTING.md` — DONE (August 5, 2026)

- **Category:** docs · **Effort:** S · **Already a Phase 9 task**
- **Evidence:** the README's "Contributing" section promises guidelines that
  don't exist; MVP success criteria include "Contributing guidelines
  available".
- **Fix:** as planned; the content largely exists already in
  `best_practices.md` and `CLAUDE.local.md`-style workflow rules — distill
  rather than write from scratch.
- **Resolution:** `CONTRIBUTING.md` added, distilled from
  `best_practices.md`: bug-report guidance, development setup (including the
  pre-commit hooks), the change workflow (tests first, full suite +
  `flutter analyze` before a PR), PR guidelines (focused PRs, conventional
  commits, no new dependencies without discussion, never hand-edit generated
  files), and AGPL licensing terms for contributions.  The rewritten README
  links to it.

### F16: Minor code-level cleanups (optional, batch opportunistically)

- **Category:** debt · **Effort:** S each
- `DefinedFunction.evaluate` / `evaluateInverse`
  (`lib/core/domain/models/function.dart:461–511`) duplicate the
  circular-definition check and `ExpressionParser` construction — extract a
  shared private helper.
- `FreeformNotifier._extractResult`
  (`lib/features/freeform/state/freeform_provider.dart:139–156`) recovers the
  history string by `replaceFirst('= ', '')` on formatted display text —
  fragile coupling to display formatting; consider carrying the raw
  formatted value in the result states instead.
- `_buildCurrencyDescriptors` catches `on Exception`
  (`unit_repository.dart:735`) where sibling resolution paths use
  `catch (_)` — harmonize (resolution failures are `UnitaryException`s
  either way).


Non-findings (checked and healthy)
----------------------------------

Recorded so the review is evidence of health, not just a defect list:

- **Layering:** no file under `lib/core/` imports Flutter UI (sole
  state-management exception is F2); no cross-feature imports anywhere under
  `lib/features/`; nothing in `lib/shared/` imports from features.
- **Lint hygiene:** strict custom rule set in `analysis_options.yaml` on top
  of `flutter_lints`; **zero** `// ignore:` comments in `lib/` (the one
  `avoid_print` ignore is in a benchmark test); no TODO/FIXME/HACK markers —
  debt is tracked in docs, not comments.
- **Core domain quality:** `parser.dart`, `function.dart`, `errors.dart`,
  and `expression_parser.dart` are well-documented, well-sized, and
  idiomatic; the `visited`-set threading for cycle detection reads cleanly
  end-to-end despite having been added incrementally; the exception
  hierarchy is consistent and messages are specific.
- **State management:** provider patterns are consistent across features;
  `WorksheetNotifier` and `CurrencyStatusNotifier` are clean; the
  `unitRepositoryVersionProvider` invalidation pattern is used uniformly
  (browser + worksheet).
- **Persistence layer:** the four SharedPreferences repositories are small
  (76–150 lines), idiomatic, and defensively parse stored JSON.  A shared
  base class would save ~20 lines each — **not worth extracting now**; if
  Phase 12's sqflite migration happens, design the seam then.
- **Tooling:** `tool/` consistently follows the lib/exe split, has 164
  dedicated tests, and does not duplicate core-domain parsing (the GNU Units
  importer parses a different grammar by necessity).
- **Tests:** `test/` mirrors `lib/` directory-for-directory; the untested
  files (`app.dart`, `main.dart`, `ast.dart`, `token.dart`,
  `worksheet_state.dart`, etc.) are wiring or data classes covered
  indirectly through parser/provider/screen tests — acceptable gaps.
- **CI & config:** lint → test → deploy pipeline with pinned Flutter
  version, pre-commit hooks (including codegen-drift guards) run in CI, and
  the dependency list is lean (8 runtime deps, all mainstream).


Suggested sequencing
--------------------

**Fold into remaining Phase 9 work** (all small, most already planned):

- ~~F6 (delete debug instrumentation) — immediately.~~ **Done** (July 19, 2026).
- ~~F12 + F13 + F14 + F15 — one documentation change (the planned Phase 9
  doc cleanup, now with a concrete worklist).~~ **Done** (August 5, 2026, as
  one documentation change; the README rewrite ran wider than F12's fix —
  full user-first rewrite from scratch).
- F8 (dropdown overflow) — small UI fix.
- ~~F11 (coverage threshold) — small CI change.~~ **Done** (August 13, 2026,
  `ci-coverage-threshold`) — scoped wider than this review suggested (all of
  `lib/` at 90%), because the review's stated rationale for narrowing did not
  survive measurement.
- ~~F1 (UserSettings decoupling) — small, and moves the worksheet benchmark
  where it belongs.~~ **Done** (July 22, 2026,
  `decouple-usersettings-flutter`).
- ~~F10 (shared widget-test harness)~~ **Done** (July 26, 2026,
  `test-harness-cleanup`) — done standalone rather than bundled with F9.
- ~~F9 (`integration_test/`)~~ **Done** (August 2, 2026,
  `integration-tests`) — Android-emulator suite, enabled unconditionally
  in CI; the frame-timing harness stays with F7.

**Do with its natural trigger, not standalone:**

- F7 (fast-scroll rebuild scoping) — when performance polish is next on the
  agenda; build the frame-timing harness into the now-existing
  `integration_test/` suite (F9).
- F4 (dynamic-layer consistency) — before or at the start of Phase 11
  (custom units); cheap enough to do sooner if touching `UnitRepository`.
- F3 (UnitRepository split/rename) — bundle with Phase 11 registration work.
- F2 (provider out of core) — bundle with F3, or any time as a mechanical
  move.
- F5 (freeform notifier refactor) — remains deferred; revisit only when a
  feature change reworks freeform state anyway.
- F16 (minor cleanups) — batch into whichever change next touches those
  files.
