## 1. Verification tool, test-first

Write the tests first and watch them fail, then confirm the finished tool fails
against the current build, so later passes mean something.  All local APK
builds and edited test files go in the session scratch directory or `build/`,
never in tracked paths.  After each local build, check `git status`: `flutter`
may regenerate `pubspec.lock` or touch `analysis_options.yaml`, and those side
effects must not be committed.

- [x] 1.1 Build the current release APK locally with no `android/key.properties`
  (`flutter build apk --release`, debug-signed by the fallback).  Record its
  size, its `unzip -Z1 <apk> 'lib/*'` listing, and the `versionCode` from
  `aapt2 dump badging`, as the baseline
- [x] 1.2 Write `test/tool/verify_apk_abis_lib_test.dart` for a pure function in
  `tool/verify_apk_abis_lib.dart` that takes an APK's entry names and returns
  the problems found (empty when the layout is valid).  Cover:
  - complete `arm64-v8a` and `armeabi-v7a` directories and nothing else: no
    problems
  - entries outside `lib/` (`AndroidManifest.xml`, `assets/...`) are ignored
  - a complete extra `x86_64` directory: reported as unexpected
  - a partial `x86_64` directory holding only
    `libdatastore_shared_counter.so`: reported as unexpected
  - a partial `x86` directory: reported as unexpected
  - `armeabi-v7a` missing `libflutter.so`, and `arm64-v8a` missing
    `libapp.so`: each reported as a missing library in that ABI
  - an expected ABI directory absent entirely: reported as missing
  - no `lib/` entries at all: reported
  - several problems at once: all reported, not only the first

  Run the tests and confirm they fail because the function doesn't exist yet
- [x] 1.3 Implement `tool/verify_apk_abis_lib.dart` until the 1.2 tests pass
- [x] 1.4 Write the executable `tool/verify_apk_abis.dart <apk>`.  It runs
  `unzip -Z1 <apk>`, passes the entry names to the 1.3 function, prints the ABI
  directories and libraries it found, and exits 0 only when there are no
  problems.  Otherwise it prints each problem and exits non-zero.  With no
  argument or a nonexistent path it prints usage and exits non-zero.  If
  `unzip` fails, it reports that and exits non-zero
- [x] 1.5 Run the executable by hand:
  - against the 1.1 baseline APK: it **fails**, reporting `x86_64` as
    unexpected
  - against a scratch copy of the baseline with `lib/x86_64/*` deleted
    (`zip -d`): it passes
  - with no argument and with a nonexistent path: it prints usage and fails

## 2. Build configuration

- [x] 2.1 In `android/app/build.gradle.kts`, add the release-only packaging
  exclusion from design D2 (`androidComponents.onVariants` selecting the
  `release` build type, adding `**/x86_64/**` to `packaging.jniLibs.excludes`).
  Add a comment explaining why a packaging exclusion is used rather than
  `abiFilters` or `--target-platform` alone: Flutter resets the ABI filters, and
  dependency libraries would otherwise leave a partial `lib/x86_64/` that makes
  x86_64 devices crash instead of translating ARM
- [x] 2.2 Build with `flutter build apk --release --target-platform
  android-arm,android-arm64` and confirm `dart run tool/verify_apk_abis.dart`
  passes.  If `lib/x86_64/` is still present, the pattern matched nothing:
  adjust it and record the working form in `design.md` D2.  Record the APK size
  in bytes and MiB
- [x] 2.3 Build with plain `flutter build apk --release` (no flag) and confirm
  the tool still passes, showing the packaging exclusion alone decides what
  ships (design D3)
- [x] 2.4 Confirm `aapt2 dump badging` on the 2.2 APK reports the same
  `versionCode` as the baseline and as `pubspec.yaml`
- [x] 2.5 Build a profile APK (`flutter build apk --profile`) and confirm it
  still contains `lib/x86_64/libflutter.so`, showing the exclusion is limited to
  the release build type
- [x] 2.6 Run the integration suite locally on the x86_64 emulator
  (`tool/run_integration_tests.sh`) and confirm it passes, showing debug builds
  are unaffected
- [x] 2.7 Install the 2.2 APK on an x86_64 emulator image that translates ARM,
  launch it, and confirm it reaches the first screen.  Not every x86_64 image
  translates: the API 33 `google_apis` image lists only `x86_64`.  The API 35
  `google_apis` x86_64 image does (`ro.dalvik.vm.native.bridge` is
  `libndk_translation.so`), for 64-bit ARM only (ABI list `x86_64,arm64-v8a`).
  Create an AVD from it, `adb install` the APK, and confirm Android chose
  `primaryCpuAbi=arm64-v8a`, `libflutter.so` loads from `lib/arm64-v8a/`, and
  the app stays running on the Freeform screen.  Uninstall afterwards so later
  emulator runs start clean

## 3. CI

- [x] 3.1 In `.github/workflows/ci.yml`, add `--target-platform
  android-arm,android-arm64` to the `flutter build apk` command in both
  `build-android-apk-test` and `build-android-apk-release`
- [x] 3.2 Add a `Verify native library ABIs` step running
  `dart run tool/verify_apk_abis.dart build/app/outputs/flutter-apk/app-release.apk` to
  both jobs, right after the build.  In `build-android-apk-release`, place it
  next to `Verify signing certificate`, so both checks run before the
  signing-material cleanup and the upload
- [x] 3.3 Update the comments above the two jobs if they describe what the APK
  contains, so they stay accurate
- [x] 3.4 On the pull request, confirm `build-android-apk-test` passes, its
  verification output lists exactly the two ARM ABIs, and the integration
  tests in the `test` job pass unchanged

## 4. Final checks

- [x] 4.1 Run `flutter test --reporter failures-only` and confirm all tests
  pass, including the new `test/tool/verify_apk_abis_lib_test.dart`
- [x] 4.2 Run `flutter analyze` and confirm there are no issues
- [x] 4.3 Run the pre-commit hooks over the changed files and confirm they pass
- [x] 4.4 Confirm `git status` shows no unintended changes (in particular to
  `pubspec.lock` or `analysis_options.yaml`) and that no build output or
  scratch APK is in the working tree

## 5. Documentation

- [x] 5.1 Update `doc/implementation_plan.md` Phase 10 task 5: check it off and
  record the decision (one APK, both ARM ABIs, no x86_64), the options rejected
  and why, the partial-directory problem, and the measured APK size from 2.2
- [x] 5.2 Update the MVP success criterion line "App size <50MB" in
  `doc/implementation_plan.md` to met, citing the measured size
- [x] 5.3 Add a dated entry to `doc/design_progress.md` covering the decision,
  the device research (CDD §7.6.1, Chromebook translation, the last x86 phones),
  Flutter's ABI filter reset and the DataStore library, and the measured size
- [x] 5.4 Replace the estimated size in `proposal.md` (What Changes and Impact)
  and `design.md` (D1 and Risks) with the measured figure from 2.2
- [x] 5.5 Check `README.md` and `CONTRIBUTING.md` for statements about the APK's
  contents or supported devices, and update any that are no longer accurate

## 6. After merge

- [x] 6.1 On the next `v*` release, confirm the attached APK passes
  `dart run tool/verify_apk_abis.dart`, its size matches 2.2, it is still the only APK
  asset, and `apksigner` still reports the app signing certificate
