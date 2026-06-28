import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/shared/window_size_class.dart';

void main() {
  group('WindowSizeClass.fromWidth', () {
    test('width below 600 is compact', () {
      expect(WindowSizeClass.fromWidth(0), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(500), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(599.9), WindowSizeClass.compact);
    });

    test('lower boundary 600 is medium', () {
      expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
    });

    test('mid width is medium', () {
      expect(WindowSizeClass.fromWidth(800), WindowSizeClass.medium);
    });

    test('upper boundary 1040 is medium', () {
      expect(WindowSizeClass.fromWidth(1040), WindowSizeClass.medium);
    });

    test('width above 1040 is expanded', () {
      expect(WindowSizeClass.fromWidth(1040.1), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1400), WindowSizeClass.expanded);
    });
  });

  group('WindowSizeClass convenience getters', () {
    test('isCompact', () {
      expect(WindowSizeClass.compact.isCompact, isTrue);
      expect(WindowSizeClass.medium.isCompact, isFalse);
      expect(WindowSizeClass.expanded.isCompact, isFalse);
    });

    test('showsTwoPanes is true at medium and expanded', () {
      expect(WindowSizeClass.compact.showsTwoPanes, isFalse);
      expect(WindowSizeClass.medium.showsTwoPanes, isTrue);
      expect(WindowSizeClass.expanded.showsTwoPanes, isTrue);
    });

    test('usesRail is true only at expanded', () {
      expect(WindowSizeClass.compact.usesRail, isFalse);
      expect(WindowSizeClass.medium.usesRail, isFalse);
      expect(WindowSizeClass.expanded.usesRail, isTrue);
    });
  });

  group('WindowSizeClass.of', () {
    Future<WindowSizeClass> classForSize(WidgetTester tester, Size size) async {
      late WindowSizeClass result;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: size),
          child: Builder(
            builder: (context) {
              result = WindowSizeClass.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return result;
    }

    testWidgets('derives the class from MediaQuery width', (tester) async {
      expect(
        await classForSize(tester, const Size(500, 800)),
        WindowSizeClass.compact,
      );
      expect(
        await classForSize(tester, const Size(800, 600)),
        WindowSizeClass.medium,
      );
      expect(
        await classForSize(tester, const Size(1400, 900)),
        WindowSizeClass.expanded,
      );
    });

    testWidgets('recomputes when width changes', (tester) async {
      WindowSizeClass? observed;
      Widget build(Size size) {
        return MediaQuery(
          data: MediaQueryData(size: size),
          child: Builder(
            builder: (context) {
              observed = WindowSizeClass.of(context);
              return const SizedBox.shrink();
            },
          ),
        );
      }

      await tester.pumpWidget(build(const Size(500, 800)));
      expect(observed, WindowSizeClass.compact);

      await tester.pumpWidget(build(const Size(1400, 900)));
      expect(observed, WindowSizeClass.expanded);
    });
  });
}
