## 1. Setup

- [x] 1.1 Add `integration_test: {sdk: flutter}` to `dev_dependencies` in `pubspec.yaml`; run `flutter pub get`
- [x] 1.2 Create `integration_test/` directory
- [x] 1.3 Create `integration_test/helpers/real_prefs.dart`: a helper for
      seeding/clearing keys in the real (platform-channel) `SharedPreferences`
      instance, distinct from `test/helpers/repository_overrides.dart`'s
      mock-backed `TestRepositories`
- [x] 1.4 (added during implementation) Create `test_driver/integration_test.dart`
      (`integrationDriver()` entrypoint) — required by `flutter drive`, the
      only mechanism that supports the web target for `integration_test`;
      see the note under task 5.1

## 2. Boot sequence tests

- [x] 2.1 Create `integration_test/boot_test.dart`: initialize
      `IntegrationTestWidgetsFlutterBinding`, call `app.main()`, and assert
      the Freeform screen renders with no provider-resolution error
- [x] 2.2 Add a scenario that seeds a currency rate (with `updatedAt:
      DateTime.now()`, so `maybeRefresh()`'s staleness check short-circuits
      and no real network call is attempted) via the real-prefs helper
      before `app.main()`, then evaluates a currency conversion and asserts
      it reflects the seeded rate rather than the built-in compiled rate

Written and statically verified (`flutter analyze` clean); **not yet
confirmed passing under live execution** — see task 6.2.

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

Written and statically verified; not yet confirmed passing under live
execution — see task 6.2.

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

Written and statically verified; not yet confirmed passing under live
execution — see task 6.2.

## 5. CI wiring

- [x] 5.1 Add a step to `.github/actions/test/action.yml` that runs the
      suite. **Deviates from the original plan**: `flutter test
      integration_test/ -d chrome` does not exist as a supported combination
      in Flutter 3.44 ("Web devices are not supported for integration tests
      yet") — discovered during implementation. Web integration tests
      require the older `flutter drive --driver=test_driver/integration_test.dart
      --target=<file> -d chrome` mechanism instead, which needs its own
      `chromedriver` WebDriver server (installed via `apt-get install
      chromium-driver` in the CI step; matches the runner's preinstalled
      Chrome version) and the `--web-run-headless` flag (without it, `flutter
      drive -d chrome` launches a *visible* browser window — confirmed the
      hard way during local diagnosis).
- [ ] 5.2 Confirm the step runs headlessly on the existing `ubuntu-latest`
      runner with no additional emulator/browser-driver setup. **Partially
      done**: confirmed headless (`--web-run-headless`) prevents a visible
      window. **Not confirmed**: a full successful pass. Local diagnosis (on
      a real desktop, not a clean CI-like environment) got as far as
      chromedriver establishing a session and the DWDS debug service
      starting, then hung/failed with an unresolved
      `AppConnectionException` / timeout before any test result was
      reported. Root cause not isolated — possibly specific to that
      machine's networking (VPN mesh interface, an unexplained chromedriver
      `bind() failed` warning), possibly a general fragility in this
      Flutter version's web+`flutter drive`+headless path. **Mitigation
      adopted**: the whole step is gated off by default via the
      `ENABLE_CHROME_INTEGRATION_TESTS` env var (`.github/workflows/ci.yml`),
      so it does not block CI until someone flips it on after seeing it pass
      reliably in the clean `ubuntu-latest` environment (which lacks this
      dev machine's networking quirks, so may well behave better).
- [ ] 5.3 Confirm a deliberately-introduced failure in the integration suite
      fails the CI workflow, then revert the deliberate failure. **Not
      done** — requires a working baseline pass first (see 5.2) and requires
      actually pushing to trigger a CI run, which needs separate user
      go-ahead.

## 6. Verification

- [x] 6.1 Run the full existing test suite
      (`flutter test --reporter failures-only`) and `flutter analyze` to
      confirm no regressions. Both clean (2043 tests passing; 0 analyzer
      issues, including the new `integration_test/`/`test_driver/` files).
- [ ] 6.2 Run the new integration suite locally and confirm all scenarios
      pass. **Not completed** — see 5.2. Attempted via `flutter drive
      --web-run-headless` (the correct invocation; the originally-planned
      `flutter test integration_test/ -d chrome` does not work at all) with
      a manually-extracted `chromedriver` (no root available locally); did
      not reach a passing result within the diagnostic effort spent. Left
      for the next session or for CI's clean environment to confirm.
- [ ] 6.3 Verify no test in `integration_test/` contacts the real
      Frankfurter API. **Not run** (depends on 6.2). By code inspection:
      every test that calls `app.main()` seeds a fresh `currencyRates`
      timestamp first via `RealPrefs.seedFreshCurrencyTimestamp()`, and
      `currency_refresh_test.dart` never calls `app.main()` or constructs a
      real `http.Client` at all (always `MockClient`) — but this is
      unverified by an actual run.
- [x] 6.4 Update `doc/design_progress.md` with a dated entry documenting
      the new suite and its scope, including the tooling findings above.
- [x] 6.5 Update `doc/implementation_plan.md`'s Phase 9 "Comprehensive
      testing" task to reflect the integration tests now in place, noting
      Android/iOS-emulator coverage remains deferred and that CI execution
      is gated off pending a confirmed passing run.
