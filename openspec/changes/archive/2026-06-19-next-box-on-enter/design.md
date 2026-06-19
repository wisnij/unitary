## Context

The freeform screen (`freeform_screen.dart`) hosts two text fields, "Convert
from" (`_inputController` / `_inputFocus`) and "Convert to" (`_outputController`
/ `_outputFocus`), each rendered through a `CompletionField` wrapper around a
`TextField`.  Both fields currently pass `onSubmitted: (_) => _evaluate()` and
use the inner `TextField`'s default `TextInputAction`, so pressing Enter
evaluates and then lets the platform dismiss focus for both fields identically.

`CompletionField` does not currently expose a `textInputAction`, so the inner
`TextField` falls back to the platform default.

## Goals / Non-Goals

**Goals:**

- Enter in "Convert from" advances focus to "Convert to".
- Enter in "Convert to" dismisses focus (current behaviour).
- Evaluation still fires on Enter in both fields so on-submit mode is unaffected.

**Non-Goals:**

- No change to debounced/real-time evaluation behaviour.
- No change to the symbol key panel, swap button, history, or completion overlay.
- No new keyboard shortcuts beyond the Enter/submit action.

## Decisions

**Decision 1: Move focus in the input field's `onSubmitted`, not via raw key
handling.**  The `TextField.onSubmitted` callback already fires on Enter for
single-line fields, so the focus move is implemented by calling
`_outputFocus.requestFocus()` inside the "Convert from" field's `onSubmitted`
handler (after `_evaluate()`).  This reuses the existing, tested submit path
rather than adding a `Focus`/`KeyboardListener` wrapper.

- Alternative considered: intercept the raw Enter `KeyEvent`.  Rejected as more
  code and redundant with `onSubmitted`.

**Decision 2: Set `textInputAction: TextInputAction.next` on the "Convert from"
field and `TextInputAction.done` on the "Convert to" field.**  This makes the
on-screen keyboard's action key show "next" / "→" for the input and "done" for
the output, matching the new focus-advance behaviour and the existing
dismiss-on-output behaviour.  `CompletionField` gains an optional
`textInputAction` parameter forwarded to its inner `TextField`.

- Alternative considered: rely solely on `onSubmitted` and leave the action key
  visuals as the default.  Rejected because the keyboard action label would not
  reflect the actual behaviour, and `TextInputAction.next` is the idiomatic
  Flutter signal for "advance to next field".

**Decision 3: Keep `_evaluate()` on both submit handlers.**  Preserves on-submit
evaluation mode (where Enter is the only evaluation trigger) and is a no-op
beyond a debounce in real-time mode.

## Risks / Trade-offs

- [On `TextInputAction.next`, Flutter's default `onEditingComplete` may itself
  attempt to move focus to the next focusable node, which could conflict with an
  explicit `requestFocus`.] → The explicit `_outputFocus.requestFocus()` in
  `onSubmitted` targets the intended field directly; if default traversal lands
  elsewhere, override `onEditingComplete` to no-op on the input field.  Verify on
  device/web during implementation.

- [Web focus quirks: `requestFocus()` can trigger a browser select-all, as seen
  with the completion overlay and key panel.] → If observed, re-apply a collapsed
  selection in a post-frame callback, mirroring the existing
  `_insertCompletion` / `_insertSymbol` workaround.
