# Page State Preservation Spec

## Purpose

Define the requirements for preserving top-level page state across in-session
navigation.  When the user navigates between the Freeform, Worksheet, and Browse
pages via the app drawer, each page SHALL retain its widget state (text field
contents, active template, search query, group collapse state) for the duration
of the session.

## Requirements

### Requirement: Freeform page input is preserved across navigation
The app SHALL retain the contents of the "Convert from" and "Convert to" text
fields on the Freeform page when the user navigates to another top-level page
and returns within the same session.

#### Scenario: Navigate to Worksheet and back
- **WHEN** the user has typed text in the Freeform "Convert from" or "Convert to" fields
- **AND** the user opens the drawer and navigates to the Worksheet page
- **AND** the user opens the drawer and navigates back to the Freeform page
- **THEN** both text fields SHALL display the same text that was present before navigation

#### Scenario: Navigate to Browse and back
- **WHEN** the user has typed text in the Freeform "Convert from" or "Convert to" fields
- **AND** the user opens the drawer and navigates to the Browse page
- **AND** the user opens the drawer and navigates back to the Freeform page
- **THEN** both text fields SHALL display the same text that was present before navigation

#### Scenario: Evaluation result is preserved across navigation
- **WHEN** the Freeform page displays a result (success or error)
- **AND** the user navigates to another page and returns
- **THEN** the result display SHALL show the same result as before navigation

### Requirement: Worksheet page input is preserved across navigation
The app SHALL retain the contents of all worksheet row text fields when the user
navigates to another top-level page and returns within the same session.

#### Scenario: Worksheet row values survive navigation
- **WHEN** the user has entered values in one or more worksheet rows
- **AND** the user opens the drawer and navigates to the Freeform page
- **AND** the user opens the drawer and navigates back to the Worksheet page
- **THEN** all row fields SHALL display the same values as before navigation

#### Scenario: Active worksheet template is preserved across navigation
- **WHEN** the user has selected a specific worksheet template (e.g., Speed)
- **AND** the user navigates to another page and returns
- **THEN** the same worksheet template SHALL be active on return

### Requirement: Browse page search state is preserved across navigation
The app SHALL retain the browse page search bar visibility and query when the
user navigates to another top-level page and returns within the same session.

#### Scenario: Open search bar survives navigation
- **WHEN** the user has opened the search bar on the Browse page
- **AND** the user has typed a search query
- **AND** the user navigates to another page and returns
- **THEN** the search bar SHALL be visible with the same query text

#### Scenario: Collapsed group state survives navigation
- **WHEN** the user has expanded or collapsed groups on the Browse page
- **AND** the user navigates to another page and returns
- **THEN** the same groups SHALL be in the same expanded or collapsed state as before navigation
