## ADDED Requirements

### Requirement: Boot sequence verified via the real entry point

The `integration_test` suite SHALL drive the actual application entry point
(`main()` in `lib/main.dart`, via `import 'package:unitary/main.dart' as
app; app.main();`) rather than reconstructing an independent
`ProviderScope`, so that the real provider wiring and pre-first-frame
currency-rate rehydration logic execute exactly as shipped.

#### Scenario: App boots without provider errors

- **WHEN** `app.main()` is called and the widget tree settles
- **THEN** the Freeform screen is displayed and no
  `UnimplementedError` or other provider-resolution error is thrown

#### Scenario: Currency rate rehydration runs before the first frame

- **WHEN** a currency rate is seeded into the real `SharedPreferences`
  store before `app.main()` is called
- **THEN** a currency conversion evaluated immediately after boot reflects
  the seeded rate, not the compiled-in built-in rate

### Requirement: Persisted state survives a simulated app restart

The suite SHALL simulate an app restart by calling `app.main()` a second
time within the same test session, so a fresh provider graph is
reconstructed against the same real (non-mocked), `SharedPreferences`-backed
storage used by the first boot, and SHALL verify that worksheet source
values, user settings, and freeform history all survive the reconstruction.

#### Scenario: Worksheet source value persists across restart

- **WHEN** a worksheet template is selected and a source value is entered,
  then the app is restarted via a second `app.main()` call
- **THEN** the same template is active and the same source value is
  restored after restart

#### Scenario: Settings persist across restart

- **WHEN** a user setting (e.g. theme preference or precision) is changed,
  then the app is restarted via a second `app.main()` call
- **THEN** the changed setting is still in effect after restart

#### Scenario: Freeform history persists across restart

- **WHEN** a successful freeform conversion is performed, then the app is
  restarted via a second `app.main()` call
- **THEN** the conversion's history entry is still present after restart

### Requirement: Currency refresh flow tested without contacting the real API

The suite SHALL exercise the manual currency-refresh flow (status update,
dynamic-unit registration, a conversion reflecting the new rate) using a
`CurrencyService` built on `package:http/testing.dart`'s `MockClient`,
overriding `currencyServiceProvider` in an independently-constructed
`ProviderScope`. The real Frankfurter API SHALL NOT be contacted by any
test in the suite.

#### Scenario: Successful mocked refresh updates state and conversions

- **WHEN** a manual refresh is triggered and the mocked HTTP client returns
  a successful rate response
- **THEN** the refresh status reflects the new update time and a
  subsequent currency conversion reflects the new rate

#### Scenario: Failed mocked refresh surfaces an error without changing rates

- **WHEN** a manual refresh is triggered and the mocked HTTP client returns
  a failure (non-200 response or a thrown exception)
- **THEN** an error is surfaced to the user and previously stored rates are
  unchanged

### Requirement: Integration suite runs in CI against an Android emulator, gated behind an opt-in toggle

The `integration_test` suite SHALL run in CI against an Android emulator
(via `reactivecircus/android-emulator-runner`, `flutter test
integration_test/<file>.dart -d <device>` — no `flutter drive`, no
WebDriver server), only when the `ENABLE_ANDROID_INTEGRATION_TESTS`
environment variable is `'true'` on the calling job.

#### Scenario: CI executes the integration suite when enabled

- **WHEN** the CI test workflow runs with `ENABLE_ANDROID_INTEGRATION_TESTS`
  set to `'true'`
- **THEN** it includes a step that boots an Android emulator and runs the
  `integration_test/` suite against it, and a failure in that step fails
  the workflow

#### Scenario: CI skips the integration suite when not enabled

- **WHEN** the CI test workflow runs with `ENABLE_ANDROID_INTEGRATION_TESTS`
  unset or not `'true'` (the default)
- **THEN** the Android-emulator integration-test step does not run, and
  does not affect the workflow's pass/fail outcome

### Requirement: Real-`SharedPreferences` seeding helper for integration tests

A helper for integration tests SHALL be provided to seed and clear values
in the real, platform-channel-backed `SharedPreferences` instance before
calling `app.main()` — distinct from the widget-test harness's
`TestRepositories`, which relies on the mocked `SharedPreferences` plugin
and doesn't apply here.

#### Scenario: Helper seeds real preferences before boot

- **WHEN** an integration test uses the helper to write a specific
  `SharedPreferences` key before calling `app.main()`
- **THEN** the booted app's repositories observe the seeded value through
  their normal load path, with no use of `setMockInitialValues`
