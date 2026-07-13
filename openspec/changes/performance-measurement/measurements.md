# Recorded Measurements

Working notes for tasks 5.1/5.2 — raw numbers from the implementation session,
to be written up in `doc/performance.md`.

## Benchmark tool (July 13, 2026; dev machine, Linux x64, Dart JIT via `dart run`)

```
case                  iters  min      median   mean
repo-construct        10     3.07 ms  4.32 ms  4.47 ms
resolve-all-cold      10     10.4 ms  11.1 ms  11.6 ms
resolve-all-warm      10     132 µs   133 µs   133 µs
evaluate-expressions  20     58 µs    60 µs    75 µs
browse-catalog        10     10.5 ms  12.3 ms  13.4 ms
currency-descriptors  10     1.44 ms  1.48 ms  1.54 ms
suggest-completions   20     2.12 ms  2.17 ms  2.22 ms
```

Notes:

- `evaluate-expressions` is 6 expressions per iteration (~10 µs each);
  `suggest-completions` is 4 queries per iteration (~0.5 ms per keystroke).
- Run-to-run variance observed up to ~25% on `repo-construct` (JIT); other
  cases within ~6%.

## Companion worksheet benchmark (July 13, 2026; `flutter test`, debug JIT, asserts on)

```
case                           iters  min     median  mean
worksheet-compute-length       20     136 µs  151 µs  170 µs
worksheet-compute-temperature  20     162 µs  183 µs  194 µs
```

## Memory report (July 13, 2026; dev machine, Linux x64, AOT via `dart compile exe`)

```
stage                         rss      delta
baseline                      8.25 MB
unit repository               10.1 MB  1.88 MB
resolution cache (all units)  18.8 MB  8.64 MB
browse catalog                18.8 MB  0.00 kB
currency descriptors          18.9 MB  132 kB
```

JIT run for contrast: baseline ~246 MB with negative deltas mid-report (GC of
compiler artifacts) — hence the tool's AOT recommendation and JIT warning.

## Preliminary go/no-go reads (to confirm in 5.2)

- **Cache pre-warming**: cold resolution of all ~6236 units is ~11 ms *total*
  (JIT, dev machine) — a background pre-warm task would save at most a few ms
  spread across first uses.  Strong "no".
- **`buildCurrencyDescriptors()` pre-frame cost**: ~1.5 ms on a cold repo —
  negligible; no need to move it off the startup path.  (On-device startup
  trace in 3.1 can confirm.)
- **Memory**: core domain totals ~10.6 MB over VM baseline (repo 1.9 MB +
  resolution cache 8.6 MB + catalog ~0 + descriptors 0.1 MB).  Not a problem;
  suggests a generous threshold when one is set in 5.2.
- **Frame-timing harness**: pending the manual DevTools pass (3.2).

## On-device measurements (tasks 3.1/3.2)

### Startup traces (July 13, 2026; `flutter run --profile --trace-startup`, real device)

(A first exploratory trace was discarded — the app's stored-rate state for it
was unknown.  The two runs below have known conditions.)

Clean install (fully uninstalled first; no stored rates):

```json
{
  "engineEnterTimestampMicros": 3259444624317,
  "timeToFrameworkInitMicros": 298147,
  "timeToFirstFrameRasterizedMicros": 722331,
  "timeToFirstFrameMicros": 650369,
  "timeAfterFrameworkInitMicros": 352222
}
```

Warm relaunch (no uninstall/clear; stored rates present, fetched earlier):

```json
{
  "engineEnterTimestampMicros": 3259577058229,
  "timeToFrameworkInitMicros": 190924,
  "timeToFirstFrameRasterizedMicros": 384415,
  "timeToFirstFrameMicros": 380408,
  "timeAfterFrameworkInitMicros": 189484
}
```

Reading: clean cold install without rates reached first frame in ~650 ms
(352 ms app-side); a warm relaunch running the **full** stored-rate startup
path (rate load + ~30 `registerDynamic` calls + `buildCurrencyDescriptors()`)
reached it in ~380 ms (189 ms app-side).  The with-rates launch being much
*faster* shows launch-cache warmth dominates these traces, and the stored-rate
path's cost is bounded to a small fraction of 189 ms — consistent with the JIT
benchmarks (`buildCurrencyDescriptors()` ~1.5 ms, repo construction ~4 ms).
The conditions differ in two variables at once (cache warmth and rates), so
the traces alone can't isolate the rates cost, but both launches are well
within acceptable cold-start range.

### DevTools pass 1 — frame chart, profile mode, tracking off (July 13, 2026, real device)

