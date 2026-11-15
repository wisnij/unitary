## ADDED Requirements

### Requirement: The Android build uses a supported toolchain

The project SHALL build with Gradle 9.3.1, Android Gradle Plugin 9.0.1, and
Kotlin Gradle Plugin 2.3.20.  These versions SHALL be ones that the Flutter
version pinned in CI lists as supported.  The app's JVM target SHALL remain 17
for both Java and Kotlin compilation.

#### Scenario: The wrapper names the Gradle version

- **WHEN** `android/gradle/wrapper/gradle-wrapper.properties` is read
- **THEN** its `distributionUrl` names the Gradle 9.3.1 distribution

#### Scenario: The settings file names the plugin versions

- **WHEN** `android/settings.gradle.kts` is read
- **THEN** it declares `com.android.application` at version 9.0.1 and
  `org.jetbrains.kotlin.android` at version 2.3.20

#### Scenario: A build raises no toolchain version warning

- **WHEN** `flutter build apk` runs with the Flutter version pinned in CI
- **THEN** the output contains no warning that Flutter support for the
  project's Gradle, Android Gradle Plugin, or Kotlin version will be dropped

#### Scenario: Every build variant builds

- **WHEN** the debug APK, the profile APK, the release APK, and the release app
  bundle are built
- **THEN** each build succeeds

### Requirement: CI selects the JDK explicitly

Every CI job that runs a Gradle build SHALL set up a named JDK distribution and
major version before building, and SHALL NOT depend on the JDK that the runner
image provides by default.  All such jobs SHALL use the same JDK major version.

#### Scenario: The integration tests build with the selected JDK

- **WHEN** the shared test action runs
- **THEN** a JDK setup step naming the distribution and major version runs
  before the Android integration tests

#### Scenario: The Android build jobs build with the selected JDK

- **WHEN** `build-android-test` or `build-android-release` runs
- **THEN** a JDK setup step naming the same distribution and major version runs
  before any `flutter build` step

#### Scenario: The runner image's default JDK changes

- **WHEN** the runner image's default JDK is a version that the project's
  Gradle cannot run on
- **THEN** the Android builds in CI still succeed, because they run on the
  selected JDK

### Requirement: The toolchain upgrade leaves the artifacts unchanged

Upgrading the build toolchain SHALL NOT change what the release artifacts
contain.  The release APK and the app bundle SHALL keep the version code derived
from `pubspec.yaml`, the native-library layout that `tool/verify_apk_abis.dart`
checks, the application ID, the minimum and target SDK levels, and the set of
declared permissions.

#### Scenario: The release artifacts pass the ABI check

- **WHEN** the release APK and the app bundle are built with the upgraded
  toolchain
- **THEN** `tool/verify_apk_abis.dart` accepts both

#### Scenario: The manifest values match the previous release

- **WHEN** the release APK built with the upgraded toolchain is compared with
  the last APK published before the upgrade
- **THEN** the application ID, minimum SDK level, target SDK level, and declared
  permissions are the same, and the version code is the one `pubspec.yaml`
  records

#### Scenario: The debug build runs on the x86_64 emulator

- **WHEN** the integration test suite runs on an x86_64 emulator
- **THEN** the debug build installs and every integration test passes
