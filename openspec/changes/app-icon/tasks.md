## 1. Rasterize the SVG to a PNG master

- [ ] 1.1 Confirm `assets/icon/DejaVuSansMono-Bold.ttf` is available to the
      rasterizer (install/reference it if Inkscape does not resolve the relative
      `@font-face` URL)
- [ ] 1.2 Rasterize `assets/icon/unitary.svg` to `assets/icon/unitary.png` at
      1024×1024 with Inkscape
- [ ] 1.3 Visually verify the PNG master: text renders in DejaVu Sans Mono Bold,
      gradient background and glow are correct, no fallback font
- [ ] 1.4 Add a documented regeneration step (script under `tool/` or README
      section) capturing the rasterize + generate commands

## 2. Configure flutter_launcher_icons

- [ ] 2.1 Add `flutter_launcher_icons` to `dev_dependencies` in `pubspec.yaml`
      with a pinned caret range
- [ ] 2.2 Add the `flutter_launcher_icons` config block (image_path, android +
      adaptive icon with `#060d18` background, ios with `remove_alpha_ios`, web
      generate with background/theme `#060d18`)
- [ ] 2.3 Run `flutter pub get`

## 3. Generate platform icons

- [ ] 3.1 Run `dart run flutter_launcher_icons`
- [ ] 3.2 Verify Android mipmap icons (mdpi–xxxhdpi) and adaptive icon resources
      were replaced
- [ ] 3.3 Verify iOS `AppIcon.appiconset` images and `Contents.json` were updated
      and contain no alpha
- [ ] 3.4 Verify web `favicon.png` and `web/icons/*` (192/512 + maskable) were
      replaced; update `web/manifest.json` `background_color`/`theme_color` to
      `#060d18` if not already

## 4. Verify and finalize

- [ ] 4.1 Build/run web and confirm the favicon and PWA icons show the Unitary mark
- [ ] 4.2 Build/run Android (emulator or device) and confirm the launcher icon
- [ ] 4.3 Run `flutter analyze` and `flutter test --reporter failures-only` to
      confirm no regressions from the pubspec/asset changes
- [ ] 4.4 Update README/progress docs to note the icon and its regeneration step
