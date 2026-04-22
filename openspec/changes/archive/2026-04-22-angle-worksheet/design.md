## Context

The worksheet feature ships with 10 predefined templates in
`lib/features/worksheet/data/predefined_worksheets.dart`.  Each template is a
`WorksheetTemplate` value with an id, display name, and a list of
`WorksheetRow` objects.  All angle units are already registered in
`predefined_units.dart` — no new unit definitions are needed.

## Goals / Non-Goals

**Goals:**

- Add a single `WorksheetTemplate` for angle conversion with 10 rows
- Update the `worksheet-templates` spec to reflect the new template count and rows
- Keep the change self-contained (data only, no engine or UI changes)

**Non-Goals:**

- Adding new angle unit definitions (all required units already exist)
- Changing worksheet sort order (existing alphabetical sort handles it)
- Custom worksheet creation or editing

## Decisions

### Row selection

Rows chosen to span the full range of practical angle units, from
sub-arcsecond astronomical precision up to full-circle navigation:
`mas`, `arcsec`, `seclongitude`, `arcmin`, `gon`, `degree`, `radian`,
`sextant`, `rightangle`, `circle`.  All are `UnitRow` (ratio-based), since none
require an affine offset — angle conversions are always multiplicative.

### Row order

Smallest-to-largest by radian value, consistent with all-`UnitRow` templates.

### No new dependencies

All angle units (`mas`, `seclongitude`, `gon`, `sextant`, `rightangle`, etc.)
are already registered via `predefined_units.dart`.  No imports or
`pubspec.yaml` changes are required.

## Risks / Trade-offs

- `seclongitude` is an unusual unit (1 second of Earth rotation ≈ 15 arcsec);
  its label should make its meaning clear to avoid user confusion →
  label it "seconds of longitude" so the context is obvious.
- `gon` (gradian) is stored under id `gon` with alias `grade`; using `gon` as
  the expression is unambiguous → use `gon`.
