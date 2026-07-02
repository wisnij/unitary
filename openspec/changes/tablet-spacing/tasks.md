## 1. Shared wrapper

- [ ] 1.1 Add a `ReadableWidth` stateless widget under `lib/shared/` that centers
      its child within a max width, plus a shared `kReadableMaxWidth = 600`
      constant

## 2. Apply to screens

- [ ] 2.1 Wrap the Freeform scroll content column in `ReadableWidth` (inside
      `SafeArea`, leaving the key panel as a full-width sibling)
- [ ] 2.2 Wrap the Worksheet row table content in `ReadableWidth`
- [ ] 2.3 Wrap the Settings `ListView` body in `ReadableWidth`

## 3. Tests

- [ ] 3.1 Widget test: at a wide width the content is capped at
      `kReadableMaxWidth` and centered (assert content left margin > 0 and width
      ≈ cap)
- [ ] 3.2 Widget test: at phone width the content fills the pane (cap inert, no
      offset)
- [ ] 3.3 Test that Freeform, Worksheet, and Settings all use the same shared cap

## 4. Verification

- [ ] 4.1 Manually verify on a landscape tablet that Freeform, Worksheet, and
      Settings content is centered and no longer over-wide, and that phone
      layouts are unchanged
- [ ] 4.2 Run `flutter test --reporter failures-only` — all tests pass
- [ ] 4.3 Run `flutter analyze` — no new lint issues
