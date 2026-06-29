## MODIFIED Requirements

### Requirement: Active worksheet is persisted across sessions
The app SHALL save the active worksheet template ID to persistent storage
whenever the user switches templates, and SHALL restore that template as the
active template on next launch.  The active worksheet is optional: when no
template has been selected, or the persisted selection is absent or
unrecognised, no worksheet SHALL be active on launch (the screen presents the
worksheet-selection affordance defined by the worksheet-ui capability).  There
is no longer any hard-coded fall-back to the Length template.

#### Scenario: Active template restored on launch
- **WHEN** the user has previously selected the "Mass" worksheet and restarts the app
- **THEN** the worksheet screen opens showing the "Mass" template

#### Scenario: No worksheet active when no persisted selection
- **WHEN** the app is launched for the first time (no persisted data)
- **THEN** no worksheet is active and the worksheet screen presents the
  worksheet-selection affordance

#### Scenario: No worksheet active when persisted ID is unrecognised
- **WHEN** the persisted template ID does not match any registered template
- **THEN** no worksheet is active and the worksheet screen presents the
  worksheet-selection affordance
