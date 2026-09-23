## 1. Baseline and verification script

Write the check first and watch it fail against the current build, so later
passes mean something.  All local APK builds and crafted test files go in the
session scratch directory or `build/`, never in tracked paths.  After each
local build, check `git status`: `flutter` may regenerate `pubspec.lock` or
touch `analysis_options.yaml`, and those side effects must not be committed.

- [ ] 1.1 Build the current release APK locally with no `android/key.properties`
  (`flutter build apk --release`, debug-signed by the fallback).  Record its
  size, its `unzip -Z1 <apk> 'lib/*'` listing, and the `versionCode` from
  `aapt2 dump badging`, as the baseline
- [ ] 1.2 Write `tool/verify_apk_abis.sh <apk>` per design D4.  It exits 0 only
  when the set of ABI directories under `lib/` is exactly `arm64-v8a` and
  `armeabi-v7a`, and each contains `libflutter.so` and `libapp.so`.  On failure
  it prints the ABI directories and libraries it found, and exits non-zero.
  With a missing or unreadable APK argument it prints usage and exits non-zero.
  Make it executable
- [ ] 1.3 Run the script against the baseline APK from 1.1 and confirm it
  **fails**, reporting `x86_64` as unexpected
- [ ] 1.4 Confirm the other failure paths using edited copies of the baseline
  APK in the scratch directory (`zip -d` to delete entries):
  - with all `lib/x86_64/*` entries removed, the script passes
  - with `lib/x86_64/*` removed except `libdatastore_shared_counter.so`, it
    fails (partial unexpected directory)
  - with `lib/x86_64/*` and `lib/armeabi-v7a/libflutter.so` removed, it fails
    (missing engine library)
  - with no APK argument or a nonexistent path, it prints usage and fails

## 2. Build configuration

- [ ] 2.1 In `android/app/build.gradle.kts`, add the release-only packaging
  exclusion from design D2 (`androidComponents.onVariants` selecting the
  `release` build type, adding `lib/x86_64/**` to `packaging.jniLibs.excludes`).
  Add a comment explaining why a packaging exclusion is used rather than
  `abiFilters` or `--target-platform` alone: Flutter resets the ABI filters, and
  dependency libraries would otherwise leave a partial `lib/x86_64/` that makes
  x86_64 devices crash instead of translating ARM
- [ ] 2.2 Build with `flutter build apk --release --target-platform
  android-arm,android-arm64` and confirm `tool/verify_apk_abis.sh` passes.
  Record the APK size in bytes and MiB
- [ ] 2.3 Build with plain `flutter build apk --release` (no flag) and confirm
  the script still passes, showing the packaging exclusion alone decides what
  ships (design D3)
- [ ] 2.4 Confirm `aapt2 dump badging` on the 2.2 APK reports the same
  `versionCode` as the baseline and as `pubspec.yaml`
- [ ] 2.5 Build a profile APK (`flutter build apk --profile`) and confirm it
  still contains `lib/x86_64/libflutter.so`, showing the exclusion is limited to
  the release build type
- [ ] 2.6 Run the integration suite locally on the x86_64 emulator
  (`tool/run_integration_tests.sh`) and confirm it passes, showing debug builds
  are unaffected
- [ ] 2.7 Install the 2.2 APK on the x86_64 emulator (an Android 11+ image, which
  translates ARM) with `adb install`, launch it, and confirm it reaches the
  first screen.  Uninstall afterwards so later emulator runs start clean

## 3. CI

- [ ] 3.1 In `.github/workflows/ci.yml`, add `--target-platform
  android-arm,android-arm64` to the `flutter build apk` command in both
  `build-android-apk-test` and `build-android-apk-release`
- [ ] 3.2 Add a `Verify native library ABIs` step running
  `tool/verify_apk_abis.sh build/app/outputs/flutter-apk/app-release.apk` to
  both jobs, right after the build.  In `build-android-apk-release`, place it
  next to `Verify signing certificate`, so both checks run before the
  signing-material cleanup and the upload
- [ ] 3.3 Update the comments above the two jobs if they describe what the APK
  contains, so they stay accurate
- [ ] 3.4 On the pull request, confirm `build-android-apk-test` passes, its
  verification output lists exactly the two ARM ABIs, and the integration
  tests in the `test` job pass unchanged

## 4. Final checks

- [ ] 4.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [ ] 4.2 Run `flutter analyze` and confirm there are no issues
- [ ] 4.3 Run the pre-commit hooks over the changed files and confirm they pass
- [ ] 4.4 Confirm `git status` shows no unintended changes (in particular to
  `pubspec.lock` or `analysis_options.yaml`) and that no build output or
  scratch APK is in the working tree

## 5. Documentation

- [ ] 5.1 Update `doc/implementation_plan.md` Phase 10 task 5: check it off and
  record the decision (one APK, both ARM ABIs, no x86_64), the options rejected
  and why, the partial-directory problem, and the measured APK size from 2.2
- [ ] 5.2 Update the MVP success criterion line "App size <50MB" in
  `doc/implementation_plan.md` to met, citing the measured size
- [ ] 5.3 Add a dated entry to `doc/design_progress.md` covering the decision,
  the device research (CDD §7.6.1, Chromebook translation, the last x86 phones),
  Flutter's ABI filter reset and the DataStore library, and the measured size
- [ ] 5.4 Replace the estimated size in `design.md` (Context, D1, Risks) with the
  measured figure from 2.2
- [ ] 5.5 Check `README.md` and `CONTRIBUTING.md` for statements about the APK's
  contents or supported devices, and update any that are no longer accurate

## 6. After merge

- [ ] 6.1 On the next `v*` release, confirm the attached APK passes
  `tool/verify_apk_abis.sh`, its size matches 2.2, it is still the only APK
  asset, and `apksigner` still reports the app signing certificate
