## Why

The freeform "Convert from" / "Convert to" fields are single-line text fields: a long expression scrolls horizontally with no visual indication that content is clipped, and editing off-screen text requires dragging through the string.  This resolves open UX question #2 (long-expression handling) from the Phase 9 polish work.  Results already soft-wrap in the result display; inputs should match.

## What Changes

- Both freeform expression fields become soft-wrapping multiline fields that grow vertically without bound as the expression wraps (the surrounding page already scrolls).
- Wrapping is purely visual: no literal newline characters can be entered, so the lexer, parser, history storage, and persistence are untouched.
- Enter / the keyboard action key retains its existing submit behavior ("Convert from" evaluates and advances focus to "Convert to"; "Convert to" evaluates and dismisses) — Enter never inserts a newline.
- The predictive-completion overlay continues to anchor to the field's edges and reposition as the field grows taller.

## Capabilities

### New Capabilities

- `freeform-field-wrapping`: soft-wrap and vertical growth behavior of the freeform expression input fields, including preserved Enter-to-submit semantics and completion-overlay anchoring on multi-line fields.

### Modified Capabilities

None — `freeform-enter-navigation` and `predictive-completion` requirements are unchanged; this change must preserve them, but their spec-level behavior does not change.

## Impact

- `lib/features/freeform/presentation/widgets/completion_field.dart` — the inner `TextField` gains multiline configuration (`maxLines: null` with an explicit non-newline `textInputAction`).
- `lib/features/freeform/presentation/freeform_screen.dart` — no structural change expected; fields sit in a scrollable `Column` that tolerates vertical growth.
- Tests: new widget tests for wrapping/growth; existing enter-navigation and completion-overlay tests must keep passing.
- No new dependencies.  Worksheet fields are out of scope (expressions there are template-defined until Phase 12).
