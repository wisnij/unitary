Unitary - Performance Measurement
=================================

This document describes the checked-in performance measurement tools, the
manual on-device procedures, the decision rules for acting on results, and the
recorded baseline numbers.  It was produced by the `performance-measurement`
change (July 2026), which closed Phase 9's performance-optimization section
with measurements rather than speculative tuning.


Decision rules
--------------

- **Latency**: a user interaction *measured at over 100 ms* warrants action.
  The threshold is about the interaction's total observed cost, not about how
  much an optimization could recover.
- **Smoothness**: over-budget frames (jank) during steady-state interaction
  warrant investigation; the frame budget depends on the device (16.7 ms at
  60 Hz, 8.3 ms at 120 Hz).
- **Memory**: investigate if the core-domain memory report's stages sum to
  more than ~50 MB (they currently sum to ~10.6 MB; see baselines below).
- **Tooling escalation**: an `integration_test` frame-timing harness
  (`traceAction`/`TimelineSummary`) is only built as part of a follow-up
  change that needs it to verify a fix — not speculatively.


Benchmark tool
--------------

Pure-Dart benchmarks for the core-domain hot paths:

~~~~ bash
dart run tool/benchmark.dart                     # run all cases, print table
dart run tool/benchmark.dart --filter resolve    # run a subset
dart run tool/benchmark.dart --json out.json     # also write JSON results
dart run tool/benchmark.dart --baseline out.json # diff against a saved run
~~~~

Cases: `repo-construct`, `resolve-all-cold`, `resolve-all-warm`,
`evaluate-expressions`, `browse-catalog`, `currency-descriptors`,
`suggest-completions`.  Each case runs untimed warmup iterations followed by
timed ones and reports min/median/mean.  Cold-cache cases construct a fresh
`UnitRepository` per iteration (notably `currency-descriptors`, whose result
is memoized per repository).

### Baseline workflow

`--json` saves a run; `--baseline` compares the current run against it and
flags cases whose median moved more than ±20%.  **Timings are machine- and
mode-dependent (JIT vs. AOT): only compare against baselines recorded on the
same machine, and do not commit baseline files.**  Run-to-run variance of
~25% has been observed on `repo-construct` under JIT; repeat runs before
trusting a flagged regression.

JIT numbers (from `dart run`) answer *relative* questions — cold vs. warm,
before vs. after a change.  For absolute claims use the on-device procedures
below, or `dart compile exe` for AOT-flavored numbers.

### Companion worksheet benchmark

`computeWorksheet()` cannot be benchmarked from the pure-Dart tool because its
import chain reaches `package:flutter/material.dart` (via `UserSettings`).
Its benchmark runs under `flutter test` instead:

~~~~ bash
flutter test test/tool/worksheet_benchmark_test.dart --reporter expanded
~~~~

It prints the same table format and doubles as a smoke test in normal suite
runs.  Note `flutter test` runs debug-mode JIT with asserts enabled: its
numbers are not comparable to `tool/benchmark.dart` output.


Memory report tool
------------------

Reports process RSS after building each core-domain structure, with deltas:

~~~~ bash
dart compile exe tool/memory_report.dart -o build/memory_report
build/memory_report
~~~~

**Compile AOT first** — under `dart run` the JIT compiler's own memory swamps
the numbers (~246 MB baseline vs. ~8 MB AOT), and the tool prints a warning if
run that way.  RSS is a coarse, order-of-magnitude measurement; if a stage
delta ever looks alarming, escalate to DevTools' allocation profiler manually.


Manual on-device procedures
---------------------------

### Startup timing

~~~~ bash
flutter run --profile --trace-startup
~~~~

Timings land in `build/start_up_info.json` (`timeToFirstFrameMicros`,
`timeAfterFrameworkInitMicros`, etc.).  Launch-cache warmth dominates
single-run numbers — a warm relaunch can be ~2× faster than a cold clean
install — so compare only runs with known, matching conditions, and expect
tens-of-ms noise regardless.

### Frame times and rebuild tracking (DevTools)

1. `flutter run --profile`, open the DevTools URL printed in the terminal,
   go to the **Performance** page.
2. **Jank check first, in profile mode**: watch the frame chart while
   exercising the flows (typing in freeform with the completion overlay open,
   editing worksheet cells, scrolling Browse with and without the fast-scroll
   thumb).  Bars over the budget line are jank; ignore the first frame or two
   after opening a screen.
