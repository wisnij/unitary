## 1. Tests first

- [x] 1.1 Add widget tests for field wrapping: a long expression wraps onto multiple lines and grows the field height; shortening the text shrinks it back; the field's text value contains no newline characters when wrapped
- [x] 1.2 Add widget test that Enter on a wrapped multi-line "Convert from" field triggers evaluation, advances focus to "Convert to", and inserts no newline; same (minus focus advance) for "Convert to"
- [x] 1.3 Add widget test that the completion overlay appears below the current bottom edge of a two-line field
- [x] 1.4 Add test that an expression containing a literal newline (pasted text) evaluates the same as with a space (lexer already treats `\n` as whitespace; added an end-to-end pin in `expression_parser_test.dart`)

## 2. Implementation

- [x] 2.1 Set `maxLines: null` on the inner `TextField` in `CompletionField` (`lib/features/freeform/presentation/widgets/completion_field.dart`); confirm both call sites keep their explicit `textInputAction` (`next` / `done`) so Enter submits instead of inserting a newline
- [x] 2.2 Run the freeform and completion test suites; fix any existing tests that assumed single-line field geometry (none needed fixing — all 639 freeform/parser tests pass unchanged)

## 3. Verification and documentation

- [x] 3.1 Run `flutter test --reporter failures-only` (full suite) and `flutter analyze`; all pass (1993 tests, no analyzer issues)
- [ ] 3.2 Manual check (device or web): long expression wraps and stays editable, Enter behavior unchanged, overlay positions correctly, clear-button placement acceptable on a tall field
- [x] 3.3 Mark open question #2 resolved in `doc/design_progress.md` and check it off in the Phase 9 list in `doc/implementation_plan.md`; update the README status blurb if warranted
