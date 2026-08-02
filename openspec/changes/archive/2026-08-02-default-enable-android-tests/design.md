## Context

`.github/actions/test/action.yml`'s Android integration-test step currently
gates on a plain environment variable (`ENABLE_ANDROID_INTEGRATION_TESTS`)
that the *calling job* must set — it's read via `env.ENABLE_ANDROID_INTEGRATION_TESTS`
inside the composite action, which works because composite-action steps
inherit the calling job's `env:` block. `ci.yml`'s `test` job sets it to
`'true'`; `release.yml`'s `test` job does not set it at all, so it silently
defaults to unset/false there. This was intentional while the CI
configuration was unverified (see the archived `integration-tests` change's
design.md) — the gate has since been confirmed passing, including a
deliberately-broken-assertion check proving a real failure actually fails
the workflow, so the "unverified" justification no longer applies.

Separately, `run-tests.sh` (a local dev convenience script, not part of any
GitHub Actions workflow) has its own `ENABLE_ANDROID_INTEGRATION_TESTS`
check — a plain shell variable read via `${ENABLE_ANDROID_INTEGRATION_TESTS:-}`
that decides whether the script boots a local emulator and runs the suite.
It shares a variable name with the CI-side toggle purely by convention
(the two were introduced together and documented as matching); it is not
read by, or connected to, GitHub Actions in any way.

## Goals / Non-Goals

**Goals:**

- Every current and future caller of `./.github/actions/test` runs the
  Android integration suite, with no per-caller configuration required.
- Confirm `run-tests.sh`'s local gating is unaffected by this change.

**Non-Goals:**

- Changing the per-attempt timeout, retry behavior, or emulator profile in
  `tool/run_integration_tests.sh` / `.github/actions/test/action.yml`'s
  `with:` block for `reactivecircus/android-emulator-runner`.
- Auditing or changing any other workflow beyond `ci.yml` and (implicitly,
  by inheriting the new unconditional behavior) `release.yml`.
- Preserving a way to disable the step per-caller. No current or
  anticipated pipeline needs one; if a future pipeline does, that's a
  reason to add a toggle *then*, not to keep one around unused now (see
  Decisions).

## Decisions

### Remove the conditional entirely rather than replace it with a different toggle

Delete the Android step's `if:` condition outright, so it always runs for
every caller of `./.github/actions/test`. An earlier version of this
design proposed instead converting the env-var gate into a formal
composite-action `input` with `default: 'true'` (keeping an opt-out
available via `with:`). That was reconsidered: there is no current caller
that wants to opt out, and no concrete anticipated one — CLAUDE.md's
guidance against pre-building for hypothetical requirements applies
directly here. An unconditional step is simpler to read (no `inputs:`
block, no `if:` to reason about) and has nothing to drift out of sync. If
a real future need for a per-caller opt-out arises, adding an `inputs:`
entry at that point is a small, easily-reviewed change with a concrete
motivating case behind it.
**Alternative considered**: formal `input` with `default: 'true'` — see
above; rejected as speculative complexity for a need that doesn't exist
yet.
**Alternative considered**: keep the plain env var, and just add it to
`release.yml` too. Rejected — it satisfies today's two callers but doesn't
achieve "all pipelines using that action" for any *future* caller, which
would need to remember to set the var themselves.

### `run-tests.sh`'s local toggle is untouched

`run-tests.sh` gates its local emulator-boot-and-test path on
`ENABLE_ANDROID_INTEGRATION_TESTS` as a plain shell environment variable —
a mechanism entirely internal to that script, with no relationship to
GitHub Actions `env:`/`inputs:` semantics. Removing the CI-side toggle has
no effect on it: a developer running `ENABLE_ANDROID_INTEGRATION_TESTS=true
./run-tests.sh` locally continues to work exactly as before. The shared
variable name is now purely coincidental rather than a real coupling; not
worth renaming either side over, since the name still accurately describes
what it does in each context.

## Risks / Trade-offs

- **Every pipeline now pays the Android-emulator runtime cost** (boot +
  test time, on top of the existing lint/unit-test time) → Mitigation:
  this is the explicit intent of the change (coverage that was silently
  being skipped on `release.yml`); the per-attempt timeout/retry in
  `tool/run_integration_tests.sh` already bounds worst-case runtime, and
  that mechanism is unchanged by this proposal.
- **No per-caller escape hatch if a future pipeline needs one** →
  Mitigation: accepted per the Decisions section above; adding one back is
  a small, well-motivated change if that need ever materializes.

## Migration Plan

Pure CI-configuration change, no data or runtime migration. Rollback is a
one-line revert (restore the `if:` condition and `ci.yml`'s `env:` block)
if the always-on behavior proves too slow or flaky for `release.yml` in
practice.
