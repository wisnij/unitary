import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/shared/two_pane_layout.dart';

void main() {
  const leftKey = Key('left-pane');
  const rightKey = Key('right-pane');

  Future<void> pump(
    WidgetTester tester, {
    required Size size,
    required Widget pane,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: pane)));
    await tester.pumpAndSettle();
  }

  Widget twoPane({
    PaneSize leftSize = const PaneSize.fill(),
    PaneSize rightSize = const PaneSize.fill(),
    PaneSide compactPrimary = PaneSide.left,
    Widget? left,
    Widget? right,
  }) {
    return TwoPaneLayout(
      leftSize: leftSize,
      rightSize: rightSize,
      compactPrimary: compactPrimary,
      left: left ?? const SizedBox.expand(key: leftKey),
      right: right ?? const SizedBox.expand(key: rightKey),
    );
  }

  group('Pane visibility by window size class', () {
    testWidgets('medium shows both panes and a divider', (tester) async {
      await pump(tester, size: const Size(800, 600), pane: twoPane());
      expect(find.byKey(leftKey), findsOneWidget);
      expect(find.byKey(rightKey), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('expanded shows both panes and a divider', (tester) async {
      await pump(tester, size: const Size(1200, 800), pane: twoPane());
      expect(find.byKey(leftKey), findsOneWidget);
      expect(find.byKey(rightKey), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('compact shows only the left primary pane', (tester) async {
      await pump(
        tester,
        size: const Size(400, 800),
        pane: twoPane(compactPrimary: PaneSide.left),
      );
      expect(find.byKey(leftKey), findsOneWidget);
      expect(find.byKey(rightKey), findsNothing);
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('compact shows only the right primary pane', (tester) async {
      await pump(
        tester,
        size: const Size(400, 800),
        pane: twoPane(compactPrimary: PaneSide.right),
      );
      expect(find.byKey(rightKey), findsOneWidget);
      expect(find.byKey(leftKey), findsNothing);
    });
  });

  group('Per-pane sizing', () {
    testWidgets('fixed pane uses its exact width', (tester) async {
      await pump(
        tester,
        size: const Size(1000, 600),
        pane: twoPane(
          leftSize: const PaneSize.fixed(300),
          rightSize: const PaneSize.fill(),
        ),
      );
      expect(tester.getSize(find.byKey(leftKey)).width, 300);
    });

    testWidgets('fit-content pane sizes to its content', (tester) async {
      await pump(
        tester,
        size: const Size(1000, 600),
        pane: twoPane(
          leftSize: const PaneSize.fitContent(),
          left: const SizedBox(key: leftKey, width: 180, height: 100),
          rightSize: const PaneSize.fill(),
        ),
      );
      expect(tester.getSize(find.byKey(leftKey)).width, 180);
    });

    testWidgets('fit-content respects its maximum', (tester) async {
      await pump(
        tester,
        size: const Size(1000, 600),
        pane: twoPane(
          leftSize: const PaneSize.fitContent(max: 360),
          left: const SizedBox(key: leftKey, width: 500, height: 100),
          rightSize: const PaneSize.fill(),
        ),
      );
      expect(tester.getSize(find.byKey(leftKey)).width, 360);
    });

    testWidgets('fit-content respects its minimum', (tester) async {
      await pump(
        tester,
        size: const Size(1000, 600),
        pane: twoPane(
          leftSize: const PaneSize.fitContent(min: 130),
          left: const SizedBox(key: leftKey, width: 50, height: 100),
          rightSize: const PaneSize.fill(),
        ),
      );
      expect(tester.getSize(find.byKey(leftKey)).width, 130);
    });

    testWidgets('two fill panes split by ratio', (tester) async {
      // 901 wide minus the 1px divider leaves 900 split 1:2 → 300 / 600.
      await pump(
        tester,
        size: const Size(901, 600),
        pane: twoPane(
          leftSize: const PaneSize.fill(flex: 1),
          rightSize: const PaneSize.fill(flex: 2),
        ),
      );
      expect(tester.getSize(find.byKey(leftKey)).width, 300);
      expect(tester.getSize(find.byKey(rightKey)).width, 600);
    });
  });

  group('Independent scrolling', () {
    testWidgets('scrolling one pane does not move the other', (tester) async {
      final leftItems = List.generate(50, (i) => 'L$i');
      final rightItems = List.generate(50, (i) => 'R$i');
      await pump(
        tester,
        size: const Size(1000, 600),
        pane: twoPane(
          leftSize: const PaneSize.fixed(300),
          left: ListView(
            key: leftKey,
            children: [
              for (final t in leftItems) SizedBox(height: 40, child: Text(t)),
            ],
          ),
          rightSize: const PaneSize.fill(),
          right: ListView(
            key: rightKey,
            children: [
              for (final t in rightItems) SizedBox(height: 40, child: Text(t)),
            ],
          ),
        ),
      );

      // Scroll the left list; the right list should stay at the top.
      await tester.drag(find.byKey(leftKey), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('R0'), findsOneWidget);
    });
  });
}
