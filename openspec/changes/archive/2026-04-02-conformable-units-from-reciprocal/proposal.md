## Why

The "Browse conformable units" AppBar button is disabled when the freeform
result is `ReciprocalConversionSuccess`, because the button's enabled logic is
a whitelist of result types that carry a well-defined quantity.  When new result
types are added (as happened with `ReciprocalConversionSuccess`), they must be
manually added to the whitelist or the button silently stays disabled.  The
safer approach is an exhaustive `switch` over the sealed `EvaluationResult`
subtypes: the compiler enforces that every subtype is explicitly handled, so a
newly added result type cannot be silently forgotten.

## What Changes

- The button enabled condition in `home_screen.dart` replaces the whitelist
  (`is EvaluationSuccess || is ConversionSuccess || …`) with an exhaustive
  `switch` expression over `EvaluationResult` that returns `false` for
  `EvaluationIdle`, `EvaluationError`, and `FunctionDefinitionResult`, and
  `true` for all other subtypes (`EvaluationSuccess`, `ConversionSuccess`,
  `UnitDefinitionResult`, `FunctionConversionResult`,
  `ReciprocalConversionSuccess`).
- The same post-force-evaluate modal-open guard in `freeform_screen.dart` is
  updated to use the same exhaustive switch.
- `ReciprocalConversionSuccess` is thereby enabled, and future result types
  will cause a compile error if not explicitly handled in both locations.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `conformable-units-ui`: The requirement describing which result types enable
  the button changes from a whitelist to an exhaustive switch, adding
  `ReciprocalConversionSuccess` as an enabled state.

## Impact

- `lib/features/freeform/presentation/home_screen.dart` — `browseEnabled`
  condition
- `lib/features/freeform/presentation/freeform_screen.dart` — post-force-evaluate
  modal-open guard in `initState` subscription
- `openspec/specs/conformable-units-ui/spec.md` — update the enabled-state
  requirement and its scenarios
