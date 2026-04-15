import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/models/unit_repository_provider.dart';
import 'package:unitary/features/about/presentation/about_screen.dart';
import 'package:unitary/features/browser/presentation/browser_screen.dart';
import 'package:unitary/features/freeform/presentation/freeform_screen.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/presentation/settings_screen.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';
import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';
import 'package:unitary/shared/home_screen.dart';

void main() {
  late SettingsRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = SettingsRepository(prefs);
  });

  UnitRepository buildTestBrowserRepo() {
    final r = UnitRepository();
    r.register(const PrimitiveUnit(id: 'm'));
    r.register(const DerivedUnit(id: 'ft', expression: '0.3048 m'));
    return r;
  }

  Widget buildApp({UnitRepository? browserRepo}) {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        if (browserRepo != null)
          unitRepositoryProvider.overrideWithValue(browserRepo),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  /// Navigate to worksheet mode: open drawer and tap 'Worksheet'.
  Future<void> navigateToWorksheet(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Worksheet'));
    await tester.pumpAndSettle();
  }

  /// Navigate to browser mode: open drawer and tap 'Browse'.
  Future<void> navigateToBrowser(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Browse'));
    await tester.pumpAndSettle();
  }

  /// Navigate to freeform mode: open drawer and tap 'Freeform'.
  Future<void> navigateToFreeform(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Freeform'));
    await tester.pumpAndSettle();
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

    testWidgets('Worksheet entry is enabled and shows worksheet content', (
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
      // WorksheetScreen with dropdown in AppBar.
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

  group('HomeScreen — worksheet navigation', () {
    testWidgets('worksheet AppBar shows hamburger icon, not back arrow', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await navigateToWorksheet(tester);

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('hamburger icon on worksheet screen opens the drawer', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await navigateToWorksheet(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Freeform'), findsOneWidget);
      expect(find.text('Worksheet'), findsOneWidget);
    });

    testWidgets(
      'Worksheet drawer tile is selected when on worksheet screen',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await navigateToWorksheet(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        final worksheetTile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, 'Worksheet'),
        );
        final freeformTile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, 'Freeform'),
        );
        expect(worksheetTile.selected, isTrue);
        expect(freeformTile.selected, isFalse);
      },
    );

    testWidgets(
      'Freeform drawer tile is selected when on freeform screen',
      (tester) async {
        await tester.pumpWidget(buildApp());

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        final freeformTile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, 'Freeform'),
        );
        final worksheetTile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, 'Worksheet'),
        );
        expect(freeformTile.selected, isTrue);
        expect(worksheetTile.selected, isFalse);
      },
    );

    testWidgets('dropdown lists all template names', (tester) async {
      await tester.pumpWidget(buildApp());
      await navigateToWorksheet(tester);

      // Open the dropdown.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      for (final template in predefinedWorksheets) {
        expect(
          find.text(template.name),
          findsWidgets, // may appear in button + list
          reason: '${template.name} not in dropdown',
        );
      }
    });

    testWidgets('selecting a template from dropdown switches worksheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await navigateToWorksheet(tester);

      // Open dropdown and select Speed.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Speed').last);
      await tester.pumpAndSettle();

      final speedTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'speed',
      );
      expect(find.text(speedTemplate.rows.first.label), findsOneWidget);
    });
  });

  group('HomeScreen — page state preservation', () {
    testWidgets(
      'freeform Convert-from text survives navigation to Worksheet and back',
      (tester) async {
        await tester.pumpWidget(buildApp());

        // Type into the Convert-from field while Freeform is the active page.
        final inputField = find
            .descendant(
              of: find.byType(FreeformScreen),
              matching: find.byType(TextField),
            )
            .first;
        await tester.enterText(inputField, '5 m');
        await tester.pump();

        await navigateToWorksheet(tester);
        await navigateToFreeform(tester);

        expect(
          tester.widget<TextField>(inputField).controller!.text,
          '5 m',
        );
      },
    );

    testWidgets(
      'freeform Convert-from text survives navigation to Browse and back',
      (tester) async {
        await tester.pumpWidget(buildApp(browserRepo: buildTestBrowserRepo()));

        final inputField = find
            .descendant(
              of: find.byType(FreeformScreen),
              matching: find.byType(TextField),
            )
            .first;
        await tester.enterText(inputField, '5 m');
        await tester.pump();

        await navigateToBrowser(tester);
        await navigateToFreeform(tester);

        expect(
          tester.widget<TextField>(inputField).controller!.text,
          '5 m',
        );
      },
    );

    testWidgets(
      'worksheet row value survives navigation to Freeform and back',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await navigateToWorksheet(tester);

        // Type into the first row's numeric field while Worksheet is active.
        final rowField = find
            .descendant(
              of: find.byType(WorksheetScreen),
              matching: find.byType(TextField),
            )
            .first;
        await tester.enterText(rowField, '42');
        await tester.pump();

        await navigateToFreeform(tester);
        await navigateToWorksheet(tester);

        expect(
          tester.widget<TextField>(rowField).controller!.text,
          '42',
        );
      },
    );

    testWidgets('active worksheet template survives navigation', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await navigateToWorksheet(tester);

      // Switch to the Speed template.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Speed').last);
      await tester.pumpAndSettle();

      await navigateToFreeform(tester);
      await navigateToWorksheet(tester);

      // Speed template should still be active.
      final speedTemplate = predefinedWorksheets.firstWhere(
        (t) => t.id == 'speed',
      );
      expect(find.text(speedTemplate.rows.first.label), findsOneWidget);
    });

    testWidgets('browse search query survives navigation', (tester) async {
      await tester.pumpWidget(buildApp(browserRepo: buildTestBrowserRepo()));
      await navigateToBrowser(tester);

      // Open search bar and type a query.
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      final searchField = find.descendant(
        of: find.byType(BrowserScreen),
        matching: find.byType(TextField),
      );
      await tester.enterText(searchField, 'xyz');
      await tester.pump();

      await navigateToFreeform(tester);
      await navigateToBrowser(tester);

      // Search bar should still be visible and retain the query text.
      expect(searchField, findsOneWidget);
      expect(
        tester.widget<TextField>(searchField).controller!.text,
        'xyz',
      );
    });

    testWidgets(
      'browse expand-all state survives navigation',
      (tester) async {
        await tester.pumpWidget(buildApp(browserRepo: buildTestBrowserRepo()));
        await navigateToBrowser(tester);

        // Default: dimension view with all groups collapsed.
        // Expand all so the provider state has collapsedGroups = {}.
        await tester.tap(find.byIcon(Icons.unfold_more));
        await tester.pump();

        await navigateToFreeform(tester);
        await navigateToBrowser(tester);

        // All groups should still be expanded — no chevron_right icons.
        expect(
          find.byWidgetPredicate(
            (w) => w is Icon && w.icon == Icons.chevron_right,
          ),
          findsNothing,
        );
      },
    );
  });

  group('HomeScreen — browse navigation', () {
    testWidgets('Expand All button is present on Browse page', (tester) async {
      await tester.pumpWidget(
        buildApp(browserRepo: buildTestBrowserRepo()),
      );
      await navigateToBrowser(tester);
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);
    });

    testWidgets('Collapse All button is present on Browse page', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(browserRepo: buildTestBrowserRepo()),
      );
      await navigateToBrowser(tester);
      expect(find.byIcon(Icons.unfold_less), findsOneWidget);
    });

    testWidgets(
      'Browse drawer tile is selected when on browse screen',
      (tester) async {
        await tester.pumpWidget(
          buildApp(browserRepo: buildTestBrowserRepo()),
        );
        await navigateToBrowser(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        final browseTile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, 'Browse'),
        );
        final freeformTile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, 'Freeform'),
        );
        expect(browseTile.selected, isTrue);
        expect(freeformTile.selected, isFalse);
      },
    );
  });
}
