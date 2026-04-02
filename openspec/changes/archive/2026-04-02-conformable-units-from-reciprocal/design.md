## Context

The "Browse conformable units" button in the freeform AppBar is enabled via a
whitelist of `EvaluationResult` subtypes.  `ReciprocalConversionSuccess` was
added in a later phase and was never added to the whitelist, leaving the button
disabled during reciprocal conversions.  The same whitelist appears in two
places: the `browseEnabled` expression in `home_screen.dart` and the
post-force-evaluate guard in `freeform_screen.dart`.

`EvaluationResult` is a `sealed` class with eight known subtypes.  The Dart
compiler enforces exhaustiveness on `switch` expressions over sealed types.

## Goals / Non-Goals

**Goals:**

- Fix the button being disabled for `ReciprocalConversionSuccess`.
- Replace both whitelist checks with exhaustive `switch` expressions so future
  `EvaluationResult` subtypes cannot be silently forgotten.

**Non-Goals:**

- Changes to what the conformable-units modal displays or how it computes
  conformable entries.
- Changes to `ReciprocalConversionSuccess` itself or the reciprocal conversion
  logic.

## Decisions

**Use an exhaustive `switch` expression rather than a blacklist of `is not` checks.**

Both approaches fix the immediate bug.  An exhaustive `switch` is preferred
because:

1. The Dart compiler flags any future `EvaluationResult` subtype that is not
   explicitly handled, making the omission a compile error rather than a silent
   runtime bug.
2. The intent is self-documenting: each subtype gets an explicit `true` or
   `false`, making it easy to audit which states produce a usable quantity.

A top-level helper `conformableBrowseEnabled(EvaluationResult)` SHALL be
defined in `freeform_state.dart` and shared between the two call sites.
Co-locating it with the `EvaluationResult` sealed class avoids a cross-feature
import (from `freeform_screen.dart` into `home_screen.dart`) and keeps the
enabled-state logic adjacent to the types it switches on.

**Alternative considered: add `ReciprocalConversionSuccess` to the existing
whitelist.**  Rejected — it fixes only the immediate bug and leaves the
structural fragility in place.

## Risks / Trade-offs

- **Compiler enforcement only covers sealed subtypes in the same library.**
  `EvaluationResult` and all subtypes are in `freeform_state.dart`, so this
  is satisfied.  No risk here.

- **Two files must stay in sync.**  The switch must be consistent in both
  `home_screen.dart` and `freeform_screen.dart`.  Extracting the helper
  eliminates this risk.

## Open Questions

_(none)_
