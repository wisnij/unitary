## 1. Fix classification order

- [x] 1.1 In `tool/import_gnu_units_lib.dart`, move the `nameToken.contains('[')` piecewise block above the `nameToken.contains('(')` unsupported block in `_classifyLine`

## 2. Tests

- [x] 2.1 Add a test in `test/tool/import_gnu_units_lib_test.dart` for `plategauge[(oz/ft^2)/(480*lb/ft^3)]` — verify it produces `type: "piecewise"`, not `type: "unsupported"`
- [x] 2.2 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 2.3 Run `flutter analyze` and confirm no linting errors
