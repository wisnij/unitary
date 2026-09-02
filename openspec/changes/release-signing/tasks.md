## 1. Prerequisites and safety

- [ ] 1.1 Confirm the version-code change has landed — Play rejects duplicate
  version codes, and every build currently reports `versionCode=1`
- [ ] 1.2 Add `*.jks`, `*.p12`, `*.keystore`, and `android/key.properties` to
  `.gitignore`, and commit this **before** any key exists on disk
- [ ] 1.3 Verify the ignore rules by placing a dummy file at each path and
  confirming `git status` does not offer it

## 2. Confirm the open questions before generating keys

- [ ] 2.1 Confirm the Play Console still offers "use your own signing key" at
  first release creation, and capture the current PEPK export procedure
- [ ] 2.2 Confirm Play's current minimum app-signing-key expiry date and that 30
  years clears it
- [ ] 2.3 Re-read the decided DN (`CN=Unitary, O=wisnij.dev, C=US`) once before
  generating anything, and confirm that omitting `L`, `ST`, and `OU` is accepted
  by Play's enrolment flow — a typo or a rejected field cannot be corrected after
  the key exists
- [ ] 2.4 Decide whether the release job runs in a GitHub Actions environment
  with required reviewers, or relies on repository secrets alone

## 3. Generate and secure the keys

These commands are run **by hand, by the maintainer** — never by CI, an agent, or
any automated process.  The private keys must not exist in a build environment
that did not create them, and the passwords must not appear in a transcript.

Note that no `-storepass` or `-keypass` is passed: keytool prompts instead, which
keeps the password out of shell history and out of the process table, where
command-line arguments are world-readable via `ps`.  PKCS12 does not support a
key password distinct from the store password — keytool warns and ignores
`-keypass` if given — so each keystore has exactly one password.

- [ ] 3.1 Create a destination outside the repository, so the keys are never in
  the working tree at all rather than merely ignored:

  ```bash
  mkdir -p ~/keys/unitary && chmod 700 ~/keys/unitary
  ```

- [ ] 3.2 Generate the app signing key (prompts for a password; use a long random
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

  `-sigalg` is explicit because JDK 21 otherwise defaults RSA 2048 to
  SHA384withRSA.  `-validity 10950` is 30×365 days.  `-dname` is explicit so
  keytool never falls into its interactive prompt sequence, where a typo is
  easier to make and impossible to correct afterwards.

- [ ] 3.3 Generate the upload key — same parameters and DN, different alias, and
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

- [ ] 3.4 Restrict permissions on both keystores:

  ```bash
  chmod 600 ~/keys/unitary/*.p12
  ```

- [ ] 3.5 Confirm each certificate reports the intended owner, signature
  algorithm, and validity — and that no empty `L=` or `ST=` component was baked
  in:

  ```bash
  keytool -list -v -keystore ~/keys/unitary/unitary-app.p12 -alias unitary-app \
    | grep -E 'Owner|Valid from|Signature algorithm|Subject Public Key'
  ```

  Expect `Owner: CN=Unitary, O=wisnij.dev, C=US` exactly, `SHA256withRSA`, a
  2048-bit RSA key, and an expiry roughly 30 years out.  Repeat for the upload
  keystore.

- [ ] 3.6 Record both certificate SHA-256 fingerprints, normalised to the form
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
- [ ] 3.7 Store both keystores and their passwords in a password manager, and
  place offline backups in at least two locations — losing the app signing key
  ends the app's upgrade path permanently
- [ ] 3.8 Verify each keystore opens with its recorded password from a clean
  location, so the backup is known-good rather than assumed

## 4. Gradle signing configuration

- [ ] 4.1 Add the `key.properties`-driven signing config to
  `android/app/build.gradle.kts`, replacing
  `signingConfig = signingConfigs.getByName("debug")` under `buildTypes.release`
- [ ] 4.2 Make the release signing config conditional on `key.properties` being
  present, falling back to debug signing so a keyless clone still builds
- [ ] 4.3 Remove the stale `applicationId` TODO comment — the ID is already set
  to `dev.wisnij.unitary`; only the signing TODO above it was real
- [ ] 4.4 Verify a local release build with `key.properties` present is signed
  with the app signing key, by fingerprint
- [ ] 4.5 Verify a local release build with `key.properties` absent still
  succeeds and falls back to debug signing
- [ ] 4.6 Verify the built APK contains no keystore and no `key.properties`

## 5. CI wiring

- [ ] 5.1 Add repository secrets: base64-encoded app signing keystore, its
  password, and its alias
- [ ] 5.2 Add repository secrets for the upload keystore, its password, and its
  alias
- [ ] 5.3 Add the expected app signing certificate SHA-256 fingerprint as a
  non-secret CI variable
- [ ] 5.4 In `build-android-apk`, decode the app signing keystore and write
  `android/key.properties` before `flutter build apk`, with no shell tracing and
  nothing echoed
- [ ] 5.5 Add the verification step: compare the built APK's signer certificate
  SHA-256 fingerprint against the expected value and fail on mismatch, comparing
  the normalised lowercase contiguous form from 3.6 rather than keytool's
  colon-separated rendering
- [ ] 5.6 Confirm the verification step actually fails on a wrong-key build, by
  temporarily pointing it at a deliberately wrong expected fingerprint — a check
  that has never been seen to fail is not yet a check
- [ ] 5.7 Confirm the workflow log contains no keystore content and no passwords
- [ ] 5.8 Run the release workflow end to end and confirm the published APK
  carries the app signing certificate

## 6. Play App Signing enrolment

- [ ] 6.1 In the Play Console, create the first release **deliberately choosing
  to upload the existing app signing key** — the default generates a Google key
  and silently forecloses matching signatures across channels, permanently
- [ ] 6.2 Export the app signing key with PEPK and complete the upload
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
