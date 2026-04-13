## Context

The freeform screen has two `TextField` widgets: "Convert from" (input) and "Convert to" (output).  Both are managed by `TextEditingController` instances owned by `_FreeformScreenState`.  Evaluation is triggered by `_evaluate()`, which reads both controllers and delegates to `freeform_provider`.

Currently there is no way to invert a conversion without manually editing both fields.

## Goals / Non-Goals

**Goals:**

- Add a swap `IconButton` between the two text fields.
- The button is enabled only when both fields are non-empty.
- Tapping the button exchanges the two field contents and immediately re-evaluates.

**Non-Goals:**

- Persisting the swapped state across sessions (the existing in-session behaviour is sufficient).
- Animating the swap (out of scope for MVP).
- Adding swap behaviour to the worksheet screen.

## Decisions

**Where to place the button**

The button sits between the two `TextField` widgets, replacing the fixed `SizedBox(height: 16)` spacer.  A `Row` centred on the horizontal axis keeps the button visually connected to both fields without adding padding complexity.  Alternative: a floating button overlaid on the fields — rejected because it obscures field content on small screens.

**Icon choice**

`Icons.swap_vert` (vertical swap arrows) clearly communicates the swapping of the two stacked fields.  `Icons.compare_arrows` is a reasonable alternative but is less specific.

**Enabled state**

Compute `_canSwap` inline in `build()` as `_inputController.text.isNotEmpty && _outputController.text.isNotEmpty`.  The output field's `onChanged` currently does not call `setState`, so it must be updated to do so (mirrors the existing pattern on the input field's `onChanged`).  No new state variable is needed.

**Swap implementation**

In the `onPressed` callback: capture both values, set both controllers, cancel any pending debounce, then call `_evaluate()` directly (same pattern as `_fillOutputField`).

## Risks / Trade-offs

- Minimal risk — the change is confined to a single `StatefulWidget` and touches no shared state.
- The output `onChanged` change (adding `setState`) is a minor behavioural fix, not a feature addition; it was already required for the clear button on the input field.
