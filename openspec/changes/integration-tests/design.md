## Context

`doc/implementation_plan.md`'s Phase 9 "Comprehensive testing" task and code
review finding F9 (`doc/code_review_2026-07.md`) both call for an
`integration_test/` suite; none exists. The project has ~2000 `flutter_test`
widget tests, which are thorough for business logic (parser/evaluator,
worksheet engine, providers) and UI behavior, but structurally cannot cover
a class of bugs that only exist when the whole app process boots for real:

- `main.dart` (provider wiring, pre-first-frame currency-rate rehydration,
  stale-key cleanup) never executes in any existing test — widget tests
  build their own `ProviderScope` via `test/helpers/pump_app.dart` and never
  touch the real entry point.
- `SharedPreferences` is always the mocked in-memory plugin
  (`setMockInitialValues`) in existing tests, so "does persisted data
  survive a full reconstruction of the app" is asserted only at the
  notifier/`build()` level, never end to end.

A prior exploration (see conversation leading to this proposal) ruled out
needing an Android/iOS emulator for most of this: `main.dart` has no
platform branches, and the `web` target already builds in CI
(`deploy-web` job), so running against Chrome reaches the same code paths
without new device infrastructure. The one genuine gap that needs a real
device — frame-timing/rendering fidelity — is already scoped in
`doc/performance.md` as a manual, on-device procedure and stays out of this
change.

