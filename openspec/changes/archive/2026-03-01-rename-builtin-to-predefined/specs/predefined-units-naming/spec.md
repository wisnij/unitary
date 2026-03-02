## ADDED Requirements

### Requirement: Predefined units use consistent naming
Code identifiers, file names, and documentation that refer to the unit
definitions shipped with the app SHALL use the term "predefined" rather than
"builtin".  The term "builtin" is reserved for math functions (`sin`, `cos`,
`sqrt`, etc.) resolved by the evaluator.

#### Scenario: Factory constructor name
- **WHEN** a caller creates a UnitRepository pre-loaded with all app-supplied units
- **THEN** the factory method is named `withPredefinedUnits`

#### Scenario: Registration function name
- **WHEN** a caller registers all app-supplied units into an existing repository
- **THEN** the function is named `registerPredefinedUnits`

#### Scenario: Source file names
- **WHEN** a developer looks for the generated unit definitions file
- **THEN** the file is named `predefined_units.dart`

#### Scenario: Codegen tool names
- **WHEN** a developer looks for the code-generation tool that produces the unit definitions file
- **THEN** the tool is named `generate_predefined_units.dart` and its library `generate_predefined_units_lib.dart`
