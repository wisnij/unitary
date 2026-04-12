import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/browse_entry.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/features/about/presentation/about_screen.dart';
import 'package:unitary/features/browser/state/browser_provider.dart';
import 'package:unitary/features/freeform/presentation/home_screen.dart';
import 'package:unitary/features/freeform/state/freeform_provider.dart';
import 'package:unitary/features/freeform/state/freeform_state.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/presentation/settings_screen.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/predefined_worksheets.dart';

// ---------------------------------------------------------------------------
// Lightweight test browser notifier (avoids loading all predefined units).
// ---------------------------------------------------------------------------

class _TestBrowserNotifier extends BrowserNotifier {
  _TestBrowserNotifier(this._testRepo);
  final UnitRepository _testRepo;

  @override
  (UnitRepository, List<BrowseEntry>) createData() =>
      (_testRepo, _testRepo.buildBrowseCatalog());
}

UnitRepository _buildTestBrowserRepo() {
  final repo = UnitRepository();
  repo.register(const PrimitiveUnit(id: 'm'));
  repo.register(const DerivedUnit(id: 'ft', expression: '0.3048 m'));
  return repo;
}

void main() {
  late SettingsRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = SettingsRepository(prefs);
  });

  Widget buildApp({UnitRepository? browserRepo}) {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        if (browserRepo != null)
          browserProvider.overrideWith(() => _TestBrowserNotifier(browserRepo)),
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

  group('HomeScreen — conformable-units button', () {
    final browseButtonFinder = find.byIcon(Icons.balance);

    testWidgets('button is present on freeform page', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(browseButtonFinder, findsOneWidget);
    });

    testWidgets('button is absent on worksheet page', (tester) async {
      await tester.pumpWidget(buildApp());
      await navigateToWorksheet(tester);
      expect(browseButtonFinder, findsNothing);
    });

    testWidgets('button is disabled when freeformProvider is idle', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      final btn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.balance),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets(
      'button is enabled when freeformProvider is EvaluationSuccess',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              freeformProvider.overrideWith(
                () => _StubFreeformNotifier(
                  EvaluationSuccess(
                    result: _stubQty,
                    formattedResult: '= 5',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'button is enabled when freeformProvider is ConversionSuccess',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              freeformProvider.overrideWith(
                () => _StubFreeformNotifier(
                  const ConversionSuccess(
                    convertedValue: 2.0,
                    formattedResult: '= 2 ft',
                    formattedReciprocal: '= (1 / 0.5) ft',
                    outputUnit: 'ft',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'button is enabled when freeformProvider is UnitDefinitionResult',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              freeformProvider.overrideWith(
                () => _StubFreeformNotifier(
                  const UnitDefinitionResult(
                    aliasLine: null,
                    definitionLine: null,
                    formattedResult: '= 8 bit',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'button is enabled when freeformProvider is FunctionConversionResult',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              freeformProvider.overrideWith(
                () => _StubFreeformNotifier(
                  const FunctionConversionResult(
                    functionName: 'tempC',
                    formattedValue: '26.85',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets(
      'button is disabled when freeformProvider is FunctionDefinitionResult',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              freeformProvider.overrideWith(
                () => _StubFreeformNotifier(
                  const FunctionDefinitionResult(
                    label: 'tempC(x) =',
                    expression: 'x + 273.15',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNull);
      },
    );

    testWidgets(
      'button is enabled when freeformProvider is ReciprocalConversionSuccess',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              freeformProvider.overrideWith(
                () => _StubFreeformNotifier(
                  const ReciprocalConversionSuccess(
                    reciprocalInputLabel: '1 / mph',
                    formattedResult: '= 2.2369363 s/m',
                    formattedReciprocal: '= 0.44704 m/s',
                    outputUnit: 's/m',
                  ),
                ),
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pump();
        final btn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.balance),
        );
        expect(btn.onPressed, isNotNull);
      },
    );

    testWidgets('button is disabled when freeformProvider is EvaluationError', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(repo),
            freeformProvider.overrideWith(
              () => _StubFreeformNotifier(
                const EvaluationError(message: 'oops'),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();
      final btn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.balance),
      );
      expect(btn.onPressed, isNull);
    });
  });

  group('HomeScreen — browse AppBar buttons', () {
    testWidgets('Expand All button is present on Browse page', (tester) async {
      await tester.pumpWidget(
        buildApp(browserRepo: _buildTestBrowserRepo()),
      );
      await navigateToBrowser(tester);
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);
    });

    testWidgets('Collapse All button is present on Browse page', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(browserRepo: _buildTestBrowserRepo()),
      );
      await navigateToBrowser(tester);
      expect(find.byIcon(Icons.unfold_less), findsOneWidget);
    });

    testWidgets('Expand All and Collapse All are disabled during search', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(browserRepo: _buildTestBrowserRepo()),
      );
      await navigateToBrowser(tester);

      // Activate the search bar and type a query.
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'm');
      await tester.pump();

      final expandBtn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.unfold_more),
      );
      final collapseBtn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.unfold_less),
      );
      expect(expandBtn.onPressed, isNull);
      expect(collapseBtn.onPressed, isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

final _stubQty = Quantity(1.0, Dimension.dimensionless);

class _StubFreeformNotifier extends FreeformNotifier {
  final EvaluationResult _initial;
  _StubFreeformNotifier(this._initial);

  @override
  EvaluationResult build() => _initial;
}
