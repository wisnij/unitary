## 1. Layout widget

- [x] 1.1 Write widget tests for the free-space layout: the area gets the height left below shrink-wrapped content; with the floor enabled and less than 48 dp left, the area is 48 dp and the content is limited to the rest; with the floor disabled, the content can use the full height
- [x] 1.2 Implement the layout widget with a `MultiChildLayoutDelegate` (content laid out first with a loose height limit, area given the remaining height and placed below it) so the tests pass

## 2. Completion area widget

- [x] 2.1 Write widget tests for `CompletionArea`: chips appear in rank order for the focused field; no chips when unfocused, with no token, or with no matches; only the focused field's suggestions show; kind-annotated chip text (`kg`, `kilo-`, `tempC(`); `"<name>, <kind>"` semantic labels; tappable region at least 48 × 48 dp; a long name is ellipsized within the area width
- [x] 2.2 Write widget tests for selection: tapping a chip inserts the kind-specific text into the focused field only, places the cursor after it, restores focus, calls that field's `onChanged`, and a unit insertion leaves no chips
- [x] 2.3 Write widget tests for scrolling: with more chips than fit, the last one can be scrolled into view; the scroll position returns to the top when the suggestions change
- [x] 2.4 Implement `CompletionAreaLayout` (listens to both controllers and focus nodes, watches `completionsProvider`, inserts the tapped suggestion) and `CompletionArea` (`Wrap` of `OutlinedButton` pill chips in a vertical `SingleChildScrollView`, `outline` border with `onSurface` text, inside a `TextFieldTapRegion`), with selection at pointer-down on web and on a completed press elsewhere
- [x] 2.5 Move `applyCompletion`, `completionSemanticLabel`, and the display-name and insert-text helpers to the area's file, and update their existing tests' imports

## 3. Remove the overlay

- [x] 3.1 Update `completion_field_test.dart`: delete the overlay tests, keep the tests for the inner `TextField` configuration (soft wrap, keyboard type, autocorrect and suggestions off)
- [x] 3.2 Strip the `OverlayPortal`, `CompositedTransformFollower`, layer link, above/below logic, and suggestion watch from `CompletionField`, leaving the configured `TextField` wrapper
- [x] 3.3 Delete the field-wrapping test that pins the overlay to a multi-line field's bottom edge

## 4. Freeform screen integration

- [x] 4.1 Write screen tests: with suggestions showing, both fields and the result display are fully visible and no chip overlaps them; the area sits between the result and the key panel; on a wide pane the area's edges align with the fields'; on a short test view the area is one line high and the content scrolls
- [x] 4.2 Restructure the freeform body: `ReadableWidth` around the layout widget, the scrolling content passed as a prebuilt child, and `CompletionArea` wired to both fields' controllers, focus nodes, and change callbacks
- [x] 4.3 Update existing `freeform_screen_test.dart` and `freeform_two_pane_test.dart` cases that find or tap overlay rows
- [x] 4.4 Run the rebuild-scope tests; confirm a keystroke still rebuilds the freeform screen subtree root zero times, and adjust the host widget (not the bound) if it does not

## 5. Swap button in the app bar

- [x] 5.1 Update the swap-button tests: the button is found in the app bar before the history and conformable-units buttons, at compact and two-pane widths; it has the tooltip "Swap from and to"; the "Convert to" field starts 16 dp below the "Convert from" field; the existing enabled-state and swap-behaviour tests still pass
- [x] 5.2 Move the swap `ListenableBuilder` + `IconButton` into the app bar actions with the tooltip, and replace the row between the fields with a 16 dp gap
- [x] 5.3 Confirm the rebuild-scope test still shows the swap button reacting to a keystroke without a screen-subtree rebuild

## 6. Related tests and tools

- [x] 6.1 Remove the completion-overlay exemption from the header comment of `test/shared/color_contrast_test.dart`
- [x] 6.2 Remove the unfocus-before-capture workaround for the overlay from `integration_test/screenshots/take_screenshots.dart` if it has no other purpose
- [x] 6.3 Check the `integration_test/` suite for finders that depend on the overlay and update them

## 7. Documentation

- [x] 7.1 Update `doc/implementation_plan.md` and `doc/design_progress.md` with a dated entry for this change, and correct any present-tense description of the completion overlay in `doc/architecture.md` or other docs
- [x] 7.2 Regenerate the screenshots that show the freeform screen (`tool/take_screenshots.sh`) and update the README if it describes the dropdown or the swap button's position

## 8. Verification

- [x] 8.1 Run `flutter test --reporter failures-only` and `flutter analyze`; both clean
- [x] 8.2 On a phone with the keyboard open, in portrait and landscape: confirm the result stays visible while typing in each field, measure how many chip lines fit, and check that chip tapping and area scrolling do not conflict
- [x] 8.3 On the web build: confirm a chip tap inserts the suggestion and returns focus with the cursor after the inserted text
- [x] 8.4 With TalkBack: confirm chips are announced as `"<name>, <kind>"` and can be activated
