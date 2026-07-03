import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/shared/readable_width.dart';

/// Unit tests for the [ReadableWidth] wrapper's cap-and-center behavior.
void main() {
  const probeKey = Key('probe');

  // A child that wants to fill the available width, so its measured width
  // reflects whatever the wrapper allows.
  Widget harness() => const Directionality(
    textDirection: TextDirection.ltr,
    child: ReadableWidth(
      child: SizedBox(key: probeKey, width: double.infinity, height: 100),
    ),
  );

  void setSize(WidgetTester tester, Size size) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
  }

  testWidgets('caps and centers content wider than the max', (tester) async {
    setSize(tester, const Size(1000, 600));
    await tester.pumpWidget(harness());

    // Capped at the shared maximum, not the full 1000 dp.
    expect(tester.getSize(find.byKey(probeKey)).width, kReadableMaxWidth);
    // Centered: equal margins on both sides.
    expect(
      tester.getTopLeft(find.byKey(probeKey)).dx,
      (1000 - kReadableMaxWidth) / 2,
    );
  });

  testWidgets('fills the width when narrower than the max', (tester) async {
    setSize(tester, const Size(360, 600));
    await tester.pumpWidget(harness());

    // The cap is inert below the threshold: content fills the width...
    expect(tester.getSize(find.byKey(probeKey)).width, 360);
    // ...and is not offset.
    expect(tester.getTopLeft(find.byKey(probeKey)).dx, 0);
  });
}
