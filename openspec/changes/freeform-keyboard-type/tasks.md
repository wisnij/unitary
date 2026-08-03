# Tasks: freeform-keyboard-type

## 1. Tests (write first, expect red)

- [ ] 1.1 Add widget tests to `test/features/freeform/presentation/widgets/completion_field_test.dart` pinning the inner `TextField`'s `keyboardType == TextInputType.text`, `autocorrect == false`, and `enableSuggestions == false` (red for `autocorrect`/`enableSuggestions` against the current diagnostic code; `maxLines == null` should already be pinned by existing wrapping tests — verify, and add if not)
- [ ] 1.2 Add a widget test confirming the completion overlay still appears when typing a partial identifier (spec: "Predictive completion overlay is unaffected") if not already covered by existing tests — verify existing coverage first

## 2. Implementation

- [ ] 2.1 In `lib/features/freeform/presentation/widgets/completion_field.dart`, replace the `TEMP DIAGNOSTIC round 2` comment with a permanent comment explaining that the explicit `keyboardType: TextInputType.text` is load-bearing (overrides the `maxLines: null`-implied multiline type that triggers Android IME auto-capitalization), and add `autocorrect: false` and `enableSuggestions: false`
- [ ] 2.2 Run the new tests and the existing `freeform-field-wrapping` tests; all green

## 3. Verification and docs

- [ ] 3.1 Full test suite passes (`flutter test --reporter failures-only`) and `flutter analyze` is clean
- [ ] 3.2 On-device check on Android: keyboard opens lowercase, no autocorrect/suggestion strip in the freeform fields, soft-wrap and Enter-to-submit still work
- [ ] 3.3 Update `doc/design_progress.md` (and the README status paragraph if warranted) with a dated entry for this fix
