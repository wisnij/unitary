## 1. Touch Target Expansion

- [x] 1.1 Add `_thumbHitWidth = 44.0` constant to `_FastScrollBarState`, keeping `_thumbWidth` as the visual width
- [x] 1.2 Wrap the `GestureDetector` child in a `SizedBox(width: _thumbHitWidth)` with the thumb right-aligned inside it
- [x] 1.3 Add widget test: hit area extends at least 44 dp from the right edge (drag gesture accepted outside the visual thumb bounds)

## 2. Drag Handle Appearance

- [x] 2.1 Update `_thumbWidth` constant from `6.0` to `12.0`
- [x] 2.2 Restyle `_ThumbWidget`: widen pill to `_thumbWidth`, add three horizontal grip-line `Container`s centred vertically (each ~8 dp wide, 2 dp tall, `colorScheme.onSurface.withValues(alpha: 0.4)`)
- [x] 2.3 Add widget test: three grip-line widgets are present when the thumb is visible
- [x] 2.4 Add widget test: grip lines are rendered in dark theme (verify widget exists with dark `ThemeData`)

## 3. Neighbour Group Label Panel

- [x] 3.1 Add static helper `groupIndexForFraction(double fraction, List<(int, String)> anchors, int itemCount) → int` to `FastScrollBar` returning the current anchor index (−1 when no anchors)
- [x] 3.2 Add unit tests for `groupIndexForFraction`: empty anchors, single anchor, first group, mid-list group, last group
- [x] 3.3 Replace `_LabelBubble` with `_PeekPanel` widget; accept `currentIndex`, `anchors`, and a `neighbourCount` (default 2) parameter
- [x] 3.4 Implement `_PeekPanel` layout: up to `neighbourCount` de-emphasised rows above, the current-group row in `titleMedium`/bold, up to `neighbourCount` de-emphasised rows below; omit rows that don't exist
- [x] 3.5 Add `maxWidth` constraint to `_PeekPanel` (e.g. `BoxConstraints(maxWidth: 220)`) to prevent overflow on narrow screens
- [x] 3.6 Update `FastScrollBar.labelKey` to target the new `_PeekPanel` (or add a `peekPanelKey` constant) and remove the now-unused `labelKey` if appropriate
- [x] 3.7 Update the `Positioned` calculation in `_FastScrollBarState.build` to anchor on the mid-point of the current-group row rather than the top of the bubble
- [x] 3.8 Add widget test: mid-list drag shows 2 neighbours above and 2 below the current group
- [x] 3.9 Add widget test: drag near top shows fewer than 2 neighbours above
- [x] 3.10 Add widget test: panel is not visible when not dragging
- [x] 3.11 Add widget test: panel current-group label updates when thumb crosses a group boundary

## 4. Cleanup and Verification

- [x] 4.1 Remove the old `_LabelBubble` class if fully replaced by `_PeekPanel`
- [x] 4.2 Run `flutter test test/shared/widgets/fast_scroll_bar_test.dart` — all tests pass
- [x] 4.3 Run `flutter test --reporter failures-only` — full suite passes
- [x] 4.4 Run `flutter analyze` — no new lint errors
