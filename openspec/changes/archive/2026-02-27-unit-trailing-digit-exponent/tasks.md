## 1. Parser Implementation

- [x] 1.1 In `lib/core/domain/parser/parser.dart`, add a private digit-check helper (or
  inline logic) that walks a string backward to find the trailing digit run and
  classifies it (underscore-preceded, ends-in-0/1, single-2–9, or multi-2–9)
- [x] 1.2 In `_identifierOrFunction()`, insert the digit-suffix check after the
  affine-unit check and before `return UnitNode(name)`, returning
  `BinaryOpNode(UnitNode(baseName), TokenType.exponent, NumberNode(digit))` for
  single-digit 2–9, `UnitNode(name)` for the ends-in-0/1 and underscore cases,
  and throwing `ParseException` for multi-digit ending in 2–9

## 2. Tests — Parser

- [x] 2.1 Add group `'Parser: unit trailing-digit exponents'` in
  `test/core/domain/parser/parser_test.dart` with cases:
  - `m2` → same AST as `m^2`
  - `centimeters3` → same AST as `centimeters^3`
  - `m2s` → `UnitNode('m2s')` (embedded digit, not trailing — single identifier)
  - `x0` → `UnitNode('x0')`
  - `y1` → `UnitNode('y1')`
  - `x10` → `UnitNode('x10')`
  - `k1250` → `UnitNode('k1250')`
  - `y21` → `UnitNode('y21')`
  - `m_2` → `UnitNode('m_2')`
  - `u_235` → `UnitNode('u_235')`
  - `a_123b` → `UnitNode('a_123b')`
  - `m 2` → implicit multiply (not exponent)
  - `u235` → throws `ParseException`
  - `m23` → throws `ParseException`
  - `a_b123` → throws `ParseException`

## 3. Tests — Evaluator (integration)

- [x] 3.1 Add integration tests in `test/core/domain/parser/evaluator_test.dart` using
  `ExpressionParser` with a unit repo:
  - `5 m2` evaluates to same `Quantity` as `5 m^2`
  - `centimeters3` evaluates to same `Quantity` as `cm^3`

## 4. Update Builtin-Units Regression Test

- [x] 4.1 In `test/core/domain/data/builtin_units_test.dart`, remove the following six
  entries from `_knownEvalFailures` (their definitions use `m2`/`ft3` shorthand which
  now resolves):
  - `naturalgas_HHV`
  - `naturalgas_LHV`
  - `k1250`
  - `k1400`
  - `K_apex1961`
  - `K_apex1971`
  Also remove or update the comment block that describes these entries.

## 5. Verification

- [x] 5.1 Run `flutter test --reporter failures-only` and confirm all tests pass with no
  regressions
