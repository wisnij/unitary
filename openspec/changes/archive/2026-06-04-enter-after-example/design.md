## Context

The freeform screen shows an idle hint when no expression is entered.  Tapping the hint copies the example expression into the "Convert from" field and triggers evaluation.  Currently whichever field had focus before the tap retains it (or the "Convert from" field gains it), so the on-screen keyboard remains open — which is unexpected: the user only wanted to see the result, not to continue editing.  This applies even if the "Convert to" field was focused before the tap.

The desired behaviour mirrors pressing Enter on a physical keyboard: evaluate and dismiss focus.

## Goals / Non-Goals

**Goals:**

- Dismiss focus (and therefore the on-screen keyboard) from all freeform fields immediately after tapping the idle example, regardless of which field was focused beforehand.

**Non-Goals:**

- Changing how explicit Enter / submit works in any other scenario.
- Dismissing focus after history-entry taps or other auto-fill triggers (those can be addressed separately if desired).

## Decisions

### Unfocus via `FocusScope.of(context).unfocus()` after inserting the text

The tap handler in `FreeformScreen` already has access to a `BuildContext`.  Calling `FocusScope.of(context).unfocus()` after setting the controller text and triggering evaluation is the standard Flutter idiom for programmatically dismissing focus from the entire scope — this removes focus from both the "Convert from" and "Convert to" fields in one call, regardless of which was active.

**Alternative considered**: calling `_fromController.value = ...` and then posting a `WidgetsBinding.instance.addPostFrameCallback` to unfocus.  This is unnecessary here because the tap originates outside the text field — there is no pending focus request to race against — so a direct `unfocus()` call suffices.

## Risks / Trade-offs

- **Minimal risk**: the change is a single additional call in one tap handler.  It does not affect any other interaction path.
- On desktop/web there is no on-screen keyboard, so `unfocus()` has no visible effect but is harmless.
