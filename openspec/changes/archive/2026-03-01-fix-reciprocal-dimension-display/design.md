## Context

`formatQuantity` in `lib/shared/utils/quantity_formatter.dart` builds its output
as `"$valueStr ${quantity.dimension.canonicalRepresentation()}"`.
`Dimension.canonicalRepresentation()` outputs `"1"` as the numerator when all
exponents are negative (e.g., `Dimension({'s': -1})` → `"1 / s"`).
Concatenating a numeric value with this string produces `"1 1 / s"` or `"2 1 / m"`,
which looks like a malformed fraction.

The fix is localized entirely to `formatQuantity`; `canonicalRepresentation()` is
correct for its own use (as a standalone label) and should not change.

## Goals / Non-Goals

**Goals:**
- Remove the spurious `1` from quantity strings whose dimension is purely
  reciprocal (e.g., `1/s`, `1/m`).
- Allow callers to supply a custom dimension string (e.g., the raw user input
  used as the output unit) instead of the canonical form, so the same stripping
  logic applies uniformly.

**Non-Goals:**
- Changing `Dimension.canonicalRepresentation()` — its `"1 / …"` form is correct
  when the representation is used standalone.
- Altering the conversion display path (`evaluateConversion`), which already
  formats the unit label separately via `formatOutputUnit`.

## Decisions

**Decision 1: strip `"1 "` in `formatQuantity`, not in `canonicalRepresentation`**

`canonicalRepresentation` is also used in error messages (e.g., `"Cannot convert
1 / s to …"`) where the leading `1` is meaningful. Fixing only the display layer
avoids changing shared behaviour across the codebase.

**Decision 2: optional `dimension` parameter over a separate helper**

Adding `String? dimension` to `formatQuantity` keeps the fix at the only call
site that needs it and lets future callers (e.g., worksheet mode) pass a
user-visible unit label without going through `canonicalRepresentation` at all.
Alternative — a private `_stripLeadingOne` helper called only internally — would
not support the override use-case.

**Decision 3: string-prefix check, not structural Dimension inspection**

Checking whether the effective dimension string starts with `"1 /"` is simpler
and more robust than inspecting the Dimension object (e.g., checking whether all
exponents are negative). It works regardless of whether `dimension` was provided
by the caller or derived from the Quantity.

## Risks / Trade-offs

- **False positive if a future unit is literally named `"1"`**: Extremely
  unlikely given the lexer's identifier rules; acceptable risk.
- **Locale / formatting assumptions**: The check is hard-coded to the ASCII
  space-separated `"1 /"` form produced by `canonicalRepresentation`. This is
  safe because both the check and the producer live in the same codebase.

## Migration Plan

Pure in-process change; no data migration or deployment steps required.
Existing callers of `formatQuantity` are unaffected (the new parameter defaults
to `null`).
