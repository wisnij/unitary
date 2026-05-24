## Why

The Browse screen exposes the full unit catalog, but switching to it while
composing a freeform expression breaks the flow — the user must navigate away,
find the unit name, remember it, navigate back, and retype it.  Predictive
completion surfaces the same catalog inline as the user types, making unit
discovery a seamless part of expression entry without the context-switching
overhead.

## What Changes

- A suggestion overlay appears below the focused expression field whenever the
  cursor is inside a partial identifier.
- Suggestions are drawn from the full unit repository (units, functions,
  constants, and named prefixes) and filtered to those whose primary ID or any
  alias starts with the token under the cursor (case-insensitive).
- Tapping a suggestion replaces the partial token at the cursor position with
  the selected identifier and moves the cursor to just after it.
- The overlay dismisses when the field loses focus, when the token is cleared,
  or when the cursor moves outside an identifier.
- A maximum of ~8 suggestions are shown at a time; the list is scrollable.
- Suggestions are ranked: exact-prefix matches on primary ID first, then alias
  matches, both groups sorted alphabetically.

## Capabilities

### New Capabilities

- `predictive-completion`: Inline unit/function/constant identifier suggestions
  in freeform expression fields; filters by prefix of the token under the
  cursor; tap-to-insert replaces the partial token.

### Modified Capabilities

<!-- No existing spec-level behavior is changing. -->

## Impact

- `lib/features/freeform/presentation/freeform_screen.dart` — add overlay
  management logic to each expression `TextField`.
- `lib/features/freeform/presentation/widgets/` — new
  `completion_overlay.dart` widget.
- `lib/features/freeform/state/` — new `completion_provider.dart` with the
  filtering and ranking logic.
- `lib/core/domain/models/unit_repository.dart` — may need a new
  `suggestCompletions(String prefix)` method.
- No new package dependencies (Flutter's `Overlay` widget is used).
