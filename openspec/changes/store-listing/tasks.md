## 1. Store listing checks

- [x] 1.1 Write tests first in `test/tool/check_store_listing_lib_test.dart`
  for the PNG header reader: width, height, bit depth, and colour type from
  synthetic PNG bytes; a clear error for a non-PNG or truncated file
- [x] 1.2 Write tests for the text checks: limits counted in runes (a `•` or
  `–` counts once), single-line rules for the title and short description, a
  trailing newline ignored, empty text rejected
- [x] 1.3 Write tests for the image rules in design D2: icon, feature graphic,
  phone, and tablet, including exact 9:16 and 16:9 acceptance, 16:10 rejection,
  alpha rejection, size bounds, and the 4–8 count per set
- [x] 1.4 Implement `tool/check_store_listing_lib.dart` until 1.1–1.3 pass
- [x] 1.5 Add a test that runs every check against the real
  `fastlane/metadata/android/en-US/` tree, reporting each failing file and
  rule.  It fails until sections 2–5 have produced the tree

## 2. Screenshot capture

- [x] 2.1 Make `test_driver/screenshots_driver.dart` write to the directory in
  `SCREENSHOT_DIR`, defaulting to `doc/screenshots/`
- [x] 2.2 Refactor `integration_test/screenshots/take_screenshots.dart` into
  layout-aware helpers (design D6): navigation rail or drawer, dropdown or
  template list, pushed or embedded unit detail
- [x] 2.3 Select the capture sequence with `--dart-define=SCREENSHOT_SET`
  (`readme`, `phone`, `tablet`).  Keep the `readme` sequence and names exactly
  as today.  For `tablet`, run a few conversions before the freeform capture so
  the history pane is filled
- [x] 2.4 Add AVD creation to `tool/take_screenshots.sh`: the three profiles in
  design D5, created from the API 35 `google_apis` x86_64 image with
  `ANDROID_AVD_HOME=~/.android/avd`, with `hw.lcd.width`, `hw.lcd.height`, and
  `hw.lcd.density` overridden.  Confirm on first boot that each reports the
  intended size and density (`adb shell wm size`, `wm density`) and that the
  10-inch one starts in landscape
- [x] 2.5 Add the target argument to `tool/take_screenshots.sh` (`readme`
  default, `phone`, `seven-inch`, `ten-inch`, `store`).  For store targets:
  boot the AVD, turn on the dark theme, capture into
  `build/screenshots/<target>/`, remove the alpha channel, and replace the
  fastlane folder's contents with numbered files.  Use `[[ ]]` tests
- [x] 2.6 ~~Check the demo-mode commands on the API 35 image~~ – dropped: the
  capture records only the Flutter surface, so the system status bar never
  appears in a screenshot (README captures included), and demo mode had
  nothing to fix.  Found on the first phone capture
- [x] 2.7 Run `tool/take_screenshots.sh` with no argument and confirm the
  README screenshots come out with the same names and sizes as before and look
  the same
- [x] 2.8 Run `tool/take_screenshots.sh store` and review every capture:
  correct layout tier per set, two panes on tablets, history filled, no stray
  overlays or keyboards, no files changed under `doc/screenshots/`

## 3. Store graphics

- [x] 3.1 Download Anton and Oswald from their upstream repositories (Google
  Fonts) into a scratch directory with their `OFL.txt`
- [x] 3.2 Write `assets/store/feature_graphic.svg` following the mockup in
  design D4: gradient background, icon via `<image>` of `../icon/unitary.svg`,
  wordmark and tagline as `<text>`, and a device frame with the phone set's
  Length worksheet clipped to its screen
- [x] 3.3 Render the graphic with each candidate font, compare both with
  `feature-graphic.png`, keep the closer one in `assets/store/fonts/` with its
  `OFL.txt`, and record the choice in the design's Open Questions
- [x] 3.4 Write `tool/generate_store_graphics.sh`: temporary fontconfig file
  adding `assets/store/fonts/`, an `fc-match` check that fails unless the
  bundled font resolves, the 512×512 RGBA icon, and the 1024×500 RGB feature
  graphic with the alpha channel removed.  Fall back to the rendered icon PNG in
  the SVG if Inkscape renders the nested SVG poorly
- [x] 3.5 Check the font-missing path: with the font file moved away, the
  script fails, names the font, and writes no feature graphic
- [x] 3.6 Add the `generate-store-graphics` pre-commit hook with its inputs
  (design D3), and add it to `SKIP` in `.github/actions/lint/action.yml` with a
  comment, next to `generate-icons`
- [x] 3.7 Confirm the font is not in the app: `assets/store/` is not listed
  under `flutter: assets:` in `pubspec.yaml`, and a release APK's
  `flutter_assets` does not contain it

## 4. Store text

- [x] 4.1 Write `title.txt` (`Unitary: Unit Converter`)
- [x] 4.2 Write `short_description.txt` per design D7
- [x] 4.3 Write `full_description.txt` per design D7, checking every factual
  claim against the app and `PRIVACY.md`
- [ ] 4.4 Show the text to the maintainer for review before finishing

## 5. Verification

- [x] 5.1 The real-tree test from 1.5 passes
- [x] 5.2 Run `pre-commit run --all-files` and fix anything it reports
- [x] 5.3 Run `flutter test --reporter failures-only` and `flutter analyze`,
  both clean
- [ ] 5.4 Compare the rendered feature graphic with the mockup side by side
  and show both to the maintainer
- [ ] 5.5 Delete `feature-graphic.png` from the repository root once the
  maintainer accepts the rendered graphic, or move it under `assets/store/` if
  they want to keep it as a reference

## 6. Documentation

- [x] 6.1 Update `tool/take_screenshots.sh`'s header comment and the capture
  file's header for the targets; add a short "Store listing" note to
  `CONTRIBUTING.md` or `doc/` saying where the listing lives and how to
  regenerate it
- [x] 6.2 Update `doc/implementation_plan.md` Phase 10 task 7: the listing copy,
  graphics, and screenshot items, with what was done and what remains (copying
  into the Play Console)
- [x] 6.3 Add a dated entry to `doc/design_progress.md`
