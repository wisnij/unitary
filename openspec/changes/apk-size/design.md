## Context

Every GitHub release attaches one APK, built by `.github/workflows/ci.yml`:
`build-android-apk-release` on `v*` tags (signed with the app signing key) and
`build-android-apk-test` on every other push and pull request (debug-signed,
never published).  Both run a plain `flutter build apk --release`.

Current state, verified rather than assumed:

- The v0.9.8 asset is 56,433,241 bytes (53.8 MiB).  Its native libraries make
  up 97.7% of the file: `arm64-v8a` 17.7 MB, `armeabi-v7a` 15.6 MB, `x86_64`
  19.1 MB, and 1.2 MB of everything else.
- Native libraries are stored uncompressed with `extractNativeLibs=false` (the
  AGP default at `minSdk 24`; nothing in `AndroidManifest.xml` sets it).  They
  are loaded in place from the installed APK, so the device stores the whole
  file, including slices it cannot run.
- `android/` contains no `abiFilters`, `splits`, or `packaging` configuration.
- The Flutter Gradle plugin sets ABI filters itself.  In a build without
  `--split-per-abi`, `configureAbiWithoutSplits` (`FlutterPlugin.kt`, Flutter
  3.44) clears `defaultConfig.ndk.abiFilters` and refills it with all three
  default ABIs, whatever `--target-platform` was passed.
  `--target-platform` only controls which ABIs `libflutter.so` and `libapp.so`
  are compiled for.
- The project has a dependency that contributes native code:
  `shared_preferences_android` depends on androidx DataStore, which bundles
  `libdatastore_shared_counter.so` for all three ABIs.  A local release build
  made with `--target-platform android-arm64` (September 6) contains
  `lib/x86_64/libdatastore_shared_counter.so` and
  `lib/armeabi-v7a/libdatastore_shared_counter.so`, with no engine in either
  directory.
- The integration suite (`tool/run_integration_tests.sh`) runs
  `flutter test integration_test/...` on an x86_64 emulator, which builds a
  **debug** APK for that emulator.  It never builds the release variant.

What is known about the devices involved (researched September 13, 2026):

- **x86_64.**  Intel cancelled its phone chips in 2016.  The last x86 phones
  came out in 2017–2018 on the Spreadtrum SC9853i (Intel Airmont), for example
  the Leagoo T5c on Android 7.0, which does meet `minSdk 24`.  Device-info apps
  report that phone as also supporting `arm64-v8a` and `armeabi-v7a`, meaning it
  translates ARM code.  Other x86_64 Android today is emulators, Chromebooks,
  and hobbyist PC ports.  ChromeOS's developer documentation says every
  Android-capable Chromebook translates 32-bit ARM, but not every x86 Chromebook
  translates 64-bit ARM.
- **armeabi-v7a.**  This is still a current ABI, not only an old one.  The
  Android 16 CDD, §7.6.1, requires devices with under 2 GB RAM to support a
  single ABI (32-bit only or 64-bit only), and strongly recommends 32-bit-only
  userspace for devices with 2 GB to under 4 GB.  The Android 14 and 15 CDDs say
  the same.  Such devices are sold new, often on 64-bit chips.
- **ABI selection at install.**  The package manager uses the device's preferred
  ABI when the APK contains libraries under `lib/<preferred-abi>/`, and falls
  back to a secondary ABI only when it finds none there.  A partial directory is
  therefore worse than no directory: Flutter issue #192530 describes x86_64 and
  32-bit devices crashing on launch after being given native code with no
  `libflutter.so`.

## Goals / Non-Goals

**Goals:**

- The GitHub release APK installs and runs on every phone and tablet that meets
  `minSdk 24`, including 32-bit-only devices, with no choice of file needed.
- Nothing in the APK serves a device that cannot install Unitary.
- No ABI directory in the APK is partial, now or after a dependency changes.
- Debug builds, the x86_64 emulator integration suite, and the version code are
  unaffected.
- The published layout is checked mechanically on every build, not only on
  tags.

**Non-Goals:**

- Making the APK as small as possible.  The two-ABI fat APK deliberately stores
  about 16–18 MB a given device cannot run, in exchange for one file that
  installs everywhere.
- The Play app bundle (Phase 10 task 7).  Play splits bundles per device itself.
- Shrinking `libapp.so` with `--split-debug-info` or `--obfuscate`.
- Native x86_64 support on devices without ARM translation.

