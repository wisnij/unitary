## Why

`pubspec.yaml` carries a bare `version: 0.9.7` with no `+build` suffix, so
Flutter defaults the Android version code to 1 and every release ever published
has shipped as `versionCode='1'` — confirmed with `aapt2 dump badging` against a
built release APK.

That blocks the Play Store outright: each upload must carry a version code
strictly greater than the previous one, so a permanent 1 can be accepted at most
once.  It also degrades the GitHub channel, where Android uses the version code —
not the version *name* — to decide whether an APK is an upgrade, and to enforce
downgrade protection.  Today every Unitary APK looks like the same build to the
package manager.

This is a hard prerequisite for the first Play upload, and independently worth
fixing for direct APK installs, so it lands before the release-signing work
rather than alongside it.

## What Changes

- Adopt a version code derived deterministically from the semantic version:
  `MAJOR × 10000 + MINOR × 100 + PATCH`, so `1.0.0` → `10000` and `1.2.3` →
  `10203`.  The version name remains the single source of truth; there is no
  second counter to keep in sync or forget.
- Teach the existing release tooling (`tool/release.dart` /
  `tool/release_lib.dart`, which already parses, bumps, and writes the version)
  to compute the code and write `X.Y.Z+CODE` into `pubspec.yaml` as part of a
  release bump.
- Set the build suffix on the current version so the working tree is consistent
  immediately, rather than only after the next release.
- Add tests covering the computation, its monotonicity, and its boundaries,
  following the established `tool/*_lib.dart` + `test/tool/*_lib_test.dart`
  convention.
- No change to the version *name*, to `CHANGELOG.md` formatting, to tag naming,
  or to what the About screen displays.

## Capabilities

### New Capabilities

- `version-code`: how the Android version code is derived from the semantic
  version, the guarantees it must provide (strictly increasing across releases,
  within Android's valid range), and where it is computed and recorded.

### Modified Capabilities

<!-- None.  No existing spec covers release tooling, `pubspec.yaml` version
     handling, or Android build configuration.  `changelog-unreleased-section`
     covers a different part of `tool/release.dart` and is untouched: this change
     adds to the version-bump path, not the changelog path. -->

## Impact

- **Release tooling**: `tool/release_lib.dart` (the `Version` class gains a
  derived version code; the pubspec write path emits the `+CODE` suffix) and its
  test file.  `Version.parse` already tolerates and strips a `+build` suffix, and
  `updatePubspecVersion` already handles versions with or without one, so the
  existing round-trip is prepared for this.
- **`pubspec.yaml`**: the `version:` line gains a `+CODE` suffix.
- **Android builds**: `versionCode` starts tracking releases instead of being
  permanently 1.  No Gradle change is required — `flutter.versionCode` already
  reads the pubspec build number.
- **Runtime display**: none.  The About screen shows `PackageInfo.version`, which
  is the version *name*; the build number is a separate field it does not read.
- **Prerequisite for**: `release-signing`, whose first Play upload cannot succeed
  while every build reports version code 1.
- **Not in scope**: the signing key, the AAB build, and anything else in the Play
  submission path.
