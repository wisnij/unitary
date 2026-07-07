# Tasks: screen-reader

## 1. Speech formatting

- [x] 1.1 Write unit tests for `formatSpeech` in `test/shared/utils/quantity_formatter_test.dart`: symbol wording (`=`, `/`, `^`, `×`), positive/negative signed exponents, unsigned `2e3` left unchanged, plain strings pass through
- [x] 1.2 Implement `formatSpeech(String)` in `lib/shared/utils/quantity_formatter.dart` per the quantity-formatter delta spec

## 2. Freeform result live region

- [x] 2.1 Write tests for `resultSpeechLabel(EvaluationResult)`: exhaustive over all sealed variants (non-empty label each), "Error: " prefix on `EvaluationError`, reciprocal line included in conversion variants, idle speaks instruction + example
- [x] 2.2 Implement `resultSpeechLabel` beside `ResultDisplay` as an exhaustive `switch` over `EvaluationResult`, composing spoken labels from the variants' display strings via `formatSpeech`
- [x] 2.3 Write widget tests via `tester.getSemantics`: `ResultDisplay` node has `liveRegion` set with the expected label per state (both evaluation modes), raw result `Text` widgets excluded from semantics
- [x] 2.4 Wrap `ResultDisplay` content in `Semantics(liveRegion: true, label: ...)` + `ExcludeSemantics`, per design D1

## 3. Worksheet cell errors

- [x] 3.1 Write widget tests: erroring cell shows the message in-field in the error color with an `error_outline` prefix icon carrying an "Error" semantic label; error and normal fields render at the same height; non-error cells unchanged
- [x] 3.2 Keep error rendering in-field in `worksheet_screen.dart` and add the freeform-style error prefix icon with overridden `prefixIconConstraints` (revised from the original `errorText` approach, which made erroring rows taller — see design D3)
- [x] 3.3 Verify row height uniformity with an error present in a widget test and visually (on-device visual check covered by 5.2)
- [x] 3.4 Mark erroring fields `SemanticsValidationResult.invalid` via an inner `Semantics` wrapping the `TextField` directly (merges into the field's own node; on the outer copy-action wrapper it would not), with a test asserting invalid on error fields only

## 4. Idle-example button and copy actions

- [x] 4.1 Write semantics tests: idle example exposes button flag + tap action (and non-idle states do not); each copy site (worksheet cell, About rows, unit detail definition) exposes its labeled `CustomSemanticsAction` whose invocation copies to the clipboard
- [x] 4.2 Add `button: true` semantics to the idle-example tap target in `ResultDisplay`
- [x] 4.3 Add `CustomSemanticsAction(label: 'Copy value')` to the worksheet value-cell copy gesture in `worksheet_screen.dart`
- [x] 4.4 Add labeled `CustomSemanticsAction`s to the About screen copy rows and the unit entry detail definition copy gesture

## 5. Verification and documentation

- [x] 5.1 Run `flutter test --reporter failures-only` and `flutter analyze`; fix any failures (1953 tests passing, no analyzer issues)
- [x] 5.5 Fix misplaced TalkBack focus rectangles on worksheet fields (device-pass finding): `RenderTable` double-applies the cell offset to semantics transforms for cells without the `cell` role; wrap all worksheet cells in `TableCell` (which supplies `Semantics(role: SemanticsRole.cell)`) and add a regression test asserting field semantics rects match their render rects — see design D6
- [x] 5.2 On-device TalkBack pass: result announcements in both evaluation modes, worksheet error reading (check how the invalid field state and the icon's "Error" label combine — drop the icon's `semanticLabel` if redundant), error icon appearance in the dense fields, actions menu shows copy actions, idle example announced as button.  Findings fixed during the pass: misplaced worksheet focus rectangles (5.5 / design D6), `|` missing from the speech map, "Result: " prefix on success announcements
- [x] 5.3 Update `doc/implementation_plan.md` (check off the screen-reader item under Phase 9) and `doc/design_progress.md`; note the Phase 12 deferrals (per-row error announcements, label-cell transfer gesture labeling)
- [x] 5.4 Update README project status if warranted
- [x] 5.6 Delete the orphaned `WorksheetRowWidget` and its test (verification cleanup — the test encoded the superseded red-text error behavior)
