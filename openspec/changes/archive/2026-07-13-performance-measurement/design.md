# Design — Performance Measurement

## Context

The Phase 9 performance section (implementation_plan.md) lists four buckets: parser/evaluator tuning, UI rendering optimization, memory analysis, and startup time.  No performance problem has been observed in practice, so this change is measurement-only: build reusable tooling, record baseline numbers, and let the numbers decide whether any optimization work is warranted.

Almost every hot path named in the plan is pure Dart with no Flutter dependency:

- `UnitRepository.withPredefinedUnits()` — ~6300 unit registrations (`unit_repository.dart`)
- `resolveUnit()` cold vs. warm — the `_resolvedQuantityCache` added under "Unit Resolution Caching"
- `buildBrowseCatalog()` (`unit_repository.dart:415`) — eager full-catalog build in `BrowserNotifier.build()`
- `buildCurrencyDescriptors()` (`unit_repository.dart:709`) — runs synchronously in `main()` before the first frame whenever stored rates exist; evaluates every `[A-Z]{3}`-shaped name in the catalog
- `suggestCompletions()` (`unit_repository.dart:625`) — the per-keystroke core of the completion overlay
- `computeWorksheet()` (`lib/features/worksheet/services/worksheet_engine.dart`) — the per-edit core of worksheet recompute

The residual UI questions (rebuild scope and frame times for the completion overlay and worksheet) and startup time require Flutter and, for honest numbers, a real device.

Existing `tool/` convention: `foo.dart` thin executable + `foo_lib.dart` testable library + tests in `test/tool/` (see `import_gnu_units*`, `generate_predefined_units*`, `release*`).

## Goals / Non-Goals

**Goals:**

- Checked-in, reusable measurement scripts following the `tool/` convention
- Baseline numbers for every hot path named in the implementation plan, recorded in a checked-in doc
- Regression protection: baseline diffing for timing, widget tests for rebuild scope
- Clear go/no-go answers for the deferred optimization questions (cache pre-warming, frame-timing harness)

**Non-Goals:**

- Any actual optimization — findings become follow-up changes only if measurements justify them
- An `integration_test/` frame-timing harness — built only if the manual DevTools pass finds jank (separate follow-up change)
- CI-enforced performance gates — timing numbers are machine-dependent; CI runners are too noisy for thresholds
- Absolute performance claims from dev-machine numbers — on-device procedures cover those

## Decisions

### D1: Hand-rolled `Stopwatch` benchmark loops, no new dependency

Each benchmark case runs a warmup phase (to let the JIT settle and populate caches where intended) followed by N timed iterations, reporting min / median / mean.  The alternative — the `benchmark_harness` package — is small and official, but it adds a dependency for ~30 lines of loop code, offers only a mean, and project rules require justification for new dependencies.  Hand-rolling also lets cold-cache cases construct a fresh `UnitRepository` per iteration, which `benchmark_harness`'s fixed run/setup split handles awkwardly.

### D2: Benchmark tool shape — `tool/benchmark.dart` + `tool/benchmark_lib.dart`

The library defines a `BenchmarkCase` abstraction (name, setup, run, iteration counts) and the case registry; the executable parses flags and prints results.  Output is a human-readable table by default; `--json <path>` writes machine-readable results; `--baseline <path>` reads a previous JSON run and prints per-case deltas with a configurable regression highlight (default ±20%, well above run-to-run noise).  `--filter <substring>` runs a subset of cases.  This mirrors how the import/codegen tools split executable from testable library.

Initial case list (one benchmark per plan item, plus the startup-adjacent paths discovered in `main.dart`):

1. `repo-construct` — `UnitRepository.withPredefinedUnits()`
2. `resolve-all-cold` — fresh repo per iteration, `resolveUnit()` over every registered unit
3. `resolve-all-warm` — same repo, second pass (cache hits)
4. `evaluate-expressions` — representative parse→evaluate round trips (simple conversion, compound units, function call, worst-case long expression)
5. `browse-catalog` — `buildBrowseCatalog()`
6. `currency-descriptors` — `buildCurrencyDescriptors()` on a fresh repo (its result is memoized, so warm runs are trivial)
7. `suggest-completions` — representative queries (short prefix with many hits, infix match, near-miss)

