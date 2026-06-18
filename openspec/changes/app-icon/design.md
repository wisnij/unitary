## Context

Unitary targets Android (primary), iOS (secondary), and web.  All three
platforms currently carry the stock Flutter launcher icons created by
`flutter create`.  A designed icon now exists at `assets/icon/unitary.svg`
(1024×1024 viewBox), which embeds `DejaVuSansMono-Bold.ttf` (co-located in
`assets/icon/`) via an `@font-face` rule and uses gradients/filters for a glowing
arc-and-text mark.

`flutter_launcher_icons` is the established tool for generating per-platform icon
assets, but it consumes a raster image (PNG), not SVG.  So the SVG must first be
rasterized to a high-resolution PNG master.  The dev environment has both
`inkscape` and ImageMagick (`magick`/`convert`) available.


## Goals / Non-Goals

**Goals:**

- Replace the default launcher/favicon icons on Android, iOS, and web with the
  Unitary mark.
- Keep the SVG as the single source of truth, with a repeatable, documented step
  to regenerate the PNG master and all platform assets.
- Add no runtime dependencies — only a dev dependency used at build/generation
  time.

**Non-Goals:**

- No in-app use of the icon (splash screens, about page artwork, etc.).
- No change to app name, theme colors, or other branding beyond the icon.
- No automated CI regeneration of icons; regeneration is a manual, documented
  developer step.
- No new desktop platforms (macOS/Windows/Linux are not present and are out of
  scope).


## Decisions

### 1. Rasterize the SVG with Inkscape, not ImageMagick

Use `inkscape assets/icon/unitary.svg -w 1024 -h 1024 -o assets/icon/unitary.png`
to produce the PNG master.

- **Why**: The SVG relies on `@font-face` text rendering, gradients, and a Gaussian
  blur filter.  Inkscape has a full SVG/CSS rendering engine and honors the
  embedded font reference; ImageMagick's SVG support (via its internal MSVG/rsvg
  delegate) is inconsistent with fonts and filters and frequently mis-renders.
- **Alternative considered**: `magick unitary.svg unitary.png` — rejected due to
  unreliable font and filter handling.
- **Font availability**: The `@font-face` `src` is a relative path to the bundled
  TTF.  If Inkscape does not resolve the relative URL, the build step will
  temporarily install/point to `assets/icon/DejaVuSansMono-Bold.ttf` so glyphs
  render correctly.  Output must be visually verified to confirm the text renders
  in DejaVu Sans Mono Bold and not a fallback.

### 2. Generate platform icons with `flutter_launcher_icons`

Add `flutter_launcher_icons` as a dev dependency and configure it in
`pubspec.yaml`:

```yaml
flutter_launcher_icons:
  image_path: "assets/icon/unitary.png"
  android: true
  adaptive_icon_background: "#060d18"
  adaptive_icon_foreground: "assets/icon/unitary.png"
  ios: true
  remove_alpha_ios: true
  web:
    generate: true
    background_color: "#060d18"
    theme_color: "#060d18"
```

Then run `dart run flutter_launcher_icons`.

- **Why**: It is the de facto standard, regenerates all required Android mipmap
  densities, the iOS `AppIcon.appiconset`, and web manifest icons from one source,
  and keeps sizing/format correct per platform.
- **Alternative considered**: Hand-rolled `inkscape`/`magick` resize script
  writing each target file.  Rejected — more code to maintain, and it would not
  produce iOS `Contents.json` or Android adaptive-icon XML correctly.

### 3. Background and adaptive-icon handling

- Use the SVG's dark background color (`#060d18`, the gradient's darker stop) for
  the Android adaptive icon background and web theme/background colors, so the
  icon reads consistently on adaptive launchers and as a PWA.
- `remove_alpha_ios: true` because iOS rejects icons with an alpha channel.
- The existing `manifest.json` currently uses `#0175C2`; it will be updated to
  match the icon's dark background for visual consistency.

### 4. Commit generated assets to the repo

The generated PNGs (master and all platform files) are committed, matching how
Flutter already tracks the stock icons.

- **Why**: Builds must not require Inkscape on every machine/CI; only developers
  regenerating the icon need it.  The generation step is documented for that case.


## Risks / Trade-offs

- **Embedded font may not render during rasterization** → Verify the PNG master
  visually; if the relative `@font-face` URL is not honored by Inkscape, install
  or reference the bundled `DejaVuSansMono-Bold.ttf` before rasterizing.  The font
  is already present in `assets/icon/`.
- **Filters/glow may differ between renderers** → Standardize on Inkscape (Decision
  1) and verify output; the master PNG is committed so the rendered result is
  fixed regardless of who builds the app.
- **iOS alpha rejection** → `remove_alpha_ios: true` flattens transparency against
  the configured background.
- **Manifest color change** is a minor visual tweak, not a functional risk; it
  aligns the PWA chrome with the new icon.
- **`flutter_launcher_icons` version drift** → Pin a caret range in
  `pubspec.yaml`; it is dev-only and does not affect the shipped app at runtime.