- Selecting the freeform input box: one jank bar (one-off; focus/keyboard
  bring-up, first-build class, expected)
- Each character typed in freeform: ~two frames flagged as jank at ~13–16 ms
- Typing in worksheet cells: a single flagged frame per keystroke
- Browse fling-scroll: a few flagged frames, not many
- **Browse scrolling with the fast-scroll thumb: many flagged frames** — the
  standout finding; the `FastScrollBar` drag path (thumb + peek preview)
  is markedly heavier than plain scrolling.  Follow-up candidate (3.3).

Note: 13–16 ms UI frames only count as jank on a high-refresh-rate display
(budget 11.1 ms at 90 Hz, 8.3 ms at 120 Hz); at 60 Hz they would be within
budget.  Device refresh rate: TBC.  Either way, per-keystroke latency is far
below the 100 ms interaction threshold; the question is smoothness, not
responsiveness.

### DevTools pass 2 — rebuild scope (debug mode required)

"Track/count widget builds" is unavailable in profile mode, so scope
observation runs under plain `flutter run` (debug).  Rebuild *scope* is
mode-independent (same widget-tree logic); debug-mode frame *times* are
meaningless and are not recorded.

Device refresh rate: **120 Hz** (frame budget 8.3 ms) — the 13–16 ms typing
frames from pass 1 are genuinely over budget on this device, though they would
pass at 60 Hz.

**Freeform, one keystroke** (counts settled before reading; 1-char token, so
no completion suggestions were produced):

- The entire `FreeformScreen` subtree rebuilt **twice**: `Scaffold`, `AppBar`,
  `TwoPaneLayout`, `ResultDisplay`, both `CompletionField`s, and the 9-key
  operator panel (9 × `Expanded`/`TextButton`/`Text` = the 18s).
- Cause, confirmed in code: (1) `freeform_screen.dart:99` runs
  `setState(() {})` on every text change to refresh the clear/swap button
  states; (2) the debounced evaluation result arrives via a screen-level
  provider watch.  Both rebuild from the screen root.
- This is the known deferred refactor from responsive-layouts ("lift Freeform
  field/eval state into a notifier"), now with measured consequences.

**Worksheet (Currency), one cell edit** (counts settled before reading):

- The `WorksheetScreen` subtree rebuilt **once** — all 12 row `TextField`s,
  the banner, the AppBar dropdown (12 `DropdownMenuItem`s).  Better scoped
  than freeform; the banner/dropdown rebuilding alongside the rows is
  incidental and cheap.
- Discovered while writing the scope tests: the worksheet recompute path is
  **synchronous** — `onRowChanged` updates the source row and runs the engine
  in the same turn (`worksheet_provider.dart:131-151`).  There is no
  worksheet-side debounce; the "500 ms debounce" in the Phase 6 design notes
  is stale for worksheets (freeform's debounce still exists).  At ~150 µs per
  engine pass, synchronous-per-keystroke is sound.

**Browse fast-scroll thumb drag** (counts cleared mid-drag; steady state over
~188 captured frames):

- `FastScrollBar`, its `GestureDetector`/`Positioned`, and `_PeekPanel`
  rebuilt **every frame** of the drag (187–188 counts); `Text` 935 = 5 peek
  labels × 187 frames.
- List-item counts (`_GroupHeaderTile`/`InkWell`/`Icon` at 49) are normal
  ListView virtualization as content scrolls past.
- Per-frame rebuild of a scrollbar during drag is inherent; the finding is
  that its per-frame cost overruns the 8.3 ms budget "many" times (pass 1),
  unlike plain fling-scrolling.  Whether the cost is UI-thread build/layout or
  raster (the thumb/panel use elevation/alpha) needs a dedicated look in the
  follow-up.

### Follow-up candidates (task 3.3 — recorded, NOT fixed in this change)

1. **Freeform whole-screen ×2 rebuild per keystroke** — lift field/eval state
   out of `FreeformScreen`'s widget `State` into a notifier so keystrokes
   rebuild only the widgets that depend on the changed state (the already
   deferred responsive-layouts item; now evidence-backed by the 13–16 ms
   over-budget typing frames at 120 Hz).
2. **`FastScrollBar`/`_PeekPanel` drag cost** — many over-budget frames at
   120 Hz during thumb drags (vs. few for plain fling).  Candidate
   directions: RepaintBoundary isolation, repositioning via transform instead
   of rebuild, cheaper peek-panel styling; profile UI vs. raster split first.
3. No action on startup, memory, worksheet editing, or plain scrolling — all
   comfortably within thresholds.
