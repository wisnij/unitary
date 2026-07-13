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

## On-device measurements (pending — tasks 3.1/3.2)

- Startup trace (with/without stored rates): TBD
- DevTools frame chart + rebuild scope observations: TBD
