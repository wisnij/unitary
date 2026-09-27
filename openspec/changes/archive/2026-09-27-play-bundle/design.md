## Context

The release pipeline in `.github/workflows/ci.yml` runs `prepare`, then the two
Android build jobs and `build-web`, then `release` on tags.  The Android jobs
build only an APK:

- `build-android-apk-test` runs on non-tag events.  It has no environment, so
  there is no `key.properties`, the release build type falls back to the debug
  key, and its artifact is never published.
- `build-android-apk-release` runs on `v*` tags in the `release` environment.
  It writes `android/key.properties` for the app signing key, builds the APK,
  checks the signer fingerprint against `ANDROID_APP_CERT_SHA256`, checks the
  ABI layout with `tool/verify_apk_abis.dart`, removes the signing material,
  and uploads the APK for the `release` job to attach.

The `release-signing` change already settled the signing model and left this
change's inputs in place:

- Two keys in separate PKCS12 keystores: the app signing key (signs the GitHub
  APK and will be enrolled with Play) and the upload key (authenticates uploads
  to Play).
- Its design D3: one Gradle signing config, with CI rewriting `key.properties`
  before each build step, so the app key signs the APK and the upload key signs
  the bundle.
- `ANDROID_UPLOAD_KEYSTORE_B64`, `ANDROID_UPLOAD_KEYSTORE_PASSWORD`, and
  `ANDROID_UPLOAD_KEY_ALIAS` are secrets on the `release` environment, and
  `ANDROID_UPLOAD_CERT_SHA256` is a variable there.  Nothing reads them yet.

Facts established by building a release bundle locally for this proposal
(`flutter build appbundle --release`, 37.7 MB, signed with the app key because
that is what the local `key.properties` names):

- Native libraries sit under `base/lib/<abi>/`, not `lib/<abi>/`.  The bundle
  held exactly `arm64-v8a` and `armeabi-v7a`, each with `libapp.so`,
  `libflutter.so`, and DataStore's `libdatastore_shared_counter.so`.  The
  release-only x86_64 packaging exclusion in `android/app/build.gradle.kts`
  applies to bundles as well as APKs, so no Gradle change is needed.
- Bundles are JAR-signed (`META-INF/*.SF`, `META-INF/*.RSA`), so `apksigner`
  cannot check them.  `keytool -printcert -jarfile` prints the signer
  certificate with an uppercase, colon-separated SHA-256 fingerprint.  It exits
  1 when a signed entry has been altered (tested by modifying the manifest after
  signing), but prints `Not a signed jar file` and exits **0** for an unsigned
  bundle.
- `jarsigner -verify` exits 0 for the valid bundle and 1 for the altered one.
  With `-strict` it exits 4 for the valid bundle, because the certificate is
  self-signed and the signature has no timestamp, neither of which matters to
  Android.
- Every native library's ELF `LOAD` segments are aligned to at least 16 KB
  (0x4000 or 0x10000), which Play requires of apps targeting Android 15 or
  later.  Play checks this itself at upload, so this change does not add a
  check for it.

A stale local Gradle cache after the September 26 dependency update made the
first local build fail to compile `GeneratedPluginRegistrant.java`.  `flutter
clean` fixed it, and CI was unaffected.

## Goals / Non-Goals

**Goals:**

- Every tag build produces a Play-ready bundle signed with the upload key.
- A wrong-key, debug-signed, unsigned, or corrupted bundle fails the job before
  anything is uploaded, as the APK already does.
- The bundle's ABI layout is checked with the same rules as the APK's.
- Bundle build failures surface on pull requests, not first on a tag.
- The bundle is easy to find and download when it is time to upload it.

**Non-Goals:**

- Play App Signing enrolment and the first upload.  Both are manual Console
  steps, listed in section 6 of the `release-signing` change.
- Uploading to Play from CI.  The first uploads are deliberately manual so the
  Console's warnings and pre-launch reports are seen; automation can come later.