## Decisions

### D1: One fat APK with both ARM ABIs

On-disk cost is what matters here, not download size, because the whole APK is
kept on the device:

| Option | Assets | Stored on arm64 device | Stored on 32-bit device | Installs on 32-bit-only devices | Version-code impact |
|---|---|---|---|---|---|
| Status quo (3 ABIs) | 1 | 53.8 MB | 53.8 MB | Yes | None |
| **Both ARM ABIs (chosen)** | **1** | **35.1 MB** | **35.1 MB** | **Yes** | **None** |
| arm64 only | 1 | ~18.9 MB | n/a | No | None |
| `--split-per-abi`, ARM only | 2 | ~18.9 MB | ~16.8 MB | Yes, with the right file | Offset added |

The chosen figure is measured: a local release build is 36,785,016 bytes
(35.1 MB), against 57,146,011 bytes (54.5 MB) for the same commit with all
three ABIs.  The other rows are estimates from the v0.9.8 slice sizes.

- **arm64 only** was rejected because it leaves out current Android Go phones
  and tablets running 32-bit-only userspace, plus x86 Chromebooks that translate
  32-bit ARM but not 64-bit ARM.  The owners of those devices are the least
  likely to know why the app won't install, since the device's chip is
  advertised as 64-bit.
- **`--split-per-abi`** was rejected for two reasons.  First, users must pick the
  right file.  The devices that most need the smaller 32-bit file are the ones
  that look 64-bit, so their owners are the most likely to pick wrong.  Second,
  Flutter overrides each split's version code with `abiIndex × 1000 +
  versionCode` (`armeabi-v7a` = 1, `arm64-v8a` = 2, `x86_64` = 4).  That lands
  in the MINOR component of the `version-code` scheme: the arm64 split of
  1.0.0 would carry 1.2.0's code.  The override can be turned off with
  `-Pforce-version-code-ignoring-abi=true`, but a later switch between split and
  non-split layouts could make an update look like a downgrade to Android.  A
  fat APK never triggers the override.
- **Status quo** was rejected because x86_64 costs every device 19.1 MB and
  helps no phone or tablet that can install Unitary.

### D2: Exclude x86_64 at packaging, on the release variant only

Add a release-only exclusion through AGP's variant API in
`android/app/build.gradle.kts`:

```kotlin
androidComponents {
    onVariants(selector().withBuildType("release")) { variant ->
        variant.packaging.jniLibs.excludes.add("**/x86_64/**")
    }
}
```

Packaging runs last, after Flutter's filter reset, so the reset cannot undo the
exclusion.  The exclusion also covers every library under `lib/x86_64/`, whether
from Flutter or from a dependency.  Scoping it to `release` leaves `debug` and
`profile` alone, so the emulator integration suite and on-device profiling keep
working.

The pattern is written `**/x86_64/**` rather than `lib/x86_64/**`.  AGP's
documentation doesn't say whether `jniLibs` patterns are matched against the
full path inside the APK or a path relative to `lib/`, and its only example has
the form `**/exclude.so`.  A leading `**/` matches either way.  `jniLibs`
patterns only apply to native libraries, so the broader pattern can't catch
anything else.  A local release build confirms the pattern works: it removes
DataStore's x86_64 library along with Flutter's.  D4's check guards it from
then on.

Alternatives considered:

- **`--target-platform android-arm,android-arm64` alone.**  Rejected.  It
  leaves a partial `lib/x86_64/` containing DataStore's library, and x86_64
  devices would select that ABI and crash instead of translating ARM (see
  Context).
- **`ndk.abiFilters` on the `release` build type.**  This is the standard
  approach, but it fights Flutter's filter reset.  Flutter's code comment says
  user filters take precedence, but the code clears `defaultConfig`'s filters,
  and whether AGP intersects or merges build-type filters with them isn't
  confirmed.  A packaging exclusion doesn't depend on either.
- **`-Pdisable-abi-filtering=true` plus our own filters.**  Rejected.  It
  replaces Flutter's filtering with ours, so we would have to keep it right
  across Flutter upgrades.
- **A static `packaging { jniLibs { excludes } }` block.**  Rejected.  That block
  applies to every build type and would remove x86_64 from the debug build the
  integration suite runs on.

### D3: Both APK jobs pass `--target-platform android-arm,android-arm64`

The packaging exclusion decides what ships.  The flag only avoids compiling an
x86_64 engine and `libapp.so` that would be discarded.  It goes on both jobs so
`build-android-apk-test` rehearses exactly what `build-android-apk-release`
publishes, and a layout problem shows up on a pull request instead of at a tag.
Without the flag the result would be the same, just slower to build.

### D4: A tested Dart tool verifies the ABI layout in both jobs

Add `tool/verify_apk_abis.dart`, called by both APK jobs right after the build.
In the release job it runs next to the signing-certificate check, before the
signing-material cleanup and the upload.  It fails unless:

- the set of ABI directories under `lib/` is exactly `arm64-v8a` and
  `armeabi-v7a`, and
- each of them contains `libflutter.so` and `libapp.so`.

The check pins the full expected set instead of just "no `x86_64`", so it also
catches a partial directory for an ABI nobody has thought about.  Examples:
32-bit `x86` libraries from a future dependency, or a Flutter upgrade that
changes its filtering.

It follows the project's tool convention.  The logic lives in
`tool/verify_apk_abis_lib.dart` as a pure function over the APK's entry names,
returning the problems it found, and is unit-tested in
`test/tool/verify_apk_abis_lib_test.dart`.  The executable only gets the entry
list, prints the result, and sets the exit code.  It gets the list by running
`unzip -Z1 <apk>`, which is available on GitHub-hosted Ubuntu runners, so no
dependency is added.  Both APK jobs already set up Flutter, so `dart run` is
available there.

Alternatives considered:

- **A shell script.**  Rejected.  The set comparison and partial-directory
  detection are real logic, and a shell script could only be checked by hand
  once.  The project's `.sh` tools only orchestrate other commands; every tool
  with logic is a Dart `_lib` with tests.
- **Reading the APK with `package:archive`.**  Rejected.  It would add a
  dependency to do what `unzip -Z1` already does.
- **Inline workflow YAML.**  Rejected.  Two jobs share the check, and it should
  be runnable against a local build.
- **Only inspect the tag build.**  Rejected.  A problem would surface only when
  cutting a release.

### D5: The version code is left alone

No per-ABI split is introduced, so Flutter's version-code override doesn't
apply, and `version-code` needs no change.  An `aapt2 dump badging` check during
implementation confirms the built APK still reports the pubspec code.

## Risks / Trade-offs

- **[Devices store unused code]** An arm64 device stores ~15.6 MB of 32-bit code
  it never runs, and a 32-bit device stores ~17.7 MB of arm64 code.  →
  Accepted in D1 in exchange for one file that installs everywhere.  This also
  hits the storage-constrained Go devices hardest, which is the main argument
  against D1 and is accepted knowingly.
- **[x86_64 devices without ARM translation can no longer install]** →
  None is known that meets `minSdk 24`.  x86 Chromebooks translate 32-bit ARM,
  which the APK includes.  The web app covers anyone else.
- **[The 32-bit translation path is untested locally]** The API 35 emulator
  image that verified the fallback translates 64-bit ARM only, so it showed an
  x86_64 device falling back to `arm64-v8a`, not to `armeabi-v7a`.  x86
  Chromebooks without 64-bit translation depend on the second.  → The package
  manager's fallback works the same way for either ABI, and ChromeOS documents
  32-bit translation on every Android-capable Chromebook.  Accepted without
  further testing.
- **[AGP API drift]** `androidComponents.onVariants` and
  `variant.packaging.jniLibs` are AGP 8 variant APIs.  → If they're renamed, the
  Gradle build fails with an error.  If the exclusion stops taking effect for
  some other reason, D4's check fails the job.
- **[The exclusion will probably reach the future AAB]** `flutter build
  appbundle` builds the same release variant.  → Left to Phase 10 task 7.  An
  ARM-only bundle looks harmless, since Play serves the ARM split to translating
  x86 devices, but that is for task 7 to confirm.  If it is wrong, that change
  narrows the selector.  It must also avoid `--target-platform` on bundle
  builds (Flutter issue #192530).
- **[Existing x86_64 installs of a three-ABI APK]** An update would change the
  installed app's native ABI from x86_64 to ARM under translation.  → Android
  allows the primary ABI to change on update, and the affected install base is
  effectively empty.  Not verified further.

## Migration Plan

Nothing to migrate.  The next `v*` tag after merge publishes the two-ABI APK
under the unchanged asset name.  Rollback is reverting the commit.  Earlier
releases keep their three-ABI APKs.
