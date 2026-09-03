## 1. Prerequisites and safety

- [x] 1.1 Confirm the version-code change has landed — Play rejects duplicate
  version codes, and every build currently reports `versionCode=1`
- [x] 1.2 Add `*.jks`, `*.p12`, `*.keystore`, and `android/key.properties` to
  `.gitignore`, and commit this **before** any key exists on disk
- [x] 1.3 Verify the ignore rules by placing a dummy file at each path and
  confirming `git status` does not offer it

## 2. Confirm the open questions before generating keys

- [x] 2.1 Confirm the Play Console still offers "use your own signing key" at
  first release creation, and capture the current PEPK export procedure —
  **confirmed September 3, 2026.**  `developer.android.com/studio/publish/app-signing`:
  "select Change app signing key and select one of the Export and upload options
  that lets you securely upload a private key and its public certificate."
  Option A stands
- [x] 2.2 Confirm Play's current minimum app-signing-key expiry date and that 30
  years clears it — **confirmed September 3, 2026.**  Play requires "a validity
  period ending after 22 October 2033" and recommends "25 years or more".  A key
  generated now with `-validity 10950` expires 2056-08-26 (verified), clearing
  the hard date by 23 years and satisfying the recommendation
- [x] 2.3 Confirm the decided DN (`CN=Unitary, O=wisnij.dev, C=US`) is
  acceptable — **settled September 3, 2026.**  Play's published requirements
  cover only key type and size ("Custom keys must be RSA 2048-bit or higher")
  and impose no constraint on distinguished-name fields; a search for
  counter-examples found none.  This is absence of a documented constraint
  rather than positive confirmation, but it is the strongest evidence available
  short of enrolling, and the DN is accepted as final on that basis.  The
  re-read-before-generating caution moves to 3.2, where it applies
- [x] 2.4 Decide how CI reaches the signing secrets — **settled September 3,
  2026**: a GitHub Actions environment with a `v*` deployment tag policy and no
  required reviewers.  Cuts key exposure from every push and PR down to tag
  builds, keeps releases unattended, and places the rule in repository settings
  where a workflow edit cannot bypass it.  See design D6

## 3. Generate and secure the keys

These commands are run **by hand, by the maintainer** — never by CI, an agent, or
any automated process.  The private keys must not exist in a build environment
that did not create them, and the passwords must not appear in a transcript.

Note that no `-storepass` or `-keypass` is passed: keytool prompts instead, which
keeps the password out of shell history and out of the process table, where
command-line arguments are world-readable via `ps`.  PKCS12 does not support a
key password distinct from the store password — keytool warns and ignores
`-keypass` if given — so each keystore has exactly one password.

- [x] 3.1 Create a destination outside the repository, so the keys are never in
  the working tree at all rather than merely ignored:

  ```bash
  mkdir -p ~/keys/unitary && chmod 700 ~/keys/unitary
  ```

- [x] 3.2 Generate the app signing key (prompts for a password; use a long random
  one from the password manager):

  ```bash
  keytool -genkeypair \
    -alias unitary-app \
    -keyalg RSA -keysize 2048 -sigalg SHA256withRSA \
    -validity 10950 \
    -storetype PKCS12 \
    -keystore ~/keys/unitary/unitary-app.p12 \
    -dname "CN=Unitary, O=wisnij.dev, C=US"
  ```

  **Read the `-dname` line once more before pressing return.**  It is baked into
  the certificate permanently, a typo cannot be corrected without generating a
  new key, and by this point in the process it is the easiest thing in the
  command to skim past.

  `-sigalg` is explicit because JDK 21 otherwise defaults RSA 2048 to
  SHA384withRSA.  `-validity 10950` is 30×365 days, expiring in 2056.  `-dname`
  is explicit so keytool never falls into its interactive prompt sequence, where
  a typo is both easier to make and harder to notice.

- [x] 3.3 Generate the upload key — same parameters and DN, different alias, and
  a **separate file** so that one keystore's password does not expose both keys:

  ```bash
  keytool -genkeypair \
    -alias unitary-upload \
    -keyalg RSA -keysize 2048 -sigalg SHA256withRSA \
    -validity 10950 \
    -storetype PKCS12 \
    -keystore ~/keys/unitary/unitary-upload.p12 \
    -dname "CN=Unitary, O=wisnij.dev, C=US"
  ```

