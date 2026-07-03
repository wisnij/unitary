## 1. Operator key panel labels

- [x] 1.1 Add a `const Map<String, String>` glyph→action label map (power,
  multiply, divide, numeric divide, plus, minus, inverse, open/close
  parenthesis) beside
  `freeformKeyPanelSymbols` in `freeform_screen.dart`
- [x] 1.2 Write a **coverage** widget test (before implementing 1.3) that
  iterates the whole `freeformKeyPanelSymbols` list and asserts every glyph
  resolves to a non-empty label that is not just the glyph itself — so a symbol
  added to the list without a map entry fails; also assert focusing the `*` key
  exposes the label "multiply" (via `find.bySemanticsLabel` / `matchesSemantics`,
  with `tester.ensureSemantics()`)
- [x] 1.3 Wrap each key's glyph `Text` in `Semantics(label: <mapped word>,
  child: ExcludeSemantics(child: Text(sym)))` in `_KeyPanel`, falling back to
  the glyph when the map has no entry
- [x] 1.4 Add a render-level coverage test asserting the panel renders exactly
  `freeformKeyPanelSymbols.length` semantics-labelled keys (guards against a
  render path bypassing the wrapper), and that each visible glyph text is still
  present (no visual regression)

## 2. Completion suggestion labels

- [x] 2.1 Write a **coverage** test (before implementing 2.2) that iterates
  `CompletionEntryKind.values` and asserts each kind yields a label containing
  both the name and that kind's word — so a new enum variant without a label
  fails an assertion; include the concrete cases "kilo, prefix" /
  "tempC, function" / "meter, unit"
- [x] 2.2 Add a `_semanticLabel(CompletionEntry)` helper in `completion_field.dart`
  returning `"<name>, <kind>"` (kind = lower-cased `CompletionEntryKind`), written
  as an **exhaustive `switch` expression with no `default`** so a new kind is a
  compile error until labelled; mirrors the existing `_displayName` /
  `_insertText` switch
- [x] 2.3 Wrap each suggestion's `Text(_displayName(...))` in
  `Semantics(label: _semanticLabel(...), child: ExcludeSemantics(child: ...))`
  in `_buildSuggestions`
- [x] 2.4 Add a render-level coverage test asserting the overlay renders one
  semantics-labelled row per suggestion (count matches), and that the visible
  display text (`name`, `name-`, `name(`) is unchanged

## 3. Verification

- [x] 3.1 Run `flutter test --reporter failures-only` — all tests green
- [x] 3.2 Run `flutter analyze` — no new issues
