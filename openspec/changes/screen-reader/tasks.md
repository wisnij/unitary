# Tasks: screen-reader

## 1. Speech formatting

- [ ] 1.1 Write unit tests for `formatSpeech` in `test/shared/utils/quantity_formatter_test.dart`: symbol wording (`=`, `/`, `^`, `×`), positive/negative signed exponents, unsigned `2e3` left unchanged, plain strings pass through
- [ ] 1.2 Implement `formatSpeech(String)` in `lib/shared/utils/quantity_formatter.dart` per the quantity-formatter delta spec

## 2. Freeform result live region

- [ ] 2.1 Write tests for `resultSpeechLabel(EvaluationResult)`: exhaustive over all sealed variants (non-empty label each), "Error: " prefix on `EvaluationError`, reciprocal line included in conversion variants, idle speaks instruction + example
- [ ] 2.2 Implement `resultSpeechLabel` beside `ResultDisplay` as an exhaustive `switch` over `EvaluationResult`, composing spoken labels from the variants' display strings via `formatSpeech`
- [ ] 2.3 Write widget tests via `tester.getSemantics`: `ResultDisplay` node has `liveRegion` set with the expected label per state (both evaluation modes), raw result `Text` widgets excluded from semantics
- [ ] 2.4 Wrap `ResultDisplay` content in `Semantics(liveRegion: true, label: ...)` + `ExcludeSemantics`, per design D1

## 3. Worksheet cell errors

- [ ] 3.1 Write widget tests: erroring cell has empty field text and the error string as `errorText`; error semantics exposed; non-error cells unchanged; red `style` override gone
- [ ] 3.2 Change error rendering in `worksheet_screen.dart` from red in-field text to `errorText` + empty field value; remove the error text `style` override
- [ ] 3.3 Verify table row alignment with an error present (label cell vs. taller input cell) in a widget test and visually

## 4. Idle-example button and copy actions

- [ ] 4.1 Write semantics tests: idle example exposes button flag + tap action (and non-idle states do not); each copy site (worksheet cell, About rows, unit detail definition) exposes its labeled `CustomSemanticsAction` whose invocation copies to the clipboard
- [ ] 4.2 Add `button: true` semantics to the idle-example tap target in `ResultDisplay`
- [ ] 4.3 Add `CustomSemanticsAction(label: 'Copy value')` to the worksheet value-cell copy gesture in `worksheet_screen.dart`
- [ ] 4.4 Add labeled `CustomSemanticsAction`s to the About screen copy rows and the unit entry detail definition copy gesture

## 5. Verification and documentation

- [ ] 5.1 Run `flutter test --reporter failures-only` and `flutter analyze`; fix any failures
- [ ] 5.2 On-device TalkBack pass: result announcements in both evaluation modes, worksheet error reading, actions menu shows copy actions, idle example announced as button
- [ ] 5.3 Update `doc/implementation_plan.md` (check off the screen-reader item under Phase 9) and `doc/design_progress.md`; note the Phase 12 deferrals (per-row error announcements, label-cell transfer gesture labeling)
- [ ] 5.4 Update README project status if warranted