- Checking the bundle's version code in CI.  The APK's is not checked in CI
  either; Play rejects a duplicate code on upload, and the build reads the same
  `pubspec.yaml` for both artifacts.
- Store listing assets and declarations.

## Decisions

### D1: Build the bundle in the same job as the APK

Each Android job builds both artifacts, one after the other.  The alternative
was a separate bundle job alongside each APK job.

A separate job would repeat the Flutter setup, `pub get`, and a cold Gradle
build, adding several minutes to every run.  In the same job, the bundle build
reuses the APK build's compiled output; locally it took about 45 seconds.

A separate job would also keep the two keystores on different runners.  That
isolation is not real: both keys' secrets are on the same `release`
environment, so any tag job can already read both.  Separating them properly
would need a second environment, which `release-signing` D2 did not call for
and this change does not either.

Because each job now builds both artifacts, the jobs are renamed
`build-android-test` and `build-android-release`.  The environment's tag rule is
attached to the environment, not to a job name, so the rename does not affect
access to the keys.

### D2: Order of steps in the tag job

1. Write `key.properties` for the app key; build the APK; check its signer
   against `ANDROID_APP_CERT_SHA256`; check its ABI layout.
2. Write `key.properties` for the upload key, replacing the file; build the
   bundle; check its signer against `ANDROID_UPLOAD_CERT_SHA256`; check its ABI
   layout.
3. Always remove `key.properties` and both keystore files.
4. Upload both artifacts.

All checks come before any upload, so a failure in either artifact uploads
nothing.  Each signature is checked against its own expected fingerprint, so if
the second write were skipped, the bundle would be signed with the app key and
fail step 2's check.  That covers the one mistake this ordering makes likely.

Both keystores are decoded to `RUNNER_TEMP` under their own names, as the app
keystore already is.  The upload keystore is written only when step 2 begins,
which keeps the two write steps symmetrical and each easy to read on its own.

### D3: Check the bundle signature with `keytool -printcert -jarfile`

The step runs `keytool -printcert -jarfile` and requires all of the following:

- a zero exit status, which rules out a bundle whose signed entries were
  altered;
- exactly one `Signer #` block, which rules out an unsigned bundle (keytool
  exits 0 for those) and a bundle with several signers;
- a SHA-256 fingerprint equal to `ANDROID_UPLOAD_CERT_SHA256` once both are
  lowercased and stripped of colons.

Alternatives considered:

- `apksigner`: handles APKs only.
- `jarsigner -verify`: adds nothing over keytool's exit status, needs parsing
  of a different output format for the fingerprint, and `-strict` rejects every
  valid bundle this project will produce (self-signed, no timestamp).  It is
  also not guaranteed to be on `PATH`, while `keytool` is.
- `bundletool`: would have to be downloaded on every run.

The step is inline shell, like the existing APK signature step, rather than a
Dart tool.  It is about a dozen lines, and it is exercised before the change is
finished by running it locally against a correct bundle and the failing cases
the spec lists.

### D4: Extend `verify_apk_abis` to bundles, selecting the layout by extension

The tool decides where to look from the file name: `.aab` means native
libraries are under `base/lib/`; `.apk` means `lib/`.  Any other extension is a
usage error (exit 2).  The library functions take the root prefix as a
parameter, defaulting to `lib/`, so the existing APK tests and behaviour are
unchanged.

Alternatives considered:

- A `--bundle` flag: says the same thing the extension already says, and
  passing the wrong one would check the wrong directory and report every ABI
  as missing.
- Auto-detecting from the entries (for example, the presence of
  `BundleConfig.pb`): hides the decision in the tool; the extension is visible
  in the CI step.
- A separate tool: would duplicate the grouping and checking logic that is
  identical for both formats.

