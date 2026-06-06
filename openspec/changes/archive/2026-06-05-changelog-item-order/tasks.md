## 1. Release Tool

- [x] 1.1 In `formatChangelogSection` (`tool/release_lib.dart`), reverse each section's entries list before writing so items appear oldest-first
- [x] 1.2 In `formatUnreleasedSection` (`tool/release_lib.dart`), apply the same reversal so the `[Unreleased]` section also emits items oldest-first

## 2. Tests

- [x] 2.1 Add or update tests in `test/tool/release_lib_test.dart` covering multi-commit sections: verify that the earlier commit's entry appears before the later commit's entry in the output
- [x] 2.2 Verify all existing release tool tests still pass (`flutter test test/tool/ --reporter failures-only`)
