## 1. Preconditions

- [x] 1.1 Confirm the repository's artifact retention setting allows 90 days
  (Settings → Actions → General → Artifact and log retention); a lower value
  caps `retention-days` silently
- [x] 1.2 Check branch protection rules and rulesets for required status checks
  named after `build-android-apk-test` or `build-android-apk-release`.  If any
  exist, plan to update them in the same sitting as the rename, or merges will
  block waiting for a check that no longer runs

## 2. ABI verification tool

- [x] 2.1 Write tests first in `test/tool/verify_apk_abis_lib_test.dart` for a
  root-prefix parameter: bundle entries under `base/lib/<abi>/` group and check
  exactly as APK entries under `lib/<abi>/` do; with the `base/lib/` root,
  entries under a top-level `lib/` are ignored, and with the default root,
  entries under `base/lib/` are ignored; existing APK tests pass unchanged
- [x] 2.2 Add the root-prefix parameter (default `lib/`) to `nativeLibraries`
  and `checkApkAbis` in `tool/verify_apk_abis_lib.dart`; update doc comments to
  cover both formats
- [x] 2.3 Add a tested function mapping a file name to its root prefix: `.apk`
  to `lib/`, `.aab` to `base/lib/`, anything else to null (usage error)
- [x] 2.4 Update `tool/verify_apk_abis.dart` to select the root from the file
  extension, exit 2 for an unrecognised extension, and say in its usage text and
  header comment that it accepts APKs and bundles
- [x] 2.5 Run the tool against the local release bundle and a local release APK
  and confirm both pass; run it against a copy of the bundle with a fake
  `base/lib/x86_64/libfoo.so` added and confirm it fails with exit 1

## 3. Signature check

- [x] 3.1 Write the bundle signature check as a shell snippet per design D3:
  `keytool -printcert -jarfile` exit status zero, exactly one `Signer #` block,
  and the SHA-256 fingerprint equal to the expected value after lowercasing and
  removing colons on both sides.  Print expected and actual values as the APK
  step does, and fail with an `::error::` annotation naming the cause
- [x] 3.2 Exercise the snippet locally before putting it in the workflow,
  with the expected value set to the upload certificate's fingerprint: a bundle
  signed with the app key fails (the local `key.properties` names it); an
  unsigned bundle (signature files deleted from a copy) fails; a tampered
  bundle (an entry modified in a copy) fails.  Then set the expected value to
  the app certificate's fingerprint and confirm the app-key bundle passes, and
  that colon-separated uppercase and contiguous lowercase forms both match

## 4. Workflow

- [x] 4.1 Rename `build-android-apk-test` to `build-android-test` and
  `build-android-apk-release` to `build-android-release`, updating the
  `release` job's `needs` and output references and the comments that name
  them
- [x] 4.2 In `build-android-test`, after the APK steps, build the bundle with
  `flutter build appbundle` using the same `--dart-define` and `--release` and
  no `--target-platform`; run the ABI check on it; upload
  `unitary-<version>.aab` as artifact `android-aab-test` with 7-day retention
- [x] 4.3 In `build-android-release`, after the APK's signature and ABI checks:
  write `key.properties` for the upload key from the `ANDROID_UPLOAD_*` secrets
  (decoding the keystore to its own file under `RUNNER_TEMP`, without shell
  tracing, as the app key step does); build the bundle as in 4.2; run the
  signature check against `vars.ANDROID_UPLOAD_CERT_SHA256`, failing if the
  variable is empty; run the ABI check
- [x] 4.4 Extend the `always()` cleanup step to remove the upload keystore too,
  and move it so it runs after both builds
- [x] 4.5 Move both artifact uploads in `build-android-release` after all four
  checks; upload the bundle as artifact `android-aab-release` with 90-day
  retention; leave the `release` job's downloads and `gh release create`
  arguments unchanged, so the bundle is not attached
- [x] 4.6 Run `pre-commit run --all-files` and fix anything it reports.  The
  hooks do not lint workflow files, so also re-read the edited jobs for step
  order: every check before any upload, and cleanup in an `always()` step

## 5. Verification in CI

- [x] 5.1 Open a pull request and confirm `build-android-test` builds both
  artifacts, both ABI checks pass, and both rehearsal artifacts appear with
  7-day retention
- [ ] 5.2 After merging, cut the next `0.9.x` tag.  Confirm in the
  `build-android-release` log that the APK matched the app certificate and the
  bundle matched the upload certificate, that the two fingerprints differ, and
  that the log shows no key material
- [ ] 5.3 Confirm the GitHub release carries only the APK and the web archive,
  and that the `android-aab-release` artifact is listed with 90-day retention
- [ ] 5.4 Download the bundle artifact and confirm locally that
  `keytool -printcert -jarfile` reports the upload certificate, that its
  `base/lib/` holds only the two ARM ABIs, and that it contains no keystore or
  `key.properties`
- [ ] 5.5 Confirm the bundle's version code equals the APK's, either with
  `bundletool dump manifest --xpath /manifest/@android:versionCode` or from the
  Play Console when it is uploaded

## 6. Documentation

- [x] 6.1 Update `doc/implementation_plan.md` Phase 10 task 7: check off the AAB
  build item and record the decisions (same job as the APK, upload key checked
  by fingerprint, 90-day artifact not attached to the release, x86_64 exclusion
  kept)
- [x] 6.2 Add a dated entry to `doc/design_progress.md` covering the change and
  what was learned (bundle layout, keytool's exit 0 for unsigned bundles,
  `jarsigner -strict` rejecting valid self-signed bundles, 16 KB alignment
  already met)
- [x] 6.3 Leave the old job names in the dated entries of
  `doc/design_progress.md` and in `doc/implementation_plan.md` task 2, which
  record the pipeline as it was; update any other current description of the
  jobs to the new names
- [x] 6.4 Run `flutter test --reporter failures-only` and `flutter analyze` and
  confirm both are clean
