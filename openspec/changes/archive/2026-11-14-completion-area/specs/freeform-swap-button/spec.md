## REMOVED Requirements

### Requirement: Swap button is present between the two input fields
**Reason**: The button's own row between the fields used 48 dp of height that the completion area and result need on a phone.
**Migration**: See the added requirement "Swap button is present in the app bar".  Enabled state and swap behaviour are unchanged.

## ADDED Requirements

### Requirement: Swap button is present in the app bar
The freeform screen SHALL display the swap button as an action in its app bar
at all times and at every window width, placed before the other app bar
actions.  The button SHALL have a tooltip that describes the action.  The
"Convert from" and "Convert to" fields SHALL be separated by a 16 dp gap with
no control between them.

#### Scenario: Button is in the app bar
- **WHEN** the freeform screen is displayed
- **THEN** a swap button is rendered in the app bar, before the history and conformable-units buttons

#### Scenario: Button has a tooltip
- **WHEN** the swap button is rendered
- **THEN** it exposes the tooltip "Swap from and to"

#### Scenario: No control between the fields
- **WHEN** the freeform screen is displayed
- **THEN** the "Convert to" field starts 16 dp below the bottom of the "Convert from" field

#### Scenario: Present at two-pane widths
- **WHEN** the freeform screen is displayed at a medium or expanded window width
- **THEN** the swap button is still rendered in the app bar
