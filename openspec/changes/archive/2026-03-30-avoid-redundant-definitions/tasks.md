## 1. Implementation

- [x] 1.1 In `freeform_provider.dart`, update the redundancy check to collapse whitespace before comparing `rawDefinitionLine` to `formattedResult`

## 2. Tests

- [x] 2.1 Add a test: definition line is suppressed when expression and result differ only in spacing (e.g. `"= m/s"` vs `"= m / s"`)
- [x] 2.2 Verify existing test still passes: definition line is suppressed when expression exactly equals result (e.g. `"= 273.15 K"`)
- [x] 2.3 Verify existing test still passes: definition line is shown when expression meaningfully differs from result (e.g. `"= 4.184 J"` vs `"= 4.184 kg m² / s²"`)

## 3. Spec Sync

- [x] 3.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 3.2 Run `flutter analyze` and confirm no linting errors
