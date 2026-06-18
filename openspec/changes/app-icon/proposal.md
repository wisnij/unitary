## Why

Unitary still ships the default Flutter launcher icons on Android, iOS, and web,
so the app has no distinct brand identity on the home screen, app switcher, or
browser tab.  A custom icon (`assets/icon/unitary.svg`) now exists and should be
applied across all platforms.


## What Changes

- Add a raster master image derived from `assets/icon/unitary.svg` and a
  repeatable tooling step to regenerate it, since `flutter_launcher_icons`
  requires a PNG source rather than SVG.
- Add the `flutter_launcher_icons` dev dependency and its configuration block to
  `pubspec.yaml`.
- Generate and replace launcher icons for:
  - **Android** — mipmap launcher icons (mdpi → xxxhdpi) plus adaptive icon.
  - **iOS** — the `AppIcon.appiconset` image set.
  - **Web** — favicon and PWA manifest icons (192/512, including maskable).
- Document the icon regeneration workflow so the icon can be rebuilt when the SVG
  changes.


## Capabilities

### New Capabilities

- `app-icon`: The application's branded launcher/favicon icon and the tooling
  that generates platform-specific icon assets from the source SVG.

### Modified Capabilities

<!-- None — no existing spec's requirements change. -->


## Impact

- **Dependencies**: adds `flutter_launcher_icons` (dev dependency only).
- **Assets**: adds a generated PNG master under `assets/icon/`; the SVG and its
  bundled `DejaVuSansMono-Bold.ttf` are the source of truth.
- **Platform files**: overwrites Android `mipmap-*/ic_launcher.png` (and adaptive
  icon resources), iOS `AppIcon.appiconset`, and web `favicon.png` /
  `web/icons/*` / `manifest.json` icon entries.
- **Tooling**: adds a script/step to rasterize the SVG (via `inkscape`/`magick`)
  and run `dart run flutter_launcher_icons`.
- **Runtime code**: none — no Dart application logic changes.
