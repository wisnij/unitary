# Settings

## Purpose

Specifies the Settings screen and the user settings it controls: decimal precision, number notation, theme, and freeform evaluation mode, with their defaults and their persistence across sessions.  How the user reaches the screen is specified in `adaptive-navigation`.  The Currency rates section is specified in `currency-rates`, and the width of the screen content in `content-max-width`.  The effect of each setting on formatting, theming, and evaluation is specified with the feature that uses it.

## Requirements

### Requirement: Settings screen sections

The Settings screen SHALL have the title "Settings" and SHALL show four sections in this order: "Display", "Appearance", "Freeform behavior", and "Currency rates".  The screen SHALL NOT contain an "About" section.

#### Scenario: All sections are shown

- **WHEN** the Settings screen is displayed
- **THEN** the section headers "Display", "Appearance", "Freeform behavior", and "Currency rates" are shown in that order

#### Scenario: No About section

- **WHEN** the Settings screen is displayed
- **THEN** no "About" section header is shown

### Requirement: Decimal precision setting

The "Display" section SHALL contain a "Decimal precision" setting that lets the user select an integer from 2 to 10 inclusive.  The default precision SHALL be 8.  The settings model SHALL reject a precision outside the range 2 to 10.

#### Scenario: Default precision

- **WHEN** the Settings screen is displayed and the user has never changed the precision
- **THEN** the "Decimal precision" setting shows 8

#### Scenario: User selects a precision

- **WHEN** the user selects 4 for "Decimal precision"
- **THEN** the current precision setting is 4

#### Scenario: Out-of-range precision is rejected

- **WHEN** a settings value is constructed with a precision of 1 or 11
- **THEN** an `ArgumentError` is thrown

### Requirement: Number notation setting

The "Display" section SHALL contain a "Number notation" setting that lets the user select one of "Automatic", "Scientific", or "Engineering".  The default notation SHALL be "Automatic".

#### Scenario: Default notation

- **WHEN** the Settings screen is displayed and the user has never changed the notation
- **THEN** the "Number notation" setting shows "Automatic"

#### Scenario: User selects a notation

- **WHEN** the user selects "Scientific" for "Number notation"
- **THEN** the current notation setting is scientific

### Requirement: Theme setting

The "Appearance" section SHALL let the user select exactly one of three theme options: "Use system theme", "Dark mode", or "Light mode".  The default SHALL be "Use system theme".

#### Scenario: Three theme options are shown

- **WHEN** the Settings screen is displayed
- **THEN** the options "Use system theme", "Dark mode", and "Light mode" are shown

#### Scenario: Default theme

- **WHEN** the user has never changed the theme
- **THEN** "Use system theme" is selected

#### Scenario: User selects dark mode

- **WHEN** the user selects "Dark mode"
- **THEN** the current theme setting is dark

#### Scenario: User returns to the system theme

- **WHEN** the current theme setting is dark and the user selects "Use system theme"
- **THEN** the current theme setting is system

### Requirement: Evaluation mode setting

The "Freeform behavior" section SHALL let the user select exactly one of two evaluation modes: "Real-time", described as "Evaluate as you type", or "On submit", described as "Evaluate on Enter or button press".  The default SHALL be "Real-time".

#### Scenario: Default evaluation mode

- **WHEN** the user has never changed the evaluation mode
- **THEN** "Real-time" is selected

#### Scenario: User selects on-submit evaluation

- **WHEN** the user selects "On submit"
- **THEN** the current evaluation mode setting is on submit

### Requirement: Setting changes take effect immediately

A change to any setting SHALL update the current settings state at once, without a separate save or apply action, so that every part of the app that reads the setting sees the new value.

#### Scenario: Change is visible without a save action

- **WHEN** the user changes a setting on the Settings screen
- **THEN** the current settings state holds the new value and no further confirmation is needed

### Requirement: Settings persist across sessions

Each change to a setting SHALL be saved to local storage on the device, and the app SHALL load the saved settings when it starts.

#### Scenario: Round trip preserves all settings

- **WHEN** settings with non-default precision, notation, theme, and evaluation mode are saved and then loaded
- **THEN** the loaded settings equal the saved settings

#### Scenario: Changed setting survives a restart

- **WHEN** the user changes a setting and the app is restarted
- **THEN** the setting has the changed value after the restart

### Requirement: Missing or unrecognized stored values fall back to defaults

When a stored setting is missing, the app SHALL use the default for that setting and SHALL keep the stored values of the other settings.  When the stored notation, theme, or evaluation mode is not a recognized value, the app SHALL use the default for that setting.

#### Scenario: No stored settings

- **WHEN** settings are loaded and nothing has been stored
- **THEN** the loaded settings are precision 8, automatic notation, system theme, and real-time evaluation

#### Scenario: Partially stored settings

- **WHEN** settings are loaded and only the precision has been stored, with the value 4
- **THEN** the loaded precision is 4 and the other settings have their defaults

#### Scenario: Unrecognized stored notation

- **WHEN** settings are loaded and the stored notation is not a recognized value
- **THEN** the loaded notation is automatic

#### Scenario: Unrecognized stored theme

- **WHEN** settings are loaded and the stored theme is not a recognized value
- **THEN** the loaded theme is system

#### Scenario: Unrecognized stored evaluation mode

- **WHEN** settings are loaded and the stored evaluation mode is not a recognized value
- **THEN** the loaded evaluation mode is real-time
