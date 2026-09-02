## 1. Version code computation

- [ ] 1.1 Write tests first in `test/tool/release_lib_test.dart` for the derived
  version code: `1.0.0` → `10000`, `1.2.3` → `10203`, `0.9.7` → `907`
- [ ] 1.2 Write tests for the range guard: minor ≥ 100 throws, patch ≥ 100
  throws, and minor/patch of 99 succeeds
- [ ] 1.3 Write a test asserting monotonicity — for each of major, minor, and
  patch, bumping a version strictly increases its version code
- [ ] 1.4 Write a test that a version string already carrying a build suffix
  (`1.2.3+10203`) derives its code from the version part alone
- [ ] 1.5 Add the derived version code to `Version` in `tool/release_lib.dart`,
  computing `major * 10000 + minor * 100 + patch` and throwing on an
  out-of-range minor or patch component
- [ ] 1.6 Confirm all new tests pass

## 2. Writing the suffix during a release

- [ ] 2.1 Write tests for the pubspec write path: a bump produces a `version:`
  line of the form `X.Y.Z+CODE` with the code matching the new name
- [ ] 2.2 Write tests covering the round trip — a pubspec already carrying a
  suffix is rewritten with the new name and new code, leaving no duplicate `+`
  and no stale code
- [ ] 2.3 Update the release bump path so the version written to `pubspec.yaml`
  includes the derived code; `updatePubspecVersion` already accepts versions
  with or without a suffix, so confirm whether it needs any change at all
- [ ] 2.4 Confirm the tag name, changelog section heading, and link references
  still use the bare `X.Y.Z` form with no build suffix leaking into them
- [ ] 2.5 Confirm all tests pass

## 3. Consistency check

- [ ] 3.1 Write tests for the check: a pubspec recording `1.2.3+10203` passes; a
  pubspec whose suffix disagrees with its name fails
- [ ] 3.2 Add the check to the release tooling so it runs before any bump,
  commit, or tag, and exits non-zero on mismatch without modifying anything
- [ ] 3.3 Verify by hand that a deliberately corrupted suffix aborts a
  `--dry-run` release rather than being silently corrected

## 4. Seed the current version

- [ ] 4.1 Set `pubspec.yaml` to `version: 0.9.7+907`
- [ ] 4.2 Confirm `flutter analyze` and the full test suite still pass
- [ ] 4.3 Build a release APK and confirm `aapt2 dump badging` reports
  `versionCode='907'` and `versionName='0.9.7'` — the same command that
  originally exposed the permanent `versionCode='1'`
- [ ] 4.4 Confirm the About screen still shows the bare version name, since it
  reads `PackageInfo.version` rather than the build number

## 5. Documentation

- [ ] 5.1 Document the scheme where the release process is described, including
  the two-digit ceiling on minor and patch and what to do if it is ever
  approached
- [ ] 5.2 Update `doc/implementation_plan.md` Phase 10 to check off the version
  code task and record the chosen scheme
- [ ] 5.3 Update `doc/design_progress.md` with a dated entry noting that every
  release through v0.9.7 shipped as `versionCode='1'`, and that the scheme's
  first value comfortably exceeds it so the transition needs no special handling
- [ ] 5.4 Confirm `release-signing`'s task 1.1 — which gates on this change
  having landed — is satisfied
