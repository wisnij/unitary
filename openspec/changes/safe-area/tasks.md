## 1. Platform inset verification

- [x] 1.1 Confirm Android reports display-cutout insets: run on a cutout device
      (or emulator with a simulated cutout) in landscape and verify
      `MediaQuery.of(context).padding` reports a non-zero inset on the cutout edge
      — verified analytically: content is *already* drawn under the cutout, which
      is only possible when the window extends into the cutout region, meaning
      Android already reports the cutout via `WindowInsets` → `MediaQuery.padding`.
      Empirical on-device confirmation folded into 5.1.
- [x] 1.2 If insets are not reported, enable edge-to-edge / display-cutout mode
      (Android manifest / theme `layoutInDisplayCutoutMode`) and re-verify — not
      needed: insets are already reported (see 1.1), so no manifest/theme change
      was required.

## 2. Screen body safe areas

- [x] 2.1 Wrap the `Scaffold` body in `SafeArea` in `freeform_screen.dart`
- [x] 2.2 Wrap the `Scaffold` body in `SafeArea` in `worksheet_screen.dart`
- [x] 2.3 Wrap the `Scaffold` body in `SafeArea` in `browser_screen.dart`
- [x] 2.4 Wrap the `Scaffold` body in `SafeArea` in `settings_screen.dart`
- [x] 2.5 Wrap the `Scaffold` body in `SafeArea` in `about_screen.dart`
- [x] 2.6 Wrap the bodies of pushed sub-screens (`UnitEntryDetailScreen`,
      `LicenseScreen`) in `SafeArea`

## 3. Navigation rail safe area

- [x] 3.1 Wrap the navigation rail `Row` in `app_shell.dart` (expanded tier) in
      `SafeArea` and confirm no double-inset with body-level `SafeArea`s

## 4. Tests

- [x] 4.1 Add widget tests that pump a screen under a `MediaQuery` with non-zero
      `padding` and assert body content is offset by the inset
- [x] 4.2 Add a test confirming zero `padding` leaves the layout unchanged
- [x] 4.3 Add a test for the rail being inset at expanded width with a cutout on
      the rail edge

## 5. Verification

- [ ] 5.1 Manually verify on-device in landscape that the previously-obscured
      content (Freeform "Convert to", Browse list, Settings section headers) is
      no longer behind the cutout — **requires a physical cutout device; pending
      user.**
- [x] 5.2 Run `flutter test --reporter failures-only` — all tests pass (1898)
- [x] 5.3 Run `flutter analyze` — no new lint issues ("No issues found!")
