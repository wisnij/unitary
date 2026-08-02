## Why

The Android-emulator integration-test step has now been observed passing
repeatedly in real CI runs (including a deliberately-broken-assertion check
confirming a genuine failure actually fails the workflow), closing out the
"unverified CI YAML" risk that originally justified gating it behind an
opt-in toggle. Today that toggle only gets set to `'true'` in
`ci.yml`'s `test` job; `release.yml`'s `test` job (which also uses
`./.github/actions/test`) never sets it, so the release pipeline silently
skips integration coverage. Since the toggle is proven, it should default
to on for every pipeline using the action, not require each caller to
remember to opt in.

## What Changes

- The Android integration-test step in `.github/actions/test/action.yml`
  runs unconditionally for every workflow that uses
  `./.github/actions/test` — the `if:` gate and the
  `ENABLE_ANDROID_INTEGRATION_TESTS` toggle are removed entirely, not
  replaced with a different toggle.
- `ci.yml`'s `test` job drops its now-unused `env:` block.
- `release.yml`'s `test` job gains Android integration-test coverage with
  no changes to that file — it already calls `./.github/actions/test` and
  will now run the step unconditionally, same as every other caller.
- `run-tests.sh`'s own, independent `ENABLE_ANDROID_INTEGRATION_TESTS`
  check (a plain shell variable gating whether the *local* script boots an
  emulator) is untouched — it shares a variable name with the old CI
  toggle by convention only, and has no connection to the GitHub Actions
  mechanism being removed here.

**Explicitly out of scope**: changing the per-attempt timeout/retry
behavior in `tool/run_integration_tests.sh`, and changing which CI runner
or emulator profile is used — this change only affects whether the step
runs by default, not how it runs.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `integration-test-harness`: the "Integration suite runs in CI against an
  Android emulator" requirement changes from "only when
  `ENABLE_ANDROID_INTEGRATION_TESTS` is `'true'` on the calling job" to
  "unconditionally, for every caller of `./.github/actions/test`" — the
  opt-in toggle is removed, not replaced.

## Impact

- **`.github/actions/test/action.yml`**: removes the Android step's `if:`
  condition entirely; the step always runs.
- **`.github/workflows/ci.yml`**: removes the `env:` block from the `test`
  job (no longer read by anything).
- **`.github/workflows/release.yml`**: no changes needed — it starts
  running the Android integration suite as a side effect of the step no
  longer being conditional, which is the point of this change.
- **No changes** to `run-tests.sh`, `tool/run_integration_tests.sh`, the
  `integration_test/` suite itself, or any `lib/` code.
