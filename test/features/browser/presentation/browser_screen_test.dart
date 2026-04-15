import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/models/unit_repository_provider.dart';
import 'package:unitary/features/browser/presentation/browser_screen.dart';
import 'package:unitary/features/browser/state/browser_provider.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/shared/widgets/fast_scroll_bar.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Test notifier that starts in alphabetical view with all groups expanded,
/// making entries immediately visible in widget tests.
/// (Production default is all-collapsed; this is a deliberate override for
/// test visibility.)
class _TestBrowserNotifier extends BrowserNotifier {
  @override
  BrowserState build() {
    final initialState = super.build();
    // Force alphabetical view with all groups expanded for easier testing.
    return initialState.copyWith(
      viewMode: BrowseViewMode.alphabetical,
      collapsedGroups: const {},
    );
  }
}

late SettingsRepository _settingsRepo;

Future<void> _setUpSettings() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  _settingsRepo = SettingsRepository(prefs);
}

Widget _buildScreen(UnitRepository repo) {
  return ProviderScope(
    overrides: [
      unitRepositoryProvider.overrideWithValue(repo),
      browserProvider.overrideWith(_TestBrowserNotifier.new),
      settingsRepositoryProvider.overrideWithValue(_settingsRepo),
    ],
    child: MaterialApp(
      home: BrowserScreen(onNavigate: (_) {}),
    ),
  );
}

// ---------------------------------------------------------------------------
// Test repos
// ---------------------------------------------------------------------------

