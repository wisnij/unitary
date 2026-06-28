import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/models/unit_repository_provider.dart';
import 'package:unitary/features/currency/data/currency_rate_repository.dart';
import 'package:unitary/features/currency/state/currency_provider.dart';
import 'package:unitary/features/freeform/data/freeform_history_repository.dart';
import 'package:unitary/features/freeform/state/freeform_history_provider.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/worksheet_repository.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';
import 'package:unitary/shared/app_shell.dart';
import 'package:unitary/shared/widgets/app_drawer.dart';

void main() {
  late SettingsRepository repo;
  late WorksheetRepository worksheetRepo;
  late FreeformHistoryRepository historyRepo;
  late CurrencyRateRepository currencyRateRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = SettingsRepository(prefs);
    worksheetRepo = WorksheetRepository(prefs);
    historyRepo = FreeformHistoryRepository(prefs);
    currencyRateRepo = CurrencyRateRepository(prefs);
  });

  UnitRepository buildTestRepo() {
    final r = UnitRepository();
    r.register(const PrimitiveUnit(id: 'm'));
    r.register(const DerivedUnit(id: 'ft', expression: '0.3048 m'));
    return r;
  }

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
        freeformHistoryRepositoryProvider.overrideWithValue(historyRepo),
        currencyRateRepositoryProvider.overrideWithValue(currencyRateRepo),
        unitRepositoryProvider.overrideWithValue(buildTestRepo()),
      ],
      child: const MaterialApp(home: AppShell()),
    );
  }

  /// Sets the logical screen size for the duration of a test.
  void setSize(WidgetTester tester, Size size) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
  }

  group('AppShell — compact width (drawer)', () {
    testWidgets('shows hamburger and no rail', (tester) async {
      setSize(tester, const Size(400, 800));
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });
  });

  group('AppShell — medium width (drawer)', () {
    testWidgets('shows hamburger and no rail', (tester) async {
      setSize(tester, const Size(800, 800));
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });
  });

  group('AppShell — expanded width (rail)', () {
    testWidgets('shows a persistent rail and no hamburger/drawer', (
      tester,
    ) async {
      setSize(tester, const Size(1200, 800));
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.byType(AppDrawer), findsNothing);
    });

    testWidgets('rail highlights the active destination', (tester) async {
      setSize(tester, const Size(1200, 800));
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      // Freeform is the default active page (index 0).
      expect(rail.selectedIndex, 0);
    });

    testWidgets('selecting a rail destination switches the page', (
      tester,
    ) async {
      setSize(tester, const Size(1200, 800));
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.selectedIndex, 2);
      // The Browse AppBar title is now visible.
      expect(find.widgetWithText(AppBar, 'Browse'), findsOneWidget);
    });

    testWidgets('rail exposes Settings and About', (tester) async {
      setSize(tester, const Size(1200, 800));
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Settings'), findsOneWidget);
      expect(find.byTooltip('About'), findsOneWidget);
    });
  });

  group('AppShell — state preservation', () {
    testWidgets('page state preserved across rail navigation', (tester) async {
      setSize(tester, const Size(1200, 800));
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Type into the freeform "Convert from" field.
      await tester.enterText(find.byType(TextField).first, '5 ft');
      await tester.pumpAndSettle();

      // Navigate away via the rail and back.
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Freeform'));
      await tester.pumpAndSettle();

      expect(find.text('5 ft'), findsOneWidget);
    });

    testWidgets('page state preserved across the rail breakpoint', (
      tester,
    ) async {
      // Start medium (drawer), type, then widen to expanded (rail).
      setSize(tester, const Size(800, 800));
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '5 ft');
      await tester.pumpAndSettle();

      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('5 ft'), findsOneWidget);
    });
  });
}
