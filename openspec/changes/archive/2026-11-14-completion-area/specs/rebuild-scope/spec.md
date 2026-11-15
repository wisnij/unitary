## MODIFIED Requirements

### Requirement: Freeform keystroke rebuild bound

A single keystroke in a freeform expression field, including its debounced evaluation, SHALL NOT rebuild the freeform screen subtree root at all: only the widgets that depend on the changed state SHALL rebuild — the buttons listening to the text controllers (the clear button in the field and the swap button in the app bar), the completion area, and the scoped consumers of the evaluation result and history (result display, conformable-browse button, history pane and button).  Widget tests SHALL pin the zero-subtree-rebuild bound with rebuild-count probes, and SHALL also assert the positive effects (the result updates, the buttons react) so the bound cannot pass vacuously.

#### Scenario: Keystroke does not rebuild the screen subtree

- **WHEN** a single character is typed into a freeform expression field in a widget test instrumented with rebuild-count probes, and the evaluation debounce elapses
- **THEN** the probed freeform screen subtree root records zero rebuilds

#### Scenario: Scoped dependents still update

- **WHEN** a keystroke makes both fields non-empty and its debounced evaluation completes
- **THEN** the result display shows the new evaluation result and the clear and swap buttons reflect the new field contents, without a screen-subtree rebuild
