## ADDED Requirements

### Requirement: Every release tag produces an app bundle

The workflow run for each `v*` tag SHALL build an Android App Bundle from the
same commit, build type, and version as the release APK, and SHALL keep it as a
workflow artifact named `unitary-<version>.aab`.  The bundle SHALL report the
same version code as the APK built in the same run.  The bundle SHALL be built
without `--target-platform`, because bundles built with it have been reported to
crash on the ABIs they leave out (Flutter issue #192530).

#### Scenario: A tag build keeps the bundle

- **WHEN** the workflow runs for a `v*` tag
- **THEN** its artifacts include `unitary-<version>.aab`, where `<version>` is
  the version the tag names

#### Scenario: The bundle carries the pubspec version code

- **WHEN** a bundle is built from a `pubspec.yaml` recording `X.Y.Z+CODE`
- **THEN** the version code in the bundle's manifest is `CODE`

### Requirement: The bundle is signed with the upload key and verified

The release bundle SHALL be signed with the upload key, not the app signing key.
The tag job SHALL check the bundle's signature before uploading it, and SHALL
fail without uploading when the signature does not verify, when the bundle is
unsigned, when it has more than one signer, or when the signer certificate's
SHA-256 fingerprint differs from the expected upload certificate fingerprint.
The comparison SHALL ignore case and colon separators, since tools print the
same fingerprint in different formats.

#### Scenario: A correctly signed bundle passes

- **WHEN** the tag job builds a bundle signed with the upload key
- **THEN** the check finds the expected upload certificate fingerprint and the
  job proceeds to upload the bundle

#### Scenario: A bundle signed with the app signing key fails

- **WHEN** the bundle is signed with the app signing key, for example because
  the signing configuration was not switched after the APK build
- **THEN** the check fails and the job uploads neither the bundle nor the APK

#### Scenario: A debug-signed bundle fails

- **WHEN** the signing configuration falls back to the debug key
- **THEN** the check fails and the job uploads nothing

#### Scenario: An unsigned or tampered bundle fails

- **WHEN** the bundle carries no signature, or a signed entry has been altered
  after signing
- **THEN** the check fails and the job uploads nothing

### Requirement: The APK remains signed with the app signing key

Adding the bundle SHALL NOT change which key signs the release APK.  When both
are built in one job, the APK SHALL be signed with the app signing key and
checked against the expected app certificate as before, regardless of the order
in which the two are built.

#### Scenario: Both artifacts from one tag build

- **WHEN** a tag build produces both the APK and the bundle
- **THEN** the APK's signer is the app signing certificate and the bundle's
  signer is the upload certificate, and the two fingerprints differ

### Requirement: The bundle carries exactly the two ARM ABIs

The release bundle SHALL contain native libraries for exactly `arm64-v8a` and
`armeabi-v7a`, under `base/lib/`, and each of those directories SHALL contain
`libflutter.so` and `libapp.so`.  No other ABI directory, complete or partial,
SHALL be present.  Every job that builds a bundle SHALL check this layout and
SHALL fail without uploading when it does not hold.

#### Scenario: A correctly built bundle passes

- **WHEN** a job builds a bundle whose `base/lib/` holds complete `arm64-v8a`
  and `armeabi-v7a` directories and nothing else
- **THEN** the layout check passes and the job proceeds

#### Scenario: An unexpected ABI fails the job

- **WHEN** the bundle's `base/lib/` contains any other ABI directory, such as
  `x86_64`
- **THEN** the layout check fails and the job uploads nothing

#### Scenario: A missing engine library fails the job

- **WHEN** either expected ABI directory in the bundle lacks `libflutter.so` or
  `libapp.so`
- **THEN** the layout check fails and the job uploads nothing

### Requirement: Non-tag builds rehearse the bundle

Workflow runs for pull requests and branch pushes SHALL build the bundle with the
same command and the same layout check as a tag build, without access to any
signing key.  The rehearsal bundle is debug-signed, SHALL NOT be published, and
SHALL NOT be kept longer than the rehearsal APK.

#### Scenario: A pull request builds and checks a bundle

- **WHEN** the workflow runs for a pull request
- **THEN** a bundle is built and passes the layout check, no job obtains a
  signing key, and nothing is published

### Requirement: The bundle is kept for manual upload and not published

The release bundle SHALL be kept as a workflow artifact for 90 days, so that it
can be downloaded and uploaded to the Play Console by hand.  It SHALL NOT be
attached to the GitHub release, whose assets remain the APK and the web archive.

#### Scenario: The GitHub release assets are unchanged

- **WHEN** a `v*` tag is released
- **THEN** the GitHub release carries the APK and the web archive and no `.aab`
  file

#### Scenario: The bundle is kept for 90 days

- **WHEN** the tag build's artifacts are listed
- **THEN** the bundle's retention period is 90 days
