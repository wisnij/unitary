# memory-report-tool Specification

## ADDED Requirements

### Requirement: Stage-by-stage memory report

The memory report tool SHALL build the core-domain data structures in stages — VM baseline, `UnitRepository.withPredefinedUnits()`, resolution of every registered unit (populating the resolution cache), `buildBrowseCatalog()`, and `buildCurrencyDescriptors()` — and report the process RSS after each stage along with the delta from the previous stage.

#### Scenario: Full staged run

- **WHEN** `dart run tool/memory_report.dart` is invoked
- **THEN** the output lists each stage in order with its absolute RSS and the delta attributable to that stage

### Requirement: Measurement caveat in output

The tool's output SHALL state that RSS is a coarse, order-of-magnitude measurement that includes VM overhead and is affected by garbage-collection timing.

#### Scenario: Caveat printed

- **WHEN** the tool runs
- **THEN** the output includes the RSS-coarseness caveat alongside the numbers

### Requirement: Testable library structure

The staging and formatting logic SHALL live in `tool/memory_report_lib.dart` with unit tests under `test/tool/`, with `tool/memory_report.dart` as a thin executable wrapper, matching the existing tool-script convention.

#### Scenario: Library logic covered by tests

- **WHEN** `flutter test test/tool/` runs
- **THEN** tests exercising the stage sequencing and report formatting of `memory_report_lib.dart` pass without depending on actual RSS values
