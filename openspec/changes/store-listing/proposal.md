## Why

The app is published on Google Play's closed track with a placeholder
description, phone screenshots downscaled for the README, and no feature
graphic.  The listing is what closed-test recruits and, later, the public see
first, and none of it is version-controlled: the text lives only in the Play
Console, and nothing can regenerate the graphics.  Play also needs tablet
screenshots before it will show the app as tablet-ready, and the two-pane
layouts are worth showing.

## What Changes

- New `fastlane/metadata/android/en-US/` tree, the standard layout read by
  fastlane `supply`, Gradle Play Publisher, and F-Droid.  It holds the store
  text (`title.txt`, `short_description.txt`, `full_description.txt`) and the
  images (`images/icon.png`, `images/featureGraphic.png`, and screenshot
  folders for phone, 7-inch, and 10-inch tablets).  Uploading stays manual:
  the files are copied into the Play Console by hand.
- Store text written for people who have never heard of the app, with the title
  **"Unitary: Unit Converter"**.  A test enforces Play's length limits.
- A feature graphic built from an SVG source that follows the maintainer's
  mockup: the app icon, the "Unitary" wordmark and tagline in a
  bundled SIL Open Font License font, and a device frame holding a screenshot
  from the capture pipeline.  It renders to a 1024×500 PNG with no alpha.  The
  512×512 store icon is rendered from the existing `assets/icon/unitary.svg`.
- The screenshot capture gains three store targets (phone, 7-inch tablet,
  10-inch tablet), each on its own emulator profile with a 9:16 or 16:9 screen
  at a resolution Play accepts.  The capture flow navigates each layout the way
  a user would: drawer or navigation rail, template dropdown or list pane,
  pushed or embedded unit detail.  Store captures keep full resolution and use
  the dark theme.
- The existing README capture is unchanged by default.
- A test checks the committed images against Play's requirements: dimensions,
  aspect ratios, alpha channel, and the minimum screenshot counts.

Not in this change: automated uploads to Play, per-release "What's new" text
(`changelogs/`), translations, and a Chromebook screenshot set.

## Capabilities

### New Capabilities

- `store-listing-metadata`: the version-controlled store text: where it lives,
  its title, what the description must cover and must not claim, and the length
  limits the test enforces.
- `store-graphics`: the store icon and the feature graphic: their sources,
  rendering, bundled font, required formats, and how they stay in step with
  their sources.
- `store-screenshots`: the phone, 7-inch, and 10-inch screenshot sets: the
  emulator profiles, what each set shows, the requirements each image must
  meet, and how they are captured without disturbing the README screenshots.

### Modified Capabilities

None.

## Impact

- New `fastlane/metadata/android/en-US/` tree (text and PNGs).
- New `assets/store/` holding the feature-graphic SVG and its font with the
  font's license.
- `tool/take_screenshots.sh`, `integration_test/screenshots/take_screenshots.dart`,
  and `test_driver/screenshots_driver.dart`: capture targets, layout-aware
  navigation, and a configurable output directory.
- New script to render the store graphics, and a pre-commit hook that runs it
  when its sources change.
- New `tool/check_store_listing_lib.dart` with tests, including one that checks
  the committed tree.
- New local emulator profiles (not committed), created by the capture script
  from the installed API 35 system image.
- No new Dart or Gradle dependencies.  Uses Inkscape and ImageMagick, which the
  icon and README pipelines already require.
