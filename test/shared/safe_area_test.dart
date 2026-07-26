import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/models/unit_repository_provider.dart';
import 'package:unitary/features/about/presentation/about_screen.dart';
import 'package:unitary/shared/app_shell.dart';

import '../helpers/pump_app.dart';
import '../helpers/repository_overrides.dart';

/// Tests that screen content is inset within the device's safe area (display
/// cutouts / system bars), driven by `MediaQuery.padding`.
void main() {
  late TestRepositories repos;

  setUp(() async {
    repos = await TestRepositories.create();
    PackageInfo.setMockInitialValues(
      appName: 'unitary',
      packageName: 'dev.wisnij.unitary',
      version: '1.2.3',
      buildNumber: '',
      buildSignature: '',
    );
  });

  UnitRepository buildTestRepo() {
    final r = UnitRepository();
    r.register(const PrimitiveUnit(id: 'm'));
    r.register(const DerivedUnit(id: 'ft', expression: '0.3048 m'));
    return r;
  }

  /// Sets the logical screen size for the duration of a test.
  void setSize(WidgetTester tester, Size size) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
  }

  /// Wraps [home] so its subtree sees the given safe-area [padding], copying
  /// the ambient `MediaQuery` so size and other fields are preserved.
  Widget withPadding(EdgeInsets padding, Widget home) {
    return Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: padding),
          child: home,
        );
      },
    );
  }

  Future<void> pumpAbout(WidgetTester tester, EdgeInsets padding) {
    return pumpApp(
      tester,
      withPadding(padding, const AboutScreen()),
      repos: repos,
    );
  }

  Future<void> pumpShell(WidgetTester tester, EdgeInsets padding) {
    return pumpApp(
      tester,
      withPadding(padding, const AppShell()),
      repos: repos,
      overrides: [unitRepositoryProvider.overrideWithValue(buildTestRepo())],
    );
  }

  group('Screen body safe area', () {
    testWidgets('body content is offset by a non-zero left inset', (
      tester,
    ) async {
      await pumpAbout(tester, const EdgeInsets.only(left: 50));
      await tester.pumpAndSettle();

      // The body ListView should start at (or past) the safe-area inset,
      // rather than at the physical left edge.
      final left = tester.getTopLeft(find.byType(ListView)).dx;
      expect(left, greaterThanOrEqualTo(50.0));
    });

    testWidgets('body content is not offset when there is no inset', (
      tester,
    ) async {
      await pumpAbout(tester, EdgeInsets.zero);
      await tester.pumpAndSettle();

      final left = tester.getTopLeft(find.byType(ListView)).dx;
      expect(left, 0.0);
    });
  });

  group('Navigation rail safe area', () {
    testWidgets('rail is offset by a non-zero left inset at expanded width', (
      tester,
    ) async {
      setSize(tester, const Size(1200, 800));
      await pumpShell(tester, const EdgeInsets.only(left: 50));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      final left = tester.getTopLeft(find.byType(NavigationRail)).dx;
      expect(left, greaterThanOrEqualTo(50.0));
    });

    testWidgets('rail sits at the edge when there is no inset', (tester) async {
      setSize(tester, const Size(1200, 800));
      await pumpShell(tester, EdgeInsets.zero);
      await tester.pumpAndSettle();

      final left = tester.getTopLeft(find.byType(NavigationRail)).dx;
      expect(left, 0.0);
    });
  });
}
