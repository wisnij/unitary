## Context

`.github/actions/test/action.yml` already produces coverage on every workflow that
uses it (`ci.yml`, `release.yml`): `flutter test --coverage` writes
`coverage/lcov.info`, `dart run cobertura convert` produces `cobertura.xml`, that
file is uploaded as an artifact, and `dart run cobertura show` prints a summary.
Nothing fails the build below a threshold, so the MVP criterion ">80% for parser
and core domain logic" is aspirational rather than enforced (finding **F11**).

Measured baseline for this change (full suite, 2045 tests passing, August 13, 2026):

| Scope                                    | Covered / total lines | Percent    |
|------------------------------------------|-----------------------|------------|
| `lib/core/` including generated units     | 8315 / 8370           | **99.34%** |
| `lib/core/` excluding generated units     | 1082 / 1137           | **95.16%** |
| `lib/core/domain/data/predefined_units.dart` (generated) | 7233 / 7233 | 100.00% |

The generated file alone is 86% of `lib/core`'s tracked lines and is fully covered
as a side effect of `UnitRepository.withPredefinedUnits()` running in nearly every
test.  Any threshold applied to the including-generated figure is meaningless: the
hand-written 1137 lines could drop to roughly 55% covered before the combined
number fell below 95%.

Flutter's LCOV output is minimal — only `SF:` / `DA:` / `LF:` / `LH:` /
`end_of_record`, with repo-relative paths and no branch data.

## Goals / Non-Goals

**Goals:**

- Fail CI when line coverage of hand-written `lib/core/` code drops below a
  configured minimum, on every workflow that uses `./.github/actions/test`.
- Make the enforced scope, exclusions, and threshold explicit, reviewable, and
  unit-tested rather than buried in a shell one-liner.
- Keep the coverage report artifact available even when the gate fails.
- Add no new dependencies.

**Non-Goals:**

- Repo-wide or per-file thresholds.  The criterion names the parser and core
  domain; a repo-wide number would be dominated by UI code and the generated
  units file, and per-file minimums would fail on legitimately thin data classes
  (`completion_entry.dart` is 8.33%, `token.dart` 33.33% — both covered
  indirectly and accepted as gaps in the July review).
- Branch/function coverage.  Flutter's LCOV output carries neither.
- Raising coverage.  This change enforces a floor; the separate Phase 9
  widget-test coverage-gap audit is where coverage actually improves.
- Replacing the `cobertura` conversion/upload steps.

## Decisions

### D1: A checked-in Dart checker, not `lcov` or the `cobertura` package

`tool/check_coverage.dart` (thin executable) + `tool/check_coverage_lib.dart`
(logic) + tests under `test/tool/`, matching the convention every other tool in
`tool/` already follows (`benchmark`, `memory_report`, `generate_predefined_units`,
`import_gnu_units`, `release`).

Alternatives rejected:

- **`dart run cobertura`** — verified to expose only `convert` and `show`
  subcommands; it has no threshold or gating capability at all.
- **`lcov --extract` + `lcov --summary`** — would add an `apt-get install lcov`
  step to the runner, put the scope/exclusion/threshold logic in an untestable
  shell pipeline, and require parsing human-readable summary text to get a number
  to compare.
- **An inline `awk`/shell step in `action.yml`** — cheapest to write, but the
  scoping and exclusion rules are exactly the part worth testing, and they would
  be invisible to `flutter analyze` and to the test suite.

### D2: Scope is `lib/core/`, excluding the generated units file

The enforced scope is the path prefix `lib/core/`, minus the exact path
`lib/core/domain/data/predefined_units.dart`.

Exclusion matching is by exact relative path or directory prefix — no glob engine.
The only exclusion needed today is a single generated file, and a hand-rolled glob
matcher would be more code than the thing it configures.

The generated file is excluded rather than the whole `lib/core/domain/data/`
directory, so its hand-written sibling `builtin_functions.dart` (82 lines, 100%)
stays inside the gate.

### D3: Threshold 90%, defaulted in the tool

Hand-written `lib/core` is at 95.16%.  A gate at the literal 80% MVP floor would
tolerate losing ~173 covered lines before firing; 90% leaves roughly 59 lines of
slack — enough that adding a thin uncovered data class doesn't break the build,
tight enough that a real regression in the parser or domain does.  The 80%
criterion in `implementation_plan.md` remains satisfied by construction.

The threshold, scope, and exclusions live as defaults in `check_coverage_lib.dart`
so that changing any of them is a reviewable, test-covered code change rather than
an edit to a CI argument list.  Flags (`--lcov`, `--min`, `--scope`, `--exclude`)
override them for local use and for the tests.

### D4: Absent files are pinned by an explicit allowlist, checked both ways

`flutter test --coverage` reports only files loaded during the run, so a file can be
missing from `lcov.info` for two indistinguishable reasons:

1. no test ever loads it (genuinely untested — `lib/main.dart` today), or
2. it is loaded and tested but has **no executable lines to instrument**.

