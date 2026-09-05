## Why

Every release Unitary has ever published — 38 of them — is signed with the
local Android **debug** keystore, because `android/app/build.gradle.kts` still
carries the `flutter create` default (`signingConfig =
signingConfigs.getByName("debug")`).  Verified against the built artifact:
`apksigner verify --print-certs` reports `Signer #1 certificate DN: C=US,
O=Android, CN=Android Debug`.  That is acceptable for a pre-1.0 stream nobody
installs, and unacceptable for a published 1.0.0: the Play Store rejects
debug-signed uploads outright, and the identity of `dev.wisnij.unitary` is
currently protected only by a keystore whose password is the universally-known
`android`.

It must be fixed *before* the first real publication rather than after.  A
signing key cannot be changed once users have installed: Android refuses any
update whose signature differs, so re-signing later would force every user to
uninstall and lose their settings, worksheet values, and history.  The cost of
doing it now is near zero — 27 lifetime APK downloads across all releases, and
zero on every recent one — and rises permanently the moment 1.0.0 ships.

## What Changes

- Generate two RSA-2048 signing keys, valid 30 years, held offline with
  backups: an **app signing key** (the permanent identity of the app) and a
  separate **upload key** (used only to authenticate uploads to Play, and
  rotatable through the Play Console if it leaks).
- Replace the debug `signingConfig` in `android/app/build.gradle.kts` with a
  real one reading credentials from an untracked `android/key.properties`,
  following the standard Flutter convention.
- Add keystore patterns to `.gitignore` **before** any key exists, so a stray
  `git add -A` cannot commit one.
- Supply both keystores to CI as secrets on a `release` environment restricted
  to `v*` tags, and wire the tag-only signing job to sign the GitHub APK with the
  app signing key — and, when the Play AAB build lands, to sign that with the
  upload key by rewriting `key.properties` between the two build steps.
- Enrol in Play App Signing by **uploading the existing app signing key** rather
  than letting Google generate one, so that a GitHub-downloaded APK and a
  Play-delivered install of the same version carry identical signatures.
- **BREAKING** for existing installs: the first signed build cannot install over
  any previously published debug-signed build.  Anyone holding one must
  uninstall first, losing locally stored data.  Called out in the release notes;
  no migration path is built, because the installed base is effectively empty.

## Capabilities

### New Capabilities

- `release-signing`: how release artifacts are signed — the two-key model, the
  Gradle and `key.properties` wiring, which key signs which artifact, how the
  keys reach CI, the secrecy guarantees the build must not violate, and the
  verification that proves the right key was used.

### Modified Capabilities

<!-- None.  No existing spec describes release signing, Gradle configuration, or
     the release job's artifact production; `coverage-threshold` is the closest
     CI-adjacent spec and is untouched by this change. -->

## Impact

- **Build configuration**: `android/app/build.gradle.kts` (`buildTypes.release`
  gains a real signing config; the stale `applicationId` TODO can go at the same
  time), plus a new untracked `android/key.properties`.
- **Repository hygiene**: `.gitignore` gains `*.jks`, `*.p12`, `*.keystore`, and
  `android/key.properties`.
- **CI**: `.github/workflows/ci.yml` — the APK build splits in two.
  `build-android-apk-test` runs on every push and pull request with no keys in
  reach, and `build-android-apk-release` runs on tags only, decoding the keystore
  and generating `key.properties`.  Secrets are scoped to a `release`
  environment restricted to `v*` tags, not held as repository secrets.
- **Play Console**: one-time app signing enrolment using the PEPK-encrypted app
  signing key, performed as part of the first manual submission.
- **Distribution**: both channels converge on one certificate, so users can move
  between the GitHub APK and the Play build.
- **Security posture**: the app signing key becomes readable by the release
  workflow.  This is a deliberate trade for unattended releases, mitigated but
  not eliminated; see `design.md`.
- **Not in scope**: the version-code scheme (separate change, and a prerequisite
  for the first Play upload), the AAB build itself, Play listing assets, and the
  privacy policy.
