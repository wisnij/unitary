## MODIFIED Requirements

### Requirement: History is accessible via an AppBar button
At `compact` width the freeform screen SHALL include a history button
(`Icons.history`) in the AppBar to the left of the conformable-units button.
The button SHALL be enabled when the history list is non-empty and disabled when
it is empty.  Tapping the button SHALL open a modal bottom sheet listing all
history entries.

At `medium` and `expanded` width the history is shown in a persistent pane (see
"History pane on wide screens") and the AppBar history button SHALL NOT be
shown, since the modal would duplicate the always-visible pane.

#### Scenario: History button disabled when history is empty
- **WHEN** the window size class is `compact` and the history list is empty
- **THEN** the history button is disabled (onPressed is null)

#### Scenario: History button enabled when entries exist
- **WHEN** the window size class is `compact` and the history list contains one
  or more entries
- **THEN** the history button is enabled

#### Scenario: Tapping history button opens modal
- **WHEN** the window size class is `compact` and the user taps the enabled
  history button
- **THEN** a modal bottom sheet appears listing the history entries

#### Scenario: No history button at wide widths
- **WHEN** the window size class is `medium` or `expanded`
- **THEN** the AppBar does not show the history button

## ADDED Requirements

### Requirement: History pane on wide screens
At `medium` and `expanded` width the freeform screen SHALL display the input
history in a persistent pane beside the input/result column instead of behind a
modal.  The pane SHALL list the same entries, in the same order, as the modal
bottom sheet, and tapping an entry SHALL behave identically to tapping it in the
modal (restoring both fields and evaluating immediately).  When the history is
empty the pane MAY show an empty-state message.

#### Scenario: History pane shown beside the input at wide widths
- **WHEN** the window size class is `medium` or `expanded` and the history list
  is non-empty
- **THEN** the history entries are shown in a persistent pane beside the input
  and result, not in a modal

#### Scenario: Tapping a history pane entry restores fields and evaluates
- **WHEN** the window size class is `medium` or `expanded` and the user taps an
  entry in the history pane
- **THEN** the "Convert from" and "Convert to" fields are populated from the
  entry and evaluation occurs immediately

#### Scenario: Same entries and order as the modal
- **WHEN** the same history list would be shown in the compact modal and the
  wide pane
- **THEN** both present the same entries in the same order
