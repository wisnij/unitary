import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/browse_entry.dart';
import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/features/browser/presentation/browser_screen.dart';
import 'package:unitary/features/browser/state/browser_provider.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Test notifier that uses a custom repo and starts in alphabetical view so
/// all groups are expanded by default, making entries immediately visible.
class _TestBrowserNotifier extends BrowserNotifier {
  _TestBrowserNotifier(this._testRepo);
  final UnitRepository _testRepo;

  @override
  (UnitRepository, List<BrowseEntry>) createData() =>
      (_testRepo, _testRepo.buildBrowseCatalog());

  @override
  BrowserState build() {
    final initialState = super.build();
    // Start in alphabetical view (all groups expanded) for easier testing.
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
      browserProvider.overrideWith(() => _TestBrowserNotifier(repo)),
      settingsRepositoryProvider.overrideWithValue(_settingsRepo),
    ],
    child: const MaterialApp(home: Scaffold(body: BrowserScreen())),
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
}
