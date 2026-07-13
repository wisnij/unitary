# Tasks — Performance Measurement

## 1. Benchmark tool

- [x] 1.1 Write tests in `test/tool/benchmark_lib_test.dart` for the case abstraction, timing statistics (min/median/mean from iteration samples), case filtering, baseline diffing (including unmatched cases and the ±20% threshold), and table/JSON formatting
- [x] 1.2 Implement `tool/benchmark_lib.dart`: `BenchmarkCase` abstraction (name, setup, run, warmup/timed iteration counts), runner, statistics, baseline comparison, and output formatting
- [x] 1.3 Implement `tool/benchmark.dart` executable: flag parsing (`--json`, `--baseline`, `--filter`), case registry with the seven pure-Dart cases from design D2 (fresh repo per iteration for `resolve-all-cold` and `currency-descriptors`), machine-dependence caveat in help text and baseline output
- [x] 1.4 Implement the companion `test/tool/worksheet_benchmark_test.dart` (per design D2): times the real `computeWorksheet()` for the Length and Temperature templates via `benchmark_lib.dart`, prints the table, asserts sanity conditions
- [x] 1.5 Run the full suite end-to-end (`dart run tool/benchmark.dart --json <tmp>` then `--baseline <tmp>`, plus the companion benchmark) and sanity-check the numbers and diff output

## 2. Memory report tool

- [x] 2.1 Write tests in `test/tool/memory_report_lib_test.dart` for stage sequencing and report formatting (injected RSS reader so tests don't depend on real values)
- [x] 2.2 Implement `tool/memory_report_lib.dart` (staged builds with RSS sampling and delta computation, coarseness caveat in output) and the `tool/memory_report.dart` executable
- [x] 2.3 Run it end-to-end and sanity-check the stage deltas (AOT-compiled; JIT runs are dominated by the in-process compiler and now trigger a warning)

## 3. Manual measurement passes

- [x] 3.1 On-device startup measurement: `flutter run --profile --trace-startup` on a real device, with stored currency rates present and absent; record `start_up_info.json` timings (recorded in measurements.md)
- [x] 3.2 DevTools profile pass on a real device: widget rebuild tracking + frame chart while typing in freeform (overlay open), editing worksheet cells, and opening/scrolling Browse; record frame times and observed rebuild scope (frame chart in profile mode; rebuild counts in debug mode, where tracking is available)
- [x] 3.3 Record any scope or jank findings as follow-up candidates (do not fix in this change): freeform whole-screen ×2 rebuild per keystroke (existing deferred notifier refactor, now evidence-backed) and FastScrollBar/_PeekPanel per-frame drag cost (see measurements.md)

## 4. Rebuild-scope widget tests

- [x] 4.1 Build the rebuild-count probe helper for widget tests (`test/shared/rebuild_counter.dart`, via the framework's `debugOnRebuildDirtyWidget` hook — the same mechanism DevTools' build tracking uses — with its own tests)
- [x] 4.2 Write freeform keystroke scope tests, with assertions matching the scope verified in 3.2 (whole-screen ×2 observed → tests pin the ≤2 upper bound; spec revised accordingly, narrow-scope ideal recorded as follow-up)
- [x] 4.3 Write worksheet edit scope tests, with assertions matching the scope verified in 3.2 (≤1 screen rebuild per edit + recomputed rows; discovered the worksheet path is synchronous with no debounce — spec revised accordingly)

## 5. Documentation and decisions

- [x] 5.1 Write `doc/performance.md` (setext headers): how to run both tools, baseline workflow with machine-dependence caveat, both manual procedures, decision rules (interactions measured at over 100 ms warrant action, memory threshold set at ~50 MB, frame-timing harness deferred to the follow-up change that needs it), and the dated, machine-labeled baseline numbers
- [x] 5.2 Record go/no-go outcomes: cache pre-warming **rejected** (~11 ms cold total); currency pre-frame path **kept** (~1.5 ms, bounded well under 100 ms on-device); frame-timing harness **deferred** to the FastScrollBar follow-up; memory threshold set at ~50 MB (core domain is ~10.6 MB) — in `doc/performance.md` "Findings and decisions"
- [x] 5.3 Update `doc/implementation_plan.md` (Phase 9 performance section complete with per-item outcomes; new "Performance Follow-ups" future section incl. the `UserSettings`-decoupling refactor; pre-warming item closed as rejected) and `doc/design_progress.md` (new session entry, date bumped)
- [x] 5.4 Update README project status (2034 tests, performance pass added to the Phase 9 done list, date bumped)

## 6. Verification

- [x] 6.1 Run `flutter test --reporter failures-only` (2034 tests pass) and `flutter analyze` (no issues)
