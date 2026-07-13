# rebuild-scope Specification

## ADDED Requirements

### Requirement: Freeform keystroke rebuild bound

A single keystroke in a freeform expression field SHALL trigger at most two rebuilds of the freeform screen subtree: one immediate rebuild (button-state refresh) and one when the debounced evaluation result arrives.  Widget tests SHALL pin this bound with rebuild-count probes so that rebuild storms (three or more builds per keystroke) cannot ship unnoticed, while allowing a future state-lifting refactor to narrow the scope below the bound.

The fact that the *entire* screen subtree (operator key panel, app bar, both fields) rebuilds — rather than only the widgets that depend on the changed state — is a recorded follow-up finding (see measurements.md and the deferred freeform-notifier refactor), not behavior these tests endorse; the tests assert only the upper bound.

#### Scenario: Keystroke rebuild bound

- **WHEN** a single character is typed into a freeform expression field in a widget test instrumented with rebuild-count probes, and the evaluation debounce elapses
- **THEN** the probed freeform screen subtree records at most two rebuilds

### Requirement: Worksheet edit rebuild bound

A single edit to a worksheet value cell SHALL trigger at most one rebuild of the worksheet screen subtree, in which the row value fields display the recomputed values.  (The worksheet recompute path is synchronous — `onRowChanged` updates the source row and runs the engine in the same turn; there is no worksheet-side debounce, contrary to older design notes.)  Widget tests SHALL pin this bound with rebuild-count probes.

#### Scenario: One rebuild per cell edit

- **WHEN** a value is typed into a worksheet cell in a widget test instrumented with rebuild-count probes
- **THEN** the probed worksheet screen subtree records at most one rebuild and the other rows show recomputed values

### Requirement: Assertions derived from verified behavior

The rebuild-scope assertions SHALL encode behavior confirmed by a manual DevTools rebuild-tracking pass on a real device, not assumed behavior.  Where the observed scope was broader than intended, the discrepancy MUST be recorded as a follow-up finding (not pinned as endorsed behavior), and the tests SHALL assert upper bounds that a narrowing refactor would still satisfy.

#### Scenario: Manual pass precedes test authoring

- **WHEN** the rebuild-scope tests are written
- **THEN** the asserted bounds match the rebuild behavior observed during the documented DevTools pass (freeform: two subtree builds per keystroke; worksheet: one per edit), and the observed broader-than-intended freeform scope is recorded as a follow-up candidate rather than encoded as expected behavior
