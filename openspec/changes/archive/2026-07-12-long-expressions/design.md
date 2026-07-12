## Context

The freeform screen's two expression fields are stock single-line `TextField`s wrapped by `CompletionField` (`lib/features/freeform/presentation/widgets/completion_field.dart`).  Long expressions scroll horizontally inside the field with no clipping indicator, and editing off-screen text requires dragging.  The result display already soft-wraps (plain `Text` widgets), so output and input behave inconsistently.

Existing behavior that must be preserved:

- **Enter-to-submit** (`freeform-enter-navigation` spec): "Convert from" uses `textInputAction: next` and its `onSubmitted` evaluates and advances focus; "Convert to" uses `done` and evaluates.
- **Completion overlay anchoring** (`predictive-completion` spec): the overlay anchors to the whole field via `CompositedTransformTarget`/`Follower` (top/bottom-left corners) and flips above/below based on the field's center relative to the viewport.
- The fields sit in a `Column` inside a `SingleChildScrollView` under `ReadableWidth`, so vertical growth is already tolerated by the layout.
- The lexer's `_skipWhitespace()` already treats `\n` (and `\r`) as whitespace, so a literal newline in the text — only reachable by pasting — cannot break evaluation or `tokenAtCursor`.

This resolves open UX question #2 (see `doc/design_progress.md`), decided in exploration as: soft-wrap, unbounded vertical growth, Enter still submits, no special handling for swap/history restore.

## Goals / Non-Goals

**Goals:**

- Long expressions are fully visible: the field soft-wraps and grows vertically without bound.
- Enter / the keyboard action key keeps its submit semantics on both fields; it never inserts a newline.
- The completion overlay continues to position correctly against a multi-line field.

**Non-Goals:**

- No cap-and-scroll behavior inside the field (unbounded growth was chosen; the page scrolls).
- No changes to the swap button, history restore, or history list rendering — a long restored expression simply renders taller.
- No changes to worksheet fields (template-defined expressions; revisit with Phase 12 worksheet editing).
- No input formatter to strip pasted newlines — the lexer already treats them as whitespace; a pasted newline is a cosmetic hard break only.

## Decisions

### D1: Soft-wrap via `maxLines: null` on the inner `TextField`

Set `maxLines: null` (with the default `minLines`) on the `TextField` inside `CompletionField`, so every `CompletionField` instance wraps.  Alternatives considered:

- **Capped growth (`maxLines: 4` + internal scroll)** — rejected: reintroduces hidden content at a different threshold, and the page already scrolls so unbounded height costs nothing.
- **Tap-to-expand editor** — rejected as over-engineered for expressions that realistically span 1–3 lines.
- **Overflow fade/ellipsis on a single-line field** — rejected: fixes visibility but not editability.

`CompletionField` is only used by the two freeform fields, so changing the wrapper directly (rather than adding a `maxLines` parameter) is the simplest correct scope.  If a future caller needs a single-line variant, a parameter can be added then.

### D2: Keep Enter as submit via explicit `textInputAction`

With `maxLines: null`, Flutter defaults `keyboardType` to `TextInputType.multiline`, and an unset `textInputAction` would default to `newline` (Enter inserts a line break).  Both call sites already pass an explicit `textInputAction` (`next` / `done`), which overrides that default: the IME action button and hardware Enter trigger `onSubmitted` instead of inserting a newline.  No newline characters can therefore be typed; only pasting can introduce one, and the lexer treats it as whitespace.

Alternative — forcing `keyboardType: TextInputType.text` — rejected: unnecessary once the action is explicit, and the multiline keyboard type is what enables wrapping-friendly IME behavior on Android.

### D3: No changes to overlay positioning logic

`CompositedTransformFollower` recomputes from the field's render box each frame, so a taller field moves the overlay's anchor edge automatically.  The above/below flip in `_updateAbove()` uses the field's center, which remains meaningful for a multi-line field.  Verified by inspection; a widget test pins the overlay-below-a-two-line-field case.

## Risks / Trade-offs

- [Field height shifts while typing as text wraps] → Inherent to wrapping; the layout motion is small and the page scroll position is unaffected above the field.  Accepted.
- [The clear-button `suffixIcon` vertically centers in a taller field] → Material default behavior; acceptable.  If it looks wrong in practice, `InputDecoration` alignment can be adjusted in a follow-up.
- [Existing widget tests may assume single-line geometry (e.g. field heights, overlay offsets)] → Run the freeform and completion test suites early in implementation and adjust assertions deliberately, not reflexively.
- [Pasted text containing newlines renders a hard line break] → Harmless to evaluation (lexer skips `\n`); accepted as a cosmetic edge rather than adding an input formatter.
