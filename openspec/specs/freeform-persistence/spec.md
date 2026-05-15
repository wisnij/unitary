# Freeform Persistence

## Purpose

Persist worksheet state across app sessions using SharedPreferences.  Freeform
"Convert from" and "Convert to" fields are intentionally not persisted — restoring
stale freeform expressions proved more disorienting than convenient, so the
freeform screen always opens blank each session.

## Requirements

### Requirement: Freeform persistence uses no new package dependencies
The persistence mechanism SHALL use SharedPreferences (already a project dependency)
for worksheet state and freeform history.  No additional packages SHALL be introduced
for this feature.

#### Scenario: No new dependencies after feature implementation
- **WHEN** the change is implemented
- **THEN** `pubspec.yaml` lists no packages that were not present before this change
