## 1. Tests for the checker library

Written first, against the API sketched in design.md; they should fail to compile
until task 2 lands.

- [x] 1.1 Create `test/tool/check_coverage_lib_test.dart` with a helper that writes
      a synthetic `lcov.info` (`SF:`/`DA:`/`LF:`/`LH:`/`end_of_record`) to a
      temporary directory, so no test depends on a real coverage run
- [x] 1.2 Parsing tests: a well-formed report yields the expected per-file
      covered/total counts; a line with count `0` counts as uncovered; a file with
      no `DA:` records contributes nothing
- [x] 1.3 Duplicate-record test: the same line number appearing twice for one file
      with differing counts is counted once at the highest count (spec: "Duplicate
      line records are merged")
- [x] 1.4 Summary-record test: `LF:`/`LH:` values contradicting the `DA:` records
      are ignored and the totals follow the `DA:` records
- [x] 1.5 Scope tests: files under `lib/core/`, `lib/features/`, and `lib/shared/`
      all contribute to the totals; files outside `lib/` (tool/test sources) do not
- [x] 1.6 Exclusion tests: `lib/core/domain/data/predefined_units.dart` is dropped
      from the totals and from the in-scope file list, while its sibling
      `lib/core/domain/data/builtin_functions.dart` is retained
- [x] 1.7 Allowlist tests, one per verdict in design D4's table: an unallowlisted
      in-scope file absent from the report fails; an allowlisted file *present* in
      the report fails as a stale entry; an allowlist entry naming a file absent
      from disk fails as a stale entry
- [x] 1.8 Allowlist acceptance tests: an allowlisted file that exists on disk and is
      absent from the report neither fails nor changes the computed percentage
      (contributes 0/0, not 0/1); an *excluded* file absent from the report is
      exempt from the comparison entirely
- [x] 1.9 Threshold tests: a scoped percentage above, exactly at, and below the
      minimum produce pass, pass, and fail results respectively
- [x] 1.10 Missing-report test: a nonexistent report path produces a clear failure
      result naming the path rather than an unhandled exception

## 2. Checker library

- [x] 2.1 Create `tool/check_coverage_lib.dart` with the LCOV parser: read records,
      aggregate `DA:` entries per file keyed by line number taking the maximum
      count, ignore `LF:`/`LH:`
- [x] 2.2 Add the scope/exclusion filter: include by path prefix, exclude by exact
      relative path or directory prefix (no glob engine — see design D2)
- [x] 2.3 Add on-disk enumeration of in-scope `.dart` files and the bidirectional
      allowlist comparison, per design D4: unexpected absence, allowlisted file
      present in the report, and allowlist entry with no file on disk are each a
      failure; allowlisted absences contribute 0/0
- [x] 2.4 Declare the allowlist as a `const <String>{}` seeded with the four
      currently-absent in-scope files, each carrying a comment naming its reason
      (`lib/main.dart` — entry point, unreached by the unit-test run;
      `lib/shared/top_level_page.dart` — bare enum;
      `lib/features/about/about_constants.dart` — const declarations;
      `lib/features/worksheet/data/predefined_worksheets.dart` — const template
      data).  Doc comment explains what qualifies and how to retire an entry,
      mirroring `_knownEvalFailures` in `predefined_units_test.dart`
- [x] 2.5 Add the result type carrying per-file counts, allowlist-mismatch details
      by category, the scoped total, the enforced minimum, and the pass/fail verdict
- [x] 2.6 Define the in-code defaults: minimum `90.0`, scope `lib/`, exclusion
      `lib/core/domain/data/predefined_units.dart`, report path
      `coverage/lcov.info`
- [x] 2.7 Run `flutter test test/tool/check_coverage_lib_test.dart` and confirm the
      task-1 tests now pass

## 3. Executable wrapper

- [x] 3.1 Create `tool/check_coverage.dart` as a thin executable with the standard
      `#!/usr/bin/env dart` + `library;` header and a usage comment, following
      `tool/benchmark.dart`'s shape
- [x] 3.2 Parse `--lcov`, `--min`, `--scope` (repeatable), `--exclude`
      (repeatable), and `--help`; fall back to the library defaults
- [x] 3.3 Print the per-file breakdown least-covered-first, the scoped total, and an
      explicit pass/fail line naming the minimum; on an allowlist mismatch, name the
      offending files by category with the remedy (add an entry with its reason,
      remove the stale entry, or write a test)
- [x] 3.4 Exit `0` on pass and `1` on fail (threshold shortfall, allowlist mismatch,
      or missing report)
- [x] 3.5 Verify against the real report: run `flutter test --coverage`, then
      `dart run tool/check_coverage.dart`, and confirm it reports ~95.9%
      (3332/3474 on the measured run; drifts by a line — see design Risks),
      reports no allowlist mismatches, and passes
- [x] 3.6 Verify the failure path: run with `--min 99` and confirm a non-zero exit
      with the shortfall explained

## 4. CI wiring

- [x] 4.1 Add a `Check coverage threshold` step to `.github/actions/test/action.yml`
      running `dart run tool/check_coverage.dart`, placed after
      `dart run cobertura show` and before `Enable KVM group permissions`
- [x] 4.2 Add a comment on the step recording the placement rationale (artifact
      already uploaded; fail fast before the expensive emulator steps), matching
      the commenting style of the surrounding steps
- [x] 4.3 Confirm no workflow changes are needed — `ci.yml`'s `test` job consumes
      the composite action and gates every downstream job, so the whole pipeline
      (deploy-web, APK build, release) picks the gate up automatically.  Note: the
      separate `release.yml` referenced in earlier docs no longer exists; the
      pipelines were consolidated in commit 6e27a2e

## 5. Documentation

- [x] 5.1 Mark the Phase 9 task "Verify >80% coverage target for parser/core
      domain" complete in `doc/implementation_plan.md`, noting the enforced scope
      and the 90% threshold
- [x] 5.2 Update the Testing Strategy section of `doc/design_progress.md`: coverage
      is now enforced, not merely measured; remove F11 from the remaining-work list
      and add a dated implementation-progress entry
- [x] 5.3 Update the testing section of `doc/best_practices.md` with the checker's
      local invocation and the enforced scope/threshold
- [x] 5.4 Mark F11 as DONE in `doc/code_review_2026-07.md`, in both the finding and
      the "Suggested sequencing" list, matching the format used for F1/F6/F9/F10

## 6. Verification

- [x] 6.1 Run the full suite: `flutter test --reporter failures-only`
- [x] 6.2 Run `flutter analyze` and confirm it is clean
- [x] 6.3 Confirm the new tool files match the repo convention (lib/exe split, tests
      under `test/tool/`, no new dependencies in `pubspec.yaml`)

## 7. Review follow-ups

Findings from the `/opsx:verify` pass after group 6, fixed one at a time.  Both
defects lived in the argument-override paths, which had no automated coverage —
which is what motivated 7.2.

- [x] 7.1 **Allowlist staleness misfired under `--scope`** (critical): narrowing the
      scope made `enumerateSourceFiles` skip allowlisted files elsewhere in the
      tree, so all four were reported as deleted.  Fixed by skipping entries via
      `!config.isInScope(path)` (which subsumes the exclusion check) instead of
      `config.isExcluded(path)`; two red-first regression tests and a new spec
      scenario, "Allowlist entries outside the configured scope are ignored"
- [x] 7.2 **Executable wrapper was untested**: extracted `parseArgs` from
      `check_coverage.dart` into `check_coverage_lib.dart` and covered it with 13
      tests (defaults, each flag, `--min` boundaries, repeatability, rejection of
      unknown/valueless/out-of-range arguments).  Spec requirement 7 and design D1
      updated to name argument parsing as library-resident, plus a new scenario
      "Invalid arguments are rejected".  `_report`/`_reportMismatches` remain
      verified by invocation only — a deliberate boundary
- [x] 7.3 **`--exclude` could un-exclude the generated file**: replace semantics
      meant `--exclude lib/features/` silently readmitted `predefined_units.dart`
      and reported 99.20% instead of 95.29%.  Made `--exclude` additive while
      `--scope` keeps replace semantics (narrowing is the point of passing it);
      output now lists the active exclusions.  New spec scenario, "An override
      cannot re-admit excluded generated code"; a `--no-default-excludes` escape
      hatch was considered and left out
- [x] 7.4 Second verify pass: recorded the suite's ±1-line coverage nondeterminism
      (unseeded `Random` in `_pickExample` + short-circuiting `operator ==`) in
      design Risks rather than seeding production code for it, and refreshed the
      test counts and baseline figures across the docs