- [x] 3.4 Restrict permissions on both keystores:

  ```bash
  chmod 600 ~/keys/unitary/*.p12
  ```

- [x] 3.5 Confirm each certificate reports the intended owner, signature
  algorithm, and validity — and that no empty `L=` or `ST=` component was baked
  in:

  ```bash
  keytool -list -v -keystore ~/keys/unitary/unitary-app.p12 -alias unitary-app \
    | grep -E 'Owner|Valid from|Signature algorithm|Subject Public Key'
  ```

  Expect `Owner: CN=Unitary, O=wisnij.dev, C=US` exactly, `SHA256withRSA`, a
  2048-bit RSA key, and an expiry roughly 30 years out.  Repeat for the upload
  keystore.

- [x] 3.6 Record both certificate SHA-256 fingerprints, normalised to the form
  `apksigner` emits, in a durable location outside the keystores:

  ```bash
  keytool -list -v -keystore ~/keys/unitary/unitary-app.p12 -alias unitary-app \
    | awk '/SHA256:/ {gsub(":",""); print tolower($2)}'
  ```

  keytool prints `SHA256: AA:BB:CC:…` while `apksigner` prints a lowercase
  contiguous digest; they are the same value in different formats, and the
  normalisation above is what makes the CI comparison in 5.5 possible.  Verified
  against the existing debug key, where both tools agree byte for byte once
  normalised.
- [x] 3.7 Export each public certificate in PEM form — Play's enrolment expects
  the app signing key's certificate as `.der` or `.pem`, and the upload key is
  registered by its certificate too:

  ```bash
  keytool -exportcert -rfc -alias unitary-app \
    -keystore ~/keys/unitary/unitary-app.p12 \
    -file ~/keys/unitary/unitary-app.pem
  ```

  These contain no private key and are not secret.

- [x] 3.8 Store both keystores and their passwords in a password manager, as
  base64 text.  The `.p12` is already encrypted by its store password, so the
  encoding is only to make it paste-able; the blob carries the private key,
  certificate, and alias together, so a restore needs nothing else:

  ```bash
  base64 -w0 ~/keys/unitary/unitary-app.p12
  base64 -w0 ~/keys/unitary/unitary-upload.p12
  ```

  About 3.5 KB of text each.  This is the same encoding CI needs in 5.2, so
  produce it once and use it in both places.  Keep the password in the same
  entry as the blob — a keystore whose password is lost is as dead as one that
  was never backed up — and place offline copies in at least two locations.
  Losing the app signing key ends the app's upgrade path permanently.
- [x] 3.9 Verify the backup restores, rather than assuming it does: decode each
  blob into a scratch directory, open it with the recorded password, and confirm
  the certificate fingerprint matches the value recorded in 3.6:

  ```bash
  base64 -d < backup.txt > /tmp/restore-check.p12
  keytool -list -v -keystore /tmp/restore-check.p12 -alias unitary-app \
    | awk '/SHA256:/ {gsub(":",""); print tolower($2)}'
  ```

  A password-manager blob is exactly the kind of backup that turns out years
  later to have been truncated or mangled, at the worst possible moment.  Delete
  the scratch copy afterwards.

## 4. Gradle signing configuration

- [x] 4.1 Add the `key.properties`-driven signing config to
  `android/app/build.gradle.kts`, replacing
  `signingConfig = signingConfigs.getByName("debug")` under `buildTypes.release`
- [x] 4.2 Make the release signing config conditional on `key.properties` being
  present, falling back to debug signing so a keyless clone still builds
- [x] 4.3 Remove the stale `applicationId` TODO comment — the ID is already set
  to `dev.wisnij.unitary`; only the signing TODO above it was real
- [x] 4.4 Verify a local release build with `key.properties` present is signed
  with the app signing key, by fingerprint — confirmed: `CN=Unitary,
  O=wisnij.dev, C=US`, SHA-256
  `4e22238ae5008f5a1dd1515fb434445ffbf1fdd47609ea93be4646705c7a62bd`, matching
  the value recorded in 3.6.  The same build still reports `versionCode=9007`
- [x] 4.5 Verify a local release build with `key.properties` absent still
  succeeds and falls back to debug signing — confirmed: build succeeded,
  `apksigner` reports `CN=Android Debug`.  Also confirmed the opposite failure
  mode is loud rather than silent: a `key.properties` present but incomplete
  fails the build with `android/key.properties is present but missing:
  storePassword, keyPassword` instead of producing a mis-signed artifact
