## Why

CI measures test coverage but never acts on it: `.github/actions/test/action.yml`
runs `flutter test --coverage`, converts the result to Cobertura, uploads it as an
artifact, and prints a summary — but no step fails the build when coverage drops.
The MVP success criterion "unit test coverage >80% for parser and core domain
logic" is therefore unenforced, and a coverage regression in the core domain would
merge silently.  This is finding **F11** in
[code_review_2026-07.md](../../../doc/code_review_2026-07.md), and it executes the
Phase 9 task "Verify >80% coverage target for parser/core domain".

## What Changes

- Add a checked-in coverage-threshold checker (`tool/check_coverage.dart` +
  `tool/check_coverage_lib.dart`, following the existing `tool/` lib/exe
  convention) that parses `coverage/lcov.info`, restricts it to a configured path
  scope, and exits non-zero when line coverage falls below a configured minimum.
- Scope enforcement to all of `lib/`, **excluding the generated
  `lib/core/domain/data/predefined_units.dart`**.  That file is 7233 lines — larger
  than all hand-written `lib/` code combined — and is 100% covered as a side effect
  of registration, so including it reports 98.66% and masks essentially any
  regression in hand-written code; excluding it, the real figure is ~95.9%.
- Set the enforced minimum at **90%**, above the 80% MVP floor.  Hand-written `lib/`
  sits at ~95.9% today, so 90% leaves roughly six points of ordinary churn while
  still failing on a genuine regression.
- Pin the files legitimately absent from the coverage report behind an explicit
  allowlist, checked in both directions, since a report omits a file either because
  no test loads it or because it has no executable lines to instrument — and cannot
  distinguish the two.
- Add a step to `.github/actions/test/action.yml` that runs the checker after the
  existing coverage steps, so a threshold failure never suppresses the coverage
  report artifact.
- Add unit tests for the checker library under `test/tool/`, matching the
  established pattern for `benchmark_lib.dart` / `memory_report_lib.dart` /
  `release_lib.dart`.

No production code changes; no new dependencies.

## Capabilities

### New Capabilities

- `coverage-threshold`: parsing an LCOV report, restricting it to a path scope with
  exclusions, computing scoped line coverage, pinning expected-absent files behind a
  bidirectionally-checked allowlist, and failing CI below a configured minimum —
  plus the CI wiring that enforces it.

### Modified Capabilities

None.  The `integration-test-harness` spec describes the Android step in the same
composite action but says nothing about coverage enforcement, so its requirements
are unchanged.

## Impact

- **New**: `tool/check_coverage.dart`, `tool/check_coverage_lib.dart`,
  `test/tool/check_coverage_lib_test.dart`
- **Modified**: `.github/actions/test/action.yml` (one added step)
- **Affected workflows**: every caller of `./.github/actions/test` gains the gate
  automatically, matching the unconditional-by-default precedent set when the
  Android integration-test opt-in toggle was removed.  Since the pipelines were
  consolidated (commit 6e27a2e) that is `ci.yml`'s single `test` job, which gates
  the whole downstream chain — `lint → test → {deploy-web, prepare} →
  build-android-apk/build-web → release` — so one gate covers the web deploy, the
  APK build, and the release
- **Dependencies**: none added.  The `cobertura` dev dependency stays for report
  conversion; it offers only `convert` and `show`, with no threshold checking, so
  the checker is our own
- **Docs**: `doc/implementation_plan.md` (Phase 9 testing task),
  `doc/design_progress.md`, `doc/best_practices.md` (testing section), and
  `doc/code_review_2026-07.md` (F11 status)
