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

- [ ] 3.1 On-device startup measurement: `flutter run --profile --trace-startup` on a real device, with stored currency rates present and absent; record `start_up_info.json` timings
- [ ] 3.2 DevTools profile pass on a real device: widget rebuild tracking + frame chart while typing in freeform (overlay open), editing worksheet cells, and opening/scrolling Browse; record frame times and observed rebuild scope
- [ ] 3.3 Record any scope or jank findings as follow-up candidates (do not fix in this change)

## 4. Rebuild-scope widget tests

- [ ] 4.1 Build the rebuild-count probe helper for widget tests
- [ ] 4.2 Write freeform keystroke scope tests (overlay content rebuilds; history pane and other field's overlay do not; no redundant rebuilds), with assertions matching the scope verified in 3.2
- [ ] 4.3 Write worksheet edit scope tests (row value fields rebuild after debounce; template list and banner do not), with assertions matching the scope verified in 3.2

## 5. Documentation and decisions

- [ ] 5.1 Write `doc/performance.md` (setext headers): how to run both tools, baseline workflow with machine-dependence caveat, both manual procedures, decision rules (interactions measured at over 100 ms warrant action, memory threshold TBD, frame-timing harness only if jank found), and the dated, machine-labeled baseline numbers from 1.4, 2.3, 3.1, and 3.2
- [ ] 5.2 Record go/no-go outcomes for the deferred questions: cache pre-warming (from `resolve-all-cold`), `buildCurrencyDescriptors()` pre-frame cost (from benchmarks + startup trace), frame-timing harness (from 3.2), and a first memory-threshold judgment (from 2.3)
- [ ] 5.3 Update `doc/implementation_plan.md` Phase 9 performance section checkboxes and notes, and `doc/design_progress.md`, to reflect the measurement results and outcomes; record the deferred `UserSettings`-decoupling refactor (drop the `material.dart` import so the worksheet engine is pure Dart) as a future enhancement
- [ ] 5.4 Update README project status if warranted

## 6. Verification

- [ ] 6.1 Run `flutter test --reporter failures-only` (all tests pass) and `flutter analyze` (no lints)
