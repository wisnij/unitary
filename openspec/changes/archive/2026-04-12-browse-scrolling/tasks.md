## 1. FastScrollBar widget

- [x] 1.1 Create `lib/shared/widgets/fast_scroll_bar.dart` with a `FastScrollBar` `StatefulWidget` accepting `ScrollController controller`, `Widget child`, `int itemCount`, `List<(int, String)> groupAnchors`, and `bool active`
- [x] 1.2 Implement `LayoutBuilder` + `Stack` structure: `child` fills the stack, thumb and label are `Positioned` overlays on the right edge
- [x] 1.3 Implement thumb position tracking: add a `ScrollController` listener that computes `_thumbFraction = pixels / maxScrollExtent` and calls `setState`; guard with `hasClients` and `maxScrollExtent > 0`
- [x] 1.4 Implement drag gesture on the thumb: `GestureDetector` with `onVerticalDragUpdate` that recomputes `_thumbFraction` from drag delta and calls `controller.jumpTo(fraction * maxScrollExtent)`; guard with `hasClients`
- [x] 1.5 Implement `_labelForFraction()`: binary-search `groupAnchors` to find the label of the last anchor whose `itemIndex ≤ (fraction × itemCount).round()`
- [x] 1.6 Implement label bubble: a `Positioned` widget to the left of the thumb, visible only while `_isDragging` is true, displaying the result of `_labelForFraction(_thumbFraction)`
- [x] 1.7 Implement fade animation: `AnimationController` (200 ms), `FadeTransition` wrapping the thumb; scroll listener triggers fade-in; a `Timer` (~1.5 s) triggers fade-out after inactivity; drag start cancels the timer, drag end restarts it
- [x] 1.8 Suppress overlay when `active` is false or `maxScrollExtent == 0`: render only `child` in those cases
- [x] 1.9 Dispose `AnimationController`, `ScrollController` listener, and `Timer` in `dispose()`

## 2. FastScrollBar tests

- [x] 2.1 Write widget tests for thumb-absent-when-content-fits scenario (mock `ScrollController` with `maxScrollExtent == 0`)
- [x] 2.2 Write widget tests for thumb-visible-and-positioned scenario: pump list taller than viewport, verify thumb appears at correct vertical fraction after scrolling
- [x] 2.3 Write widget tests for drag-scrolls-list scenario: simulate `onVerticalDragUpdate`, verify `ScrollController.jumpTo` is called with correct offset
- [x] 2.4 Write widget tests for label bubble: verify bubble text matches expected group label during drag; verify bubble absent when not dragging
- [x] 2.5 Write unit tests for `_labelForFraction()` covering: first group, last group, mid-list boundary, single group, empty anchors edge case
- [x] 2.6 Write widget test for `active: false`: verify no thumb or bubble rendered regardless of scroll position

## 3. Browse list integration

- [x] 3.1 Convert `_BrowseListView` from `StatelessWidget` to `StatefulWidget`; add `ScrollController _scrollController` field with `initState`/`dispose` lifecycle
- [x] 3.2 Thread `_scrollController` into `ListView.builder`
- [x] 3.3 Compute `groupAnchors` alongside the existing `items` list build loop: for each `_GroupHeaderItem` at flat-list index `i`, append `(i, item.label)` to a local list
- [x] 3.4 Wrap the `ListView.builder` with `FastScrollBar`, passing `controller`, `itemCount: items.length`, `groupAnchors`, and `active: !searchActive`
- [x] 3.5 Pass `searchActive` down from `BrowserScreen` to `_BrowseListView` (already available as `state.searchQuery.isNotEmpty`)

## 4. Browse integration tests

- [x] 4.1 Write widget tests verifying `FastScrollBar` is present in `_BrowseListView` when search is inactive
- [x] 4.2 Write widget tests verifying `FastScrollBar` is inactive (no thumb rendered) when a non-empty search query is active
- [x] 4.3 Verify all existing browser widget tests pass unchanged

## 5. Final checks

- [x] 5.1 Run `flutter test --reporter failures-only` and confirm all tests pass
- [x] 5.2 Run `flutter analyze` and confirm no lint errors
- [ ] 5.3 Update `CHANGELOG.md` under `[Unreleased]` with a `### Added` entry for the fast-scroll bar feature (only if explicitly asked)
