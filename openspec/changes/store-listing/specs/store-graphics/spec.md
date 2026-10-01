## ADDED Requirements

### Requirement: Store icon rendered from the app icon source

The store icon SHALL be `fastlane/metadata/android/en-US/images/icon.png`, a
512×512 32-bit PNG with an alpha channel, rendered from
`assets/icon/unitary.svg` by `tool/generate_store_graphics.sh`.

#### Scenario: The committed icon meets Play's format

- **WHEN** the committed `icon.png` is inspected
- **THEN** it is 512×512 with 8-bit RGBA colour

### Requirement: Feature graphic rendered from an SVG source

The feature graphic SHALL be `fastlane/metadata/android/en-US/images/featureGraphic.png`,
a 1024×500 24-bit PNG with no alpha channel, rendered by
`tool/generate_store_graphics.sh` from `assets/store/feature_graphic.svg`.  The
SVG SHALL follow the mockup: the app icon, the wordmark "Unitary", the tagline
"Unit conversion & dimensional analysis", and a phone showing a screenshot of
the app, on a dark navy background.  The wordmark and tagline SHALL remain
editable text in the SVG.

#### Scenario: The committed feature graphic meets Play's format

- **WHEN** the committed `featureGraphic.png` is inspected
- **THEN** it is 1024×500 with 8-bit RGB colour and no alpha channel

#### Scenario: The graphic shows a current capture

- **WHEN** the phone screenshot set is re-captured and the graphics are
  re-rendered
- **THEN** the phone in the feature graphic shows the new capture of the Length
  worksheet

### Requirement: The wordmark font is bundled and free to redistribute

The feature graphic's text SHALL use a font licensed under the SIL Open Font
License, stored with its licence text in `assets/store/fonts/`.  The font SHALL
NOT be bundled into the app.  Rendering SHALL use the bundled file without
requiring the font to be installed, and SHALL fail rather than render in a
substitute font when the bundled font cannot be found.

#### Scenario: Rendering on a machine without the font installed

- **WHEN** `tool/generate_store_graphics.sh` runs on a machine where the font is
  not installed system-wide
- **THEN** the graphic renders in the bundled font

#### Scenario: The bundled font is missing

- **WHEN** the font file is absent from `assets/store/fonts/`
- **THEN** the script exits with an error naming the font and writes no
  feature graphic

#### Scenario: The app does not ship the font

- **WHEN** a release build's assets are listed
- **THEN** they do not include the store font

### Requirement: Rendered graphics stay in step with their sources

A pre-commit hook SHALL run `tool/generate_store_graphics.sh` whenever the
feature graphic SVG, its font, the icon SVG, the phone screenshot the graphic
embeds, or the script itself changes.  CI SHALL skip the hook, since its
runners do not have Inkscape, and SHALL still check the committed images'
formats through the test suite.

#### Scenario: Editing the feature graphic source

- **WHEN** `assets/store/feature_graphic.svg` is changed and committed
- **THEN** the hook regenerates `featureGraphic.png` as part of the commit

#### Scenario: CI lint job

- **WHEN** the CI lint job runs the pre-commit hooks
- **THEN** the store graphics hook is skipped, and the image format checks run
  in the test job

### Requirement: Committed graphics are checked against Play's formats

A test SHALL check the committed icon and feature graphic against the
dimensions and colour types above, reading them from the PNG header, and SHALL
fail when either does not match.

#### Scenario: A feature graphic with an alpha channel

- **WHEN** the committed feature graphic has an alpha channel
- **THEN** the test fails, naming the file and the problem
