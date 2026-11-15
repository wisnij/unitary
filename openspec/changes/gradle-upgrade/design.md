## Context

The Android build used Gradle 8.14, Android Gradle Plugin (AGP) 8.11.1, and
Kotlin Gradle Plugin (KGP) 2.2.20, and CI never selected a JDK.  Two events made
that toolchain unusable.

GitHub is moving `ubuntu-latest` from Ubuntu 24.04 to Ubuntu 26.04 between
October 19 and November 19, 2026
([actions/runner-images#14748](https://github.com/actions/runner-images/issues/14748)).
The default JDK changes from 17.0.20 to 25.0.5.  Gradle 8.14 supports running on
Java 24 at most; Java 25 needs Gradle 9.1 or later.  The v0.9.12 runs on
November 15 were the first for this repository on the new image, and both failed
at the first Gradle build with `What went wrong: 25.0.5`.

The project also moved to Flutter 3.50 (the Material library migration, which
pins `3.50.x` in CI).  The Flutter Gradle plugin in 3.50 checks the build tool
versions and stops the build when one is too old:

| Tool | Build fails below | Build warns below | New-project template |
|------|-------------------|-------------------|----------------------|
| Gradle | 9.3.1 | 9.5.0 | 9.5.0 |
| AGP | 9.1.1 | 9.3.1 | 9.3.1 |
| KGP | 2.4.10 | 2.4.20 | 2.4.20 |
| Java | 17 | 17 | |

So Flutter 3.50 cannot build the old toolchain, and the old toolchain cannot run
on the new runner image.  The Flutter move and this change depend on each other
and land together.

Constraints:

- The artifacts must keep meeting the `release-apk-abis`, `release-bundle`, and
  `version-code` specs.
- The debug build must still run on the x86_64 emulator for the integration
  tests.

## Goals / Non-Goals

**Goals:**

- Release builds succeed in CI on the Ubuntu 26.04 runner image.
- A future change of the runner image's default JDK cannot break the build.
- The build tool versions are ones that Flutter 3.50 accepts without a
  deprecation warning.

**Non-Goals:**

- Migrating to AGP's built-in Kotlin support.  AGP 9 can compile Kotlin itself,
  without the separate `org.jetbrains.kotlin.android` plugin that this project
  applies.  Flutter warns that applying that plugin "will cause build failures
  in future versions", so the migration is needed eventually, but not for this
  fix.  The `android.builtInKotlin=false` and `android.newDsl=false` flags that
  Flutter's migrator added to `android/gradle.properties` stay as they are.
- Changing `compileSdk`, `targetSdk`, `minSdk`, or the JVM target of the app.
- Pinning the runner image (`runs-on: ubuntu-24.04`).

## Decisions

### Gradle 9.5.0, AGP 9.3.1, and KGP 2.4.20

These are the versions Flutter 3.50 uses in new projects, and the lowest that
build without a "support will soon be dropped" warning.  Gradle 9.5.0 runs on
Java 25.

Alternative: the minimums Flutter 3.50 accepts (Gradle 9.3.1, AGP 9.1.1, KGP
2.4.10).  A debug build with them passed, but with three warnings that support
will soon be dropped, so the next Flutter upgrade would force another toolchain
change.

Alternative: upgrade Gradle only.  Flutter 3.50 rejects AGP 8.11.1 and KGP
2.2.20, so this does not build.

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

Kotlin 2.3 and later turn the deprecated `kotlinOptions` setting into an error,
and this is the replacement the error message names.  The target stays 17, to
match `compileOptions`.

### CI selects JDK 21 explicitly

Each job that runs Gradle gets an `actions/setup-java@v6` step with
`distribution: temurin` and `java-version: '21'`, before the Flutter setup step.
There are three places: `.github/actions/test/action.yml` (the integration
tests build a debug APK), `build-android-test`, and `build-android-release`.

JDK 21 is a long-term-support release, it is the version on the development
machine, and it is the version every local verification build ran on.  CI and
local builds then use the same major version.

Alternative: JDK 17, the old image's default.  It works, but it is the oldest
version Flutter and AGP accept, and nothing requires staying on it.

Alternative: no explicit JDK, relying on Gradle 9.5.0 running on the image's
Java 25.  Rejected: the image default changing without notice is what caused
this failure, and nothing here has been tested on Java 25.

Alternative: JDK 25.  Not tested locally, since no JDK 25 is installed.  It can
be adopted later by changing one number in three places.

Jobs that never run Gradle (`lint`, `build-web`, `build-site`, `deploy-site`,
`release`, `prepare`) get no JDK step.

## Risks / Trade-offs

- [CI behaves differently from the development machine] → Both use Flutter 3.50
  and JDK 21.  The change is pushed on a branch first, where `test` and
  `build-android-test` run the debug build, the integration tests, and a
  rehearsal of both release artifacts before anything is tagged.
- [A plugin's Android code fails under AGP 9 in some build variant] → The
  debug, profile, and release variants were all built locally, which compiles
  every plugin in use (`shared_preferences_android`, `package_info_plus`,
  `url_launcher_android`, `integration_test`).
- [The artifacts change in a way the specs forbid] → The CI jobs already check
  the ABI layout and, on a tag, both signatures.  Locally, the release APK was
  compared with the published v0.9.11 APK: same application ID, SDK levels,
  permissions, ABIs, and signing certificate.
- [The release build is signed correctly locally but the tag job's signing path
  breaks] → `build-android-release` runs only on tags, so its signing steps are
  first exercised by the re-cut release.  A failure there publishes nothing,
  because every check runs before any upload.
- [Stale local Gradle caches make the first local build fail] → `flutter clean`,
  as after the September 26 dependency update.
- [The "applies the Kotlin Gradle Plugin" warning remains] → Accepted; see
  Non-Goals.

## Migration Plan

1. Make the changes on a branch that also carries the Flutter 3.50 move, and
   verify locally (builds, ABI checks, integration tests, device install).
2. Push the branch and confirm that `test` and `build-android-test` pass on the
   Ubuntu 26.04 image.
3. Merge to `main`.
4. Cut the release again.  The `v0.9.12` tag points at a commit that cannot
   build, so either move the tag or release as 0.9.13.

Rollback: revert both this change and the Flutter 3.50 move, and keep the JDK
step.  The step alone is enough to build the old toolchain on the new image
with Flutter 3.44, because JDK 21 runs Gradle 8.14.

## Open Questions

- Move the `v0.9.12` tag, or release the fix as 0.9.13?  No v0.9.12 artifact was
  published, so either is safe.
