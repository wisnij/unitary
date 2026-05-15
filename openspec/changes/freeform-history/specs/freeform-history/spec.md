## ADDED Requirements

### Requirement: History records successful evaluations
The system SHALL append a history entry containing the current (from, to) field
values whenever a freeform evaluation produces a non-error, non-idle result.
In real-time mode the entry SHALL be recorded after the debounce timer fires
and evaluation completes.  In on-submit mode the entry SHALL be recorded after
the user presses Enter or the Evaluate button and evaluation completes.
Partial input that has not yet been evaluated SHALL NOT produce a history entry.

#### Scenario: Real-time mode records entry after debounce
- **WHEN** the user types an expression in real-time mode and the debounce timer fires
- **THEN** the entry is added to history if and only if evaluation succeeds

#### Scenario: On-submit mode records entry on submit
- **WHEN** the user presses the Evaluate button (or Enter) in on-submit mode
- **THEN** the entry is added to history if and only if evaluation succeeds

#### Scenario: Errors are not recorded
- **WHEN** an evaluation produces an error result
- **THEN** no history entry is added

#### Scenario: Idle state is not recorded
- **WHEN** the input field is empty (idle state)
- **THEN** no history entry is added

### Requirement: History entry captures both field values
Each history entry SHALL store the trimmed text of the "Convert from" and
"Convert to" fields at the moment of evaluation.  An empty "Convert to" field
SHALL be stored as an empty string.

#### Scenario: Entry stores from and to values
- **WHEN** a successful evaluation occurs with non-empty from field and empty to field
- **THEN** the history entry records the from text and an empty string for to

#### Scenario: Entry stores both fields when to is populated
- **WHEN** a successful evaluation occurs with both fields non-empty
- **THEN** the history entry records both the from and to text

### Requirement: History entry captures the formatted result
Each history entry SHALL additionally store the formatted output of the
evaluation at the moment it was recorded (the `result` field).  This value is
derived from the `EvaluationResult` state using an exhaustive switch:

- `EvaluationSuccess` → `formattedResult` as-is (e.g. `"1.524 m"`)
- `ConversionSuccess` → `formattedResult` with leading `"= "` stripped (e.g. `"8.04672 km"`)
- `UnitDefinitionResult` → `formattedResult` with leading `"= "` stripped (e.g. `"1 m"`)
- `ReciprocalConversionSuccess` → `formattedResult` with leading `"= "` stripped
- `FunctionConversionResult` → `"functionName(formattedValue)"` (e.g. `"tempC(20)"`)
- `FunctionDefinitionResult` → `""` (no numeric result)

When `result` is non-empty, the history modal SHALL display the entry as
`"from = result"`.  When `result` is empty, only `from` SHALL be shown.
Deduplication equality is based solely on the `(from, to)` pair; `result` is
not considered, so a re-evaluated entry always refreshes the stored result.
Entries stored before this field was introduced SHALL deserialize with
`result = ""`.

#### Scenario: Entry with result shows "from = result" label
- **WHEN** a history entry has a non-empty result field
- **THEN** the modal displays it as "from = result" (e.g. "5 miles = 8.04672 km")

#### Scenario: Entry without result shows only from
- **WHEN** a history entry has an empty result field (e.g. a function definition lookup)
- **THEN** the modal displays only the from value

#### Scenario: Re-evaluating an existing pair updates the result
- **WHEN** the user evaluates a (from, to) pair already in history
- **THEN** the entry is moved to the top and its result reflects the new evaluation

### Requirement: History deduplicates entries by moving them to top
If the (from, to) pair of a new entry is identical (exact string match, after
trimming) to an existing entry, the system SHALL remove the existing entry and
prepend the new entry, rather than creating a duplicate.

#### Scenario: Re-submitting an existing pair moves it to top
- **WHEN** the user evaluates a (from, to) pair that already exists in history
- **THEN** the duplicate is removed and the entry appears at the top of the list

#### Scenario: Different pair creates a new entry
- **WHEN** the user evaluates a (from, to) pair not already in history
- **THEN** a new entry is prepended and no existing entry is removed

### Requirement: History is capped at 100 entries
The history list SHALL retain at most 100 entries.  When a new entry would
exceed this limit, the oldest entry (the last entry in the list) SHALL be
dropped.

#### Scenario: Adding an entry beyond the cap drops the oldest
- **WHEN** history already contains 100 entries and a new (non-duplicate) entry is added
- **THEN** the new entry appears at the top and the 100th entry is removed

#### Scenario: Cap does not apply when deduplicating
- **WHEN** history contains 100 entries and the user re-submits an existing pair
- **THEN** the list still contains 100 entries after the operation

### Requirement: History persists across sessions
The history list SHALL be saved to SharedPreferences and restored on app
launch so that entries from previous sessions remain available.

#### Scenario: History survives app restart
- **WHEN** the user records history entries and restarts the app
- **THEN** the history list is restored and shows the same entries in the same order

#### Scenario: Missing history key loads empty list
- **WHEN** no history data exists in SharedPreferences (e.g., first launch)
- **THEN** the history list is empty

#### Scenario: Malformed history data loads empty list
- **WHEN** the SharedPreferences value for the history key is invalid JSON
- **THEN** the history list is empty and no error is shown to the user

### Requirement: History is accessible via an AppBar button
The freeform screen SHALL include a history button (`Icons.history`) in the
AppBar to the left of the conformable-units button.  The button SHALL be
enabled when the history list is non-empty and disabled when it is empty.
Tapping the button SHALL open a modal bottom sheet listing all history entries.

#### Scenario: History button disabled when history is empty
- **WHEN** the history list is empty
- **THEN** the history button is disabled (onPressed is null)

#### Scenario: History button enabled when entries exist
- **WHEN** the history list contains one or more entries
- **THEN** the history button is enabled

#### Scenario: Tapping history button opens modal
- **WHEN** the user taps the enabled history button
- **THEN** a modal bottom sheet appears listing the history entries

### Requirement: Tapping a history entry restores both fields and evaluates
Tapping a history entry SHALL populate the "Convert from" field with the
entry's from value and the "Convert to" field with the entry's to value, then
immediately trigger evaluation without waiting for a debounce timer.

#### Scenario: Tapping entry fills fields and evaluates
- **WHEN** the user taps a history entry
- **THEN** the from field contains the entry's from value, the to field contains the entry's to value, and the result display updates immediately
