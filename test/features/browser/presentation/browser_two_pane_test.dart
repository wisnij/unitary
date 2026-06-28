import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/models/unit_repository_provider.dart';
import 'package:unitary/features/browser/presentation/browser_screen.dart';
import 'package:unitary/features/browser/presentation/unit_entry_detail_screen.dart';
import 'package:unitary/features/browser/state/browser_provider.dart';
import 'package:unitary/features/currency/data/currency_rate_repository.dart';
import 'package:unitary/features/currency/state/currency_provider.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

/// Browser notifier override: alphabetical view, all groups expanded, so
/// entries are immediately visible in widget tests.
class _TestBrowserNotifier extends BrowserNotifier {
  @override
  BrowserState build() {
    final initial = super.build();
    return initial.copyWith(
      viewMode: BrowseViewMode.alphabetical,
      collapsedGroups: const {},
    );
  }
}

void main() {
  late SettingsRepository settingsRepo;
  late CurrencyRateRepository currencyRateRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    settingsRepo = SettingsRepository(prefs);
    currencyRateRepo = CurrencyRateRepository(prefs);
  });

  UnitRepository buildRepo() {
    final r = UnitRepository();
    r.register(const PrimitiveUnit(id: 'm', aliases: ['meter', 'meters']));
    r.register(
      const DerivedUnit(id: 'ft', expression: '0.3048 m', aliases: ['feet']),
    );
    return r;
  }

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        unitRepositoryProvider.overrideWithValue(buildRepo()),
        browserProvider.overrideWith(_TestBrowserNotifier.new),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        currencyRateRepositoryProvider.overrideWithValue(currencyRateRepo),
      ],
      child: MaterialApp(home: BrowserScreen(onNavigate: (_) {})),
    );
  }

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
  }

  const compact = Size(400, 800);
  const expanded = Size(1300, 900);

  group('Wide-width embedded detail', () {
    testWidgets('empty placeholder before any selection', (tester) async {
      await pump(tester, expanded);
      expect(find.text('Select a unit'), findsOneWidget);
      expect(find.byType(UnitEntryDetailBody), findsNothing);
    });

    testWidgets('tapping a row shows detail in the embedded pane, no route', (
      tester,
    ) async {
      await pump(tester, expanded);

      await tester.tap(find.widgetWithText(ListTile, 'ft'));
      await tester.pumpAndSettle();

      expect(find.text('Select a unit'), findsNothing);
      expect(find.byType(UnitEntryDetailScreen), findsNothing); // not pushed
      final body = tester.widget<UnitEntryDetailBody>(
        find.byType(UnitEntryDetailBody),
      );
      expect(body.primaryId, 'ft');
    });

    testWidgets('alias row selects its primary', (tester) async {
      await pump(tester, expanded);

      await tester.tap(find.widgetWithText(ListTile, 'feet = ft'));
      await tester.pumpAndSettle();

      final body = tester.widget<UnitEntryDetailBody>(
        find.byType(UnitEntryDetailBody),
      );
      expect(body.primaryId, 'ft');
    });

    testWidgets('selecting another entry updates the pane in place', (
      tester,
    ) async {
      await pump(tester, expanded);

      await tester.tap(find.widgetWithText(ListTile, 'm'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<UnitEntryDetailBody>(
              find.byType(UnitEntryDetailBody),
            )
            .primaryId,
        'm',
      );

      await tester.tap(find.widgetWithText(ListTile, 'ft'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<UnitEntryDetailBody>(
              find.byType(UnitEntryDetailBody),
            )
            .primaryId,
        'ft',
      );
      expect(find.byType(UnitEntryDetailScreen), findsNothing);
    });
  });

  group('Compact-width pushed detail', () {
    testWidgets('tapping a row pushes the detail screen', (tester) async {
      await pump(tester, compact);

      // No embedded pane at compact width.
      expect(find.text('Select a unit'), findsNothing);

      await tester.tap(find.widgetWithText(ListTile, 'ft'));
      await tester.pumpAndSettle();

      expect(find.byType(UnitEntryDetailScreen), findsOneWidget);
    });
  });
}
