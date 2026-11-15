## Why

In freeform mode, the predictive-completion dropdown is an overlay anchored to the focused field.  It opens downward over the "Convert to" field and the result display, up to 384 dp tall.  The result is hidden while the user types, including at the moment a short unit such as `cm` becomes valid and the result becomes correct.  Phone is the primary target, and on a phone the overlay covers most of what the user wants to see.

## What Changes

- Replace the dropdown overlay with a **completion area**: an in-flow region between the scrolling content (fields and result) and the operator key panel.  Suggestions never cover a field or the result.
- Show suggestions as **wrapping chips** in rank order, left to right and top to bottom.  The area scrolls vertically when the chips do not fit.  Each chip keeps a 48 dp touch target.
- The area **fills the free space** below the result.  When the free space is less than one chip line (48 dp), the area takes one line from the scrolling content, so the result can scroll partly out of view on very short screens.  This is accepted; such screens are expected to be rare.
- Move the swap button from its own row between the two fields into the app bar, and close the gap between the fields to 16 dp.  This returns about 32 dp of height to the result and the completion area.
- One shared area serves both fields and shows the suggestions for the focused field.  The same design applies at all window widths and on web.
- Remove the `OverlayPortal` / `CompositedTransformFollower` dropdown from `CompletionField`, with its above/below positioning and its 8-row cap.
- Unchanged: which suggestions appear (identifier of at least 2 characters ending at the cursor, in a focused field), suggestion ranking, the kind-specific display and insertion text, the `"<name>, <kind>"` accessible labels, focus restoration after insertion, and the web tap behaviour.

Chips are a trial.  The maintainer will evaluate them on a device and may switch to full-width rows in a later change.

Out of scope, possible follow-ups:

- Smarter ranking, to be handled in a separate change: common units ahead of alphabetical neighbours (for `me`, `mebi-` and `mega-` currently come before `meter`), and a defined order for names that differ only in case.  An exact match already sorts first, because it is a prefix of every other prefix match.
- Keyboard selection of suggestions (arrow keys, Tab) on web.
- Showing conformable units in the area when "Convert to" is focused and empty.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `predictive-completion`: the overlay display requirement is replaced by completion-area display and layout requirements; token detection, tap-to-insert, and the both-fields requirement are reworded for a single shared area.
- `freeform-swap-button`: the button is required in the app bar instead of between the fields; its enabled state and behaviour are unchanged.
- `rebuild-scope`: the keystroke rebuild bound is unchanged; its list of widgets that may rebuild names the swap button's new place and the completion area.
- `semantic-labels`: the completion-suggestion label requirement refers to the completion area instead of the overlay.
- `freeform-field-wrapping`: the requirement that the overlay tracks a multi-line field's edges is removed, because nothing is anchored to the field any more.
- `freeform-ime-config`: the scenario that the app's own completion still works refers to the completion area.
- `color-contrast`: the decorative exemption for the completion overlay's `outlineVariant` border is removed, because the overlay no longer exists.

## Impact

- `lib/features/freeform/presentation/widgets/completion_field.dart`: loses the overlay; stays as the configured `TextField` wrapper.
- New completion-area widget and a small layout widget under `lib/features/freeform/presentation/widgets/`.
- `lib/features/freeform/presentation/freeform_screen.dart`: body layout restructured to host the area above the key panel; swap button moved to the app bar actions.
- Tests: `completion_field_test.dart`, `freeform_screen_test.dart`, `freeform_rebuild_scope_test.dart`, `color_contrast_test.dart` (header comment), and the field-wrapping overlay test.
- `integration_test/screenshots/take_screenshots.dart`: its unfocus workaround for the overlay becomes unnecessary.
- Documentation that describes the overlay (`doc/implementation_plan.md`, `doc/design_progress.md`, and any mention in `doc/architecture.md`).
- No new dependencies.  No change to the core domain, providers, or persisted data.
