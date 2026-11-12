## 1. Layout widget

- [ ] 1.1 Write widget tests for the free-space layout: the area gets the height left below shrink-wrapped content; with the floor enabled and less than 48 dp left, the area is 48 dp and the content is limited to the rest; with the floor disabled, the content can use the full height
- [ ] 1.2 Implement the layout widget with a `MultiChildLayoutDelegate` (content laid out first with a loose height limit, area given the remaining height and placed below it) so the tests pass

## 2. Completion area widget

- [ ] 2.1 Write widget tests for `CompletionArea`: chips appear in rank order for the focused field; no chips when unfocused, with no token, or with no matches; only the focused field's suggestions show; kind-annotated chip text (`kg`, `kilo-`, `tempC(`); `"<name>, <kind>"` semantic labels; tappable region at least 48 × 48 dp; a long name is ellipsized within the area width
- [ ] 2.2 Write widget tests for selection: tapping a chip inserts the kind-specific text into the focused field only, places the cursor after it, restores focus, calls that field's `onChanged`, and a unit insertion leaves no chips
- [ ] 2.3 Write widget tests for scrolling: with more chips than fit, the last one can be scrolled into view; the scroll position returns to the top when the suggestions change
- [ ] 2.4 Implement `CompletionArea` (listens to both controllers and focus nodes, watches `completionsProvider`, `Wrap` of custom `Material` + `InkWell` chips in a vertical `SingleChildScrollView`, `outline` border with `onSurface` text) with the web `onTapDown` / mobile `onTap` handling moved from the overlay
- [ ] 2.5 Move `applyCompletion`, `completionSemanticLabel`, and the display-name and insert-text helpers to the area's file, and update their existing tests' imports

## 3. Remove the overlay

- [ ] 3.1 Update `completion_field_test.dart`: delete the overlay tests, keep the tests for the inner `TextField` configuration (soft wrap, keyboard type, autocorrect and suggestions off)
- [ ] 3.2 Strip the `OverlayPortal`, `CompositedTransformFollower`, layer link, above/below logic, and suggestion watch from `CompletionField`, leaving the configured `TextField` wrapper
- [ ] 3.3 Delete the field-wrapping test that pins the overlay to a multi-line field's bottom edge

## 4. Freeform screen integration

- [ ] 4.1 Write screen tests: with suggestions showing, both fields and the result display are fully visible and no chip overlaps them; the area sits between the result and the key panel; on a wide pane the area's edges align with the fields'; on a short test view the area is one line high and the content scrolls
- [ ] 4.2 Restructure the freeform body: `ReadableWidth` around the layout widget, the scrolling content passed as a prebuilt child, and `CompletionArea` wired to both fields' controllers, focus nodes, and change callbacks
- [ ] 4.3 Update existing `freeform_screen_test.dart` and `freeform_two_pane_test.dart` cases that find or tap overlay rows
- [ ] 4.4 Run the rebuild-scope tests; confirm a keystroke still rebuilds the freeform screen subtree root zero times, and adjust the host widget (not the bound) if it does not

## 5. Related tests and tools

- [ ] 5.1 Remove the completion-overlay exemption from the header comment of `test/shared/color_contrast_test.dart`
- [ ] 5.2 Remove the unfocus-before-capture workaround for the overlay from `integration_test/screenshots/take_screenshots.dart` if it has no other purpose
- [ ] 5.3 Check the `integration_test/` suite for finders that depend on the overlay and update them

## 6. Documentation

- [ ] 6.1 Update `doc/implementation_plan.md` and `doc/design_progress.md` with a dated entry for this change, and correct any present-tense description of the completion overlay in `doc/architecture.md` or other docs
- [ ] 6.2 Update the README only if it describes the dropdown's appearance

## 7. Verification

- [ ] 7.1 Run `flutter test --reporter failures-only` and `flutter analyze`; both clean
- [ ] 7.2 On a phone with the keyboard open, in portrait and landscape: confirm the result stays visible while typing in each field, measure how many chip lines fit, and check that chip tapping and area scrolling do not conflict
- [ ] 7.3 On the web build: confirm a chip tap inserts the suggestion and returns focus with the cursor after the inserted text
- [ ] 7.4 With TalkBack: confirm chips are announced as `"<name>, <kind>"` and can be activated
