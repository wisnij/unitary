## 1. Implementation

- [ ] 1.1 Add `'--first-parent'` to `logArgs` in `_runChangelog` in `tool/release.dart`
- [ ] 1.2 Add `'--first-parent'` to `logArgs` in `_runRelease` in `tool/release.dart`

## 2. Tests

- [ ] 2.1 Add a test for `_runChangelog` (or its integration via `release_lib`) asserting that feature-branch commits do not appear when only first-parent commits are fed in
- [ ] 2.2 Add a test asserting that a conventional subject on a merge commit is included correctly
- [ ] 2.3 Add a test asserting that a `"Merge …"` subject on a merge commit is still excluded

## 3. Verification

- [ ] 3.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [ ] 3.2 Run `flutter analyze` and confirm no linting errors
