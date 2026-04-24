## ADDED Requirements

### Requirement: Freeform input fields are persisted across sessions
The app SHALL save the "Convert from" and "Convert to" field text to persistent
storage whenever either field changes, and SHALL restore both field texts on
next launch.

#### Scenario: Input fields restored on launch
- **WHEN** the user has typed "5 ft" in "Convert from" and "m" in "Convert to" and restarts the app
- **THEN** the freeform screen opens with "5 ft" in "Convert from" and "m" in "Convert to"

#### Scenario: Only "Convert from" text restored when "Convert to" was empty
- **WHEN** the user had text only in "Convert from" and restarts the app
- **THEN** "Convert from" is restored and "Convert to" remains empty

#### Scenario: Fields start empty on first launch
- **WHEN** the app is launched for the first time (no persisted data)
- **THEN** both freeform fields are empty and the screen shows the idle state

### Requirement: Freeform result is evaluated immediately after restore
The app SHALL evaluate the restored field text immediately on launch so the
result display is populated without requiring user interaction.

#### Scenario: Result display populated on launch
- **WHEN** the user has a non-empty "Convert from" field persisted and restarts the app
- **THEN** the result display shows the evaluated result for the restored expression without the user needing to tap or type anything

#### Scenario: Idle state shown when only whitespace is restored
- **WHEN** the persisted "Convert from" text is empty or whitespace-only
- **THEN** the freeform screen opens in the idle state

### Requirement: Freeform persistence uses no new package dependencies
The persistence mechanism SHALL use SharedPreferences (already a project
dependency).  No additional packages SHALL be introduced for this feature.

#### Scenario: No new dependencies after feature implementation
- **WHEN** the feature is implemented
- **THEN** `pubspec.yaml` lists no packages that were not present before this change
