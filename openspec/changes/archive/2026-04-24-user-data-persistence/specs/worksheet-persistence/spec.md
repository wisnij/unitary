## ADDED Requirements

### Requirement: Active worksheet is persisted across sessions
The app SHALL save the active worksheet template ID to persistent storage
whenever the user switches templates, and SHALL restore that template as the
active template on next launch.

#### Scenario: Active template restored on launch
- **WHEN** the user has previously selected the "Mass" worksheet and restarts the app
- **THEN** the worksheet screen opens showing the "Mass" template

#### Scenario: Falls back to default when no persisted template
- **WHEN** the app is launched for the first time (no persisted data)
- **THEN** the worksheet screen opens showing the default template ("Length")

#### Scenario: Falls back to default when persisted ID is unrecognised
- **WHEN** the persisted template ID does not match any registered template
- **THEN** the worksheet screen opens showing the default template ("Length")

### Requirement: Per-template source values are persisted across sessions
The app SHALL save each template's source-row index and source-row text to
persistent storage whenever the user edits a worksheet row.  On next launch,
each template's most-recently-entered value SHALL be restored and the
conversion engine SHALL re-derive all other rows from that source.

#### Scenario: Source value restored on launch
- **WHEN** the user has typed "5 ft" into row 2 of the Length worksheet and restarts the app
- **THEN** the Length worksheet reopens with "5 ft" in row 2 and all other rows showing the corresponding converted values

#### Scenario: Multiple template values restored independently
- **WHEN** the user has edited both the Length and Mass worksheets before restarting
- **THEN** each worksheet reopens with its own previously-entered source value

#### Scenario: Unedited templates start blank after restore
- **WHEN** the user has never edited the Energy worksheet
- **THEN** the Energy worksheet opens with all rows blank

#### Scenario: Engine error on restore does not crash the app
- **WHEN** a persisted source expression is invalid (e.g. references a unit that no longer exists)
- **THEN** the affected row shows an error string and all other rows in that template are blank; the app remains functional

### Requirement: Worksheet persistence uses no new package dependencies
The persistence mechanism SHALL use SharedPreferences (already a project
dependency).  No additional packages SHALL be introduced for this feature.

#### Scenario: No new dependencies after feature implementation
- **WHEN** the feature is implemented
- **THEN** `pubspec.yaml` lists no packages that were not present before this change
