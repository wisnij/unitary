## 1. Tests

- [x] 1.1 Add widget test: conformable-units button is enabled when result is `ReciprocalConversionSuccess`
- [x] 1.2 Add widget test: modal opens after force-evaluate produces `ReciprocalConversionSuccess`

## 2. Implementation

- [x] 2.1 Extract `_conformableBrowseEnabled(EvaluationResult) → bool` helper in `home_screen.dart` using an exhaustive `switch` over all `EvaluationResult` subtypes
- [x] 2.2 Replace the `browseEnabled` whitelist in `home_screen.dart` with a call to `_conformableBrowseEnabled`
- [x] 2.3 Replace the post-force-evaluate modal-open whitelist in `freeform_screen.dart` with a call to `_conformableBrowseEnabled`

## 3. Verification

- [x] 3.1 Run `flutter test --reporter failures-only` — all tests pass
- [x] 3.2 Run `flutter analyze` — no lint errors
