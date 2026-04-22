## 1. Tests

- [x] 1.1 Add test asserting the `angle` template exists in the registry with id `"angle"` and name `"Angle"`
- [x] 1.2 Add test asserting the `angle` template has 10 rows, all `UnitRow`, with expressions in order: `mas`, `arcsec`, `seclongitude`, `arcmin`, `gon`, `degree`, `radian`, `sextant`, `rightangle`, `circle`
- [x] 1.3 Add test asserting the `angle` template rows are in non-decreasing magnitude order (evaluating each expression)
- [x] 1.4 Update the "registry returns all templates" test to expect 11 templates instead of 10

## 2. Implementation

- [x] 2.1 Add the `angle` `WorksheetTemplate` to `lib/features/worksheet/data/predefined_worksheets.dart` with the 10 rows specified in the spec

## 3. Spec Update

- [x] 3.1 Apply the `worksheet-templates` delta spec: update `openspec/specs/worksheet-templates/spec.md` to reflect 11 templates, adding the Angle template table row and updating the registry scenario count
