## MODIFIED Requirements

### Requirement: Worksheet selector
The AppBar SHALL contain a dropdown that lists all predefined worksheet
templates by name, sorted in case-insensitive alphabetical order.  Selecting a
template makes it the active worksheet.

The selected item (displayed in the AppBar when the dropdown is closed) SHALL
use `titleLarge` font size.  The items listed in the open dropdown menu SHALL
use `bodyLarge` font size.

#### Scenario: Dropdown lists all templates
- **WHEN** the user opens the worksheet selector dropdown
- **THEN** all 10 predefined template names are listed

#### Scenario: Dropdown items are in alphabetical order
- **WHEN** the user opens the worksheet selector dropdown
- **THEN** the templates are listed in case-insensitive alphabetical order by name (Area, Digital Storage, Energy, Length, Mass, Pressure, Speed, Temperature, Time, Volume)

#### Scenario: Selecting a template switches the worksheet
- **WHEN** the user selects "Speed" from the dropdown
- **THEN** the speed worksheet rows are displayed
