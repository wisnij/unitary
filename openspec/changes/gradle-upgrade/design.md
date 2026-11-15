## Context

The Android build uses Gradle 8.14, Android Gradle Plugin (AGP) 8.11.1, and
Kotlin Gradle Plugin (KGP) 2.2.20.  CI builds on `ubuntu-latest` with Flutter
`3.44.x` and has never selected a JDK.

GitHub is moving `ubuntu-latest` from Ubuntu 24.04 to Ubuntu 26.04 between
October 19 and November 19, 2026
([actions/runner-images#14748](https://github.com/actions/runner-images/issues/14748)).
The default JDK changes from 17.0.20 to 25.0.5.  Gradle 8.14 supports running on
Java 24 at most; Java 25 needs Gradle 9.1 or later.  The v0.9.12 runs on
November 15 were the first for this repository on the new image, and both failed
at the first Gradle build with `What went wrong: 25.0.5`.

Independently, the local Flutter (3.47.2) warns on every build that it will soon
drop support for AGP 8.11.1 (it asks for 9.0.1 or later) and for Kotlin 2.2.20
(it asks for 2.3.20 or later).

Both upgrade levels were tried in a scratch copy of the repository on November
14, 2026, with Flutter 3.47.2 and JDK 21:

- Gradle 9.3.1 alone: debug APK, release APK, and bundle all built, and both
  release artifacts passed `tool/verify_apk_abis.dart`.
- Gradle 9.3.1, AGP 9.0.1, and KGP 2.3.20: the first build failed because Kotlin
  2.3 turns the deprecated `kotlinOptions { jvmTarget }` setting into an error.
  After that block was replaced with `kotlin { compilerOptions { jvmTarget } }`,
  the same three builds passed with the same ABI check results.  The x86_64
  packaging exclusion and the signing configuration needed no change.

Constraints:

- The versions must be supported by Flutter 3.44, which CI pins, and by Flutter
  3.47, which is used locally.
- The artifacts must keep meeting the `release-apk-abis`, `release-bundle`, and
  `version-code` specs.
- The debug build must still run on the x86_64 emulator for the integration
  tests.

## Goals / Non-Goals

**Goals:**

- Release builds succeed in CI on the Ubuntu 26.04 runner image.
- A future change of the runner image's default JDK cannot break the build.
- The build tool versions are ones that both Flutter versions in use support
  without a deprecation warning.

**Non-Goals:**

- Migrating to AGP's built-in Kotlin support.  Flutter warns that applying the
  Kotlin plugin directly "will cause build failures in future versions", so
  this is needed eventually, but not for this fix.  The
  `android.builtInKotlin=false` and `android.newDsl=false` flags that Flutter's
  migrator added to `android/gradle.properties` stay as they are.
- Changing the Flutter version that CI pins.
- Changing `compileSdk`, `targetSdk`, `minSdk`, or the JVM target of the app.
- Pinning the runner image (`runs-on: ubuntu-24.04`).

## Decisions

### Gradle 9.3.1

Flutter 3.44 and 3.47 both list 9.3.1 as the highest Gradle version they know
and support, and Flutter 3.47 uses it in new projects.  It runs on Java 25.  It
is also the minimum for AGP 9.1, so a later AGP upgrade will not need another
Gradle change.

Alternative: 9.1.0, the minimum for Java 25 and the Flutter 3.44 template
default.  Rejected because it gains nothing over 9.3.1 and would have to change
again for AGP 9.1.

### AGP 9.0.1 and KGP 2.3.20

These are the versions the Flutter 3.44 project template uses, and the highest
that Flutter 3.44 lists as fully supported (`maxKnownAgpVersionWithFullKotlinSupport`
is 9.0.1 and `maxKnownAndSupportedKgpVersion` is 2.3.20).  They are also exactly
the minimums that Flutter 3.47's warnings ask for, so they satisfy both Flutter
versions.

Alternative: AGP 9.1.0 and KGP 2.4.0, the Flutter 3.47 template versions.
Rejected because Flutter 3.44 does not list them as supported, and CI builds
with 3.44.

Alternative: upgrade Gradle only.  It fixes the release failure, but leaves the
deprecation warnings and a second toolchain change to do before Flutter drops
support.  One tested change is less work than two.

### Kotlin compiler options

`kotlinOptions { jvmTarget = ... }` inside the `android` block is removed, and a
top-level block is added to `android/app/build.gradle.kts`:

```kotlin
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
```

This is the replacement the Kotlin error message names.  The target stays 17, to
match `compileOptions`.

### CI selects JDK 21 explicitly

Each job that runs Gradle gets an `actions/setup-java@v5` step with
`distribution: temurin` and `java-version: '21'`, before the Flutter setup step.
There are three places: `.github/actions/test/action.yml` (the integration
tests build a debug APK), `build-android-test`, and `build-android-release`.

JDK 21 is a long-term-support release, it is the version on the development
machine, and it is the version the trial builds ran on.  CI and local builds
then use the same major version.

Alternative: JDK 17, the old image's default.  It works, but it is the oldest
version AGP accepts, and nothing requires staying on it.

Alternative: no explicit JDK, relying on Gradle 9.3.1 running on the image's
Java 25.  Rejected: the image default changing without notice is what caused
this failure, and nothing here has been tested on Java 25.

Alternative: JDK 25.  Not tested locally, since no JDK 25 is installed.  It can
be adopted later by changing one number in three places.

Jobs that never run Gradle (`lint`, `build-web`, `build-site`, `deploy-site`,
`release`, `prepare`) get no JDK step.

## Risks / Trade-offs

- [Flutter 3.44 in CI behaves differently from the 3.47.2 used in the trial] →
  Flutter 3.44's compatibility table lists all three versions as supported.  The
  change is pushed on a branch first, where `test` and `build-android-test` run
  the debug build, the integration tests, and a rehearsal of both release
  artifacts before anything is tagged.
- [The trial only built the app; it did not run it] → Run the integration suite
  on the local emulator, and install the release APK on a device, before
  merging.
- [A plugin's Android code fails under AGP 9 on some path the trial did not
  build] → The trial built debug and release variants of every plugin in use
  (`shared_preferences_android`, `package_info_plus`, `url_launcher_android`,
  `integration_test`).  The profile variant, used by the screenshot tool, is
  built in the verification tasks.
- [The artifacts change in a way the specs forbid] → The CI jobs already check
  the ABI layout and, on a tag, both signatures.  The verification tasks also
  compare the version code and the permission list with the v0.9.11 APK.
- [The release build is signed correctly locally but the tag job's signing path
  breaks] → `build-android-release` runs only on tags, so its signing steps are
  first exercised by the re-cut release.  A failure there publishes nothing,
  because every check runs before any upload.
- [Stale local Gradle caches make the first local build fail] → `flutter clean`,
  as after the September 26 dependency update.
- [The "applies the Kotlin Gradle Plugin" warning remains] → Accepted; see
  Non-Goals.

## Migration Plan

1. Make the changes on a branch and verify locally (builds, ABI checks,
   integration tests, device install).
2. Push the branch and confirm that `test` and `build-android-test` pass on the
   Ubuntu 26.04 image.
3. Merge to `main`.
4. Cut the release again.  The `v0.9.12` tag points at a commit that cannot
   build, so either move the tag or release as 0.9.13.

Rollback: revert the commit.  The JDK step alone is enough to build the old
toolchain on the new image (JDK 17 or 21 both run Gradle 8.14), so the step
should be kept even if the upgrade is reverted.

## Open Questions

- Move the `v0.9.12` tag, or release the fix as 0.9.13?  No v0.9.12 artifact was
  published, so either is safe.
