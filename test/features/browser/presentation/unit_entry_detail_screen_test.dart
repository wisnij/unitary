import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/core/domain/models/browse_entry.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/features/browser/presentation/unit_entry_detail_screen.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

late SettingsRepository _settingsRepo;

Future<void> _setUpSettings() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  _settingsRepo = SettingsRepository(prefs);
}

Widget _buildScreen(
  String primaryId,
  BrowseEntryKind kind,
  UnitRepository repo,
) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(_settingsRepo),
    ],
    child: MaterialApp(
      home: UnitEntryDetailScreen(
        primaryId: primaryId,
        kind: kind,
        repo: repo,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Test repository builder
// ---------------------------------------------------------------------------

UnitRepository _buildRepo() {
  final repo = UnitRepository();
  repo.register(const PrimitiveUnit(id: 'm'));
  repo.register(
    const DerivedUnit(
      id: 'ft',
      aliases: ['foot', 'feet'],
      expression: '0.3048 m',
    ),
  );
  repo.register(
    const PrimitiveUnit(
      id: 'kg',
      description: 'The SI unit of mass.',
    ),
  );
  repo.register(
    const PrimitiveUnit(id: 'rad', isDimensionless: true),
  );
  repo.register(
    const DerivedUnit(id: 'noexpr', expression: 'unknownXYZ'),
  );
  return repo;
}

UnitRepository _buildRepoWithPrefix() {
  final repo = UnitRepository();
  repo.register(const PrimitiveUnit(id: 'm'));
  repo.registerPrefix(
    const PrefixUnit(
      id: 'kilo',
      aliases: ['k'],
      expression: '1e3',
      description: 'SI prefix for 1000.',
    ),
  );
  return repo;
}

UnitRepository _buildRepoWithFunction() {
  final repo = UnitRepository();
  repo.register(const PrimitiveUnit(id: 'm'));
  repo.register(const PrimitiveUnit(id: 'K'));
  repo.registerFunction(
    DefinedFunction(
      id: 'tempC',
      aliases: ['celsius'],
      params: ['x'],
      forward: 'x + 273.15',
      inverse: 'tempC - 273.15',
    ),
  );
  return repo;
}

UnitRepository _buildRepoWithPiecewise() {
  final repo = UnitRepository();
  repo.register(const PrimitiveUnit(id: 'K'));
  final gasmark = PiecewiseFunction(
    id: 'gasmark',
    outputUnit: Quantity(1, Dimension({'K': 1})),
    noerror: false,
    points: const [
      (1.0, 413.7055555555),
      (2.0, 424.8166666666),
      (3.0, 435.9277777777),
    ],
  );
  repo.registerFunction(gasmark);
  return repo;
}

/// Piecewise function with [outputUnitExpression] set so the output column
/// header prefers the expression string over the canonical dimension string.
UnitRepository _buildRepoWithPiecewiseUnitExpr() {
  final repo = UnitRepository();
  repo.register(const PrimitiveUnit(id: 'K'));
  final func = PiecewiseFunction(
    id: 'mypiecewise',
    outputUnit: Quantity(1, Dimension({'K': 1})),
    outputUnitExpression: 'degR',
    noerror: false,
    points: const [(1.0, 413.7), (2.0, 424.8)],
  );
  repo.registerFunction(func);
  return repo;
}

/// Functions with explicit domain/range constraints for testing the
/// Domain / Range display section.
UnitRepository _buildRepoWithConstrainedFunctions() {
  final repo = UnitRepository();
  repo.register(const PrimitiveUnit(id: 'K'));

  // Function whose domain has a named unit expression (e.g. 'deg').
  repo.registerFunction(
    DefinedFunction(
      id: 'withDegDomain',
      params: ['lat'],
      forward: 'lat + 1',
      domain: [
        QuantitySpec(
          quantity: Quantity.unity,
          unitExpression: 'deg',
          min: const Bound(0, closed: true),
          max: const Bound(90, closed: true),
        ),
      ],
      range: QuantitySpec(
        quantity: Quantity(1, Dimension({'K': 1})),
        unitExpression: 'K',
      ),
    ),
  );

  // Function whose domain has unitExpression == '1' (shown as "dimensionless").
  repo.registerFunction(
    DefinedFunction(
      id: 'withDimensionlessDomain',
      params: ['x'],
      forward: 'x + 1',
      domain: [
        QuantitySpec(
          quantity: Quantity.unity,
          unitExpression: '1',
        ),
      ],
    ),
  );

  // Function whose domain has a K-dimensioned quantity but no unitExpression
  // (falls back to canonical representation 'K').
  repo.registerFunction(
    DefinedFunction(
      id: 'withKDomain',
      params: ['temp'],
      forward: 'temp + 273.15',
      domain: [
        QuantitySpec(
          quantity: Quantity(1, Dimension({'K': 1})),
        ),
      ],
    ),
  );

  return repo;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(_setUpSettings);

  group('UnitEntryDetailScreen — unit kind', () {
    testWidgets('shows name section', (tester) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('m', BrowseEntryKind.unit, repo));
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('m'), findsAtLeastNWidgets(1));
    });

    testWidgets('type section shows Primitive unit for primitive', (
      tester,
    ) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('m', BrowseEntryKind.unit, repo));
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Primitive unit'), findsOneWidget);
    });

    testWidgets(
      'type section shows Primitive unit (dimensionless) for dimensionless primitive',
      (
        tester,
      ) async {
        final repo = _buildRepo();
        await tester.pumpWidget(
          _buildScreen('rad', BrowseEntryKind.unit, repo),
        );
        expect(find.text('Type'), findsOneWidget);
        expect(find.text('Primitive unit (dimensionless)'), findsOneWidget);
      },
    );

    testWidgets('type section shows Derived unit for derived unit', (
      tester,
    ) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('ft', BrowseEntryKind.unit, repo));
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Derived unit'), findsOneWidget);
    });

    testWidgets('definition section absent for primitive unit', (tester) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('m', BrowseEntryKind.unit, repo));
      expect(find.text('Definition'), findsNothing);
    });

    testWidgets('shows definition expression for derived unit', (tester) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('ft', BrowseEntryKind.unit, repo));
      expect(find.text('Definition'), findsOneWidget);
      expect(find.text('0.3048 m'), findsAtLeastNWidgets(1));
    });

    testWidgets('aliases section shown when unit has aliases', (tester) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('ft', BrowseEntryKind.unit, repo));
      expect(find.text('Aliases'), findsOneWidget);
      expect(find.text('feet, foot'), findsOneWidget);
    });

    testWidgets('aliases section absent when unit has no aliases', (
      tester,
    ) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('m', BrowseEntryKind.unit, repo));
      expect(find.text('Aliases'), findsNothing);
    });

    testWidgets('description section shown when present', (tester) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('kg', BrowseEntryKind.unit, repo));
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('The SI unit of mass.'), findsOneWidget);
    });

    testWidgets('description section absent when null', (tester) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('m', BrowseEntryKind.unit, repo));
      expect(find.text('Description'), findsNothing);
    });

    testWidgets('value section shown for resolvable unit', (tester) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('m', BrowseEntryKind.unit, repo));
      expect(find.text('Value'), findsOneWidget);
      // The formatted quantity contains the unit dimension.
      expect(find.textContaining('m'), findsAtLeastNWidgets(1));
    });

    testWidgets('value section absent on resolution failure', (tester) async {
      final repo = _buildRepo();
      await tester.pumpWidget(
        _buildScreen('noexpr', BrowseEntryKind.unit, repo),
      );
      expect(find.text('Value'), findsNothing);
    });

    testWidgets('shows not-found message for unknown id', (tester) async {
      final repo = _buildRepo();
      await tester.pumpWidget(
        _buildScreen('xyz_missing', BrowseEntryKind.unit, repo),
      );
      expect(find.textContaining('Unit not found'), findsOneWidget);
    });
  });

  group('UnitEntryDetailScreen — prefix kind', () {
    testWidgets('type section shows Prefix', (tester) async {
      final repo = _buildRepoWithPrefix();
      await tester.pumpWidget(
        _buildScreen('kilo', BrowseEntryKind.prefix, repo),
      );
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Prefix'), findsOneWidget);
    });

    testWidgets('definition section shows expression', (tester) async {
      final repo = _buildRepoWithPrefix();
      await tester.pumpWidget(
        _buildScreen('kilo', BrowseEntryKind.prefix, repo),
      );
      expect(find.text('Definition'), findsOneWidget);
      expect(find.text('1e3'), findsOneWidget);
    });

    testWidgets('aliases section shown when prefix has aliases', (
      tester,
    ) async {
      final repo = _buildRepoWithPrefix();
      await tester.pumpWidget(
        _buildScreen('kilo', BrowseEntryKind.prefix, repo),
      );
      expect(find.text('Aliases'), findsOneWidget);
      expect(find.text('k'), findsOneWidget);
    });

    testWidgets('description section shown when present', (tester) async {
      final repo = _buildRepoWithPrefix();
      await tester.pumpWidget(
        _buildScreen('kilo', BrowseEntryKind.prefix, repo),
      );
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('SI prefix for 1000.'), findsOneWidget);
    });

    testWidgets('value section shows resolved scale factor', (tester) async {
      final repo = _buildRepoWithPrefix();
      await tester.pumpWidget(
        _buildScreen('kilo', BrowseEntryKind.prefix, repo),
      );
      expect(find.text('Value'), findsOneWidget);
      // kilo resolves to 1000 (dimensionless).
      expect(find.textContaining('1000'), findsAtLeastNWidgets(1));
    });

    testWidgets('value section absent for function', (tester) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('tempC', BrowseEntryKind.function, repo),
      );
      expect(find.text('Value'), findsNothing);
    });
  });

  group('UnitEntryDetailScreen — function kind', () {
    testWidgets('shows name section', (tester) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('tempC', BrowseEntryKind.function, repo),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('tempC'), findsAtLeastNWidgets(1));
    });

    testWidgets('aliases section shown when function has aliases', (
      tester,
    ) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('tempC', BrowseEntryKind.function, repo),
      );
      expect(find.text('Aliases'), findsOneWidget);
      expect(find.text('celsius'), findsOneWidget);
    });

    testWidgets('type section shows Function for defined function', (
      tester,
    ) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('tempC', BrowseEntryKind.function, repo),
      );
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Function'), findsOneWidget);
    });

    testWidgets('definition shows signature and forward expression', (
      tester,
    ) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('tempC', BrowseEntryKind.function, repo),
      );
      expect(find.text('Definition'), findsOneWidget);
      expect(find.text('tempC(x) = x + 273.15'), findsOneWidget);
    });

    testWidgets('inverse section shown when function has inverse', (
      tester,
    ) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('tempC', BrowseEntryKind.function, repo),
      );
      expect(find.text('Inverse'), findsOneWidget);
    });

    testWidgets('value section absent for function', (tester) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('tempC', BrowseEntryKind.function, repo),
      );
      expect(find.text('Value'), findsNothing);
    });

    testWidgets('shows not-found message for unknown function id', (
      tester,
    ) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('unknownFn', BrowseEntryKind.function, repo),
      );
      expect(find.textContaining('Function not found'), findsOneWidget);
    });
  });

  group('UnitEntryDetailScreen — piecewise function', () {
    testWidgets('type section shows Piecewise linear function', (tester) async {
      final repo = _buildRepoWithPiecewise();
      await tester.pumpWidget(
        _buildScreen('gasmark', BrowseEntryKind.function, repo),
      );
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Piecewise linear function'), findsOneWidget);
    });

    testWidgets('shows table in definition section', (tester) async {
      final repo = _buildRepoWithPiecewise();
      await tester.pumpWidget(
        _buildScreen('gasmark', BrowseEntryKind.function, repo),
      );
      expect(find.text('Definition'), findsOneWidget);
      // 3 data points + 1 header row — each data row shows the x value.
      expect(find.textContaining('1'), findsAtLeastNWidgets(1));
      expect(find.textContaining('2'), findsAtLeastNWidgets(1));
      expect(find.textContaining('3'), findsAtLeastNWidgets(1));
    });

    testWidgets('does not show Domain / Range or Values sections', (
      tester,
    ) async {
      final repo = _buildRepoWithPiecewise();
      await tester.pumpWidget(
        _buildScreen('gasmark', BrowseEntryKind.function, repo),
      );
      expect(find.text('Domain / Range'), findsNothing);
      expect(find.text('Values'), findsNothing);
    });

    testWidgets(
      'table output header uses canonical rep when outputUnitExpression is null',
      (tester) async {
        // gasmark has outputUnit dimension {K:1} and no outputUnitExpression.
        final repo = _buildRepoWithPiecewise();
        await tester.pumpWidget(
          _buildScreen('gasmark', BrowseEntryKind.function, repo),
        );
        expect(find.text('Output (K)'), findsOneWidget);
      },
    );

    testWidgets(
      'table output header prefers outputUnitExpression over canonical rep',
      (tester) async {
        // mypiecewise has K dimension but outputUnitExpression == 'degR'.
        final repo = _buildRepoWithPiecewiseUnitExpr();
        await tester.pumpWidget(
          _buildScreen('mypiecewise', BrowseEntryKind.function, repo),
        );
        expect(find.text('Output (degR)'), findsOneWidget);
        // The canonical rep ('K') should NOT appear as the header.
        expect(find.text('Output (K)'), findsNothing);
      },
    );
  });

  group('UnitEntryDetailScreen — function domain/range display', () {
    testWidgets('shows Domain / Range section when domain is constrained', (
      tester,
    ) async {
      final repo = _buildRepoWithConstrainedFunctions();
      await tester.pumpWidget(
        _buildScreen('withDegDomain', BrowseEntryKind.function, repo),
      );
      expect(find.text('Domain / Range'), findsOneWidget);
    });

    testWidgets('does not show Domain / Range section when unconstrained', (
      tester,
    ) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('tempC', BrowseEntryKind.function, repo),
      );
      expect(find.text('Domain / Range'), findsNothing);
    });

    testWidgets('domain shows unitExpression string and bounds', (
      tester,
    ) async {
      final repo = _buildRepoWithConstrainedFunctions();
      await tester.pumpWidget(
        _buildScreen('withDegDomain', BrowseEntryKind.function, repo),
      );
      // "Argument lat: deg [0, 90]"
      expect(
        find.text('Argument lat: deg [0, 90]'),
        findsOneWidget,
      );
    });

    testWidgets('domain shows "dimensionless" when unitExpression is "1"', (
      tester,
    ) async {
      final repo = _buildRepoWithConstrainedFunctions();
      await tester.pumpWidget(
        _buildScreen('withDimensionlessDomain', BrowseEntryKind.function, repo),
      );
      expect(find.text('Argument x: dimensionless'), findsOneWidget);
    });

    testWidgets(
      'domain falls back to canonical representation when no unitExpression',
      (tester) async {
        final repo = _buildRepoWithConstrainedFunctions();
        await tester.pumpWidget(
          _buildScreen('withKDomain', BrowseEntryKind.function, repo),
        );
        expect(find.text('Argument temp: K'), findsOneWidget);
      },
    );

    testWidgets('range shows unitExpression string', (tester) async {
      final repo = _buildRepoWithConstrainedFunctions();
      await tester.pumpWidget(
        _buildScreen('withDegDomain', BrowseEntryKind.function, repo),
      );
      // Range has unitExpression: 'K'.
      expect(find.text('Range: K'), findsOneWidget);
    });
  });

  group('UnitEntryDetailScreen — long-press copy', () {
    List<MethodCall> clipboardCalls = [];

    setUp(() {
      clipboardCalls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            SystemChannels.platform,
            (call) async {
              if (call.method == 'Clipboard.setData') {
                clipboardCalls.add(call);
              }
              return null;
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    String? lastClipboardText() {
      if (clipboardCalls.isEmpty) {
        return null;
      }
      final args = clipboardCalls.last.arguments as Map;
      return (args['text'] as String?) ??
          (args['data'] as Map?)?['text'] as String?;
    }

    testWidgets('long-pressing Name copies the unit id and shows snack bar', (
      tester,
    ) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('m', BrowseEntryKind.unit, repo));
      // The 'm' text under the Name heading is copyable.
      await tester.longPress(find.text('m').first);
      await tester.pump();
      expect(lastClipboardText(), 'm');
      expect(find.text('Copied: m'), findsOneWidget);
    });

    testWidgets('long-pressing Definition copies expression for derived unit', (
      tester,
    ) async {
      // Use 'ft' (derived unit) since primitive units have no Definition section.
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('ft', BrowseEntryKind.unit, repo));
      await tester.longPress(find.text('0.3048 m').first);
      await tester.pump();
      expect(lastClipboardText(), '0.3048 m');
    });

    testWidgets('long-pressing Value copies the formatted quantity', (
      tester,
    ) async {
      final repo = _buildRepo();
      await tester.pumpWidget(_buildScreen('m', BrowseEntryKind.unit, repo));
      // 'm' resolves to Quantity(1, {m:1}); formatted as '1 m'.
      await tester.longPress(find.text('1 m'));
      await tester.pump();
      expect(lastClipboardText(), '1 m');
    });

    testWidgets('long-pressing Name copies the function id', (tester) async {
      final repo = _buildRepoWithFunction();
      await tester.pumpWidget(
        _buildScreen('tempC', BrowseEntryKind.function, repo),
      );
      await tester.longPress(find.text('tempC').first);
      await tester.pump();
      expect(lastClipboardText(), 'tempC');
    });
  });
}