3. **Rebuild tracking second, in debug mode** (`flutter run` — the "track
   widget builds" option is unavailable in profile mode): enable it under
   Enhance Tracing, clear counts, perform exactly one interaction, and read
   which widgets rebuilt and how many times.  Rebuild *scope* is
   mode-independent; debug-mode frame *times* are meaningless.

Observed-good rebuild scope is pinned by widget tests
(`test/features/freeform/presentation/freeform_rebuild_scope_test.dart`,
`test/features/worksheet/presentation/worksheet_rebuild_scope_test.dart`)
using the `RebuildCounter` probe (`test/shared/rebuild_counter.dart`), which
hooks the same framework mechanism DevTools' build tracking uses.


Recorded baselines (July 13, 2026)
----------------------------------

All numbers below are snapshots from the dates and machines stated, not
contracts; re-running the tools is cheap.

### Benchmark tool — dev machine (Linux x64), Dart JIT via `dart run`

~~~~
case                  iters  min      median   mean
repo-construct        10     3.07 ms  4.32 ms  4.47 ms
resolve-all-cold      10     10.4 ms  11.1 ms  11.6 ms
resolve-all-warm      10     132 µs   133 µs   133 µs
evaluate-expressions  20     58 µs    60 µs    75 µs
browse-catalog        10     10.5 ms  12.3 ms  13.4 ms
currency-descriptors  10     1.44 ms  1.48 ms  1.54 ms
suggest-completions   20     2.12 ms  2.17 ms  2.22 ms
~~~~

`evaluate-expressions` is 6 expressions per iteration (~10 µs each);
`suggest-completions` is 4 queries per iteration (~0.5 ms per keystroke).

### Companion worksheet benchmark — `flutter test`, debug JIT

~~~~
case                           iters  min     median  mean
worksheet-compute-length       20     136 µs  151 µs  170 µs
worksheet-compute-temperature  20     162 µs  183 µs  194 µs
~~~~

### Memory report — dev machine (Linux x64), AOT

~~~~
stage                         rss      delta
baseline                      8.25 MB
unit repository               10.1 MB  1.88 MB
resolution cache (all units)  18.8 MB  8.64 MB
browse catalog                18.8 MB  0.00 kB
currency descriptors          18.9 MB  132 kB
~~~~

### On-device startup — real device (120 Hz phone), profile mode

Clean install (no stored currency rates): first frame at ~650 ms
(~352 ms app-side after framework init).  Warm relaunch with stored rates and
the full rate-registration path: first frame at ~380 ms (~189 ms app-side).
The two runs differ in both cache warmth and rates state, so they bound the
stored-rate path's cost (a small fraction of 189 ms) rather than isolate it.

### On-device frame behavior — real device, 120 Hz (8.3 ms budget)

- Typing in freeform: ~two frames per keystroke at 13–16 ms (over the 120 Hz
  budget; would pass at 60 Hz).  Cause: the whole `FreeformScreen` rebuilds
  twice per keystroke (an immediate button-state `setState` plus the debounced
  evaluation arriving at a screen-level watch).
  **Fixed (July 17, 2026, `freeform-rebuild` change)**: the per-keystroke
  `setState` was replaced with controller `ListenableBuilder`s and the
  result/history watches moved into scoped `Consumer`s.  Re-measured on the
  same device: one keystroke rebuilds only the scoped dependents (screen
  subtree root: zero rebuilds, pinned by widget tests), and normal typing
  stays entirely under the 8.3 ms threshold, with over-budget frames only
  during very rapid typing.
- Worksheet cell editing: a single flagged frame per keystroke; the screen
  rebuilds once per edit (the recompute path is synchronous — no worksheet
  debounce).
- Browse fling-scroll: a few flagged frames.
- Browse fast-scroll thumb drag: **many** flagged frames; `FastScrollBar` and
  its peek panel rebuild every frame of the drag.


Findings and decisions (July 2026)
----------------------------------

- **Resolution-cache pre-warming: rejected.**  Cold resolution of all ~6200
  units totals ~11 ms (JIT); a startup pre-warm task would save a few
  milliseconds spread across first uses.  The long-standing "pre-warm the
  cache as a background task" idea is closed as not worth the complexity.
- **Currency work on the pre-frame startup path: keep as is.**  Registering
  stored rates plus `buildCurrencyDescriptors()` costs ~1.5 ms
  (microbenchmark) and is bounded well under the 100 ms threshold on-device;
  rates being live from the first frame is worth far more than the cost.
- **Memory: non-problem.**  The entire core domain (repository + fully
  populated resolution cache + browse catalog + currency descriptors) adds
  ~10.6 MB.  Threshold set at ~50 MB for future investigation.
- **Freeform whole-screen rebuild: fixed (July 17, 2026).**  The minimal
  scoping fix (`freeform-rebuild` change) — controller `ListenableBuilder`s
  for the clear/swap buttons plus scoped `Consumer`s for the result and
  history — eliminated both whole-screen rebuilds per keystroke; the
  rebuild-scope tests now pin a zero-subtree-rebuild bound, and normal typing
  runs under the 8.3 ms/120 Hz budget on-device.  The larger
  freeform-notifier/AppBar-centralization refactor remains deferred (it is an
  architecture cleanup, no longer performance-motivated).
- **Follow-up candidate: fast-scroll thumb drag cost.**  Browse's
  `FastScrollBar`/peek panel overrun the 8.3 ms budget frequently during
  drags.  A follow-up change should profile the UI vs. raster split and
  consider RepaintBoundary isolation or transform-based repositioning; that
  change is also where a frame-timing harness would be built to verify the
  fix.
- **Deferred refactor: decouple `UserSettings` from Flutter.**  Its
  `material.dart` import (for `ThemeMode`) drags Flutter into the worksheet
  engine, forcing the companion-benchmark workaround.