**`worksheet-compute` runs as a companion `flutter test` benchmark, not in the tool** (decided during implementation): `computeWorksheet()` takes a `UserSettings`, and `user_settings.dart` imports `package:flutter/material.dart` (for `ThemeMode`), which the standalone `dart run` VM cannot compile — verified empirically.  Rather than approximate with a copy (measures the wrong code) or refactor `UserSettings` (application code is out of scope here), the case lives in `test/tool/worksheet_benchmark_test.dart`: it reuses `benchmark_lib.dart`'s runner and table formatting, times the real `computeWorksheet()` for a large `UnitRow` template (Length) and a `FunctionRow` template (Temperature), prints the table, and asserts only sanity conditions (non-empty results) so it doubles as a smoke test in normal suite runs.  Run it directly (`flutter test test/tool/worksheet_benchmark_test.dart --reporter expanded`) to see the numbers.  It is table-only — no JSON/baseline support; its numbers are recorded in `doc/performance.md` prose like the others, with the added caveat that `flutter test` runs debug-mode JIT with asserts enabled (fine for the relative/order-of-magnitude questions asked of it).

### D3: Baseline JSON files are not committed; numbers are recorded in prose

Timing baselines only mean something on the machine that produced them.  The tool reads/writes baseline JSON at user-specified paths (a gitignored `tmp/` or anywhere else); what gets committed is a summary table of representative numbers in `doc/performance.md`, dated and labeled with the machine/mode that produced them.  This documents the machine-dependence caveat where users of the numbers will see it.

### D4: JIT numbers for relative questions; AOT/on-device for absolute ones

`dart run tool/benchmark.dart` runs in JIT on the dev machine — valid for relative comparisons (cold vs. warm resolution, before vs. after a change) and baseline diffing, not for absolute claims.  The doc will note `dart compile exe` as the option for AOT-flavored numbers if a case ever looks marginal, and defer absolute interaction/startup claims to the on-device procedures.  The 100 ms user-interaction threshold (an interaction *taking* more than 100 ms warrants action, regardless of how much of that an optimization could recover) is evaluated against on-device or clearly-safe-margin numbers, not raw JIT microbenchmarks.

### D5: Memory report via `ProcessInfo.currentRss` stage deltas

`tool/memory_report.dart` builds structures stage by stage — baseline VM → `withPredefinedUnits()` → `resolveUnit()` all (cache populated) → `buildBrowseCatalog()` → `buildCurrencyDescriptors()` — and reports RSS after each stage, with deltas.  RSS is coarse (includes VM overhead, GC timing effects), so the tool reports the caveat in its own output; the question it answers ("is the catalog tens of KB, single-digit MB, or hundreds of MB?") only needs order-of-magnitude resolution.  Finer allocation profiling via VM-service/DevTools is documented as a manual escalation path, not scripted.

**Discovered during implementation: the tool must run AOT-compiled.**  Under `dart run` (JIT), the in-process kernel compiler dominates RSS (~246 MB baseline, with GC-driven *negative* deltas mid-report); AOT-compiled (`dart compile exe`), the baseline is ~8 MB and stage deltas are clean.  The tool detects JIT mode via `bool.fromEnvironment('dart.vm.product')` and prints a warning recommending the AOT invocation, which is also the documented usage.

### D6: Rebuild-scope widget tests, written after the manual DevTools pass

