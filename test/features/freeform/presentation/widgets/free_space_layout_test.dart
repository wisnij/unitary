import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:unitary/features/freeform/presentation/widgets/free_space_layout.dart';

const _contentKey = Key('content');
const _areaKey = Key('area');

/// Pumps a 300×[height] [FreeSpaceLayout] whose content is a scroll view
/// wrapping a box [contentHeight] tall.
Future<void> _pump(
  WidgetTester tester, {
  required double height,
  required double contentHeight,
  double minAreaHeight = 0,
}) {
  return tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 300,
          height: height,
          child: FreeSpaceLayout(
            minAreaHeight: minAreaHeight,
            content: SingleChildScrollView(
              key: _contentKey,
              child: SizedBox(height: contentHeight),
            ),
            area: const SizedBox.expand(key: _areaKey),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('FreeSpaceLayout', () {
    testWidgets('area gets the height left below shrink-wrapped content', (
      tester,
    ) async {
      await _pump(tester, height: 500, contentHeight: 340, minAreaHeight: 48);

      expect(
        tester.getRect(find.byKey(_contentKey)),
        const Rect.fromLTWH(0, 0, 300, 340),
      );
      expect(
        tester.getRect(find.byKey(_areaKey)),
        const Rect.fromLTWH(0, 340, 300, 160),
      );
    });

    testWidgets('floor takes height from content when less is left', (
      tester,
    ) async {
      await _pump(tester, height: 500, contentHeight: 480, minAreaHeight: 48);

      expect(tester.getSize(find.byKey(_contentKey)).height, 452);
      expect(
        tester.getRect(find.byKey(_areaKey)),
        const Rect.fromLTWH(0, 452, 300, 48),
      );
    });

    testWidgets('floor also applies when content overflows the height', (
      tester,
    ) async {
      await _pump(tester, height: 500, contentHeight: 900, minAreaHeight: 48);

      expect(tester.getSize(find.byKey(_contentKey)).height, 452);
      expect(tester.getSize(find.byKey(_areaKey)).height, 48);
    });

    testWidgets('without a floor the content can use the full height', (
      tester,
    ) async {
      await _pump(tester, height: 500, contentHeight: 480);
      expect(tester.getSize(find.byKey(_contentKey)).height, 480);
      expect(tester.getSize(find.byKey(_areaKey)).height, 20);

      await _pump(tester, height: 500, contentHeight: 900);
      expect(tester.getSize(find.byKey(_contentKey)).height, 500);
      expect(tester.getSize(find.byKey(_areaKey)).height, 0);
    });

    testWidgets('a floor larger than the height is limited to the height', (
      tester,
    ) async {
      await _pump(tester, height: 30, contentHeight: 900, minAreaHeight: 48);

      expect(tester.getSize(find.byKey(_contentKey)).height, 0);
      expect(tester.getSize(find.byKey(_areaKey)).height, 30);
    });

    testWidgets('changing the floor relays out', (tester) async {
      await _pump(tester, height: 500, contentHeight: 900);
      expect(tester.getSize(find.byKey(_areaKey)).height, 0);

      await _pump(tester, height: 500, contentHeight: 900, minAreaHeight: 48);
      expect(tester.getSize(find.byKey(_areaKey)).height, 48);
    });
  });
}
