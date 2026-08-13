## ADDED Requirements

### Requirement: Scoped coverage enforcement in CI

Every workflow that uses `./.github/actions/test` SHALL fail when line coverage of
the enforced scope falls below the configured minimum.  The enforcing step MUST run
after the coverage report has been converted and uploaded, so a threshold failure
never prevents the coverage artifact from being produced, and before the Android
emulator steps, so the cheap deterministic check fails fast.

#### Scenario: Coverage below the minimum fails the workflow

- **WHEN** a workflow using `./.github/actions/test` produces a coverage report
  whose scoped line coverage is below the configured minimum
- **THEN** the coverage-threshold step exits non-zero and the workflow fails

#### Scenario: Coverage at or above the minimum passes

- **WHEN** the scoped line coverage is at or above the configured minimum
- **THEN** the coverage-threshold step exits zero and the workflow proceeds to the
  remaining steps

#### Scenario: Report artifact survives a threshold failure

- **WHEN** the coverage-threshold step fails
- **THEN** the coverage report has already been converted and uploaded by the
  preceding steps, and remains available as a workflow artifact

### Requirement: Enforced scope excludes generated code

The enforced scope SHALL be the hand-written core domain: files under `lib/core/`,
excluding the generated `lib/core/domain/data/predefined_units.dart`.  Files outside
the scope MUST NOT contribute to the computed percentage.

The generated file is excluded because it accounts for roughly 86% of `lib/core`'s
tracked lines and is fully covered as a side effect of unit registration, so
including it would let hand-written coverage regress substantially without moving
the reported number.

#### Scenario: Generated units file is not counted

- **WHEN** scoped coverage is computed from a report containing
  `lib/core/domain/data/predefined_units.dart`
- **THEN** that file's lines are absent from both the covered and total counts, and
  it is not listed as an in-scope file

#### Scenario: Out-of-scope files are not counted

- **WHEN** the report contains files under `lib/features/`, `lib/shared/`, or
  `lib/main.dart`
- **THEN** none of their lines contribute to the computed percentage

#### Scenario: Hand-written siblings of generated code remain in scope

- **WHEN** the report contains `lib/core/domain/data/builtin_functions.dart`
- **THEN** its lines contribute to the computed percentage

### Requirement: Coverage computed from per-line records

Scoped coverage SHALL be computed as the percentage of in-scope executable lines
with a non-zero execution count, derived by aggregating the report's per-line
(`DA:`) records.  When a line appears more than once for the same file, the highest
recorded execution count MUST be used.  File-level summary records (`LF:`/`LH:`)
MUST NOT be relied on.

#### Scenario: Percentage derived from per-line records

- **WHEN** an in-scope file records four executable lines of which three have a
  non-zero execution count
- **THEN** that file contributes three covered lines out of four to the totals

#### Scenario: Duplicate line records are merged

- **WHEN** a file's records list the same line number more than once with
  differing execution counts
- **THEN** the line is counted once, using the highest recorded count, so a line
  covered in any record counts as covered

#### Scenario: Summary records disagreeing with line records are ignored

- **WHEN** a file's `LF:`/`LH:` summary values contradict its `DA:` records
- **THEN** the computed totals follow the `DA:` records

### Requirement: In-scope files missing from the report count as uncovered

The checker SHALL enumerate in-scope `.dart` files on disk, treat any file missing
from the coverage report as contributing no covered lines, and name each such file
in its output.  This is required because a coverage run only reports files that were
imported during the run, so an in-scope source file that no test reaches is omitted
from the report entirely rather than appearing at zero.

#### Scenario: Untested in-scope file is detected

- **WHEN** an in-scope `.dart` file exists on disk but has no record in the
  coverage report
- **THEN** the file is reported by name as not covered by any test, and it
  contributes uncovered lines to the totals rather than being silently skipped

#### Scenario: Excluded files are not required to appear

- **WHEN** an excluded file (such as the generated units file) is absent from the
  report
- **THEN** it is not reported as untested and does not affect the totals

### Requirement: Configurable threshold, scope, and report path

The checker SHALL carry the enforced minimum, scope prefixes, and exclusions as
in-code defaults so that changing them is a reviewable, test-covered change, and
SHALL allow each to be overridden on the command line, along with the path to the
coverage report.  The default minimum MUST be at least the 80% figure named by the
project's MVP success criteria.

#### Scenario: Default invocation needs no arguments

- **WHEN** the checker is invoked with no arguments from the repository root
- **THEN** it reads the default coverage report path and enforces the default
  scope, exclusions, and minimum

#### Scenario: Overrides take effect

- **WHEN** the checker is invoked with an explicit minimum, scope, exclusion, or
  report path
- **THEN** the supplied value replaces the corresponding default for that run

#### Scenario: Missing report is reported clearly

- **WHEN** the coverage report file does not exist at the resolved path
- **THEN** the checker exits non-zero with a message naming the missing path,
  rather than failing with an unhandled error

### Requirement: Diagnostic output identifying weak files

On both success and failure, the checker SHALL print the per-file covered/total
line counts and percentages for in-scope files, ordered so the least-covered files
appear first, followed by the scoped total and an explicit pass/fail statement
naming the enforced minimum.

#### Scenario: Failure output identifies the shortfall

- **WHEN** the scoped coverage is below the minimum
- **THEN** the output states the computed percentage, the enforced minimum, and the
  per-file breakdown with the least-covered files first

#### Scenario: Success output still reports the total

- **WHEN** the scoped coverage meets the minimum
- **THEN** the output states the computed percentage and the enforced minimum

### Requirement: Testable library structure

The coverage-checking logic SHALL live in a library file with unit tests under
`test/tool/`, with the executable as a thin wrapper that handles argument parsing,
output, and the process exit code — matching the existing `tool/` lib/exe
convention.  The library covers report parsing, scope and exclusion filtering,
percentage computation, missing-file detection, and threshold comparison.

#### Scenario: Library logic covered by tests

- **WHEN** `flutter test test/tool/` runs
- **THEN** tests exercising report parsing, scope filtering, exclusion handling,
  missing-file detection, and threshold comparison pass without requiring a real
  coverage run

#### Scenario: Executable exit code reflects the result

- **WHEN** the executable completes a check
- **THEN** it exits zero if the scoped coverage meets the minimum and non-zero
  otherwise