Most Flutter UI performance bugs are rebuild-*scope* bugs (widgets rebuilding that shouldn't, or rebuilding multiple times per event), and scope is deterministic — assertable in plain `flutter test` with zero flakiness.  The probe is `RebuildCounter` (`test/shared/rebuild_counter.dart`), which hooks the framework's `debugOnRebuildDirtyWidget` — the same mechanism DevTools' "track widget builds" uses — so real screens are probed without wrapper widgets in application code, counts match what a manual DevTools pass reports, and private widget types are addressable by name.  (An earlier draft envisioned a wrapper-widget probe; the hook supersedes it.)

The manual DevTools pass (July 13, 2026) found the actual scope broader than the ideal this design originally sketched, so the tests pin the verified *bounds* rather than narrow-scope assertions:

- One keystroke in a freeform field → at most two rebuilds of the `FreeformScreen` subtree (one immediate button-state `setState`, one when the debounced evaluation arrives); the whole-subtree breadth is a recorded follow-up (freeform-notifier refactor), not endorsed behavior
- One worksheet cell edit → at most one rebuild of the `WorksheetScreen` subtree, with recomputed row values; the recompute path turned out to be synchronous (no worksheet-side debounce, contrary to Phase 6 notes)

Exact assertions were chosen *after* the manual DevTools pass — the tests encode observed behavior, they don't guess at it.  Assertions favor scoped invariants ("at most N rebuilds") over brittle exact counts, so a future scope-narrowing refactor still passes.

Timing inside widget tests (Stopwatch under `FakeAsync`, debug JIT) was considered and rejected: unrepresentative and noisy, and the pure-Dart benchmarks already cover the compute cost.

### D7: Manual procedures live in a new `doc/performance.md`

Two documented, repeatable-by-hand procedures plus the recorded results:

- **On-device startup**: `flutter run --profile --trace-startup` on a real device; capture `start_up_info.json` timings (engine enter, first frame).  Covers the plan's "measure cold-start cost, including synchronous stored-rate load" — with a with-rates vs. without-rates comparison since `buildCurrencyDescriptors()` only runs when stored rates exist.
- **DevTools profile pass**: `flutter run --profile` + DevTools widget-rebuild tracking and frame chart while typing in freeform (overlay open), editing worksheet cells, and opening/scrolling Browse.  Findings feed the rebuild-scope test assertions (D6) and the go/no-go on a frame-timing harness.

The doc also states the decision rules: a user interaction measured at over 100 ms warrants action; memory threshold set after first real numbers; frame-timing harness only if jank observed; cache pre-warming decided by `resolve-all-cold`.  (`doc/performance.md` uses setext level-1/2 headers per project markdown style — the openspec exception applies only under `openspec/`.)

## Risks / Trade-offs

- **Timing noise on a dev machine** → warmup + multiple iterations, report min/median (min is the most stable statistic for CPU-bound loops); ±20% default highlight threshold on baseline diffs; doc tells users to close heavy background processes and repeat runs before trusting a regression.
- **RSS is a blunt instrument** → acceptable: the memory question is order-of-magnitude ("is ~7400 units a problem at all?"); escalation path to DevTools allocation profiling documented if a stage delta looks alarming.
- **Rebuild-count tests can be brittle across Flutter upgrades** → assert invariants (no rebuild / at-most-N) rather than exact counts; keep probes on our own widget boundaries, not framework internals.
- **Committed prose numbers go stale** → they are dated and machine-labeled snapshots, not contracts; the reusable tool is the durable artifact, and re-running it is cheap.
- **`buildCurrencyDescriptors()` memoizes** (`_currencyDescriptors ??=`) → cold benchmark must construct a fresh repo per iteration or the numbers are meaningless; noted in the case design so the implementation doesn't fall into it.

## Open Questions

- Memory payoff threshold: deliberately deferred until `memory_report` produces first real numbers (per proposal).
- Whether any follow-up optimization changes get opened at all — answered by the measurements themselves; candidate outcomes are pre-warming (D2 case 2), moving `buildCurrencyDescriptors()` off the pre-frame path, and a frame-timing harness (D7).
- **Deferred follow-up (independent of measurements): decouple `UserSettings` from Flutter.**  `user_settings.dart` imports `package:flutter/material.dart` only for `ThemeMode`, which drags Flutter into everything that touches settings — including the pure-logic worksheet engine, forcing the D2 companion-benchmark workaround.  Splitting the theme preference out of `UserSettings` (or giving the engine a narrower parameter than the full settings object) would make the engine pure Dart and let `worksheet-compute` join the main benchmark tool.  Out of scope for this change; noted for a future cleanup.
