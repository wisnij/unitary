## 1. Update group label logic

- [x] 1.1 In `BrowserNotifier._buildDimensionIndex`, update `labelFor` so that
  labeled dimensions return `"$userLabel ($rep)"` and unlabeled dimensions
  continue to return `rep` alone

## 2. Update tests

- [x] 2.1 Update any existing browser tests that assert against plain dimension
  label strings in the dimension view to use the new `"Label (rep)"` format
- [x] 2.2 Add a test asserting that a labeled dimension group header contains
  both the human-readable label and the canonical representation in parentheses
- [x] 2.3 Add a test asserting that an unlabeled dimension group header shows
  only the canonical representation with no parenthesized suffix

## 3. Verify

- [x] 3.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 3.2 Run `flutter analyze` and confirm no linting errors
