## 1. Setup

- [ ] 1.1 Add `integration_test: {sdk: flutter}` to `dev_dependencies` in `pubspec.yaml`; run `flutter pub get`
- [ ] 1.2 Create `integration_test/` directory
- [ ] 1.3 Create `integration_test/helpers/real_prefs.dart`: a helper for
      seeding/clearing keys in the real (platform-channel) `SharedPreferences`
      instance, distinct from `test/helpers/repository_overrides.dart`'s
      mock-backed `TestRepositories`

## 2. Boot sequence tests

- [ ] 2.1 Create `integration_test/boot_test.dart`: initialize
      `IntegrationTestWidgetsFlutterBinding`, call `app.main()`, and assert
      the Freeform screen renders with no provider-resolution error
- [ ] 2.2 Add a scenario that seeds a currency rate (with `updatedAt:
      DateTime.now()`, so `maybeRefresh()`'s staleness check short-circuits
      and no real network call is attempted) via the real-prefs helper
      before `app.main()`, then evaluates a currency conversion and asserts
      it reflects the seeded rate rather than the built-in compiled rate

## 3. Restart/persistence tests

- [ ] 3.1 Create `integration_test/restart_test.dart` with a reusable
      `restart()` helper that seeds a fresh `currencyRates.updatedAt` (to
      avoid a real network call), tears down the widget tree, and calls
      `app.main()` again within the same test
- [ ] 3.2 Scenario: select a worksheet template and enter a source value,
      restart, assert the same template is active and the value is restored
- [ ] 3.3 Scenario: change a user setting (theme preference and/or
      precision), restart, assert it's still applied
- [ ] 3.4 Scenario: perform a successful freeform conversion, restart,
      assert the history entry is still present

## 4. Currency refresh flow tests

- [ ] 4.1 Create `integration_test/currency_refresh_test.dart`: build an
      independent `ProviderScope` (not via `app.main()`) with
      `currencyServiceProvider` overridden to a `CurrencyService` using a
      `package:http/testing.dart` `MockClient`
- [ ] 4.2 Scenario: mocked successful response — trigger manual refresh,
      assert status/timestamp updates and a conversion reflects the new rate
- [ ] 4.3 Scenario: mocked failure response (non-200 and thrown exception
      cases) — trigger manual refresh, assert an error surfaces and stored
      rates are unchanged

## 5. CI wiring

- [ ] 5.1 Add a step to `.github/actions/test/action.yml` (or a clearly
      justified sibling action/job, per the design doc's open question)
      that runs `flutter test integration_test/ -d chrome`
- [ ] 5.2 Confirm the step runs headlessly on the existing `ubuntu-latest`
      runner with no additional emulator/browser-driver setup
- [ ] 5.3 Confirm a deliberately-introduced failure in the integration
      suite fails the CI workflow, then revert the deliberate failure

## 6. Verification

- [ ] 6.1 Run the full existing test suite
      (`flutter test --reporter failures-only`) and `flutter analyze` to
      confirm no regressions
- [ ] 6.2 Run the new integration suite locally
      (`flutter test integration_test/ -d chrome`) and confirm all
      scenarios pass
- [ ] 6.3 Verify no test in `integration_test/` contacts the real
      Frankfurter API (e.g. by temporarily disabling network access while
      running the suite)
- [ ] 6.4 Update `doc/design_progress.md` with a dated entry documenting
      the new suite and its scope
- [ ] 6.5 Update `doc/implementation_plan.md`'s Phase 9 "Comprehensive
      testing" task to reflect the integration tests now in place, noting
      Android/iOS-emulator coverage remains deferred
