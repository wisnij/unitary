## ADDED Requirements

### Requirement: Unknown unit name raises EvalException
When the evaluator encounters an identifier that is not found in the provided
unit repository, it SHALL throw an `EvalException` with a message that includes
the unrecognized unit name.

#### Scenario: Unrecognized unit with repo throws EvalException
- **WHEN** `ExpressionParser(repo: repo).evaluate('5 wakalixes')` is called and `wakalixes` is not registered in the repository
- **THEN** an `EvalException` is thrown whose message contains `wakalixes`

#### Scenario: Unrecognized unit mid-expression throws EvalException
- **WHEN** an expression contains a known unit combined with an unknown unit (e.g. `5 m + 3 wakalixes`)
- **THEN** an `EvalException` is thrown

#### Scenario: No repo still produces raw dimension (Phase 1 mode)
- **WHEN** `ExpressionParser()` (no repo) evaluates an expression with an unrecognized identifier
- **THEN** the identifier is treated as a raw dimension and no exception is thrown

#### Scenario: Known unit evaluates successfully
- **WHEN** a recognized unit name is used in an expression with a repo
- **THEN** the expression evaluates to a `Quantity` with the correct dimension and no exception is thrown
