# Worksheet Banner

## Purpose

Defines a general mechanism by which a worksheet template may declare a small,
unobtrusive banner of contextually-useful information rendered above its rows,
along with the currency-rates banner variant (last exchange-rate sync status)
and the shared timestamp formatting it uses with the Settings screen.

## Requirements

### Requirement: Worksheet templates may declare a banner

A `WorksheetTemplate` SHALL support an optional `banner` describing a piece of
contextually-useful information for that worksheet.  The banner SHALL be a
typed, const-constructible value (a `WorksheetBanner` sealed type) so predefined
templates can declare it as compile-time constant data.  A template with no
banner SHALL behave exactly as before.

#### Scenario: Template without a banner

- **WHEN** a `WorksheetTemplate` is constructed without a banner
- **THEN** its `banner` is `null`

#### Scenario: Template with a banner

- **WHEN** a `WorksheetTemplate` is constructed with a `WorksheetBanner`
- **THEN** its `banner` is that value and the template is a compile-time constant

### Requirement: Banner rendered above worksheet rows

When the active worksheet template declares a banner, the worksheet screen SHALL
render it as a small, unobtrusive bar positioned above the worksheet rows and
below the AppBar.  When the active template has no banner, no banner area SHALL
be rendered and the rows SHALL occupy the same position as before this change.

The banner SHALL be visually subordinate to the worksheet rows: it SHALL use a
muted/secondary surface treatment and a text size no larger than `bodySmall`, so
it does not compete with the conversion fields for attention.

#### Scenario: Banner shown for a template that declares one

- **WHEN** the active worksheet template declares a banner
- **THEN** a banner bar is displayed above the worksheet rows

#### Scenario: No banner area for a template without one

- **WHEN** the active worksheet template declares no banner
- **THEN** no banner bar is rendered and the rows start directly below the AppBar

#### Scenario: Banner is visually unobtrusive

- **WHEN** a banner is displayed
- **THEN** its text is rendered at `bodySmall` size or smaller using a muted
  (secondary) color, distinct from the highlighted conversion fields

### Requirement: Currency-rates banner content

A `WorksheetBanner` variant SHALL represent the currency exchange-rate sync
status.  When rendered, this banner SHALL display the timestamp of the most
recent successful exchange-rate sync, formatted identically to the value shown
in the Settings "Currency rates" section.  When no live rates have ever been
fetched, the banner SHALL instead indicate that built-in rates are in use.

The banner SHALL read its status from the same source as the Settings section
(`currencyStatusProvider`) and SHALL update reactively when that status changes
(for example, after a manual or background rate refresh).

#### Scenario: Banner shows last sync time

- **WHEN** the currency-rates banner is displayed and a successful rate sync has occurred
- **THEN** it shows the last-updated timestamp formatted identically to the Settings "Currency rates" section

#### Scenario: Banner shows built-in-rates state

- **WHEN** the currency-rates banner is displayed and no live rates have ever been fetched
- **THEN** it indicates that built-in rates are in use, matching the Settings wording

#### Scenario: Banner updates after a refresh

- **WHEN** the currency-rates banner is displayed
- **AND** a rate refresh completes and updates `currencyStatusProvider`
- **THEN** the banner's displayed timestamp updates without further user input

### Requirement: Shared rate-timestamp formatting

The date/time formatting used for the currency last-updated value SHALL be
provided by a single shared helper used by both the Settings "Currency rates"
section and the currency-rates worksheet banner, so the two locations always
display an identical value.

#### Scenario: Settings and banner agree

- **WHEN** the same last-updated timestamp is formatted for the Settings section and for the worksheet banner
- **THEN** both produce identical text
