## 1. Setup

- [x] 1.1 Add `integration_test: {sdk: flutter}` to `dev_dependencies` in `pubspec.yaml`; run `flutter pub get`
- [x] 1.2 Create `integration_test/` directory
- [x] 1.3 Create `integration_test/helpers/real_prefs.dart`: a helper for
      seeding/clearing keys in the real (platform-channel) `SharedPreferences`
      instance, distinct from `test/helpers/repository_overrides.dart`'s
      mock-backed `TestRepositories`

## 2. Boot sequence tests

- [x] 2.1 Create `integration_test/boot_test.dart`: initialize
      `IntegrationTestWidgetsFlutterBinding`, call `app.main()`, and assert
      the Freeform screen renders with no provider-resolution error
- [x] 2.2 Add a scenario that seeds a currency rate (with `updatedAt:
      DateTime.now()`, so `maybeRefresh()`'s staleness check short-circuits
      and no real network call is attempted) via the real-prefs helper
      before `app.main()`, then evaluates a currency conversion and asserts
      it reflects the seeded rate rather than the built-in compiled rate

**Verified passing (2/2)** against a real local Android emulator
(`emulator-5554`, AVD `Pixel_6_Pro_API_33_13.0_`).

## 3. Restart/persistence tests

- [x] 3.1 Create `integration_test/restart_test.dart` with a reusable
      `restart()` helper that seeds a fresh `currencyRates.updatedAt` (to
      avoid a real network call), tears down the widget tree, and calls
      `app.main()` again within the same test
- [x] 3.2 Scenario: select a worksheet template and enter a source value,
      restart, assert the same template is active and the value is restored
- [x] 3.3 Scenario: change a user setting (theme preference), restart,
      assert it's still applied
- [x] 3.4 Scenario: perform a successful freeform conversion, restart,
      assert the history entry is still present

**Verified passing (3/3)** against the same emulator, after two rounds of
real fixes discovered by actually running these against a device (not
theoretical — see `design.md`'s "FastScrollBar clamp crash" and
"Restart-technique test fixes" Decisions):
- A genuine production bug (`lib/shared/widgets/fast_scroll_bar.dart`, an
  unguarded `.clamp()` call) crashed every single restart, regardless of
  scenario — root-caused, confirmed unreachable via real single-launch
  usage, and fixed inline (a deliberate, documented exception to this
  change's test-only scope).
- Two test-code fixes: popping back to the base app before restarting while
  on a pushed route (settings scenario), and scoping a finder to the
  history modal specifically after a confirmed instance of old-session
  widget state (a stale `TextEditingController`) surviving the simulated
  restart (freeform-history scenario).

## 4. Currency refresh flow tests

- [x] 4.1 Create `integration_test/currency_refresh_test.dart`: build an
      independent `ProviderScope` (not via `app.main()`) with
      `currencyServiceProvider` overridden to a `CurrencyService` using a
      `package:http/testing.dart` `MockClient`
- [x] 4.2 Scenario: mocked successful response — trigger manual refresh,
      assert a conversion reflects the new rate
- [x] 4.3 Scenario: mocked failure response (non-200 and thrown exception
      cases) — trigger manual refresh, assert an error surfaces and stored
      rates are unchanged

**Verified passing (3/3)** against the same emulator.

## 5. CI wiring

- [x] 5.1 Add a step to `.github/actions/test/action.yml` that runs the
      suite. **Deviates from the original plan, twice**: first, `flutter
      test integration_test/ -d chrome` doesn't exist in Flutter 3.44 ("Web
      devices are not supported for integration tests yet") — the `flutter
      drive`-based web mechanism that replaced it was itself abandoned
      after proving to be a long-standing, unresolved upstream Flutter/DWDS
      bug (see `design.md`). The suite now runs on a local/CI **Android
      emulator** instead, via `reactivecircus/android-emulator-runner` in
      CI and the plain `flutter test -d <device>` command — no
      `flutter drive`, no chromedriver, no `test_driver/` entrypoint (that
      file has been removed, having only existed for the abandoned web
      path).
- [x] 5.2 Confirm the suite runs and passes. **Locally: yes, repeatedly**
      (all 8 scenarios across the 3 files, against a real emulator).
      **In CI: not yet observed** — the specific
      `reactivecircus/android-emulator-runner` GitHub Actions configuration
      has been written by analogy to its documented usage but never
      executed; the step is gated off
      (`ENABLE_ANDROID_INTEGRATION_TESTS: 'false'`) until someone watches a
      real CI run pass.
- [ ] 5.3 Confirm a deliberately-introduced failure in the integration
      suite fails the CI workflow, then revert the deliberate failure.
      **Not done** — requires pushing to trigger a CI run, which needs
      separate user go-ahead; can be combined with the first real
      (non-deliberately-broken) CI run.

## 6. Verification

- [x] 6.1 Run the full existing test suite
      (`flutter test --reporter failures-only`) and `flutter analyze` to
      confirm no regressions. Both clean (2043 tests passing; 0 analyzer
      issues), including after the `FastScrollBar` production fix.
- [x] 6.2 Run the new integration suite locally and confirm all scenarios
      pass. **Done** — all 8 scenarios across `boot_test.dart` (2),
      `restart_test.dart` (3), `currency_refresh_test.dart` (3) pass
      repeatedly against a real local Android emulator. (The originally-
      planned `-d chrome` invocation was abandoned; see `design.md`.)
- [x] 6.3 Verify no test in `integration_test/` contacts the real
      Frankfurter API. Confirmed by code inspection (every `app.main()`-
      driving test seeds a fresh `currencyRates` timestamp first via
      `RealPrefs.seedFreshCurrencyTimestamp()`, and
      `currency_refresh_test.dart` never calls `app.main()` or constructs a
      real `http.Client`, always `MockClient`) and by the passing local
      runs completing quickly with no network-timeout-shaped delays.
- [x] 6.4 Update `doc/design_progress.md` with a dated entry documenting
      the new suite and its scope, including the web-path abandonment and
      Android pivot, and the `FastScrollBar` bug.
- [x] 6.5 Update `doc/implementation_plan.md`'s Phase 9 "Comprehensive
      testing" task to reflect the integration tests now in place and
      passing locally, noting CI enablement is the one remaining step.
