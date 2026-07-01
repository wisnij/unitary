## 1. Platform inset verification

- [ ] 1.1 Confirm Android reports display-cutout insets: run on a cutout device
      (or emulator with a simulated cutout) in landscape and verify
      `MediaQuery.of(context).padding` reports a non-zero inset on the cutout edge
- [ ] 1.2 If insets are not reported, enable edge-to-edge / display-cutout mode
      (Android manifest / theme `layoutInDisplayCutoutMode`) and re-verify

## 2. Screen body safe areas

- [ ] 2.1 Wrap the `Scaffold` body in `SafeArea` in `freeform_screen.dart`
- [ ] 2.2 Wrap the `Scaffold` body in `SafeArea` in `worksheet_screen.dart`
- [ ] 2.3 Wrap the `Scaffold` body in `SafeArea` in `browser_screen.dart`
- [ ] 2.4 Wrap the `Scaffold` body in `SafeArea` in `settings_screen.dart`
- [ ] 2.5 Wrap the `Scaffold` body in `SafeArea` in `about_screen.dart`
- [ ] 2.6 Wrap the bodies of pushed sub-screens (`UnitEntryDetailScreen`,
      `LicenseScreen`) in `SafeArea`

## 3. Navigation rail safe area

- [ ] 3.1 Wrap the navigation rail `Row` in `app_shell.dart` (expanded tier) in
      `SafeArea` and confirm no double-inset with body-level `SafeArea`s

## 4. Tests

- [ ] 4.1 Add widget tests that pump a screen under a `MediaQuery` with non-zero
      `padding` and assert body content is offset by the inset
- [ ] 4.2 Add a test confirming zero `padding` leaves the layout unchanged
- [ ] 4.3 Add a test for the rail being inset at expanded width with a cutout on
      the rail edge

## 5. Verification

- [ ] 5.1 Manually verify on-device in landscape that the previously-obscured
      content (Freeform "Convert to", Browse list, Settings section headers) is
      no longer behind the cutout
- [ ] 5.2 Run `flutter test --reporter failures-only` — all tests pass
- [ ] 5.3 Run `flutter analyze` — no new lint issues
