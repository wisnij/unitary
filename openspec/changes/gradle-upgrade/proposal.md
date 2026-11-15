## Why

The v0.9.12 release failed in CI and published nothing.  GitHub moved the
`ubuntu-latest` runner label from Ubuntu 24.04 to Ubuntu 26.04, whose default
JDK is Java 25 instead of Java 17.  The project builds with Gradle 8.14, which
cannot run on Java 25, and the workflow never selected a JDK, so the first
Android build of the run stopped with only `25.0.5` as its error.

Two weaknesses are behind the failure.  The Android build toolchain is old
enough that Flutter 3.50, which the project now builds with, refuses it, and the
JDK that CI builds with is whatever the runner image ships.  This change fixes
both before 1.0.0, while a toolchain change can still be tested on 0.9.x
releases.

## What Changes

- Upgrade the Gradle wrapper from 8.14 to 9.5.0.
- Upgrade the Android Gradle Plugin from 8.11.1 to 9.3.1.
- Upgrade the Kotlin Gradle Plugin from 2.2.20 to 2.4.20.
- Replace the `kotlinOptions { jvmTarget }` block in
  `android/app/build.gradle.kts`, which Kotlin 2.3 and later reject, with the
  `kotlin { compilerOptions { jvmTarget } }` form.  The JVM target stays 17.
- Select the JDK explicitly (Temurin 21) in every CI job that builds for
  Android: the shared test action, `build-android-test`, and
  `build-android-release`.
- No change to the app's code, its behaviour, or the artifacts' contents: the
  same version code, ABIs, signing, and SDK levels.

## Capabilities

### New Capabilities

- `android-build-toolchain`: the versions of the Android build tools (Gradle,
  Android Gradle Plugin, Kotlin Gradle Plugin) the project builds with, and the
  rule that CI selects its JDK explicitly instead of using the runner image's
  default.

### Modified Capabilities

None.  The requirements of `release-apk-abis`, `release-bundle`, `version-code`,
and `integration-test-harness` are unchanged; this change must keep them
satisfied.

## Impact

- `android/gradle/wrapper/gradle-wrapper.properties`: Gradle version.
- `android/settings.gradle.kts`: plugin versions.
- `android/app/build.gradle.kts`: Kotlin compiler options.
- `.github/actions/test/action.yml` and `.github/workflows/ci.yml`: JDK setup
  step.
- Developer machines: the first build downloads Gradle 9.5.0, and a stale
  Gradle cache may need `flutter clean`.  Building needs JDK 17 or later, as
  before.
- This change depends on the move to Flutter 3.50 (the Material library
  migration), and that move depends on this change: Flutter 3.50 rejects
  Android Gradle Plugin versions below 9.1.1.  The two land together.
- No Dart code, runtime dependency, or test changes.
- The v0.9.12 release must be cut again after this change merges, because its
  tag points at a commit whose build fails.
