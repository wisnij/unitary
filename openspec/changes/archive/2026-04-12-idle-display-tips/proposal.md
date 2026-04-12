## Why

The freeform screen's idle state currently shows a plain "Enter an expression" placeholder, which gives new users no sense of what kinds of expressions the app accepts.  Replacing it with a randomly chosen example expression (e.g. "60 mph") gives an immediate, concrete hint about the app's capabilities without requiring any interaction.

## What Changes

- The idle result display shows two lines of text: a fixed instruction line ("Enter an expression above.") and a randomly selected example line ("Try: 60 mph").
- The example is chosen once at app launch and remains fixed until the user enters input.
- Both lines are styled as a placeholder/hint (muted colour) to distinguish them from real output.
- The example set is curated and hardcoded, covering a range of features: unit conversions, SI prefixes, constants, defined functions, compound expressions.
- The `hintText` placeholder strings on the "Convert from" (`"5 miles + 3 km"`) and "Convert to" (`"feet"`) text fields are removed, as the idle display now covers that guidance.
- Tapping the idle display fills the "Convert from" field with the example expression and triggers evaluation.

## Capabilities

### New Capabilities

- `idle-example-hint`: A randomly selected example expression shown in the freeform idle display as a usage hint.

### Modified Capabilities

## Impact

- `lib/features/freeform/presentation/widgets/result_display.dart` — `EvaluationIdle` branch updated to render the example hint with tap callback.
- `lib/features/freeform/presentation/freeform_screen.dart` — passes tap callback to `ResultDisplay`; removes `hintText` from both `TextField` widgets.
- `lib/features/freeform/state/freeform_state.dart` — `EvaluationIdle` gains an optional `example` field; stale "output unit" comment corrected to "output expression".
- `doc/design_progress.md`, `doc/phase4_plan.md` — stale "output unit field" descriptions corrected to "output expression field".
- No new dependencies required.
- No changes to the `EvaluationResult` sealed class hierarchy beyond the `EvaluationIdle` field addition.
