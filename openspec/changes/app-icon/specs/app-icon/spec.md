## ADDED Requirements

### Requirement: Branded application icon on all platforms

The application SHALL present the Unitary icon, derived from
`assets/icon/unitary.svg`, as its launcher/favicon icon on Android, iOS, and web,
replacing the default Flutter icons.

#### Scenario: Android launcher icon

- **WHEN** the app is installed on an Android device
- **THEN** the home-screen and app-switcher launcher icon SHALL be the Unitary
  mark at every required mipmap density (mdpi through xxxhdpi)

#### Scenario: Android adaptive icon

- **WHEN** the app is shown on an Android launcher that uses adaptive icons
- **THEN** the icon SHALL render with the Unitary foreground over the dark icon
  background without clipping the mark

#### Scenario: iOS app icon

- **WHEN** the app is installed on an iOS device
- **THEN** the home-screen app icon SHALL be the Unitary mark for every size in
  the `AppIcon.appiconset`, with no alpha channel

#### Scenario: Web favicon and PWA icons

- **WHEN** the web build is loaded in a browser
- **THEN** the favicon and the PWA manifest icons (192 and 512 px, including
  maskable variants) SHALL be the Unitary mark

### Requirement: SVG is the source of truth with a repeatable generation step

The project SHALL keep `assets/icon/unitary.svg` as the canonical icon source and
provide a documented, repeatable step to regenerate the PNG master and all
platform icon assets from it.

#### Scenario: Regenerating icons after the SVG changes

- **WHEN** a developer edits `assets/icon/unitary.svg` and runs the documented
  regeneration step
- **THEN** the PNG master and all Android, iOS, and web icon assets SHALL be
  regenerated from the updated SVG

#### Scenario: Building without the rasterization toolchain

- **WHEN** a developer or CI builds the app without an SVG rasterizer installed
- **THEN** the build SHALL succeed using the committed generated icon assets,
  because the rasterizer is required only when regenerating the icon

#### Scenario: Committing a changed SVG regenerates the assets

- **WHEN** a developer stages a change to `assets/icon/unitary.svg` (or its bundled
  font, or the generation script) and commits with pre-commit enabled
- **THEN** the pre-commit hook SHALL regenerate the platform icon assets from the
  updated source so the committed assets cannot silently drift from the SVG

### Requirement: Icon tooling does not affect the runtime app

The icon generation tooling SHALL be a development-time dependency only and SHALL
NOT introduce any runtime dependency or change application logic.

#### Scenario: No runtime dependency added

- **WHEN** the app is built for release
- **THEN** the shipped application SHALL NOT include `flutter_launcher_icons` or
  any other icon-generation dependency as a runtime dependency
