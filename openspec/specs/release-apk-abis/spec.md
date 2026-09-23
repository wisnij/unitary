# Release APK ABIs

## Purpose

Defines which native ABIs the APK published with each GitHub release carries:
exactly `arm64-v8a` and `armeabi-v7a`, with no `x86_64`, as a single asset.  Also
requires that no ABI directory in it is partial (each holds the Flutter engine
and the app's AOT snapshot), that the restriction applies only to release builds,
that it leaves the version code untouched, and that every CI job building a
release APK verifies the layout before uploading it.

## Requirements

### Requirement: The release APK carries exactly the two ARM ABIs

The APK published with each GitHub release SHALL contain native libraries for
exactly two ABIs, `armeabi-v7a` and `arm64-v8a`, and SHALL contain no entries
under `lib/x86_64/`.  This applies to libraries contributed by dependencies as
well as to Flutter's own.  The release SHALL continue to publish this as a
single APK asset named `unitary-<version>.apk`.

#### Scenario: The release APK's native library directories

- **WHEN** the release APK's entries under `lib/` are listed
- **THEN** the ABI directories present are exactly `arm64-v8a` and
  `armeabi-v7a`

#### Scenario: Dependency libraries are excluded for x86_64

- **WHEN** a dependency contributes a native library for x86_64, as androidx
  DataStore does with `libdatastore_shared_counter.so`
- **THEN** the release APK contains no `lib/x86_64/` entry for it

#### Scenario: One APK per release

- **WHEN** a `v*` tag is released
- **THEN** exactly one APK asset, named `unitary-<version>.apk`, is attached to
  the GitHub release

#### Scenario: The release APK runs on an x86_64 device with ARM translation

- **WHEN** the release APK is installed on an x86_64 Android emulator image that
  translates ARM code
- **THEN** the installation succeeds and the app launches to its first screen

### Requirement: No ABI directory in the release APK is partial

Every ABI directory under `lib/` in the release APK SHALL contain both
`libflutter.so` and `libapp.so`.  A directory holding some native libraries but
not the Flutter engine SHALL NOT be present, because the package manager would
select that ABI and the app would crash on launch instead of the device falling
back to another ABI.

#### Scenario: Each ABI directory contains the Flutter engine

- **WHEN** the release APK's `arm64-v8a` and `armeabi-v7a` directories are
  inspected
- **THEN** each contains `libflutter.so` and `libapp.so`

### Requirement: The ABI restriction applies only to release builds

The x86_64 exclusion SHALL apply only to the `release` build type.  `debug` and
`profile` builds SHALL keep building for x86_64, so that the integration suite on
the x86_64 emulator and local development on x86_64 emulators continue to work.

#### Scenario: A debug build for an x86_64 emulator

- **WHEN** a debug APK is built for an x86_64 emulator
- **THEN** it contains `lib/x86_64/libflutter.so`

#### Scenario: A profile build

- **WHEN** a profile APK is built with `flutter build apk --profile`
- **THEN** it contains `lib/x86_64/libflutter.so`

#### Scenario: The integration suite still runs

- **WHEN** the integration suite runs on the x86_64 emulator in CI
- **THEN** it builds, installs, and runs as it did before this change

### Requirement: The ABI configuration does not alter the version code

Restricting the release APK's ABIs SHALL NOT change its version code.  The
built APK SHALL report the version code recorded in `pubspec.yaml`, with no
per-ABI offset applied.

#### Scenario: The built APK reports the pubspec version code

- **WHEN** a release APK is built from a `pubspec.yaml` recording `X.Y.Z+CODE`
- **THEN** `aapt2 dump badging` reports `versionCode='CODE'`

### Requirement: APK builds verify the native library layout

Every CI job that builds a release APK SHALL verify the built APK's native
library layout against the two requirements above.  The job SHALL fail when
verification fails, and SHALL do so before it uploads its artifact.  This
applies to the rehearsal job as well as the tag job, since both upload one.  Verification SHALL compare the full set of ABI
directories against the expected set, not only check that `x86_64` is absent,
so that a partial directory for any other ABI is also caught.

#### Scenario: A correctly built APK passes

- **WHEN** a job builds a release APK containing complete `arm64-v8a` and
  `armeabi-v7a` directories and nothing else under `lib/`
- **THEN** verification passes and the job proceeds

#### Scenario: An unexpected ABI directory fails the job

- **WHEN** the built APK contains any ABI directory other than `arm64-v8a` and
  `armeabi-v7a`, such as `x86_64` or `x86`
- **THEN** verification fails and the job fails without uploading an artifact

#### Scenario: A missing engine library fails the job

- **WHEN** either expected ABI directory lacks `libflutter.so` or `libapp.so`
- **THEN** verification fails and the job fails without uploading an artifact

#### Scenario: Non-tag builds are verified too

- **WHEN** the workflow runs for a pull request or an ordinary branch push
- **THEN** the rehearsal APK job builds with the same ABI configuration and runs
  the same verification
