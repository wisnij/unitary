# Benchmark Tool

## Purpose

Provide a checked-in, reusable performance benchmark script (`tool/benchmark.dart` + `tool/benchmark_lib.dart`) for the core-domain hot paths, with machine-readable output and baseline diffing, so performance questions are answered by measurement and future changes can be checked for regressions.

## Requirements

### Requirement: Benchmark coverage of named hot paths

The benchmark tool SHALL provide a benchmark case for each pure-Dart core-domain hot path named in the implementation plan's performance section: repository construction (`UnitRepository.withPredefinedUnits()`), cold resolution of every registered unit, warm (cached) resolution of every registered unit, representative expression parse/evaluate round trips, `buildBrowseCatalog()`, `buildCurrencyDescriptors()`, `suggestCompletions()`, and `computeWorksheet()` for a `UnitRow` template and a `FunctionRow` template.

`computeWorksheet()`'s import chain no longer reaches Flutter (`UserSettings` was decoupled from `package:flutter/material.dart`), so unlike previously, it SHALL run as an ordinary case in `tool/benchmark.dart` rather than a separate `flutter test`-hosted companion.

#### Scenario: Full run covers all cases

- **WHEN** `dart run tool/benchmark.dart` is invoked with no case filter
- **THEN** every registered benchmark case executes and appears in the output, including the `computeWorksheet()` cases

#### Scenario: Cold-cache cases use fresh state

- **WHEN** a cold-path case (cold resolution, `buildCurrencyDescriptors()`) runs multiple timed iterations
- **THEN** each iteration measures a fresh, unmemoized code path (e.g. a new `UnitRepository` per iteration), so cached or memoized results from a prior iteration cannot contaminate the timing

### Requirement: Warmup before timing

Each benchmark case SHALL run untimed warmup iterations before its timed iterations, so JIT compilation and intentional cache population do not distort the measured numbers.

#### Scenario: Warmup iterations excluded from results

- **WHEN** a benchmark case executes
- **THEN** the reported statistics are computed only from the timed iterations that follow the warmup phase

### Requirement: Human-readable and machine-readable output

The tool SHALL print a human-readable results table to stdout by default, and SHALL write the same results as JSON to a user-specified path when invoked with `--json <path>`.  Reported statistics per case MUST include at least the minimum and median iteration times and the iteration count.

#### Scenario: Default table output

- **WHEN** the tool runs without `--json`
- **THEN** stdout contains a table with one row per executed case showing min and median times

#### Scenario: JSON output

- **WHEN** the tool runs with `--json results.json`
- **THEN** `results.json` contains one entry per executed case with the case name, iteration count, and timing statistics

### Requirement: Baseline diffing

The tool SHALL accept `--baseline <path>` pointing to a JSON file produced by a previous run, and SHALL report the relative change per case against that baseline, visually highlighting cases whose change exceeds a threshold (default ±20%).  The tool's help text and output MUST note that timings are machine- and mode-dependent, so baselines are only comparable to runs on the same machine.

#### Scenario: Diff against baseline

- **WHEN** the tool runs with `--baseline previous.json` and a case's median time differs from the baseline by more than the threshold
- **THEN** the output flags that case as a regression or improvement with its percentage change

#### Scenario: Baseline case mismatch

- **WHEN** the baseline file lacks an entry for an executed case (or contains cases that no longer exist)
- **THEN** the tool reports those cases as unmatched rather than failing

### Requirement: Case filtering

The tool SHALL accept `--filter <substring>` and run only the cases whose names contain the given substring.

#### Scenario: Filtered run

- **WHEN** the tool runs with `--filter resolve`
- **THEN** only cases whose names contain "resolve" execute and appear in the output

### Requirement: Testable library structure

The benchmark logic (case abstraction, statistics, baseline comparison, output formatting) SHALL live in `tool/benchmark_lib.dart` with unit tests under `test/tool/`, with `tool/benchmark.dart` as a thin executable wrapper, matching the existing tool-script convention.

#### Scenario: Library logic covered by tests

- **WHEN** `flutter test test/tool/` runs
- **THEN** tests exercising the statistics computation, baseline diffing, and case filtering of `benchmark_lib.dart` pass without requiring a full benchmark run