**Correction found during implementation**: the exploration assumed `flutter
test integration_test/ -d chrome` would run the suite; it does not exist as
a supported combination in Flutter 3.44 ("Web devices are not supported for
integration tests yet"). Web integration tests require the older `flutter
drive` mechanism instead. That path was pursued at length (chromedriver,
`--web-run-headless`, running in an isolated Docker container to rule out
local-machine causes) and ultimately abandoned: the failure is a
long-standing, currently-unresolved upstream Flutter/DWDS bug, not anything
fixable in this project. **The suite ended up running against a local
Android emulator instead** — see "Pivot to Android" under Decisions for the
full account, including why this turned out to be straightforward rather
than a compromise.

## Goals / Non-Goals

**Goals:**

- Exercise the real `main()` boot sequence at least once, automated, in CI.
- Prove persisted data (worksheet sources, settings, freeform history)
  survives a full teardown-and-reconstruction of the provider graph, using
  the real (non-mocked) `SharedPreferences` plugin.
- Exercise the currency-refresh flow end to end (status → dynamic unit
  registration → a conversion reflecting the new rate) without ever
  contacting the real Frankfurter API.
- Run against a target that doesn't need new CI infrastructure beyond what's
  already documented/available. (Originally read as "the `chrome` target,
  no emulator" — revised to "a local Android emulator" once the web path
  proved unreliable upstream; see Decisions. Android tooling turned out to
  already be fully present and working on the dev machine used for this
  change, so "no new infrastructure" still held, just not in the shape
  originally planned.)

**Non-Goals:**

- iOS-simulator-driven tests. Out of scope; the project's own README lists
  iOS as secondary. Android was adopted (see Decisions) but iOS wasn't
  evaluated.
- True OS-level process kill/relaunch. "Restart" here means tearing down
  the widget tree and calling `app.main()` again within the same test
  process — the same real backing store, but not a genuine cold process
  start. This is now a **confirmed**, not just theoretical, approximation:
  it was directly observed to leak old-session widget state (a stale
  `TextEditingController`) across the simulated restart — see Risks.
- Frame-timing, rendering-performance, or touch-physics assertions. Stays a
  manual on-device procedure per `doc/performance.md`.
- Testing the currency-refresh cooldown timer's expiry-then-re-enable
  behavior. Pre-existing gap (no test today touches `cooldownExpiry` or the
  re-enable `Timer` in `CurrencyStatusNotifier`), unrelated to this change's
  purpose — a candidate follow-up, not folded in here.
- Changes to `lib/` production code, **with one narrow exception**: a
  `FastScrollBar` crash (`lib/shared/widgets/fast_scroll_bar.dart`) that
  blocked every restart-based test was root-caused and fixed inline rather
  than deferred to a separate change — see "FastScrollBar clamp crash"
  under Decisions for the justification and evidence it doesn't affect real
  users.

## Decisions

### ~~Run against `chrome`, not an Android emulator~~ — superseded

Original reasoning: `main.dart` and every provider it wires have no
platform-specific branches; `shared_preferences` and `http` both have
working web implementations, and an Android emulator would add real CI cost
and flakiness for coverage this change didn't seem to need.

**Superseded during implementation.** The web path was pursued at length —
`flutter drive` (the only mechanism that supports `integration_test` on
web), `chromedriver`, `--web-run-headless`, then an isolated Docker
container specifically to rule out the local machine's networking as the
cause — and every attempt hit the identical `AppConnectionException` from
DWDS's `_startLocalDebugService`. A web search confirmed this is a
long-standing, currently-unresolved Flutter/DWDS bug (GitHub issues
#178725, #181357, #153165, #89534, #84353, spanning Flutter versions from
2021 through 3.38 as of January 2026) — not something fixable in this
project, and not specific to the local machine (the clean, isolated Docker
container hit the exact same failure).

See "Pivot to Android" below for what replaced it.

### Drive `app.main()` directly for boot and restart tests

`integration_test`'s standard pattern is
`import 'package:unitary/main.dart' as app; app.main();` inside a
`testWidgets` block, then `await tester.pumpAndSettle()`. This runs the
production entry point unmodified — no refactor of `main.dart` needed to
make it "testable." Calling `app.main()` a second time within the same test
replaces the widget tree with a fresh `ProviderScope`/provider graph while
the real, `localStorage`-backed `SharedPreferences` instance underneath is
unchanged, which is exactly the "simulated restart" this change wants.
**Alternative considered**: extract a testable `buildApp()` function from
`main.dart` that accepts injectable dependencies — rejected because it
would test a reconstruction of the boot sequence rather than the boot
sequence itself, undermining the point of this test group.

### Avoid the real network call via prefs seeding, not a `main.dart` seam

`UnitaryApp.initState()` unconditionally calls
`currencyStatusProvider.notifier.maybeRefresh()` on the first post-frame
callback, and `main.dart` gives no override point for `currencyServiceProvider`
— so driving `app.main()` naively would fire a real HTTP request to
Frankfurter on every boot/restart test. Fix: seed the real
`SharedPreferences` with a `currencyRates` entry whose `updatedAt` is
`DateTime.now()` before calling `app.main()`. `maybeRefresh()`'s staleness
check (`>= 24h`) then short-circuits and no fetch is attempted — no
production code changes required. This is free for the boot test that
already wants a stored rate present, and a one-line addition for the
others.
**Alternative considered**: add an optional dependency-injection seam to
`main.dart` (e.g. an optional `http.Client` parameter threaded through to
`currencyServiceProvider`) — rejected for this change since it touches
production code for a test-only need that the prefs-seeding trick already
solves; worth reconsidering if a future integration test needs to exercise
`maybeRefresh()` itself triggering a (mocked) fetch on boot.

### Currency-refresh flow does not go through `app.main()`

Unlike boot/restart, the currency-refresh group's own `ProviderScope` (built
directly, the way widget tests already do, but under
`IntegrationTestWidgetsFlutterBinding` for real rendering/timers) with
`currencyServiceProvider` overridden to a `CurrencyService` built on
`package:http/testing.dart`'s `MockClient`. `currencyServiceProvider` is
already a plain, trivially overridable `Provider`; no new seam needed.
Running it under `IntegrationTestWidgetsFlutterBinding` rather than as an
ordinary `flutter_test` widget test buys real (non-`fakeAsync`) timer
behavior for the in-progress/cooldown states, at the cost of the test
needing to run in the same Chrome-targeted suite as the other two groups
rather than the plain unit-test job.
**Alternative considered**: drive currency refresh through `app.main()` too,
for maximum realism — rejected; it would require the network-avoidance
prefs-seeding trick here as well while adding no coverage the isolated
`ProviderScope` approach doesn't already give, since the refresh flow is a
single-screen concern.

### (Historical/abandoned) Web execution requires `flutter drive`, `chromedriver`, and `--web-run-headless`

Kept for the record — this path was abandoned (see the superseded Decision
above) but the tooling facts remain accurate documentation of why web
integration testing is unusually heavy in current Flutter, should it ever
be revisited: `flutter test integration_test/*.dart -d chrome` is rejected
outright ("Web devices are not supported for integration tests yet"). The
actual mechanism is `flutter drive
--driver=test_driver/integration_test.dart --target=<file> -d chrome`,
which requires a `test_driver/integration_test.dart` entrypoint and a
separately running `chromedriver` WebDriver server (not bundled). Further,
`flutter drive -d chrome` launches a **visible** Chrome window by default —
`--[no-]headless` (default on) only governs the WebDriver-side "driver"
browser; the separate app-hosting browser (via `chrome_launcher`) defaults
to visible, requiring the separate `--web-run-headless` flag. This was
found the hard way during local diagnosis (a real, if brief and now-fixed,
disruption — see Risks) before any of it turned out to be moot.

### Pivot to Android emulator

Once the web path was conclusively an upstream dead end, Android was
re-evaluated — the local dev machine turned out to already have everything
needed: `flutter doctor` reported a fully-configured Android toolchain
("No issues found"), an existing AVD (`Pixel_6_Pro_API_33_13.0_`), and
confirmed KVM hardware-acceleration access (an explicit per-user ACL entry
on `/dev/kvm`, not just group membership). Native `integration_test` on
Android doesn't route through DWDS/web-driver at all — it's the simple
`flutter test integration_test/<file>.dart -d <device>` command directly,
no `flutter drive`, no chromedriver, no headless-browser flags. Every test
file, unmodified in its actual assertions (only two small test-logic fixes
were needed — see "Restart-technique test fixes" below), now passes for
real: `boot_test.dart` (2/2), `restart_test.dart` (3/3, after the
`FastScrollBar` fix), `currency_refresh_test.dart` (3/3).
**Alternative considered**: keep trying to fix the web path — rejected once
the upstream-bug evidence was conclusive (identical failure in a clean
Docker container, and multiple long-standing open Flutter issues matching
the exact stack trace); no amount of local environment tweaking was going
to fix an upstream tooling bug.

### FastScrollBar clamp crash — found, root-caused, and fixed

The restart-based tests reliably crashed on **every** restart (not just
one scenario) with `ArgumentError: Invalid argument(s): 0.0` from
`double.clamp` inside `_FastScrollBarState.build` (was `fast_scroll_bar.dart:317`).
Root cause: `AppShell` keeps every top-level page alive in an `IndexedStack`
for page-state preservation, so `BrowserScreen`'s `FastScrollBar` is laid
out even while a different page is visible. During the transient frame
right after a second `app.main()` call replaces the already-attached root
widget tree, that `LayoutBuilder` reported a **tight zero-height**
constraint (`BoxConstraints(0.0<=w<=400.0, h=0.0)`, captured via a
temporary diagnostic print, since reverted) — smaller than the fixed
48.0-logical-pixel thumb height, making the clamp's upper bound negative
(below its 0.0 lower bound), which Dart's `num.clamp` treats as an invalid
range and throws for, rather than clamping to something sane.

**Confirmed not reachable through real single-launch usage**: a standalone
diagnostic test that boots the app once (`app.main()` called exactly once,
same compact window size, same eagerly-loaded Browse catalog) never hit the
degenerate branch and threw nothing. The bug requires literally replacing
an already-attached root widget tree via a second `runApp()` call within
one process — something no real user action does (a genuine app relaunch,
even after a real process kill, is a fresh process with exactly one
`main()` call, which is the case just proven safe).

**Fix**: floor both affected clamp upper-bounds at `0.0` via `math.max`
(`fast_scroll_bar.dart`, the crash site and one structurally-identical
`.clamp()` in `_peekPanelTop` audited and fixed the same way for
consistency) — when the available height is smaller than the thumb, the
thumb simply pins at the top instead of throwing. Mirrors the defensive
`trackHeight <= 0` early-return already present in `_onDragUpdate` in the
same file, so it's consistent with an existing pattern, not a new one.
**Alternative considered**: work around it in the test technique instead of
fixing production code (e.g. avoid triggering the degenerate layout pass
somehow) — rejected: no such workaround was identified, the crash is
inherent to any restart-style test that replaces the root widget while
`BrowserScreen` is instantiated, and the fix itself is small, low-risk, and
strictly defensive (behavior is unchanged whenever `_listHeight >=
_thumbHeight`, which is every real-world case observed so far).

### Restart-technique test fixes

Two remaining restart-test failures, after the `FastScrollBar` fix, were
test-code issues, not app bugs:
- The settings scenario navigated to (and stayed on) the pushed `Settings`
  route before calling `restart()`; something about a second `runApp()`
  replacing the root while a pushed route sits on top of it left the new
  tree without its drawer/hamburger icon. Fixed by popping back to the base
  app (`tester.pageBack()`) before restarting, so every restart scenario
  restarts from the same tabbed-page footing — this also isn't something
  meaningfully under test (we care whether settings *data* persists, not
  whether mid-navigation state survives a simulated restart).
- The freeform-history scenario's `find.textContaining('5 miles')`
  ambiguously matched two widgets after restart: the intended history-modal
  entry, and — confirmed unexpectedly — the "Convert from" field's
  `TextEditingController` from the *pre-restart* session, still showing
  "5 miles" despite freeform input explicitly not persisting across
  sessions (see `doc/design_progress.md`'s "Remove freeform persistence"
  entry). This is a second, non-crashing instance of the same
  same-process-restart leaking widget state that the `FastScrollBar` bug
  exposed as a crash — recorded as a confirmed Risk below rather than
  chased further, since it doesn't undermine what these tests actually
  verify (repository-level persistence, not widget/controller lifecycle).
  Fixed by scoping the finder to `find.descendant(of:
  find.byType(DraggableScrollableSheet), matching: ...)` so only the
  history modal's own content is checked.

### Gate the CI step behind an opt-in toggle — kept, for a narrower reason

The web-path version of this gate existed because zero runs ever passed
locally. That's no longer true — all three files now pass repeatedly
against a real Android emulator — but the specific CI YAML
(`reactivecircus/android-emulator-runner`) has never itself been executed;
only reasoned about and written by analogy to its documented usage.
`.github/workflows/ci.yml`'s `test` job keeps a toggle
(`ENABLE_ANDROID_INTEGRATION_TESTS: 'false'`, renamed from the web-era
`ENABLE_CHROME_INTEGRATION_TESTS`), and the step in
`.github/actions/test/action.yml` only runs when it's `'true'`, so a
misconfigured CI-only detail (emulator boot flags, API level availability
on the runner, etc.) can't block merges before anyone's watched it run.
Recommend flipping it on after the first real CI run succeeds.
**Alternative considered**: turn it on immediately, given the much higher
confidence than the web path ever reached — rejected as still one
unverified step (the CI YAML itself) away from a real confirmation; the
cost of one gated-off run is low.

### New real-prefs seeding helper, separate from `TestRepositories`

`test/helpers/repository_overrides.dart`'s `TestRepositories` is built on
`SharedPreferences.setMockInitialValues`, the fake in-memory plugin used by
ordinary `flutter_test` widget tests. Under `IntegrationTestWidgetsFlutterBinding`,
the real platform-channel plugin is in effect (backed by browser
`localStorage` on the `chrome` target), so `setMockInitialValues` doesn't
apply and isn't wanted here — seeding must go through the real
`SharedPreferences.getInstance()` API before `app.main()` runs. A small,
separate helper (e.g. `integration_test/helpers/real_prefs.dart`) wraps
this: get the real instance, write/clear specific keys, used only by this
suite.

## Risks / Trade-offs

- **"Restart" is same-process, not a true cold start, and this has now
  demonstrably leaked old-session state twice** → No longer a purely
  theoretical approximation. It caused one real crash (`FastScrollBar`,
  fixed) and one benign-but-confirmed leftover widget (a stale
  `TextEditingController` in the Convert-from field, worked around in the
  test's finder). Both were specific to *widget/controller-tree* state
  surviving a root-widget replacement, not to the repository-level
  persistence these tests actually verify (`SharedPreferences` reads/writes
  are unaffected — those pass through the real plugin regardless of what
  the widget tree does). A genuine app-kill test would need `flutter drive`
  against a real/emulated device; revisit only if a bug class specific to
  true process death, or a *third* instance of leaked widget state, is ever
  suspected.
- **Prefs-seeding trick is implicit coupling to `maybeRefresh()`'s 24h
  threshold** → If that threshold ever changes, the seeded `updatedAt`
  timestamp (`DateTime.now()`, always fresh) stays correct by construction;
  no risk in practice.
- **Android-only coverage misses iOS-specific behavior** → Accepted; iOS is
  this project's secondary platform (per the README) and wasn't evaluated
  for this change. Unlike the original web-only plan, Android coverage does
  exercise the one real platform branch in the app
  (`freeform_screen.dart`'s mobile-vs-desktop key panel visibility, via
  `defaultTargetPlatform == TargetPlatform.android`) — a incidental bonus
  over the web path, which couldn't have reached it at all.
- **CI runtime growth** — an Android emulator boot (even from a cached
  AVD/snapshot) adds real time on top of the tests themselves, more than
  the web path would have. Mitigation: keep this initial suite to the three
  scoped groups (not a broad re-test of already-covered UI flows); revisit
  if runtime becomes a problem.
- **The CI YAML itself is unverified** → Every test file passes repeatedly
  against a real local Android emulator, and `flutter analyze` /
  `flutter test --reporter failures-only` (2043 tests) are both clean. What
  hasn't been confirmed is the specific `reactivecircus/android-emulator-runner`
  GitHub Actions configuration — API level availability, boot flags, and
  general behavior on a `ubuntu-latest` runner — since that requires an
  actual CI run to observe. Mitigation: the step stays gated off by
  `ENABLE_ANDROID_INTEGRATION_TESTS: 'false'` until someone watches it pass
  once in real CI, at which point flipping it on is a one-line change.

## Open Questions

- ~~Should the new CI step live in `.github/actions/test/action.yml` (same
  job, extra step) or a new sibling job?~~ **Resolved**: new step in the
  same composite action (`.github/actions/test/action.yml`), sharing the
  existing `flutter pub get` / SDK setup rather than duplicating it in a
  separate job.
- ~~Exact list of "restart" scenarios in tasks.md (worksheet, settings,
  history)~~ **Resolved**: keep all three. No existing test (notifier-level
  or repository-level) exercises the real, platform-channel-backed
  `SharedPreferences` plugin — every one uses
  `SharedPreferences.setMockInitialValues`, so none of the three restart
  scenarios is actually redundant with existing coverage. The theoretical
  overlap (all three exercise the same underlying real-plugin round-trip
  mechanism) is outweighed by two things: each repository's storage shape
  differs enough to plausibly catch different bugs (worksheet's nested map
  vs. settings' flat enum-as-string fields vs. history's capped JSON list),
  and the marginal cost of an extra scenario is small once the shared
  `restart()` helper (task 3.1) exists — the Chrome/app-boot overhead
  dominates runtime, not the number of assertions per boot.
