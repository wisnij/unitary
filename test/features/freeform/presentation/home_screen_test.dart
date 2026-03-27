import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/features/about/presentation/about_screen.dart';
import 'package:unitary/features/freeform/presentation/home_screen.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/presentation/settings_screen.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

void main() {
  late SettingsRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = SettingsRepository(prefs);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  group('HomeScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Unitary'), findsOneWidget);
    });

    testWidgets('drawer opens with hamburger icon', (tester) async {
      await tester.pumpWidget(buildApp());

      // Tap the hamburger icon to open the drawer.
      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Drawer should be open with entries.
      expect(find.text('Freeform'), findsOneWidget);
      expect(find.text('Worksheet'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets(
      'drawer contains Freeform, Worksheet, Settings, About entries',
      (
        tester,
      ) async {
        await tester.pumpWidget(buildApp());
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.calculate), findsOneWidget);
        expect(find.byIcon(Icons.table_chart), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      },
    );

    testWidgets('Worksheet entry is enabled and navigates to WorksheetScreen', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final worksheetTile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Worksheet'),
      );
      expect(worksheetTile.enabled, isTrue);

      await tester.tap(find.text('Worksheet'));
      await tester.pumpAndSettle();
      // WorksheetScreen uses a DropdownButton for navigation.
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('Settings tap navigates to SettingsScreen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Should now be on the SettingsScreen.
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('About tap navigates to AboutScreen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutScreen), findsOneWidget);
    });

    testWidgets('Freeform tap closes drawer', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Freeform'));
      await tester.pumpAndSettle();

      // Drawer should be closed, still on home screen.
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('body contains FreeformScreen', (tester) async {
      await tester.pumpWidget(buildApp());
      // FreeformScreen renders input/output fields.
      expect(find.text('Convert from'), findsOneWidget);
    });
  });
}
