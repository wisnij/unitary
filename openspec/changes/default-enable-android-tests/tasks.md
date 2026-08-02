## 1. Composite action

- [ ] 1.1 Remove the Android integration-test step's `if:` condition
      entirely from `.github/actions/test/action.yml`, so it always runs

## 2. Calling workflows

- [ ] 2.1 Remove the now-unused `env: ENABLE_ANDROID_INTEGRATION_TESTS`
      block from `ci.yml`'s `test` job
- [ ] 2.2 Confirm `release.yml`'s `test` job needs no changes (it will run
      the Android step unconditionally, same as every other caller)
- [ ] 2.3 Confirm `run-tests.sh`'s own, independent
      `ENABLE_ANDROID_INTEGRATION_TESTS` check is untouched and still works
      for local runs

## 3. Verification

- [ ] 3.1 Validate `action.yml` and `ci.yml` are well-formed YAML
- [ ] 3.2 Push and confirm a real CI run on `ci.yml` still executes the
      Android integration suite with no `env:` block present
- [ ] 3.3 Confirm `openspec validate default-enable-android-tests --strict`
      passes
