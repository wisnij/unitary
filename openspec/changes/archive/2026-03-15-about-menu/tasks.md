## 1. Dependencies and Assets

- [x] 1.1 Add `url_launcher: ^6.3.1` to `pubspec.yaml` dependencies
- [x] 1.2 Declare `LICENSE.md` as a Flutter asset in `pubspec.yaml`
- [x] 1.3 Add `<queries>` block for `https` intent to `android/app/src/main/AndroidManifest.xml`
- [x] 1.4 Run `flutter pub get` and verify no dependency conflicts

## 2. About Constants

- [x] 2.1 Create `lib/features/about/about_constants.dart` with `buildMetadata` constant (using `String.fromEnvironment('BUILD_METADATA', defaultValue: '')`)
- [x] 2.2 Remove `buildMetadata` constant from `lib/features/settings/presentation/settings_screen.dart` and import from `about_constants.dart` instead (temporary — will be removed entirely in task 5)

## 3. License Screen

- [x] 3.1 Create `lib/features/about/presentation/license_screen.dart` with a `Scaffold` + `AppBar` titled "License terms"
- [x] 3.2 Load `LICENSE.md` asset with `rootBundle.loadString` inside a `FutureBuilder`
- [x] 3.3 Display loaded text as scrollable, monospace-font content; show loading indicator while pending and error message on failure
- [x] 3.4 Write widget tests for `LicenseScreen`: asset loads and text is present, back navigation works

## 4. Drawer About Section

- [x] 4.1 Convert `HomeScreen` from `StatelessWidget` to `ConsumerWidget`
- [x] 4.2 Add a `Divider` after the Settings entry in the drawer
- [x] 4.3 Add non-interactive Version tile that reads from `packageInfoProvider` (loading and error states handled)
- [x] 4.4 Add non-interactive Build tile that shows `buildMetadata`; hide the tile entirely when `buildMetadata` is empty
- [x] 4.5 Add "License terms" `ListTile` that closes the drawer and pushes `LicenseScreen`
- [x] 4.6 Add "Project home" `ListTile` that calls `launchUrl` with the GitHub repo URL; handle launch failure silently
- [x] 4.7 Write widget tests for the drawer About section: version tile present, build tile hidden when metadata empty, build tile visible when metadata non-empty, license tile navigates, project home tile calls url launcher

## 5. Remove About from Settings

- [x] 5.1 Remove the `_SectionHeader(title: 'About')` and Version `ListTile` from `settings_screen.dart`
- [x] 5.2 Remove the `package_info_provider.dart` import from `settings_screen.dart` (no longer needed there)
- [x] 5.3 Remove the now-unused `buildMetadata` import/reference from `settings_screen.dart`
- [x] 5.4 Update or remove any settings screen tests that referenced the About/Version tile

## 6. Verification

- [x] 6.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 6.2 Run `flutter analyze` and confirm no lint errors
