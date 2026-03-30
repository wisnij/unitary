## Context

`freeform_provider.dart` suppresses `definitionLine` when it equals
`formattedResult`, to avoid showing the same information twice.  The current
comparison is an exact string match, so strings that differ only in whitespace
(e.g. `"= m/s"` vs `"= m / s"`) are treated as distinct even though they
convey identical information.

## Goals / Non-Goals

**Goals:**
- Suppress `definitionLine` whenever `rawDefinitionLine` and `formattedResult`
  are equivalent modulo internal whitespace.

**Non-Goals:**
- Normalising any other aspect of the strings (capitalisation, Unicode, unit
  ordering, etc.).
- Changing how `formattedResult` or `rawDefinitionLine` are produced.

## Decisions

### Strip all whitespace before comparing

Remove every whitespace character from both strings before comparing.  In Dart
this is:

```dart
String? _normalizeWhitespace(String? s) => s?.replaceAll(RegExp(r'\s+'), '');

final definitionLine =
    _normalizeWhitespace(rawDefinitionLine) == _normalizeWhitespace(formattedResult)
        ? null
        : rawDefinitionLine;
```

This handles the motivating case: `"= m/s"` → `"=m/s"` and `"= m / s"` →
`"=m/s"`, which are now equal.

**Alternatives considered:**

- *Collapse runs of whitespace to a single space* — does not handle `"m/s"` vs
  `"m / s"` because there is no whitespace in `"m/s"` to collapse.  Rejected.
- *Regex-aware unit parser* — heavyweight; this is a display hint, not a
  semantic check.  Rejected.

## Risks / Trade-offs

- **False suppression** — two strings that differ only in spacing but have
  different meanings could theoretically be suppressed.  In practice the
  formatter and the expression strings use the same unit names, so this is not
  a realistic concern.

## Open Questions

_(none)_