Cause 2 is not hypothetical and is easy to mistake for cause 1.  All three
currently-absent non-entrypoint files are of that kind — `about_constants.dart`
(two `const` declarations), `top_level_page.dart` (a bare `enum`), and
`predefined_worksheets.dart` (224 lines of pure `const` data).  The last has its own
dedicated test file and four other test files importing it, and still appears zero
times in the report.  All three are outside the enforced scope, so they are evidence
about the mechanism rather than cases the checker must handle.

Because the report cannot distinguish the two causes, the checker does not guess.
It enumerates in-scope `.dart` files on disk and compares them against an explicit
allowlist of files expected to be absent, treating any of three mismatches as an
error:

| Condition | Verdict | Meaning |
|---|---|---|
| On disk, absent from report, not allowlisted | error | Untested, or newly declaration-only and needing a reviewed entry |
| Allowlisted, present in report | error | Stale entry: the file gained executable lines |
| Allowlisted, absent from disk | error | Stale entry: the file was deleted or moved |

This is the pinned-expectation pattern the project already uses for
`_knownEvalFailures` in `predefined_units_test.dart`, including its bidirectional
intent ("when support is added, remove the affected IDs and the test will confirm
they now resolve correctly").  The third condition is the checker's own addition, so
an entry cannot outlive the file it names.

The allowlist starts **empty**: all 21 in-scope files currently report coverage, so
any absence is an error from day one.  Its doc comment cites the out-of-scope files
above as the archetype, so the first person who needs an entry knows what qualifies.

Crucially, this removes the approximation the earlier draft of this decision
depended on.  An allowlisted file genuinely has no executable lines, so contributing
`0/0` to the totals is exact rather than a fudge, and a non-allowlisted absence is a
hard error rather than a barely-visible nudge to the percentage.  No Dart
line-counting or source parsing is required in either direction.

Alternatives rejected:

- **Count each absent file as one uncovered line** (the earlier draft) — rests on
  the false premise that absence implies untested, so it would print "not covered by
  any test" for a legitimately tested const-only file.  It also under-penalizes by
  roughly the file's length: a 60-line untested module would move the scoped figure
  0.08 points instead of 4.77.
- **Report-only, no disk enumeration** — no false positives, but leaves the real
  hole open: a genuinely untested `lib/core/` file contributes to neither numerator
  nor denominator and is invisible to the gate.
- **Infer from a mirroring `test/` file** — the test tree does mirror `lib/`
  directory-for-directory, but one test file legitimately covers several source
  files, so absence of a mirror is not evidence of absence of tests.
- **Parse the Dart to count executable lines** — reimplements the instrumenter and
  needs the `analyzer` package as a new direct dependency.

### D5: Aggregate `DA:` records, don't trust `LF:`/`LH:`

Per-file totals are computed by aggregating `DA:<line>,<count>` entries, keyed by
line number and taking the maximum count when a line appears more than once (some
LCOV producers emit multiple records per file).  `LF:`/`LH:` are treated as
advisory and ignored.  Flutter's own output has them agree, but deriving the number
from the raw per-line data keeps the checker correct for any producer and makes the
parser's behavior fully determined by data the tests can construct.

### D6: Gate runs after the coverage artifact upload, before the emulator

The new step goes immediately after `dart run cobertura show` and before the
`Enable KVM group permissions` step.  Two reasons, both already reflected in the
ordering rationale documented in `action.yml`:

- The artifact upload has already happened, so a gate failure still leaves a
  downloadable coverage report to diagnose it with.
- The Android emulator steps are the expensive part of the job (~13 minutes on an
  accelerated runner).  Failing a deterministic, seconds-long check before paying
  that cost keeps the feedback loop short.

## Risks / Trade-offs

- **A legitimate refactor that moves covered code out of `lib/core/` lowers the
  scoped percentage** → the threshold sits ~5 points below the current figure, and
  the failure output names the per-file numbers, so the cause is visible
  immediately; adjusting the constant is a one-line, reviewed change.
- **The gate measures line coverage only** — well-covered lines with untested
  branches still pass → accepted; Flutter emits no branch data, so this is a floor
  on the crudest metric, not a quality proof.  It complements rather than replaces
  the widget-test coverage-gap audit.
- **The D4 allowlist needs maintenance**: adding a declaration-only file to
  `lib/core/` fails the build until it gets an entry → deliberate, and the same
  bargain `_knownEvalFailures` already makes.  The list starts empty, such files are
  rare in the core domain, and the error message names the fix (add an entry with
  its reason, or write a test).  The bidirectional checks mean a stale entry is
  reported rather than silently masking a regression.
- **The checker assumes it runs from the repository root** (relative LCOV paths and
  on-disk scope enumeration) → it is invoked only from `action.yml` and documented
  local commands, both of which run at the root; a missing `coverage/lcov.info`
  exits with a clear message rather than a stack trace.
- **Threshold drift**: coverage climbing well above 90% makes the gate loose again
  → deliberate.  A ratcheting threshold was considered and rejected in favor of a
  stable, occasionally-revisited constant, to avoid unrelated PRs failing on
  threshold bumps.
