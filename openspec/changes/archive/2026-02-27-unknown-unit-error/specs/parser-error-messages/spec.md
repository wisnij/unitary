## ADDED Requirements

### Requirement: Unrecognized unit name produces EvalException
When a unit identifier is not found in the repository during expression
evaluation, the evaluator SHALL throw an `EvalException` whose message
identifies the unknown unit name.

#### Scenario: EvalException message contains the unknown name
- **WHEN** an expression references a unit name not registered in the repository
- **THEN** an `EvalException` is thrown and its message contains the unknown unit name (e.g. `Unknown unit: "wakalixes"`)
