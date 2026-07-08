## 1. Contrast regression test (write first — it encodes the audit)

- [ ] 1.1 Create `test/shared/color_contrast_test.dart` with WCAG
  relative-luminance / contrast-ratio helpers and an alpha-compositing helper
  (`fg` over opaque `bg`)
- [ ] 1.2 Add threshold assertions for all passing pairings from the audit
  table (muted text, banner text, primary/error text, browse group headers,
  outline border) in both light and dark schemes
- [ ] 1.3 Add threshold assertions for the post-fix pairings (source-row
  `primary` border ≥3:1 vs surface; neighbour labels `onPrimary`@0.85 ≥4.5:1;
  thumb `primary`@0.8 ≥3:1 vs surface; grip lines `onPrimary`@0.9 ≥3:1 vs
  composited thumb) — these fail until sections 2–3 land
- [ ] 1.4 Annotate each entry with the widget file/line it mirrors and a
  comment pointing at the `color-contrast` spec's decorative-exemption list

## 2. Worksheet source-row indicator

- [ ] 2.1 Write/update widget tests: source row's field shows a
  `primary`-colored 2 dp enabled border, non-source rows keep the default
  border; row heights identical between source and non-source rows; focus
  without keystroke does not move the border
- [ ] 2.2 Implement the border cue in `worksheet_screen.dart` (per-row
  `enabledBorder`/`border` override when `isActive`), keeping the existing
  `primaryContainer`@0.3 tint as supplementary
- [ ] 2.3 Verify no existing worksheet tests assert the old fill-only styling;
  update any that do

## 3. Fast scroll bar colors

- [ ] 3.1 Write/update widget tests for the new colors: thumb `primary`@0.8,
  grip lines `onPrimary`@0.9, neighbour labels `onPrimary`@0.85
- [ ] 3.2 Update `fast_scroll_bar.dart`: thumb alpha 0.6 → 0.8, grip color
  `onSurface`@0.4 → `onPrimary`@0.9, neighbour-label alpha 0.65 → 0.85

## 4. Verification and documentation

- [ ] 4.1 Run `flutter test --reporter failures-only` — all tests pass,
  including the contrast test's post-fix assertions
- [ ] 4.2 Run `flutter analyze` — no lint errors
- [ ] 4.3 On-device (or emulator) visual check in both themes: source-row
  border visible but unobtrusive; thumb and preview panel look right
- [ ] 4.4 Update `doc/implementation_plan.md` (check off the contrast-audit
  item, note the accepted decorative usages) and `doc/design_progress.md`;
  update README status paragraph
