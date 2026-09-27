## Why

Google Play accepts only Android App Bundles (AABs), and the release pipeline
builds only an APK.  The closed test that must run for 14 days before this
account can apply for production access cannot start until there is a bundle to
upload.  That first upload is also where Play App Signing is enrolled, which is
irreversible, so the bundle must be signed with the right key and checked before
anyone uploads it.  Building the bundle is therefore the first item on the Play
Store critical path.

## What Changes

- Every tag build also produces a release AAB, signed with the **upload key**,
  not the app signing key.  The upload keystore secrets already exist on the
  `release` environment but nothing reads them yet.
- The tag job checks the bundle's signer certificate against
  `ANDROID_UPLOAD_CERT_SHA256` and fails before uploading anything if they
  differ, if the bundle is unsigned, or if its signature does not verify.
- The bundle's native libraries are checked the same way as the APK's: exactly
  `arm64-v8a` and `armeabi-v7a`, each holding `libflutter.so` and `libapp.so`.
  `tool/verify_apk_abis.dart` learns the bundle layout (`base/lib/<abi>/`).
- Non-tag builds rehearse the bundle build as well, debug-signed and never
  published, so a failure in the bundle steps surfaces before a tag is cut.
- The bundle is kept as a workflow artifact for 90 days, so it can be downloaded
  and uploaded to the Play Console by hand.  It is **not** attached to the
  GitHub release, since end users cannot install it.
- The two Android build jobs are renamed from `build-android-apk-test` and
  `build-android-apk-release` to `build-android-test` and
  `build-android-release`, because each now builds both artifacts.

Not in this change: the Play App Signing enrolment and the first upload (manual
steps in section 6 of the `release-signing` change), automated uploads to Play,
and store listing assets.

## Capabilities

### New Capabilities

- `release-bundle`: the release app bundle built for Google Play.  Covers when
  it is built, which key signs it and how that is verified, its native-library
  layout, the rehearsal on non-tag builds, and how the bundle is kept and
  published.

### Modified Capabilities

None.  The APK's ABI requirements in `release-apk-abis` are unchanged; the
verification tool gains a second input format without changing what it requires
of an APK.

## Impact

- `.github/workflows/ci.yml`: both Android build jobs gain a bundle build,
  verification, and artifact upload; the tag job rewrites `key.properties` for
  the upload key between the APK and bundle builds; the jobs are renamed, and
  the `release` job's `needs` follows the rename.
- `tool/verify_apk_abis.dart`, `tool/verify_apk_abis_lib.dart`, and their tests:
  support for the bundle layout.
- No change to `android/app/build.gradle.kts`.  A local release bundle built
  during the proposal already has exactly the two ARM ABIs, because the
  release-only x86_64 packaging exclusion applies to bundles too.
- No new dependencies.  Signature checks use `keytool`, which ships with the
  JDK the runners already have.
- CI time: tag and non-tag builds each gain one bundle build, which reuses the
  APK build's compiled output in the same job (about 45 seconds locally).
