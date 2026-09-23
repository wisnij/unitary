## Why

The APK attached to every GitHub release is 53.8 MB (56,433,241 bytes for
v0.9.8), missing the MVP criterion of under 50 MB.  `flutter build apk` produces
a fat APK carrying native code for three ABIs, and because native libraries are
stored uncompressed with `extractNativeLibs=false`, Android keeps the whole APK
on disk and never discards the slices a device cannot run.  The x86_64 slice is
the largest (19.1 MB), and no phone or tablet that can install Unitary needs it:
the one known x86_64 phone at `minSdk 24` also runs ARM code.
The GitHub APK is meant as a way to install on phones and tablets without Play,
so this is worth settling before 1.0.0 is cut.

## What Changes

- The release APK carries native code for exactly two ABIs, `armeabi-v7a` and
  `arm64-v8a`, and no `x86_64`.  It remains a single asset under the same name,
  measured at 35.1 MB (36,785,016 bytes) on a local build.
- x86_64 is removed at packaging time for the release variant, so that
  libraries contributed by dependencies are excluded along with Flutter's own.
  Passing `--target-platform` alone is insufficient: Flutter resets the ABI
  filters to all three defaults, so a dependency's native library (today
  androidx DataStore's `libdatastore_shared_counter.so`, via
  `shared_preferences_android`) would still ship in a partial `lib/x86_64/`
  directory.  An x86_64 device would then select that ABI, find no
  `libflutter.so`, and crash on launch instead of translating the ARM code.
- Both APK build jobs pass `--target-platform android-arm,android-arm64`, so the
  unused x86_64 engine is not compiled and the non-tag rehearsal job builds the
  same configuration the tag job publishes.
- Both APK build jobs verify the built APK's native library layout with a new,
  tested tool, `tool/verify_apk_abis.dart`, and fail unless it contains exactly
  the two ARM ABIs, each with `libflutter.so` and `libapp.so`.
- Debug and profile builds are unchanged: they keep every ABI, so the
  integration suite on the x86_64 emulator and local development are unaffected.
- The version code is unchanged.  This is a fat APK, not a per-ABI split, so
  Flutter's per-ABI version-code offset never applies.
- **BREAKING** for x86_64 devices only: the release APK no longer carries native
  x86_64 code.  Devices with ARM translation (every Android-capable Chromebook
  translates 32-bit ARM) run the ARM build instead.  The web app remains
  available to anyone else.

## Capabilities

### New Capabilities

- `release-apk-abis`: which ABIs the published release APK carries, that no
  ABI directory in it is partial, that debug and profile builds are unaffected,
  and the build-time verification that enforces the layout.

### Modified Capabilities

<!-- None.  `version-code` is untouched because no per-ABI split is introduced.
     `release-signing` is still an active change rather than a main spec, and
     its requirements (which key signs the APK, and the certificate check) are
     unaffected; the new verification sits beside its certificate check. -->

## Impact

- **Build configuration**: `android/app/build.gradle.kts` gains a release-only
  JNI packaging exclusion for x86_64 native libraries.
- **Tooling**: new `tool/verify_apk_abis.dart` and
  `tool/verify_apk_abis_lib.dart`, with tests in
  `test/tool/verify_apk_abis_lib_test.dart`.  No new dependencies: the
  executable lists the APK's entries with `unzip -Z1`.
- **CI**: in `.github/workflows/ci.yml`, `build-android-apk-test` and
  `build-android-apk-release` both gain `--target-platform
  android-arm,android-arm64` and an ABI layout verification step.
  `build-web`, `deploy-web`, and the integration tests in
  `.github/actions/test` are untouched.
- **Distribution**: the GitHub APK drops from 53.8 MB to 35.1 MB, for
  download and for storage on the device.  The asset name and single-asset
  release layout are unchanged.
- **Documentation**: `doc/implementation_plan.md` (Phase 10 task 5 and the MVP
  size criterion) and `doc/design_progress.md`.
- **Not in scope**: the Play app bundle (Phase 10 task 7).  The packaging
  exclusion is scoped to the release variant and will therefore probably apply
  to a future AAB too; whether that is wanted is decided with the AAB work.
  Also out of scope: `--split-per-abi`, an arm64-only build, and
  `--split-debug-info`/`--obfuscate`.
