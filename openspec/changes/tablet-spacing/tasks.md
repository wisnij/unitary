## 1. Shared wrapper

- [x] 1.1 Add a `ReadableWidth` stateless widget under `lib/shared/` that centers
      its child within a max width, plus a shared `kReadableMaxWidth = 600`
      constant — uses `Align(topCenter)` + `ConstrainedBox` so it only caps width
      (safe in scroll contexts; no vertical centering)

## 2. Apply to screens

- [x] 2.1 Wrap the Freeform scroll content column in `ReadableWidth` (inside
      `SafeArea`, leaving the key panel as a full-width sibling) — wraps the
      `SingleChildScrollView` inside the `Expanded`
- [x] 2.2 Wrap the Worksheet row table content in `ReadableWidth` — wraps the
      `LayoutBuilder` so the cap also feeds `maxLabelWidth`; the banner stays
      full-width
- [x] 2.3 Wrap the Settings `ListView` body in `ReadableWidth`

## 3. Tests

- [x] 3.1 Widget test: at a wide width the content is capped at
      `kReadableMaxWidth` and centered (assert content left margin > 0 and width
      ≈ cap)
- [x] 3.2 Widget test: at phone width the content fills the pane (cap inert, no
      offset)
- [x] 3.3 Test that Freeform, Worksheet, and Settings all use the same shared cap
      — each screen test asserts it renders a `ReadableWidth`

## 4. Verification

- [ ] 4.1 Manually verify on a landscape tablet that Freeform, Worksheet, and
      Settings content is centered and no longer over-wide, and that phone
      layouts are unchanged — **requires a device; pending user.**
- [x] 4.2 Run `flutter test --reporter failures-only` — all tests pass (1903)
- [x] 4.3 Run `flutter analyze` — no new lint issues ("No issues found!")
