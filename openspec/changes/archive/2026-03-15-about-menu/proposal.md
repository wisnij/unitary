## Why

The current About section is buried at the bottom of the Settings page as a single version tile, making it hard to discover and too limited for the app's legal and attribution needs.  Moving it to the sidebar as a dedicated section gives it appropriate visibility and allows it to host license terms and a project link.

## What Changes

- Add an **About** section to the sidebar drawer, below the existing Settings entry and a divider
- About section contains four entries:
  - **Version** — displays app version (e.g. "0.5.9") read from `package_info_plus`
  - **Build** — displays build metadata string (e.g. "build 20260315-123456.abc1234"), or hidden when no build metadata is set
  - **License terms** — tappable entry; navigates to a full-screen view displaying the GNU AGPL 3.0 license text bundled from `LICENSE.md`
  - **Project home** — tappable entry; opens the project GitHub URL in the system browser
- Remove the existing **About** section (Version tile) from the Settings page
- Add `url_launcher` dependency for opening the GitHub URL

## Capabilities

### New Capabilities

- `about-menu`: Sidebar About section with version, build, license, and source-code entries

### Modified Capabilities

- `settings`: Remove the About / Version tile from the settings screen (requirement change: version info no longer lives in settings)

## Impact

- `lib/features/freeform/presentation/home_screen.dart` — add About entries to the drawer
- `lib/features/settings/presentation/settings_screen.dart` — remove About section
- New screen: `lib/features/about/presentation/license_screen.dart` (or similar)
- `assets/` — bundle `LICENSE.md` as a Flutter asset
- `pubspec.yaml` — add `url_launcher` dependency; declare `LICENSE.md` asset
