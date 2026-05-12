## REMOVED Requirements

### Requirement: Freeform input fields are persisted across sessions
**Reason**: In practice, restoring stale freeform expressions was more disorienting
than convenient.  Users expect the freeform screen to start blank each session.
**Migration**: No user action required.  Existing persisted keys (`freeform_from`,
`freeform_to`) are automatically removed from SharedPreferences on the first launch
after this change.

### Requirement: Freeform result is evaluated immediately after restore
**Reason**: Dependent on freeform persistence, which is removed (see above).
**Migration**: None — freeform screen always opens in the idle state.

## MODIFIED Requirements

### Requirement: Freeform persistence uses no new package dependencies
The persistence mechanism SHALL use SharedPreferences (already a project dependency)
for worksheet state only.  No additional packages SHALL be introduced for this feature.

#### Scenario: No new dependencies after feature implementation
- **WHEN** the change is implemented
- **THEN** `pubspec.yaml` lists no packages that were not present before this change
