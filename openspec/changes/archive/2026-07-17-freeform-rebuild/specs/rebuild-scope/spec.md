# rebuild-scope Delta Specification

## MODIFIED Requirements

### Requirement: Freeform keystroke rebuild bound

A single keystroke in a freeform expression field, including its debounced evaluation, SHALL NOT rebuild the freeform screen subtree root at all: only the widgets that depend on the changed state SHALL rebuild — the field-adjacent buttons listening to the text controllers (clear, swap), and the scoped consumers of the evaluation result and history (result display, conformable-browse button, history pane and button).  Widget tests SHALL pin the zero-subtree-rebuild bound with rebuild-count probes, and SHALL also assert the positive effects (the result updates, the buttons react) so the bound cannot pass vacuously.

#### Scenario: Keystroke does not rebuild the screen subtree

- **WHEN** a single character is typed into a freeform expression field in a widget test instrumented with rebuild-count probes, and the evaluation debounce elapses
- **THEN** the probed freeform screen subtree root records zero rebuilds

#### Scenario: Scoped dependents still update

- **WHEN** a keystroke makes both fields non-empty and its debounced evaluation completes
- **THEN** the result display shows the new evaluation result and the clear and swap buttons reflect the new field contents, without a screen-subtree rebuild

### Requirement: Assertions derived from verified behavior

The rebuild-scope assertions SHALL encode behavior confirmed by measurement (a manual DevTools rebuild-tracking pass on a real device, or rebuild-count probes exercising the real screens), not assumed behavior.  Where observed scope is broader than intended, the discrepancy MUST be recorded as a follow-up finding (not pinned as endorsed behavior), and the tests SHALL assert bounds that a further scope-narrowing refactor would still satisfy.

#### Scenario: Bounds track verified behavior

- **WHEN** the rebuild-scope tests are written or tightened
- **THEN** the asserted bounds match the verified rebuild behavior current at that time, and any remaining broader-than-intended scope is recorded as a follow-up candidate rather than encoded as expected behavior
