## 1. Tests

- [x] 1.1 Add test: reciprocal dimension with value 1 renders as `"1 / s"` (not `"1 1 / s"`)
- [x] 1.2 Add test: reciprocal dimension with value 2 renders as `"2 / m"` (not `"2 1 / m"`)
- [x] 1.3 Add test: mixed dimension (e.g., `"m / s"`) is displayed unchanged
- [x] 1.4 Add test: dimensionless quantity is displayed unchanged (value only)
- [x] 1.5 Add test: optional `dimension` param overrides canonical (non-reciprocal string used as-is)
- [x] 1.6 Add test: optional `dimension` param starting with `"1 /"` has leading `"1 "` stripped
- [x] 1.7 Add test: omitting `dimension` param uses `canonicalRepresentation` as before

## 2. Implementation

- [x] 2.1 Add optional named parameter `String? dimension` to `formatQuantity`
- [x] 2.2 Compute effective dimension: `dimension ?? quantity.dimension.canonicalRepresentation()`
- [x] 2.3 Strip leading `"1 "` from effective dimension when it starts with `"1 /"`
- [x] 2.4 Use stripped dimension in the returned string

## 3. Verification

- [x] 3.1 Run `flutter test --reporter failures-only` and confirm all tests pass
