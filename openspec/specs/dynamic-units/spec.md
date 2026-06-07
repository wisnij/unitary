# Dynamic Units

## Purpose

Specifies the runtime dynamic unit layer in `UnitRepository` that allows unit
definitions to be registered, updated, and removed after construction time.
Dynamic registrations shadow the compiled static layer and are used primarily
by the currency rate system to keep exchange-rate unit definitions current.

## Requirements

### Requirement: Dynamic unit registration
`UnitRepository` SHALL expose a dynamic layer that accepts runtime unit
registrations, independently of the compiled static layer populated at
construction time.  Dynamic registrations SHALL take precedence over static
ones in all lookups.

#### Scenario: Dynamic unit shadows compiled unit
- **WHEN** a `DerivedUnit` with the same ID as a compiled unit is passed to `registerDynamic`
- **THEN** all subsequent lookups for that ID and its aliases return the dynamic unit

#### Scenario: Duplicate dynamic registration replaces silently
- **WHEN** `registerDynamic` is called twice with units sharing the same ID
- **THEN** the second call succeeds without error and the dynamic layer holds the second unit

#### Scenario: Dynamic unit with new ID is found by lookup
- **WHEN** a unit ID not present in the compiled layer is registered via `registerDynamic`
- **THEN** `findUnitWithPrefix` resolves that ID to the dynamic unit

### Requirement: Dynamic unit removal
`UnitRepository` SHALL allow a dynamically registered unit to be removed by ID
via `unregisterDynamic`.  After removal, lookups SHALL fall back to the compiled
unit if one exists, or return no match if none does.

#### Scenario: Removal restores compiled fallback
- **WHEN** a dynamic unit shadowing a compiled unit is removed via `unregisterDynamic`
- **THEN** subsequent lookups return the original compiled unit

#### Scenario: Removal of unit with no compiled counterpart
- **WHEN** a dynamic-only unit is removed via `unregisterDynamic`
- **THEN** subsequent lookups for that ID return no match

#### Scenario: Removing a non-existent dynamic unit
- **WHEN** `unregisterDynamic` is called for an ID that has no dynamic registration
- **THEN** the call completes without error and the repository state is unchanged

### Requirement: Dynamic layer enumeration
`UnitRepository` SHALL expose an `allDynamicUnits` getter that returns all
currently registered dynamic units, for use by persistence consumers.

#### Scenario: Getter reflects current dynamic state
- **WHEN** units have been registered and removed via the dynamic API
- **THEN** `allDynamicUnits` returns exactly the set of currently registered dynamic units

### Requirement: Cache invalidation on dynamic registration
`UnitRepository` SHALL clear its entire resolved-quantity cache whenever
`registerDynamic` is called, so that subsequent resolutions use the updated
unit definitions.

#### Scenario: Cached resolution is discarded after update
- **WHEN** a unit has been resolved and cached, and its definition is then updated via `registerDynamic`
- **THEN** the next call to `resolveUnit` for that unit re-evaluates the expression and returns a value reflecting the new definition
