## Why

When a freeform conversion request is made and the input and output dimensions
are exact reciprocals of each other (e.g. `mph` → `s/m`), Unitary currently
returns a dimension-mismatch error.  GNU Units handles this gracefully by
performing the conversion on `1/input` and labeling the result "reciprocal
conversion".  This is a genuinely useful case (e.g. converting fuel economy
between MPG and L/100km), and the current error is unhelpful.

## What Changes

- `FreeformNotifier.evaluate` detects when a conversion fails due to
  non-conformability but the input and output dimensions are exact reciprocals,
  and performs the conversion on the reciprocal of the input quantity instead.
- A new `ReciprocalConversionSuccess` result type is added to the
  `EvaluationResult` hierarchy.
- `ResultDisplay` renders `ReciprocalConversionSuccess` with a prominent
  "reciprocal conversion" notice in a warning/amber color and displays the
  numeric result.
- The result box shows: a "reciprocal conversion" warning notice, then the
  input expression formatted as a reciprocal (`1 / input` or `1 / (input)` when
  the input contains a division operator), then the normal value and reciprocal
  value lines.

## Capabilities

### New Capabilities

- `reciprocal-conversion`: Logic in `FreeformNotifier` to detect reciprocal
  dimensions on conversion failure, perform the reciprocal conversion, produce
  `ReciprocalConversionSuccess`, and render it in `ResultDisplay` with a
  "reciprocal conversion" warning notice.

### Modified Capabilities

- `conversion-request-types`: `ReciprocalConversionSuccess` is a new subtype
  of the sealed `EvaluationResult` class; all exhaustive `switch` statements
  over `EvaluationResult` must be updated to handle it.

## Impact

- `lib/features/freeform/state/freeform_state.dart` — new
  `ReciprocalConversionSuccess` class
- `lib/features/freeform/state/freeform_provider.dart` — reciprocal-dimension
  detection and fallback conversion path
- `lib/features/freeform/presentation/widgets/result_display.dart` — new
  render arm for `ReciprocalConversionSuccess`
- `lib/core/domain/models/dimension.dart` — may need a helper to test whether
  two `Dimension` values are exact reciprocals (all exponent signs flipped)
- No new dependencies required
