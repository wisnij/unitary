## Context

The drawer in `home_screen.dart` is a plain `StatelessWidget` with nav entries inlined.  The settings screen (`settings_screen.dart`) owns a `buildMetadata` compile-time constant and a `packageInfoProvider`-backed Version tile in its About section.  No URL-launching capability exists; `url_launcher` is not yet a dependency.  `LICENSE.md` (661 lines, GNU AGPL 3.0) is in the repo root but not declared as a Flutter asset.

## Goals / Non-Goals

**Goals:**

- Add a sidebar About section (Version, Build, License terms, Project home)
- Remove the About section from the Settings screen
- Bundle `LICENSE.md` as an asset and display it on a dedicated screen
- Open the project GitHub URL via `url_launcher`

**Non-Goals:**

- Redesigning the drawer layout beyond adding the About section
- Adding any settings or preferences to the About screen
- Caching the license asset across navigations

## Decisions

### Feature directory structure

Create `lib/features/about/presentation/` for the new `LicenseScreen` widget.  This mirrors the existing `features/settings/presentation/` pattern and keeps About-specific code self-contained.

*Alternative considered*: Inline the license screen in `home_screen.dart`.  Rejected — it would bloat the file and mix navigation logic with screen UI.

### `buildMetadata` constant location

Move the `buildMetadata` constant (currently in `settings_screen.dart`) to `lib/features/about/about_constants.dart` (a small shared file).  Both the drawer and any future About widgets import from there.

*Alternative considered*: Re-declare the constant independently in each file.  Rejected — duplicate `String.fromEnvironment` calls with the same key are error-prone.

### Default value for `BUILD_METADATA`

Change `defaultValue` from `'unknown'` to `''` (empty string).  An empty string means "not provided at compile time"; the Build tile is hidden in this case.  The current `'unknown'` default caused the tile to always display misleadingly.

### Riverpod in the drawer

`HomeScreen` remains a `StatelessWidget`.  Version data is read in `AboutScreen` (`ConsumerWidget`), not in the drawer itself — the drawer contains only a navigation entry to `AboutScreen`.

*Originally planned*: Convert `HomeScreen` to `ConsumerWidget` so the drawer could read `packageInfoProvider` directly.  Superseded when About content was moved to a dedicated screen, making the Riverpod dependency in `HomeScreen` unnecessary.

### License asset delivery

Declare `LICENSE.md` (root) as a Flutter asset in `pubspec.yaml`.  Load it at runtime with `DefaultAssetBundle.of(context).loadString('LICENSE.md')` inside a `FutureBuilder` in `LicenseScreen` (using `DefaultAssetBundle` rather than `rootBundle` to allow asset injection in widget tests).  Render using `flutter_markdown_plus` (`Markdown` widget) so headers, bold text, and hyperlinks are formatted; tapping a link opens it via `url_launcher`.  The default body font is used (not monospace).

*Alternative considered*: Hard-code license text as a Dart string constant.  Rejected — the file is 661 lines; embedding it as source is unwieldy and makes future updates to the file non-obvious.

### URL launching

Add `url_launcher: ^6.3.1` (current stable) as a runtime dependency.  Call `launchUrl(uri, mode: LaunchMode.platformDefault)` on tap.  Wrap in a try/catch; swallow errors silently (no crash, no snackbar — the entry remains tappable).

*Originally planned*: Use `LaunchMode.externalApplication`.  Changed to `LaunchMode.platformDefault` because `externalApplication` is not supported on Flutter Web and silently does nothing there; `platformDefault` opens the system browser on Android and a new tab on Web.

*Alternative considered*: Show a snackbar on launch failure.  Deferred — adds UI complexity for an edge case (no browser installed) that is extremely unlikely on Android.

## Risks / Trade-offs

- **Asset path sensitivity** → `LICENSE.md` must be declared with the exact relative path in `pubspec.yaml` (`assets: [LICENSE.md]`).  A path mismatch causes a runtime exception on the license screen.  Mitigated by a widget test that loads the asset.
- **`url_launcher` Android config** → On Android, `url_launcher` ≥6.x requires a `<queries>` element in `AndroidManifest.xml` for `https` intent visibility.  Without it, `canLaunchUrl` returns false on Android 11+.  The manifest must be updated as part of this change.
- **`HomeScreen` widget test churn** → Not applicable; `HomeScreen` remained a `StatelessWidget` (see Riverpod decision above).

## Migration Plan

1. Add `url_launcher` to `pubspec.yaml`; run `flutter pub get`
2. Declare `LICENSE.md` asset in `pubspec.yaml`
3. Update `android/app/src/main/AndroidManifest.xml` with `<queries>` for https
4. Create `lib/features/about/about_constants.dart` with `buildMetadata` constant (empty default)
5. Create `lib/features/about/presentation/license_screen.dart`
6. Update `home_screen.dart`: add "About" nav entry to the drawer footer (no Riverpod needed)
7. Update `settings_screen.dart`: remove About section and `buildMetadata` constant

No data migration needed — no persistent state is added or removed.

## Resolved Questions

- **Project home subtitle**: Shows the GitHub URL as a subtitle (more informative than icon-only).
- **License screen font**: Uses the app's default body font (`textTheme.bodyMedium`) rather than monospace.
