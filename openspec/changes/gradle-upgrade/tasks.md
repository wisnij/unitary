## 1. Build configuration

- [x] 1.1 In `android/gradle/wrapper/gradle-wrapper.properties`, change the
  `distributionUrl` from `gradle-8.14-all.zip` to `gradle-9.3.1-all.zip`
- [x] 1.2 In `android/settings.gradle.kts`, set `com.android.application` to
  version 9.0.1 and `org.jetbrains.kotlin.android` to version 2.3.20
- [x] 1.3 In `android/app/build.gradle.kts`, remove the `kotlinOptions` block
  from the `android` block and add a top-level
  `kotlin { compilerOptions { jvmTarget = JvmTarget.JVM_17 } }` block
- [x] 1.4 Confirm `android/gradle.properties` is unchanged (the
  `android.builtInKotlin=false` and `android.newDsl=false` flags stay)

## 2. CI

- [x] 2.1 In `.github/actions/test/action.yml`, set the `actions/setup-java@v5`
  step to Temurin 21 and update its comment to describe the upgraded toolchain
- [x] 2.2 In `.github/workflows/ci.yml`, set the same step to Temurin 21 in
  `build-android-test` and `build-android-release`, with the same comment update
- [x] 2.3 Confirm no other job runs a Gradle build

## 3. Local verification

- [ ] 3.1 Run `flutter clean`, then `flutter test --reporter failures-only` and
  `flutter analyze`
- [ ] 3.2 Build the debug APK and confirm the output has no warning about
  Gradle, Android Gradle Plugin, or Kotlin version support
- [ ] 3.3 Build the profile APK (the variant `tool/take_screenshots.sh` uses)
- [ ] 3.4 Build the release APK with
  `--target-platform android-arm,android-arm64` and run
  `dart run tool/verify_apk_abis.dart` on it
- [ ] 3.5 Build the release app bundle and run
  `dart run tool/verify_apk_abis.dart` on it
- [ ] 3.6 With `aapt2 dump badging`, compare the release APK with the published
  v0.9.11 APK: same application ID, `minSdk`, `targetSdk`, and permissions, and
  the version code that `pubspec.yaml` records
- [ ] 3.7 Run `tool/run_integration_tests.sh` against the local x86_64 emulator
- [ ] 3.8 Install the release APK on a real device over the existing install and
  confirm the app starts and keeps its data
- [ ] 3.9 Run the pre-commit hooks on the changed files

## 4. Documentation

- [ ] 4.1 Add a dated entry to `doc/design_progress.md` describing the failure,
  its cause, the upgrade, and the JDK selection in CI
- [ ] 4.2 Update `doc/implementation_plan.md` where it describes the release
  pipeline or toolchain, if anything there is now out of date
- [ ] 4.3 Check `README.md`, `CONTRIBUTING.md`, and `doc/best_practices.md` for
  statements about the JDK or Gradle that need a change

## 5. CI verification and release

- [ ] 5.1 Push the branch and confirm `lint`, `test`, and `build-android-test`
  pass on the Ubuntu 26.04 runner image, with the JDK setup step reporting
  Temurin 21
- [ ] 5.2 Merge to `main` and confirm the `main` run passes, including
  `deploy-site`
- [ ] 5.3 Cut the release again (move the `v0.9.12` tag or release 0.9.13) and
  confirm `build-android-release` passes both signature checks and the release
  is published with the APK and the web archive
