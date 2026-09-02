## ADDED Requirements

### Requirement: Version code is derived from the semantic version

The Android version code SHALL be computed from the semantic version as
`MAJOR × 10000 + MINOR × 100 + PATCH`, so that the version name remains the
single source of truth and no independently maintained counter exists.

#### Scenario: Typical versions encode as expected

- **WHEN** the version code is computed for `1.0.0`, `1.2.3`, and `0.9.7`
- **THEN** the results are `10000`, `10203`, and `907` respectively

#### Scenario: A build suffix in the input is ignored

- **WHEN** the version code is computed from a version string that already
  carries a build suffix, such as `1.2.3+10203`
- **THEN** the result is derived from the `1.2.3` portion alone and equals
  `10203`

### Requirement: Version codes increase with semantic version order

For any two releases, the release with the greater semantic version SHALL have
the greater version code, so that Android treats a newer build as an upgrade and
Play accepts successive uploads.

#### Scenario: Each bump increases the code

- **WHEN** a version is bumped by patch, minor, or major
- **THEN** the version code of the bumped version is strictly greater than the
  version code of the version it was bumped from

#### Scenario: The scheme clears the deployed value

- **WHEN** the version code is computed for any version at or after `0.9.7`
- **THEN** it is strictly greater than 1, the value carried by every previously
  published release

### Requirement: Unencodable versions are rejected

The computation SHALL fail with an error rather than return a colliding value
when a minor or patch component is 100 or greater.  Such a component cannot be
encoded in the two decimal digits the scheme allocates it: `1.100.0` and `2.0.0`
would both yield `20000`, silently breaking the ordering guarantee above.

#### Scenario: An out-of-range minor component fails

- **WHEN** the version code is computed for a version whose minor component is
  100 or greater
- **THEN** the computation throws rather than returning a value

#### Scenario: An out-of-range patch component fails

- **WHEN** the version code is computed for a version whose patch component is
  100 or greater
- **THEN** the computation throws rather than returning a value

#### Scenario: Boundary components are accepted

- **WHEN** the version code is computed for a version whose minor and patch
  components are 99
- **THEN** the computation succeeds

### Requirement: Releases record the version code in pubspec.yaml

The release tooling SHALL write the version to `pubspec.yaml` as
`X.Y.Z+CODE`, where `CODE` is the version code derived from `X.Y.Z`, so that
Flutter picks it up for Android builds without any Gradle change and so that the
value is visible where the version is already read.

#### Scenario: A release bump writes the suffix

- **WHEN** the release tooling bumps the version
- **THEN** the `version:` line in `pubspec.yaml` carries the new version name
  followed by `+` and its derived version code

#### Scenario: A built release APK reports the recorded code

- **WHEN** a release APK is built from a checkout whose `pubspec.yaml` records
  `X.Y.Z+CODE`
- **THEN** `aapt2 dump badging` reports `versionCode='CODE'` and
  `versionName='X.Y.Z'`

### Requirement: Recorded version code is verified against the version name

Because `pubspec.yaml` can be edited by hand, the release tooling SHALL verify
that the recorded version code matches the one derived from the recorded version
name, and SHALL fail rather than proceed when they disagree.

#### Scenario: Consistent version passes

- **WHEN** the release tooling runs against a `pubspec.yaml` recording
  `1.2.3+10203`
- **THEN** the consistency check passes and the release proceeds

#### Scenario: Inconsistent version fails the release

- **WHEN** the release tooling runs against a `pubspec.yaml` recording a version
  whose build suffix does not equal the code derived from its version name
- **THEN** the tooling reports the mismatch and exits without bumping, tagging,
  or committing
