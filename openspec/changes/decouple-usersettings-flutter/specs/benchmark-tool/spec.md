## MODIFIED Requirements

### Requirement: Benchmark coverage of named hot paths

The benchmark tool SHALL provide a benchmark case for each pure-Dart core-domain hot path named in the implementation plan's performance section: repository construction (`UnitRepository.withPredefinedUnits()`), cold resolution of every registered unit, warm (cached) resolution of every registered unit, representative expression parse/evaluate round trips, `buildBrowseCatalog()`, `buildCurrencyDescriptors()`, `suggestCompletions()`, and `computeWorksheet()` for a `UnitRow` template and a `FunctionRow` template.

`computeWorksheet()`'s import chain no longer reaches Flutter (`UserSettings` was decoupled from `package:flutter/material.dart`), so unlike previously, it SHALL run as an ordinary case in `tool/benchmark.dart` rather than a separate `flutter test`-hosted companion.

#### Scenario: Full run covers all cases

- **WHEN** `dart run tool/benchmark.dart` is invoked with no case filter
- **THEN** every registered benchmark case executes and appears in the output, including the `computeWorksheet()` cases

#### Scenario: Cold-cache cases use fresh state

- **WHEN** a cold-path case (cold resolution, `buildCurrencyDescriptors()`) runs multiple timed iterations
- **THEN** each iteration measures a fresh, unmemoized code path (e.g. a new `UnitRepository` per iteration), so cached or memoized results from a prior iteration cannot contaminate the timing
