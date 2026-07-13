# Performance Measurement

## Why

Phase 9's performance-optimization section calls for parser/evaluator tuning, UI rendering optimization, memory analysis, and startup measurement — but no performance problem has actually been observed in practice.  Before changing anything, we need measurements: optimizations will only be pursued with a high payoff-to-effort ratio, where a user interaction is measured to take over 100 ms, or to fix problems invisible to the user (e.g. excessive memory usage).  The measurement tooling itself should be checked in and reusable, so future changes can be benchmarked against a baseline instead of guessed at.

## What Changes

- New `tool/benchmark.dart` + `tool/benchmark_lib.dart`: pure-Dart performance benchmarks covering the hot paths named in the implementation plan — repository construction, cold vs. warm `resolveUnit` over all registered units, representative expression parse/evaluate round trips, `buildBrowseCatalog()`, `buildCurrencyDescriptors()`, `suggestCompletions()`, and `computeWorksheet()`.  Hand-rolled `Stopwatch` loops with warmup (no new dependencies); JSON output alongside a human-readable table; a `--baseline` flag that diffs against a saved JSON run, with the machine-dependence caveat documented.
- New `tool/memory_report.dart` + `tool/memory_report_lib.dart`: stage-by-stage RSS-delta report for the in-memory unit catalog (~7400 units), browse-entry list, and resolution cache.
- New rebuild-scope widget tests pinning that a keystroke in the freeform fields and a worksheet cell edit rebuild only the intended widget subtrees (completion overlay, worksheet rows) — written after a manual DevTools pass confirms today's scope is correct.
- New documented manual procedures (in the change's design notes and a checked-in doc): on-device startup measurement via `flutter run --profile --trace-startup`, and a DevTools profile pass (widget rebuild tracking + frame chart) on a real device.
- Explicitly **out of scope**: any actual optimization work.  Findings (including whether the planned resolution-cache pre-warming is worth doing, and whether an `integration_test` frame-timing harness is needed) become follow-up changes only if the measurements justify them.

## Capabilities

### New Capabilities

- `benchmark-tool`: checked-in pure-Dart benchmark script for core-domain hot paths, with machine-readable output and baseline diffing
- `memory-report-tool`: checked-in script reporting stage-by-stage memory footprint of the unit catalog and derived structures
- `rebuild-scope`: rebuild-scope guarantees for the completion overlay and worksheet screens, pinned by widget tests

### Modified Capabilities

_None._  No existing spec's requirements change; `unit-resolution-cache` behavior is unchanged (pre-warming remains a deferred decision pending benchmark results).

## Impact

- **New code**: `tool/benchmark.dart`, `tool/benchmark_lib.dart`, `tool/memory_report.dart`, `tool/memory_report_lib.dart`, tests under `test/tool/`, rebuild-scope widget tests under `test/features/`
- **Documentation**: a new performance-measurement doc (procedures + recorded baseline numbers); implementation-plan checkboxes updated as items are answered
- **Dependencies**: none added
- **Application code**: untouched — this change is measurement-only