- [x] 4.6 Verify the built APK contains no keystore and no `key.properties` —
  no entry matching `*.p12`, `*.jks`, `*.keystore`, `*.pem`, `*.der`, or
  `key.properties`.  Re-checked against the signed artifact from 4.4: still
  none

## 5. CI wiring

- [ ] 5.1 Create a `release` GitHub Actions environment with a deployment tag
  policy limiting it to `v*`, and no required reviewers
- [ ] 5.2 Add the app signing keystore (base64), its password, and its alias as
  **environment** secrets on `release` — not repository secrets
- [ ] 5.3 Add the upload keystore, its password, and its alias as environment
  secrets on `release`
- [ ] 5.4 Add the expected app signing certificate SHA-256 fingerprint as a
  non-secret variable
- [x] 5.5 Split the APK build: leave `build-android-apk` unconditional and
  keyless, so every push and PR keeps exercising the build path (it falls back to
  debug signing per D4 and publishes nothing), and add a tag-only
  `build-android-apk-signed` job declaring `environment: release`
- [x] 5.6 In the signed job, decode the keystore and write
  `android/key.properties` before `flutter build apk`, with no shell tracing and
  nothing echoed
- [x] 5.7 Point the `release` job at the signed job's artifact, so the published
  APK can never be the debug-signed one
- [x] 5.8 Add the verification step to the signed job: compare the built APK's
  signer certificate SHA-256 fingerprint against the expected value and fail on
  mismatch, comparing the normalised lowercase contiguous form from 3.6 rather
  than keytool's colon-separated rendering
- [ ] 5.9 Confirm the verification step actually fails on a wrong-key build, by
  temporarily pointing it at a deliberately wrong expected fingerprint — a check
  that has never been seen to fail is not yet a check.  **Rehearsed locally**
  against a throwaway keystore by running the workflow's own step verbatim:
  correct fingerprint exits 0, wrong fingerprint exits 1 with
  `::error::APK is not signed with the expected app signing key`, and an unset
  variable exits 1 rather than passing vacuously.  Still to be confirmed in CI,
  where `apksigner` discovery via `ANDROID_HOME` differs
- [ ] 5.10 Confirm a pull-request run still succeeds, produces a debug-signed
  artifact, and never obtains the keystore
- [ ] 5.11 Confirm the workflow log contains no keystore content and no passwords
- [ ] 5.12 Run the release workflow end to end from a tag and confirm the
  published APK carries the app signing certificate

## 6. Play App Signing enrolment

- [ ] 6.1 In the Play Console, create the first release **deliberately choosing
  to upload the existing app signing key** — the default generates a Google key
  and silently forecloses matching signatures across channels, permanently
- [ ] 6.2 Export the app signing key with PEPK and complete the upload.  Play's
  documentation describes the upload key as "stored in a Java keystore (.jks or
  .keystore)", while these keys are PKCS12 (`.p12`) — the modern keytool default,
  and a format Play never actually sees for the upload key, since it verifies a
  signature and a certificate rather than a container.  If PEPK or the Console
  rejects PKCS12, convert rather than regenerate:

  ```bash
  keytool -importkeystore -srckeystore ~/keys/unitary/unitary-app.p12 \
    -srcstoretype PKCS12 -destkeystore ~/keys/unitary/unitary-app.jks \
    -deststoretype JKS
  ```

  Verified lossless — the converted keystore holds the same key and reports an
  identical certificate fingerprint, so nothing downstream changes
- [ ] 6.3 Designate `unitary-upload` as the upload key
- [ ] 6.4 Confirm the app signing certificate shown in the Console matches the
  fingerprint recorded in 3.6
- [ ] 6.5 Confirm a Play-delivered install and a GitHub APK of the same version
  present the same certificate, and that each installs over the other as an
  update

## 7. Documentation and release notes

- [ ] 7.1 Record in the release notes that the first signed build cannot install
  over any earlier debug-signed build, and that affected users must uninstall
  first and will lose locally stored data
- [ ] 7.2 Document the signing setup for future maintainers: which key signs
  which artifact, where the keys live, and how to rotate the upload key
- [ ] 7.3 Update `doc/implementation_plan.md` Phase 10 to check off the release
  signing task and record the decisions made
- [ ] 7.4 Update `doc/design_progress.md` with a dated entry covering the two-key
  model, the CI-exposure trade, and anything learned during enrolment
