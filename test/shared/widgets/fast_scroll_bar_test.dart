import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/shared/widgets/fast_scroll_bar.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps a [FastScrollBar] wrapping a [ListView] whose total content height
/// equals [contentHeight] inside a 600-pixel-tall viewport.
///
/// [groupAnchors] defaults to a single anchor `(0, 'A')`.
/// [active] defaults to true.
/// The returned [ScrollController] can be used to drive scroll position.
Future<ScrollController> _pumpScrollBar(
  WidgetTester tester, {
  double contentHeight = 2000.0,
  List<(int, String)> groupAnchors = const [(0, 'A')],
  int itemCount = 10,
  bool active = true,
}) async {
  final controller = ScrollController();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 600,
          child: FastScrollBar(
            controller: controller,
            itemCount: itemCount,
            groupAnchors: groupAnchors,
            active: active,
            child: ListView(
              controller: controller,
              children: [
                SizedBox(height: contentHeight),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  // Pump a second frame so the post-frame callback fires.
  await tester.pump();
  return controller;
}

// ---------------------------------------------------------------------------
// labelForFraction unit tests
// ---------------------------------------------------------------------------

void main() {
  group('FastScrollBar.labelForFraction', () {
    test('returns empty string when anchors are empty', () {
      expect(FastScrollBar.labelForFraction(0.5, [], 10), '');
    });

    test('returns empty string when itemCount is zero', () {
      expect(FastScrollBar.labelForFraction(0.5, [(0, 'A')], 0), '');
    });

    test('returns first group label at fraction 0.0', () {
      final anchors = [(0, 'A'), (5, 'B'), (10, 'C')];
      expect(FastScrollBar.labelForFraction(0.0, anchors, 15), 'A');
    });

    test('returns last group label at fraction 1.0', () {
      final anchors = [(0, 'A'), (5, 'B'), (10, 'C')];
      expect(FastScrollBar.labelForFraction(1.0, anchors, 15), 'C');
    });

    test('returns correct group at mid-list boundary', () {
      // 15 items; anchors at 0, 5, 10.
      // fraction 0.4 → target = round(0.4 * 15) = 6 → group B (starts at 5).
      final anchors = [(0, 'A'), (5, 'B'), (10, 'C')];
      expect(FastScrollBar.labelForFraction(0.4, anchors, 15), 'B');
    });

    test('returns the only label when there is a single group', () {
      final anchors = [(0, 'Length')];
      expect(FastScrollBar.labelForFraction(0.7, anchors, 20), 'Length');
    });

    test('clamps target to valid range for fractions slightly outside 0–1', () {
      final anchors = [(0, 'A'), (5, 'B')];
      // fraction 1.1 should still return the last group.
      expect(FastScrollBar.labelForFraction(1.1, anchors, 10), 'B');
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests — thumb absent when content fits
  // ---------------------------------------------------------------------------

  group('FastScrollBar — thumb absent when content fits on screen', () {
    testWidgets('no thumb key in tree when content height ≤ viewport', (
      tester,
    ) async {
      // contentHeight 400 < viewport 600 → no scrollable content.
      await _pumpScrollBar(tester, contentHeight: 400);
      expect(find.byKey(FastScrollBar.thumbKey), findsNothing);
    });

    testWidgets('no thumb when active is false', (tester) async {
      await _pumpScrollBar(tester, contentHeight: 2000, active: false);
      expect(find.byKey(FastScrollBar.thumbKey), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests — thumb visible when content is scrollable
  // ---------------------------------------------------------------------------

  group('FastScrollBar — thumb visible when content is scrollable', () {
    testWidgets('thumb appears after scrolling', (tester) async {
      final controller = await _pumpScrollBar(tester, contentHeight: 2000);
      // Scroll down to trigger the scroll listener.
      controller.jumpTo(500);
      await tester.pump();

      expect(find.byKey(FastScrollBar.thumbKey), findsOneWidget);
    });

    testWidgets('thumb Positioned.top reflects scroll fraction', (
      tester,
    ) async {
      const listHeight = 600.0;
      const contentHeight = 2000.0;
      const thumbHeight = 48.0;

      final controller = await _pumpScrollBar(
        tester,
        contentHeight: contentHeight,
      );

      // Scroll to the middle.
      const maxExtent = contentHeight - listHeight; // 1400
      controller.jumpTo(maxExtent / 2); // 700
      await tester.pump();

      final positioned = tester.widget<Positioned>(
        find.ancestor(
          of: find.byKey(FastScrollBar.thumbKey),
          matching: find.byType(Positioned),
        ),
      );
      const expectedFraction = 0.5;
      const expectedTop = expectedFraction * (listHeight - thumbHeight); // 276
      expect(positioned.top, closeTo(expectedTop, 2.0));
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests — drag scrolls the list
  // ---------------------------------------------------------------------------

  group('FastScrollBar — drag thumb scrolls the list', () {
    testWidgets('dragging thumb down increases scroll offset', (tester) async {
      final controller = await _pumpScrollBar(tester, contentHeight: 2000);
      // Trigger thumb appearance by scrolling slightly.
      controller.jumpTo(1);
      await tester.pump();

      final initialOffset = controller.offset;

      // Drag the thumb downward.
      await tester.drag(
        find.byKey(FastScrollBar.thumbKey),
        const Offset(0, 50),
      );
      await tester.pump();

      expect(controller.offset, greaterThan(initialOffset));
    });

    testWidgets('dragging thumb up decreases scroll offset', (tester) async {
      final controller = await _pumpScrollBar(tester, contentHeight: 2000);
      controller.jumpTo(700);
      await tester.pump();

      final initialOffset = controller.offset;

      await tester.drag(
        find.byKey(FastScrollBar.thumbKey),
        const Offset(0, -50),
      );
      await tester.pump();

      expect(controller.offset, lessThan(initialOffset));
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests — label bubble
  // ---------------------------------------------------------------------------

  group('FastScrollBar — label bubble', () {
    testWidgets('label bubble absent when not dragging', (tester) async {
      final controller = await _pumpScrollBar(
        tester,
        contentHeight: 2000,
        groupAnchors: [(0, 'A'), (5, 'M')],
        itemCount: 10,
      );
      controller.jumpTo(500);
      await tester.pump();

      expect(find.byKey(FastScrollBar.labelKey), findsNothing);
    });

    testWidgets('label bubble visible during drag with correct text', (
      tester,
    ) async {
      await _pumpScrollBar(
        tester,
        contentHeight: 2000,
        groupAnchors: [(0, 'A'), (5, 'M')],
        itemCount: 10,
      );
      // Scroll to make thumb appear.
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(FastScrollBar)),
      );

      // Trigger thumb via a scroll then drag it.
      // Start drag on the thumb widget (simulate jump first).
      final controller = tester
          .widget<FastScrollBar>(
            find.byType(FastScrollBar),
          )
          .controller;
      controller.jumpTo(1);
      await tester.pump();

      // Drag the thumb.
      await gesture.moveBy(const Offset(0, 1));
      await tester.pump();
      await gesture.up();

      // A fresh drag gesture on the thumb.
      await tester.press(find.byKey(FastScrollBar.thumbKey));
      await tester.pump();
      final dragGesture = await tester.startGesture(
        tester.getCenter(find.byKey(FastScrollBar.thumbKey)),
      );
      await dragGesture.moveBy(const Offset(0, 1));
      await tester.pump();

      expect(find.byKey(FastScrollBar.labelKey), findsOneWidget);

      await dragGesture.up();
      await tester.pump();
    });

    testWidgets('label shows first group at top of list', (tester) async {
      await _pumpScrollBar(
        tester,
        contentHeight: 2000,
        groupAnchors: [(0, 'Length'), (5, 'Mass')],
        itemCount: 10,
      );
      final controller = tester
          .widget<FastScrollBar>(
            find.byType(FastScrollBar),
          )
          .controller;
      controller.jumpTo(1);
      await tester.pump();

      // Start a drag on the thumb near the top (thumb fraction near 0).
      final thumbFinder = find.byKey(FastScrollBar.thumbKey);
      final dragGesture = await tester.startGesture(
        tester.getCenter(thumbFinder),
      );
      await dragGesture.moveBy(const Offset(0, 1));
      await tester.pump();

      expect(find.text('Length'), findsOneWidget);

      await dragGesture.up();
      await tester.pump();
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests — active flag
  // ---------------------------------------------------------------------------

  group('FastScrollBar — active: false suppresses overlay', () {
    testWidgets('no thumb rendered when active is false', (tester) async {
      await _pumpScrollBar(
        tester,
        contentHeight: 2000,
        active: false,
      );
      expect(find.byKey(FastScrollBar.thumbKey), findsNothing);
    });

    testWidgets('no label bubble rendered when active is false', (
      tester,
    ) async {
      await _pumpScrollBar(
        tester,
        contentHeight: 2000,
        active: false,
      );
      expect(find.byKey(FastScrollBar.labelKey), findsNothing);
    });

    testWidgets('child is still rendered when active is false', (
      tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FastScrollBar(
              controller: controller,
              itemCount: 1,
              groupAnchors: const [(0, 'A')],
              active: false,
              child: const Center(child: Text('hello')),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('hello'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests — fade animation and timer
  // ---------------------------------------------------------------------------

  /// Finds the [FadeTransition] overlay widget by its test key.
  /// Requires the overlay to be in the tree (i.e. scrollable content exists).
  FadeTransition findFadeTransition(WidgetTester tester) {
    return tester.widget<FadeTransition>(
      find.byKey(FastScrollBar.overlayKey),
    );
  }

  group('FastScrollBar — fade animation and timer', () {
    testWidgets('thumb fades in to opacity 1.0 after scrolling', (
      tester,
    ) async {
      final controller = await _pumpScrollBar(tester, contentHeight: 2000);

      controller.jumpTo(500);
      await tester.pump(); // _onScroll fires; _fadeController.forward() starts
      // Advance past the 200 ms fade-in duration.
      await tester.pump(const Duration(milliseconds: 300));

      expect(findFadeTransition(tester).opacity.value, closeTo(1.0, 0.01));
    });

    testWidgets('thumb fades out to opacity 0.0 after idle timeout', (
      tester,
    ) async {
      final controller = await _pumpScrollBar(tester, contentHeight: 2000);

      controller.jumpTo(500);
      await tester.pump(); // _onScroll fires; idle timer starts (1500 ms)
      await tester.pump(const Duration(milliseconds: 300)); // fade-in done

      // Fire the idle timer.  pump(duration) renders only ONE frame, so the
      // reverse animation is not complete yet after this call alone.
      await tester.pump(const Duration(milliseconds: 1500));
      // Let the reverse animation (200 ms) run all the way to 0.0.
      await tester.pumpAndSettle();

      expect(findFadeTransition(tester).opacity.value, closeTo(0.0, 0.01));
    });

    testWidgets('thumb stays at opacity 1.0 while dragging past idle timeout', (
      tester,
    ) async {
      final controller = await _pumpScrollBar(tester, contentHeight: 2000);

      controller.jumpTo(500);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // fade-in done

      // Start a drag: _onDragStart cancels the idle timer.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(FastScrollBar.thumbKey)),
      );
      await gesture.moveBy(const Offset(0, 30)); // exceed touch slop
      await tester.pump();

      // Advance well past the idle timeout — timer should NOT fire.
      await tester.pump(const Duration(milliseconds: 2000));

      expect(findFadeTransition(tester).opacity.value, closeTo(1.0, 0.01));

      await gesture.up();
      await tester.pump();
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests — label updates during drag
  // ---------------------------------------------------------------------------

  group('FastScrollBar — label updates during drag', () {
    testWidgets('label changes when thumb crosses group boundary', (
      tester,
    ) async {
      // 20 items: group 'A' starts at index 0, group 'M' starts at index 10.
      // 'M' boundary is at fraction 10/20 = 0.5.
      await _pumpScrollBar(
        tester,
        contentHeight: 2000,
        groupAnchors: [(0, 'A'), (10, 'M')],
        itemCount: 20,
      );
      final controller = tester
          .widget<FastScrollBar>(find.byType(FastScrollBar))
          .controller;
      // Start near top so the initial thumb fraction is near 0.
      controller.jumpTo(1);
      await tester.pump();

      final thumbFinder = find.byKey(FastScrollBar.thumbKey);
      final gesture = await tester.startGesture(
        tester.getCenter(thumbFinder),
      );
      // First move: stay clearly in the first half → label 'A'.
      // trackHeight ≈ 552; fraction ≈ (80 / 552) ≈ 0.14 (after touch slop).
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      expect(find.text('A'), findsOneWidget);

      // Second move: cross into the second half → label 'M'.
      // Additional delta of 350 gives cumulative fraction well past 0.5.
      await gesture.moveBy(const Offset(0, 350));
      await tester.pump();
      expect(find.text('M'), findsOneWidget);

      await gesture.up();
      await tester.pump();
    });
  });
}
