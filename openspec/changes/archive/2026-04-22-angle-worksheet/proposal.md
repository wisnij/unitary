## Why

The worksheet currently covers 10 physical dimensions but lacks angle conversion,
which is a common need for geometry, navigation, astronomy, and signal-processing
work.  Adding an Angle template brings the worksheet set to a round 11 and fills
an obvious gap for the target technical audience.

## What Changes

- Add one new predefined `WorksheetTemplate` with id `"angle"` and name `"Angle"`
- The template provides 10 rows (all `UnitRow`), ordered smallest to largest:
  milli-arcsecond (mas), arcsecond, second of longitude (seclongitude),
  arcminute, gradian (gon), degree, radian, sextant, right angle, and
  turn (circle)
- The existing template count assertion in tests and specs rises from 10 to 11

## Capabilities

### New Capabilities

_(none — this change extends an existing capability)_

### Modified Capabilities

- `worksheet-templates`: adds the `angle` template to the predefined registry, raising the count from 10 to 11

## Impact

- `lib/features/worksheet/data/predefined_worksheets.dart` — add the `angle` template
- `openspec/specs/worksheet-templates/spec.md` — update template count and add Angle template rows
- Tests that assert exactly 10 templates must be updated to 11
