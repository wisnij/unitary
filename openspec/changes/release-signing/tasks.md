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

- [ ] 3.1 Generate the app signing key: RSA 2048, `-validity 10950`, PKCS12,
  alias `unitary-app`, `-dname "CN=Unitary, O=wisnij.dev, C=US"`, and an explicit
  `-sigalg SHA256withRSA` — JDK 21 otherwise defaults to SHA384withRSA
- [ ] 3.2 Generate the upload key with the same parameters and DN, alias
  `unitary-upload`, in a **separate** keystore file
- [ ] 3.3 Confirm via `keytool -list -v` that both certificates report the
  intended owner and signature algorithm, with no empty `L=` or `ST=` components
- [ ] 3.4 Record both certificate SHA-256 fingerprints in a durable location
  outside the keystores
- [ ] 3.5 Store both keystores and their passwords in a password manager, and
  place offline backups in at least two locations — losing the app signing key
  ends the app's upgrade path permanently
- [ ] 3.6 Verify each keystore opens with its recorded password from a clean
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
  SHA-256 fingerprint against the expected value and fail on mismatch
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
  fingerprint recorded in 3.4
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
