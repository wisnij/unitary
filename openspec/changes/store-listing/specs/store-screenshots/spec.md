## ADDED Requirements

### Requirement: Screenshot sets for phone, 7-inch, and 10-inch tablets

The repository SHALL hold three store screenshot sets under
`metadata/en-US/images/`: `phoneScreenshots/`,
`sevenInchScreenshots/`, and `tenInchScreenshots/`.  Each set SHALL contain
between four and eight PNG files named `NN_<name>.png`, where `NN` is a two-digit
number giving the order in the listing.

#### Scenario: Each set exists and is within the count limits

- **WHEN** the three screenshot folders are listed
- **THEN** each contains between four and eight files named `NN_<name>.png`

### Requirement: Screenshots meet Play's image requirements

Every store screenshot SHALL be a 24-bit PNG with no alpha channel and an exact
9:16 or 16:9 aspect ratio.  Phone screenshots SHALL have a short side of at
least 1080 px and a long side of at most 3840 px.  Tablet screenshots SHALL be
between 1080 and 7680 px on each side.  A test SHALL check the committed sets
against these requirements and SHALL fail when any image or set breaks one.

#### Scenario: Committed sets pass

- **WHEN** the test suite runs against the committed screenshot sets
- **THEN** the screenshot checks pass

#### Scenario: A 16:10 tablet screenshot

- **WHEN** a tablet screenshot is 2560×1600
- **THEN** the check reports it as not 9:16 or 16:9 and the test fails

#### Scenario: A screenshot with an alpha channel

- **WHEN** a screenshot is an RGBA PNG
- **THEN** the check reports the alpha channel and the test fails

### Requirement: Each set shows the layout for its screen size

The phone set SHALL be captured on a screen that puts the app in its compact
layout, the 7-inch set on one that puts it in the medium layout, and the
10-inch set on one that puts it in the expanded layout with the navigation
rail.  The tablet sets SHALL show the two-pane layouts: freeform with its
history pane holding past conversions, a worksheet beside the template list,
and the unit browser with a unit's detail in the right pane.

Every set SHALL end with the Settings page twice: in the dark theme, and again
after switching the app to light mode.

#### Scenario: 10-inch browser capture

- **WHEN** the 10-inch set's browser screenshot is viewed
- **THEN** it shows the navigation rail, the unit list, and a unit's detail
  side by side

#### Scenario: Tablet freeform capture

- **WHEN** a tablet set's freeform screenshot is viewed
- **THEN** its history pane lists at least one earlier conversion

#### Scenario: Both themes in every set

- **WHEN** any set's last two screenshots are viewed
- **THEN** they show the Settings page in the dark theme and then in the light
  theme

### Requirement: Screenshots are captured reproducibly by script

`tool/take_screenshots.sh` SHALL capture a set when given its target
(`phone`, `seven-inch`, or `ten-inch`), and all three when given `store`, and
SHALL require one of those arguments.  For
each target it SHALL create the target's emulator profile if it does not exist,
boot it, capture the set in the dark theme, remove the alpha channel, and
replace the contents of the set's folder with the new captures.  It SHALL
shut down only emulators it started.

#### Scenario: Capturing the 10-inch set on a fresh machine

- **WHEN** `tool/take_screenshots.sh ten-inch` runs with no tablet emulator
  profile present
- **THEN** it creates the profile, boots it, captures the set into
  `tenInchScreenshots/`, and shuts the emulator down

#### Scenario: Re-capturing replaces stale files

- **WHEN** a set is re-captured with fewer screenshots than before
- **THEN** the folder holds only the new captures

### Requirement: The README screenshots are derived from the phone set

The README screenshots in `doc/screenshots/` SHALL be copies of the phone set,
downscaled to 480 px wide and named after the page each shows (`freeform.png`,
`worksheet.png`, `currency.png`, `browser.png`, `unit-detail.png`,
`settings-dark.png`, `settings-light.png`).  Capturing the phone set SHALL
regenerate them; no separate README capture SHALL exist.  Capturing a tablet
set SHALL NOT modify `doc/screenshots/`.

#### Scenario: Phone capture updates the README

- **WHEN** `tool/take_screenshots.sh phone` runs
- **THEN** `doc/screenshots/` holds the seven named files, each a 480 px wide
  copy of the corresponding phone screenshot

#### Scenario: Tablet capture leaves the README alone

- **WHEN** `tool/take_screenshots.sh ten-inch` runs
- **THEN** no file under `doc/screenshots/` changes

#### Scenario: No target given

- **WHEN** `tool/take_screenshots.sh` runs with no argument
- **THEN** it prints its usage and exits without capturing anything
