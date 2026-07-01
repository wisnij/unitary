import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/models/unit_repository_provider.dart';
import 'package:unitary/features/about/presentation/about_screen.dart';
import 'package:unitary/features/currency/data/currency_rate_repository.dart';
import 'package:unitary/features/currency/state/currency_provider.dart';
import 'package:unitary/features/freeform/data/freeform_history_repository.dart';
import 'package:unitary/features/freeform/state/freeform_history_provider.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/worksheet_repository.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';
import 'package:unitary/shared/app_shell.dart';

/// Tests that screen content is inset within the device's safe area (display
/// cutouts / system bars), driven by `MediaQuery.padding`.
void main() {
  late SettingsRepository settingsRepo;
  late WorksheetRepository worksheetRepo;
  late FreeformHistoryRepository historyRepo;
  late CurrencyRateRepository currencyRateRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
    worksheetRepo = WorksheetRepository(prefs);
    historyRepo = FreeformHistoryRepository(prefs);
    currencyRateRepo = CurrencyRateRepository(prefs);
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

  Widget aboutApp(EdgeInsets padding) {
    return ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(settingsRepo)],
      child: MaterialApp(home: withPadding(padding, const AboutScreen())),
    );
  }

  Widget shellApp(EdgeInsets padding) {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
        freeformHistoryRepositoryProvider.overrideWithValue(historyRepo),
        currencyRateRepositoryProvider.overrideWithValue(currencyRateRepo),
        unitRepositoryProvider.overrideWithValue(buildTestRepo()),
      ],
      child: MaterialApp(home: withPadding(padding, const AppShell())),
    );
  }

  group('Screen body safe area', () {
    testWidgets('body content is offset by a non-zero left inset', (
      tester,
    ) async {
      await tester.pumpWidget(aboutApp(const EdgeInsets.only(left: 50)));
      await tester.pumpAndSettle();

      // The body ListView should start at (or past) the safe-area inset,
      // rather than at the physical left edge.
      final left = tester.getTopLeft(find.byType(ListView)).dx;
      expect(left, greaterThanOrEqualTo(50.0));
    });

    testWidgets('body content is not offset when there is no inset', (
      tester,
    ) async {
      await tester.pumpWidget(aboutApp(EdgeInsets.zero));
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
      await tester.pumpWidget(shellApp(const EdgeInsets.only(left: 50)));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      final left = tester.getTopLeft(find.byType(NavigationRail)).dx;
      expect(left, greaterThanOrEqualTo(50.0));
    });

    testWidgets('rail sits at the edge when there is no inset', (tester) async {
      setSize(tester, const Size(1200, 800));
      await tester.pumpWidget(shellApp(EdgeInsets.zero));
      await tester.pumpAndSettle();

      final left = tester.getTopLeft(find.byType(NavigationRail)).dx;
      expect(left, 0.0);
    });
  });
}
