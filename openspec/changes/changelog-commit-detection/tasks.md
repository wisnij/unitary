## 1. Implementation

- [x] 1.1 Add `'--first-parent'` to `logArgs` in `_runChangelog` in `tool/release.dart`
- [x] 1.2 Add `'--first-parent'` to `logArgs` in `_runRelease` in `tool/release.dart`

## 2. Tests

- [x] 2.1 Add a test for `_runChangelog` (or its integration via `release_lib`) asserting that feature-branch commits do not appear when only first-parent commits are fed in
- [x] 2.2 Add a test asserting that a conventional subject on a merge commit is included correctly
- [x] 2.3 Add a test asserting that a `"Merge …"` subject on a merge commit is still excluded

## 3. Verification

- [x] 3.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 3.2 Run `flutter analyze` and confirm no linting errors