UnitRepository _buildDecorationRepo() {
  final repo = UnitRepository();
  repo.register(const PrimitiveUnit(id: 'm'));
  repo.registerPrefix(const PrefixUnit(id: 'kilo', expression: '1e3'));
  repo.registerFunction(
    DefinedFunction(
      id: 'circlearea',
      params: ['r'],
      forward: 'r^2 * 3.14159',
    ),
  );
  return repo;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(_setUpSettings);

  group('BrowserScreen — entry row decoration', () {
    testWidgets('prefix entry title has trailing dash', (tester) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));
      expect(find.text('kilo-'), findsOneWidget);
    });

    testWidgets('function entry title includes parameter list', (tester) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));
      expect(find.text('circlearea(r)'), findsOneWidget);
    });

    testWidgets('alias entry title shows decorated-name = primaryId', (
      tester,
    ) async {
      final repo = UnitRepository();
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(
        const DerivedUnit(
          id: 'ft',
          aliases: ['foot'],
          expression: '0.3048 m',
        ),
      );
      await tester.pumpWidget(_buildScreen(repo));
      expect(find.text('foot = ft'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Expand/collapse during search
  // ---------------------------------------------------------------------------

  group('BrowserScreen — expand/collapse during search', () {
    testWidgets('collapsing a group during search shows collapsed chevron', (
      tester,
    ) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));

      // Start a search query so all groups are expanded.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(BrowserScreen)),
      );
      container.read(browserProvider.notifier).toggleSearch();
      container.read(browserProvider.notifier).setSearchQuery('k');
      await tester.pump();

      // Collapse the K group (contains "kilo-").
      container.read(browserProvider.notifier).toggleGroup('K');
      await tester.pump();

      // The K group header should show the collapsed (right-pointing) chevron.
      final headers = find.byWidgetPredicate(
        (w) => w is Icon && w.icon == Icons.chevron_right,
      );
      expect(headers, findsOneWidget);

      // The kilo- entry should not be visible.
      expect(find.text('kilo-'), findsNothing);
    });

    testWidgets(
      'expanding a collapsed group during search shows expanded chevron',
      (
        tester,
      ) async {
        final repo = _buildDecorationRepo();
        await tester.pumpWidget(_buildScreen(repo));

        final container = ProviderScope.containerOf(
          tester.element(find.byType(BrowserScreen)),
        );
        container.read(browserProvider.notifier).toggleSearch();
        container.read(browserProvider.notifier).setSearchQuery('k');
        await tester.pump();

        // Collapse then re-expand the K group.
        container.read(browserProvider.notifier).toggleGroup('K');
        await tester.pump();
        container.read(browserProvider.notifier).toggleGroup('K');
        await tester.pump();

        // The K group should show the expanded (down-pointing) chevron.
        final collapsedChevrons = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Icons.chevron_right,
        );
        expect(collapsedChevrons, findsNothing);

        // The kilo- entry should be visible again.
        expect(find.text('kilo-'), findsOneWidget);
      },
    );

    testWidgets('Expand All during search expands all groups', (tester) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(BrowserScreen)),
      );
      container.read(browserProvider.notifier).toggleSearch();
      // Type a query that matches entries in multiple groups.
      container.read(browserProvider.notifier).setSearchQuery('a');
      container.read(browserProvider.notifier).toggleGroup('C');
      await tester.pump();

      container.read(browserProvider.notifier).expandAll();
      await tester.pump();

      // No collapsed chevrons should remain.
      final collapsedChevrons = find.byWidgetPredicate(
        (w) => w is Icon && w.icon == Icons.chevron_right,
      );
      expect(collapsedChevrons, findsNothing);
    });

    testWidgets('Collapse All during search collapses all groups', (
      tester,
    ) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(BrowserScreen)),
      );
      container.read(browserProvider.notifier).toggleSearch();
      container.read(browserProvider.notifier).setSearchQuery('a');
      await tester.pump();

      // All groups are expanded after a query change; collapse all.
      container.read(browserProvider.notifier).collapseAll();
      await tester.pump();

      // All visible group headers should show the collapsed chevron.
      final expandedChevrons = find.byWidgetPredicate(
        (w) => w is Icon && w.icon == Icons.expand_more,
      );
      expect(expandedChevrons, findsNothing);

      // No entry rows visible (circlearea, m, kilo- all hidden).
      expect(find.text('kilo-'), findsNothing);
      expect(find.text('m'), findsNothing);
      expect(find.text('circlearea(r)'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // FastScrollBar integration
  // ---------------------------------------------------------------------------

  group('BrowserScreen — FastScrollBar integration', () {
    testWidgets('FastScrollBar widget is present in browse list', (
      tester,
    ) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pump(); // allow post-frame callbacks
      expect(find.byType(FastScrollBar), findsOneWidget);
    });

    testWidgets('FastScrollBar has active=true when search is inactive', (
      tester,
    ) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pump();

      final widget = tester.widget<FastScrollBar>(find.byType(FastScrollBar));
      expect(widget.active, isTrue);
    });

    testWidgets('FastScrollBar has active=false when search query is set', (
      tester,
    ) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pump();

      // Open the search bar and type a query via the provider notifier.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(BrowserScreen)),
      );
      container.read(browserProvider.notifier).toggleSearch();
      container.read(browserProvider.notifier).setSearchQuery('kilo');
      await tester.pump();

      final widget = tester.widget<FastScrollBar>(find.byType(FastScrollBar));
      expect(widget.active, isFalse);
    });

    testWidgets('thumb not rendered when search query is active', (
      tester,
    ) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(BrowserScreen)),
      );
      container.read(browserProvider.notifier).toggleSearch();
      container.read(browserProvider.notifier).setSearchQuery('m');
      await tester.pump();

      expect(find.byKey(FastScrollBar.thumbKey), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // AppBar buttons
  // ---------------------------------------------------------------------------

  group('BrowserScreen — AppBar buttons', () {
    testWidgets('Expand All button is present in AppBar', (tester) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));
      expect(find.byIcon(Icons.unfold_more), findsOneWidget);
    });

    testWidgets('Collapse All button is present in AppBar', (tester) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));
      expect(find.byIcon(Icons.unfold_less), findsOneWidget);
    });

    testWidgets('Expand All and Collapse All are enabled during search', (
      tester,
    ) async {
      final repo = _buildDecorationRepo();
      await tester.pumpWidget(_buildScreen(repo));

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
      expect(expandBtn.onPressed, isNotNull);
      expect(collapseBtn.onPressed, isNotNull);
    });
  });
}
