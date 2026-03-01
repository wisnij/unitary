## Why

When a quantity has a purely reciprocal dimension (e.g., `1/s`, `1/m`),
`formatQuantity` produces a redundant leading `1`: `/s` renders as `"1 1 / s"`
instead of `"1 / s"`, and `2/m` renders as `"2 1 / m"` instead of `"2 / m"`.
The bug exists because `canonicalRepresentation()` emits `"1 / s"` (using `"1"`
as the numerator when there are only negative-exponent units), and `formatQuantity`
unconditionally prepends the numeric value, creating the duplicate `1`.

## What Changes

- `formatQuantity` gains an optional named `dimension` parameter (`String?`) that,
  when provided, overrides `quantity.dimension.canonicalRepresentation()` as the
  unit label.
- After resolving the effective dimension string (provided or canonical), if it
  starts with `"1 /"`, the leading `"1 "` is stripped before appending to the
  value, so `"1 / s"` → `"/ s"` and the final output reads `"1 / s"` or `"2 / m"`.

## Capabilities

### New Capabilities

- `quantity-formatter`: Display rules for `formatQuantity` — optional dimension
  override, reciprocal `1`-stripping, and existing value/unit concatenation
  behavior.

### Modified Capabilities

*(none — no existing spec covers this area)*

## Impact

- `lib/shared/utils/quantity_formatter.dart` — `formatQuantity` signature and body
- `test/shared/utils/quantity_formatter_test.dart` — new test cases for the
  reciprocal stripping behavior and the optional `dimension` parameter
