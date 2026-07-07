# Result Announcements

## Purpose

Makes the freeform evaluation result audible to assistive technology: the
result display is a polite live region whose spoken label is a speech-friendly
rendering of the current evaluation state, so screen-reader users hear each
settled result (including errors) without moving focus.

## Requirements

### Requirement: Result display is a polite live region

The freeform result display SHALL be exposed to the semantics tree as a live
region (`Semantics.liveRegion`) whose accessible label is the spoken form of
the current `EvaluationResult`.  The live region SHALL be active
unconditionally, in both real-time and on-submit evaluation modes.  The
label SHALL change whenever the evaluation state changes, so assistive
technology announces each settled result politely (queued behind current
speech, without moving focus).

The visible result text SHALL be excluded from the semantics tree
(`ExcludeSemantics`) so the spoken label is not double-read alongside the raw
text nodes.

#### Scenario: Result announced after evaluation settles

- **WHEN** an evaluation completes and the result display changes to a success
  state
- **THEN** the result display's semantics node has `liveRegion` set and its
  label is the spoken form of that result

#### Scenario: Live region active regardless of evaluation mode

- **WHEN** the evaluation mode setting is either real-time or on-submit
- **THEN** the result display's semantics node has `liveRegion` set

#### Scenario: Visible text not double-read

- **WHEN** the result display renders any evaluation state
- **THEN** the raw result `Text` widgets contribute no separate semantics nodes
  beside the composed label

### Requirement: Every evaluation state has a spoken form

A spoken label SHALL be defined for every variant of the sealed
`EvaluationResult` type, derived from the variant's display strings via the
speech formatting function (see the `quantity-formatter` capability), with
multi-line variants joined into readable sentences.  The mapping SHALL be
implemented as an exhaustive `switch` over the sealed type, so that adding a
new variant without a spoken form is a compile-time error.

- The idle state SHALL speak the instruction line and, when present, the
  example hint.
- Every success-type state (any variant other than idle and error) SHALL begin
  with "Result: ", so the announcement is distinguishable from the screen
  reader's echo of the typed input that immediately precedes it.
- The error state's spoken form SHALL begin with "Error: " followed by the
  error message.
- Conversion variants that display a reciprocal line SHALL include it in the
  spoken form after the primary result.

#### Scenario: All variants covered

- **WHEN** each `EvaluationResult` variant is passed to the spoken-form mapping
- **THEN** every variant produces a non-empty spoken label

#### Scenario: Error state announced as an error

- **WHEN** the evaluation state is `EvaluationError` with message
  `Unknown unit: "xyzzy"`
- **THEN** the spoken label is `Error: Unknown unit: "xyzzy"`

#### Scenario: Conversion result spoken with operators worded

- **WHEN** the evaluation state is a conversion success whose display string is
  `= 8 kg m / s^2`
- **THEN** the spoken label renders the symbols in words, e.g.
  `Result: equals 8 kg m per s to the power 2`

#### Scenario: Success announcement marked as a result

- **WHEN** the user types `2*3` and the evaluation settles
- **THEN** the spoken label begins with "Result: " (e.g. `Result: 6`), so the
  announcement following the input echo is heard as output, not more input
