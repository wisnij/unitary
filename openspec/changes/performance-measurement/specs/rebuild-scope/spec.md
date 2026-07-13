# rebuild-scope Specification

## ADDED Requirements

### Requirement: Freeform keystroke rebuild scope

A single keystroke in a freeform expression field SHALL rebuild only the widget subtrees that depend on the changed text — the edited field and its completion overlay content — and SHALL NOT rebuild unrelated subtrees such as the other expression field's overlay or the history pane.  Widget tests SHALL pin this scope with rebuild-count probes, asserting scoped invariants (no rebuild, or at-most-N rebuilds) rather than brittle exact counts.

#### Scenario: Keystroke rebuilds only dependent subtrees

- **WHEN** a character is typed into the "Convert from" field in a widget test instrumented with rebuild-count probes
- **THEN** the completion overlay content for that field rebuilds, and the probes on the history pane and the other field's overlay record no rebuilds

#### Scenario: No redundant rebuilds per keystroke

- **WHEN** a single character is typed into a freeform expression field
- **THEN** the completion overlay content rebuilds at most a small fixed number of times (as established by the manual profile pass), not once per unrelated state change

### Requirement: Worksheet edit rebuild scope

A single edit to a worksheet value cell SHALL rebuild only the widgets that depend on the recomputed values — the worksheet row value fields — and SHALL NOT rebuild unrelated subtrees such as the template list pane or the worksheet banner.  Widget tests SHALL pin this scope with rebuild-count probes.

#### Scenario: Cell edit rebuilds only row values

- **WHEN** a value is typed into a worksheet cell in a widget test instrumented with rebuild-count probes, and the debounce elapses
- **THEN** the row value fields rebuild to show recomputed values, and the probes on the template list and banner record no rebuilds

### Requirement: Assertions derived from verified behavior

The rebuild-scope assertions SHALL encode behavior confirmed correct by a manual DevTools profile pass on a real device, not assumed behavior.  If the manual pass reveals today's rebuild scope is broader than intended, the discrepancy MUST be recorded (for a follow-up change) rather than pinned as a passing assertion.

#### Scenario: Manual pass precedes test authoring

- **WHEN** the rebuild-scope tests are written
- **THEN** the asserted scope matches the rebuild behavior observed and judged correct during the documented DevTools pass, and any observed scope problems are recorded as findings instead of being encoded as expected behavior
