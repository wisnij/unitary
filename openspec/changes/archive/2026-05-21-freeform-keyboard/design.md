## Context

The freeform screen lets users type mathematical expressions containing syntax
characters (`^`, `|`, `*`, `(`, `)`, etc.) that are difficult to reach on a standard
mobile soft keyboard.  The current body layout is a single `SingleChildScrollView`
with no mechanism for supplementary input.  The goal is to surface a symbol row above
the system keyboard, tied to field focus, without replacing normal text input.

## Goals / Non-Goals

**Goals:**

- Show a row of 8 symbol buttons (`+`, `-`, `*`, `/`, `|`, `^`, `(`, `)`) above the
  system keyboard whenever either freeform text field is focused.
- Insert the tapped symbol at the cursor position in the active field and trigger
  re-evaluation.
- Dismiss the panel when neither field is focused.
- Introduce no new package dependencies.

**Non-Goals:**

- Replace the system keyboard or prevent it from appearing.
- Support digit input or backspace in the supplementary panel.
- Apply to the worksheet or browse screens.
- Animate the panel independently (it moves with the keyboard).

## Decisions

### D1: Column body layout instead of bare SingleChildScrollView

**Decision:** Restructure the `Scaffold` body from a bare `SingleChildScrollView` to
a `Column` containing an `Expanded(SingleChildScrollView(...))` and, conditionally, a
`_KeyPanel` widget pinned at the bottom.

**Rationale:** Flutter's default `resizeToAvoidBottomInset: true` shrinks the
`Scaffold` body to exclude the keyboard area.  A `Column` with an `Expanded` scroll
view fills whatever space remains, and any widget appended at the bottom of the
`Column` naturally sits between the content and the system keyboard — exactly the
"above keyboard" position — without manual `viewInsets` arithmetic or overlay
positioning.

**Alternative considered:** `Positioned` widget inside a `Stack` keyed to
`MediaQuery.viewInsets.bottom` with `resizeToAvoidBottomInset: false`.  Rejected
because it requires manual safe-area and scroll-target math that the default scaffold
behaviour already handles for free.

**Alternative considered:** `Scaffold.bottomNavigationBar` slot.  Would also appear
above the keyboard, but repurposes a navigation-semantics slot for an input accessory,
which is misleading and affects the body layout even when the panel is hidden.

### D2: Focus tracking via two FocusNodes with post-frame-callback debounce

**Decision:** Attach a `FocusNode` to each `TextField`.  Both nodes share a single
listener that sets `_anyFieldFocused` and updates `_lastFocused` (a
`({TextEditingController ctrl, FocusNode focus})?` record).  The hide decision
(setting `_anyFieldFocused = false`) is deferred via
`WidgetsBinding.instance.addPostFrameCallback` to prevent the panel from flickering
when focus moves directly from one field to the other.

**Rationale:** When the user taps from one field to the other, the first field fires
"lost focus" before the second fires "gained focus".  Without the deferral, the panel
would briefly disappear and reappear.  `addPostFrameCallback` fires after the frame is
fully committed, which is the safest point to read the settled focus state.  It is also
consistent with the post-frame callback already used in `_insertSymbol` for cursor
restoration.

### D3: Cursor insertion via TextEditingController.value

**Decision:** On symbol tap, replace the current selection in `_lastFocused.ctrl`
(falling back to `_inputController` if none is tracked) using:

```dart
ctrl.value = TextEditingValue(
  text: ctrl.text.replaceRange(start, end, symbol),
  selection: TextSelection.collapsed(offset: start + symbol.length),
);
```

Then call `_debounceEvaluate` in real-time mode.  (No explicit `setState` needed —
mutating `controller.value` already notifies listeners and triggers a rebuild.)

**Rationale:** Replacing `controller.value` atomically updates text and cursor in one
frame with no visual glitch.  The button tap does not steal focus on Android (the
system keyboard and cursor remain in place), so insertion lands exactly where the user
expects.

### D4: Panel always visible on desktop/web

**Decision:** On desktop (macOS/Windows/Linux) and web, `_showPanel` returns `true`
unconditionally.  On mobile (Android/iOS) it returns `_anyFieldFocused`.

**Rationale:** On desktop there is no system keyboard, so the "appears above keyboard
on focus" pattern does not apply.  Showing the panel permanently avoids the event-loop
timing problem where a button click fires `blur` on the text field before `onPressed`,
which on web causes the panel to disappear before the tap completes.  A permanently
visible panel is also the more natural UX for desktop — the panel takes no more space
than a toolbar and is always ready.

## Risks / Trade-offs

- **Platform behaviour assumed:** The "button tap does not steal focus" property is
  true on Android but less certain on iOS.  If iOS focus behaviour differs, the panel
  may close on tap.  → Mitigation: test on iOS before release; add `onTapDown` +
  `FocusScope.of(context).requestFocus(node)` restoration if needed.

- **Invalid selection edge case:** If the user has never tapped a field, or the
  selection is invalid (e.g., `sel.start == -1`), insertion appends to the end of the
  input controller text.  This is a safe fallback for a recoverable edge case.

## Open Questions

None.
