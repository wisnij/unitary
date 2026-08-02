## MODIFIED Requirements

### Requirement: Integration suite runs in CI against an Android emulator

The `integration_test` suite SHALL run in CI against an Android emulator
(via `reactivecircus/android-emulator-runner`, `flutter test
integration_test/<file>.dart -d <device>` — no `flutter drive`, no
WebDriver server) unconditionally for every workflow that uses
`./.github/actions/test`.

#### Scenario: CI executes the integration suite

- **WHEN** a workflow uses `./.github/actions/test`
- **THEN** it includes a step that boots an Android emulator and runs the
  `integration_test/` suite against it, and a failure in that step fails
  the workflow
