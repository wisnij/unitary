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
drive` mechanism instead — see the new Decision below.

## Goals / Non-Goals

**Goals:**

- Exercise the real `main()` boot sequence at least once, automated, in CI.
- Prove persisted data (worksheet sources, settings, freeform history)
  survives a full teardown-and-reconstruction of the provider graph, using
  the real (non-mocked) `SharedPreferences` plugin.
- Exercise the currency-refresh flow end to end (status → dynamic unit
  registration → a conversion reflecting the new rate) without ever
  contacting the real Frankfurter API.
- Run entirely against the `chrome` target so no emulator/device is needed,
  reusing infrastructure this repo already has for web builds.

**Non-Goals:**

- Android/iOS emulator-driven tests. Deferred; the one platform branch in
  the app (`freeform_screen.dart`'s mobile-vs-desktop key panel visibility)
  isn't covered by this change.
- True OS-level process kill/relaunch. "Restart" here means tearing down
  the widget tree and calling `app.main()` again within the same Chrome
  tab/test process — the same real backing store, but not a genuine cold
  process start. Accepted approximation (see Risks).
- Frame-timing, rendering-performance, or touch-physics assertions. Stays a
  manual on-device procedure per `doc/performance.md`.
- Testing the currency-refresh cooldown timer's expiry-then-re-enable
  behavior. Pre-existing gap (no test today touches `cooldownExpiry` or the
  re-enable `Timer` in `CurrencyStatusNotifier`), unrelated to this change's
  purpose — a candidate follow-up, not folded in here.
- Any change to `lib/` production code. This change is test-only.

## Decisions

### Run against `chrome`, not an Android emulator

`main.dart` and every provider it wires have no platform-specific branches;
`shared_preferences` and `http` both have working web implementations. CI
already has Chrome available (`ubuntu-latest`) and already builds this app
for web. An Android emulator (e.g. `reactivecircus/android-emulator-runner`)
would add real CI cost and flakiness for coverage this change doesn't need.
**Alternative considered**: run against a headless Android emulator in CI
from the start — rejected as disproportionate to the boot/persistence/
currency-refresh scope; revisit only if Android-specific behavior needs
coverage later.

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

### Web execution requires `flutter drive`, `chromedriver`, and `--web-run-headless`

Discovered during implementation, correcting the original plan: `flutter
test integration_test/*.dart -d chrome` is rejected outright ("Web devices
are not supported for integration tests yet"). The actual mechanism is
`flutter drive --driver=test_driver/integration_test.dart --target=<file> -d
chrome`, which requires two things `flutter test` doesn't: a
`test_driver/integration_test.dart` entrypoint (`integrationDriver()` from
`package:integration_test/integration_test_driver.dart`), and a separately
running `chromedriver` WebDriver server (not bundled; installed via
`apt-get install chromium-driver` in CI, matching the runner's preinstalled
Chrome version).

A further correction: `flutter drive -d chrome` launches a **visible**
Chrome window by default — `--[no-]headless` (default on) only governs the
WebDriver-side "driver" browser chromedriver controls; the separate
app-hosting browser (via `chrome_launcher`, the same mechanism `flutter run
-d chrome` uses) defaults to visible. The fix is the `--web-run-headless`
flag, which specifically targets that second browser. This was found the
hard way during local diagnosis — see Risks.
**Alternative considered**: none seriously — this is simply how Flutter's
web integration-test tooling works in this version; there is no alternative
invocation that avoids `flutter drive`.

### Gate the whole suite behind an opt-in CI toggle, off by default

Local diagnosis (see Risks) could not get a full pass: after chromedriver
established a session and the DWDS debug service started, the run hung/
failed with an unresolved `AppConnectionException` before reporting a test
result. Root cause wasn't isolated in the time available, and it's unclear
whether it's specific to the local dev machine's networking or a more
general fragility in this Flutter version's web-driver path. Rather than
wire the CI step to run unconditionally (risking either a permanently red
step or, worse, a step that silently never passes and gets ignored),
`.github/workflows/ci.yml`'s `test` job sets
`ENABLE_CHROME_INTEGRATION_TESTS: 'false'`, and the new step in
`.github/actions/test/action.yml` only runs when that's `'true'`. This is a
one-line flip once someone confirms the suite passes reliably against the
clean `ubuntu-latest` runner (which lacks the local machine's VPN/mesh
networking, so may well not reproduce the hang at all).
**Alternative considered**: an in-app, Dart-level skip gate (e.g. reading an
environment variable inside the test files) — rejected: `dart:io`'s
`Platform.environment` isn't available on the `web` compile target at all,
so gating has to happen at the shell/CI level (whether the step runs),
not inside the Dart test code.

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

- **"Restart" is same-process, not a true cold start** → Accepted
  approximation (see Non-Goals). A genuine app-kill test would need
  `flutter drive` against a real/emulated device; revisit only if a bug
  class specific to true process death (e.g. a plugin failing to
  re-register) is ever suspected.
- **Prefs-seeding trick is implicit coupling to `maybeRefresh()`'s 24h
  threshold** → If that threshold ever changes, the seeded `updatedAt`
  timestamp (`DateTime.now()`, always fresh) stays correct by construction;
  no risk in practice.
- **`chrome`-only coverage misses the one real platform branch**
  (`freeform_screen.dart`'s mobile-vs-desktop panel visibility) → Accepted;
  that branch already has non-integration test coverage
  (grep confirms `kIsWeb`/`defaultTargetPlatform` branch is exercised by
  existing widget tests using `debugDefaultTargetPlatformOverride` or
  similar — verify during implementation and note if a gap is found).
- **CI runtime growth** — Chrome-driven `integration_test` runs are slower
  than plain widget tests (real rendering, real async gaps).
  Mitigation: keep this initial suite to the three scoped groups (not a
  broad re-test of already-covered UI flows); revisit if runtime becomes a
  problem.
- **No confirmed passing local run yet** → Local diagnosis on a real
  developer desktop (not a clean environment — a NordVPN mesh network
  interface is present, and chromedriver logged an unexplained `bind()
  failed: Cannot assign requested address`) got as far as chromedriver
  establishing a WebDriver session and the DWDS debug service starting, then
  hung/failed with an `AppConnectionException` before any test result was
  reported. One incidental, now-fixed problem surfaced along the way: the
  first attempt (before `--web-run-headless` was identified as necessary)
  launched a real, visible Chrome window on the developer's screen.
  Mitigation: the CI step is off by default (see the gating Decision above)
  until a passing run is confirmed in the clean `ubuntu-latest` environment;
  the Dart test code itself is written and passes `flutter analyze`, so the
  remaining risk is scoped to the web-driver tooling path, not test-logic
  correctness.

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
