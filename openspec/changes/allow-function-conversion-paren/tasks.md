## 1. Tests

- [ ] 1.1 Add `parseQuery` test: `"tempC("` with a repo → `FunctionNameNode("tempC", false)`
- [ ] 1.2 Add `parseQuery` test: `"~tempC("` with a repo → `FunctionNameNode("tempC", true)`
- [ ] 1.3 Add `parseQuery` test: `"km("` with a repo (unit, not function) → parse error / not `FunctionNameNode`

## 2. Implementation

- [ ] 2.1 In `parseQuery()` in `parser.dart`, add a branch after the bare-function-name check that matches `IDENTIFIER LPAR EOF` and returns `FunctionNameNode(name, inverse: false)` when `findFunction(name)` is non-null
- [ ] 2.2 Add a corresponding branch for `INVERSE IDENTIFIER LPAR EOF` → `FunctionNameNode(name, inverse: true)`

## 3. Verification

- [ ] 3.1 Run `flutter test --reporter failures-only` — all tests pass
- [ ] 3.2 Run `flutter analyze` — no lint errors
