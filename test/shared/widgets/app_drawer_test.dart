import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/about/presentation/about_screen.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/presentation/settings_screen.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/shared/top_level_page.dart';
import 'package:unitary/shared/widgets/app_drawer.dart';

late SettingsRepository _settingsRepo;

Widget _buildDrawer({
  required TopLevelPage currentPage,
  void Function(TopLevelPage)? onNavigate,
}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(_settingsRepo),
    ],
    child: MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Test')),
        drawer: AppDrawer(
          currentPage: currentPage,
          onNavigate: onNavigate ?? (_) {},
        ),
        body: const SizedBox.shrink(),
      ),
    ),
  );
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    _settingsRepo = SettingsRepository(prefs);
  });

  group('AppDrawer — renders all tiles', () {
    testWidgets('drawer contains all navigation tiles', (tester) async {
      await tester.pumpWidget(
        _buildDrawer(currentPage: TopLevelPage.freeform),
      );
      await _openDrawer(tester);

      expect(find.text('Freeform'), findsOneWidget);
      expect(find.text('Worksheet'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('drawer shows expected icons', (tester) async {
      await tester.pumpWidget(
        _buildDrawer(currentPage: TopLevelPage.freeform),
      );
      await _openDrawer(tester);

      expect(find.byIcon(Icons.calculate), findsOneWidget);
      expect(find.byIcon(Icons.table_chart), findsOneWidget);
      expect(find.byIcon(Icons.library_books), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  group('AppDrawer — selected state', () {
    testWidgets('Freeform tile is selected when currentPage is freeform', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildDrawer(currentPage: TopLevelPage.freeform),
      );
      await _openDrawer(tester);

      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Freeform'),
      );
      expect(tile.selected, isTrue);
    });

    testWidgets('Worksheet tile is selected when currentPage is worksheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildDrawer(currentPage: TopLevelPage.worksheet),
      );
      await _openDrawer(tester);

      final worksheetTile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Worksheet'),
      );
      final freeformTile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Freeform'),
      );
      expect(worksheetTile.selected, isTrue);
      expect(freeformTile.selected, isFalse);
    });

    testWidgets('Browse tile is selected when currentPage is browser', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildDrawer(currentPage: TopLevelPage.browser),
      );
      await _openDrawer(tester);

      final browseTile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Browse'),
      );
      final freeformTile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Freeform'),
      );
      expect(browseTile.selected, isTrue);
      expect(freeformTile.selected, isFalse);
    });
  });

  group('AppDrawer — navigation callbacks', () {
    testWidgets('tapping Freeform calls onNavigate(freeform)', (tester) async {
      TopLevelPage? navigatedTo;
      await tester.pumpWidget(
        _buildDrawer(
          currentPage: TopLevelPage.worksheet,
          onNavigate: (p) => navigatedTo = p,
        ),
      );
      await _openDrawer(tester);

      await tester.tap(find.text('Freeform'));
      await tester.pumpAndSettle();

      expect(navigatedTo, TopLevelPage.freeform);
    });

    testWidgets('tapping Worksheet calls onNavigate(worksheet)', (
      tester,
    ) async {
      TopLevelPage? navigatedTo;
      await tester.pumpWidget(
        _buildDrawer(
          currentPage: TopLevelPage.freeform,
          onNavigate: (p) => navigatedTo = p,
        ),
      );
      await _openDrawer(tester);

      await tester.tap(find.text('Worksheet'));
      await tester.pumpAndSettle();

      expect(navigatedTo, TopLevelPage.worksheet);
    });

    testWidgets('tapping Browse calls onNavigate(browser)', (tester) async {
      TopLevelPage? navigatedTo;
      await tester.pumpWidget(
        _buildDrawer(
          currentPage: TopLevelPage.freeform,
          onNavigate: (p) => navigatedTo = p,
        ),
      );
      await _openDrawer(tester);

      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      expect(navigatedTo, TopLevelPage.browser);
    });

    testWidgets('tapping a page tile closes the drawer', (tester) async {
      await tester.pumpWidget(
        _buildDrawer(currentPage: TopLevelPage.freeform),
      );
      await _openDrawer(tester);

      expect(find.text('Freeform'), findsOneWidget);
      await tester.tap(find.text('Freeform'));
      await tester.pumpAndSettle();

      // Drawer should be closed.
      expect(find.text('Worksheet'), findsNothing);
    });
  });

  group('AppDrawer — Settings and About navigation', () {
    testWidgets('tapping Settings navigates to SettingsScreen', (tester) async {
      await tester.pumpWidget(
        _buildDrawer(currentPage: TopLevelPage.freeform),
      );
      await _openDrawer(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('tapping About navigates to AboutScreen', (tester) async {
      await tester.pumpWidget(
        _buildDrawer(currentPage: TopLevelPage.freeform),
      );
      await _openDrawer(tester);

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutScreen), findsOneWidget);
    });
  });
}
