## ADDED Requirements

### Requirement: Currency worksheet uses live exchange rates

The Currency worksheet's `UnitRow` expressions SHALL be evaluated against
the same `UnitRepository` instance used elsewhere in the app (the one
exposed via `unitRepositoryProvider`), so conversions reflect exchange
rates loaded from storage at startup rather than only the compiled
fallback rates.

#### Scenario: Worksheet reflects rates stored at launch

- **WHEN** the app launches with previously saved currency rates in storage, differing from the compiled fallback rates
- **AND** the user types a value into a row of the Currency worksheet
- **THEN** the other rows' displayed values are computed using the stored rates, not the compiled fallback rates

### Requirement: Currency worksheet recomputes after a rate refresh

When a currency rate refresh updates dynamic units in the shared
`UnitRepository` (signaled via `unitRepositoryVersionProvider`), the
worksheet feature SHALL recompute and update the displayed values for
every worksheet template that has a persisted source value, using that
template's stored source row and text.

#### Scenario: Currency worksheet updates after manual refresh

- **WHEN** the user is viewing the Currency worksheet with a value typed into one row
- **AND** a currency rate refresh completes with changed rates
- **THEN** the other rows' displayed values update to reflect the new rates without further user input

#### Scenario: Non-active worksheet with a stored source also updates

- **WHEN** a non-currency worksheet template has a persisted source value from earlier in the session
- **AND** a currency rate refresh completes with changed rates
- **THEN** that template's cached display values are recomputed from its persisted source (unaffected templates remain numerically unchanged)