The tool keeps its name.  Renaming it to cover bundles would touch the CI
steps, the `release-apk-abis` spec's wording, and the docs for no functional
gain; its doc comments will say it accepts both formats.

### D5: Keep the bundle as a 90-day workflow artifact, not a release asset

The tag job uploads `unitary-<version>.aab` as a workflow artifact with
`retention-days: 90`, and the `release` job does not attach it.

- **Why not attach it to the GitHub release:** end users cannot install a
  bundle, and a second Android file beside the APK invites people to download
  the wrong one.  The bundle exists only to be uploaded to Play.
- **Why 90 days rather than 7, like the APK artifacts:** the APK artifact is
  only a hand-off to the `release` job, which publishes it permanently.  The
  bundle's workflow artifact *is* the copy that gets uploaded, possibly well
  after the tag while the closed test runs.  90 days is the maximum GitHub
  allows for a public repository by default.
- **The rehearsal bundle keeps 7 days,** like the rehearsal APK.

### D6: Keep the x86_64 exclusion for the bundle; never pass `--target-platform`

For Play, x86_64 in the bundle would cost users nothing, because Play delivers
only the split for the device's ABI.  Keeping x86_64 would let Play serve native
code to x86_64 devices instead of ARM code under translation.  It is still
excluded:

- The `apk-size` research found no device that can install Unitary and needs
  x86_64: the last x86 phones that meet `minSdk 24` also translate ARM, and
  every Android-capable Chromebook translates 32-bit ARM.
- One ABI set for both channels means one set of behaviour to reason about.
- The exclusion is keyed on the build type, which APKs and bundles share.
  Exempting bundles would need a second mechanism, such as a Gradle property
  passed only to the APK build.

The bundle build omits `--target-platform`, as the plan requires, because of
Flutter issue #192530.  Flutter therefore also compiles the x86_64 engine and
app snapshot, which the exclusion then drops.  That wastes some build time but
is harmless, and the layout check confirms the result either way.

## Risks / Trade-offs

**[A bundle signed with the wrong key reaches the first upload]** If the first
bundle were signed with the app signing key, Play could register that key as
the upload key too, undoing the separation `release-signing` D2 set up.  That is
recoverable, since an upload key can be reset through Play support, but slow.
The irreversible choice is the app signing key registered at enrolment, which is
a manual Console step.  → D3's check makes a wrong-key bundle fail CI, and
section 6 of `release-signing` covers the enrolment choice.

**[The repository caps artifact retention below 90 days]** A repository setting
limits `retention-days`, and a lower cap would silently shorten the bundle's
life.  → The tasks include confirming the setting.

**[The bundle artifact expires before it is uploaded]** → 90-day retention.
After that, the bundle can be rebuilt from the tag with the upload key.  A local
rebuild must point `key.properties` at the upload keystore first, because the
local file names the app key.

**[The rehearsal cannot catch key-switching mistakes]** The rehearsal job has no
keys, so it exercises the build and the layout check but not the signature
steps.  → The same holds for the APK today.  D3's check fails the tag job
before anything is uploaded, and a failed tag job can be fixed and re-run.

**[Both keystores are decoded on the same runner]** → Accepted in D1: both are
already readable from the same environment.  Both files are removed in an
`always()` step, as the app keystore is today.

**[Tooling output formats change]** keytool's `Signer #` and `SHA256:` lines
are what the check parses.  → A format change makes the check fail, not pass,
because it requires one signer and a matching fingerprint.

## Migration Plan

1. Extend the ABI tool with tests; update the workflow.
2. Open a pull request: the rehearsal job builds and checks a debug-signed
   bundle.
3. Cut the next `0.9.x` tag: the release job builds both artifacts, both
   signature checks pass, and the GitHub release is unchanged.
4. Download the bundle artifact for the first Play upload (manual, outside this
   change).

Rollback: revert the workflow and tool changes.  Nothing is published
differently, so there is nothing to undo elsewhere.

## Open Questions

None.
