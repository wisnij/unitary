## 1. Tests

- [ ] 1.1 Write widget tests for `_KeyPanel`: renders all 8 symbols in correct order
- [ ] 1.2 Write widget test: panel is not visible when neither field is focused
- [ ] 1.3 Write widget test: panel appears when "Convert from" field is focused
- [ ] 1.4 Write widget test: panel appears when "Convert to" field is focused
- [ ] 1.5 Write widget test: tapping a symbol inserts it at cursor in "Convert from"
- [ ] 1.6 Write widget test: tapping a symbol inserts it at cursor in "Convert to"
- [ ] 1.7 Write widget test: tapping a symbol replaces selected text
- [ ] 1.8 Write widget test: insertion triggers debounced evaluation in real-time mode
- [ ] 1.9 Write widget test: insertion does not trigger evaluation in on-submit mode

## 2. Layout Restructure

- [ ] 2.1 Replace the bare `SingleChildScrollView` body in `FreeformScreen` with a
  `Column` containing `Expanded(SingleChildScrollView(...))` as the first child
- [ ] 2.2 Verify all existing freeform screen tests still pass after layout change

## 3. Focus Tracking

- [ ] 3.1 Add `FocusNode _inputFocus` and `FocusNode _outputFocus` fields to
  `_FreeformScreenState`; dispose them in `dispose()`
- [ ] 3.2 Assign the focus nodes to their respective `TextField` widgets via the
  `focusNode` parameter
- [ ] 3.3 Add `bool _anyFieldFocused` and `TextEditingController? _lastFocused` state
  fields
- [ ] 3.4 Attach a shared `_onFocusChange` listener to both nodes in `initState()`;
  update `_anyFieldFocused` and `_lastFocused` inside a `Future.microtask` so
  field-to-field transitions do not cause a flicker

## 4. Key Panel Widget

- [ ] 4.1 Create a `_KeyPanel` private widget (stateless) that accepts an
  `onSymbol(String)` callback and renders a single row of `TextButton`s for
  `+`, `-`, `*`, `/`, `|`, `^`, `(`, `)`
- [ ] 4.2 Style the panel with a `Material` / `Container` background that visually
  separates it from the scroll content (e.g., a top divider or slight elevation)

## 5. Symbol Insertion

- [ ] 5.1 Implement `_insertSymbol(String symbol)` on `_FreeformScreenState`: insert
  at cursor (or append if selection is invalid) in `_lastFocused ?? _inputController`,
  call `setState`, and call `_debounceEvaluate` in real-time mode
- [ ] 5.2 Wire the `_KeyPanel.onSymbol` callback to `_insertSymbol`
- [ ] 5.3 Add the `_KeyPanel` to the bottom of the `Column` body, shown conditionally
  on `_anyFieldFocused`

## 6. Final Checks

- [ ] 6.1 Run `flutter test --reporter failures-only` — all tests pass
- [ ] 6.2 Run `flutter analyze` — no lint errors
- [ ] 6.3 Update `CHANGELOG.md` if requested
