import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/features/currency/presentation/currency_refresh_button.dart';
import 'package:unitary/features/currency/state/currency_provider.dart';
import 'package:unitary/features/worksheet/presentation/widgets/worksheet_banner.dart';
import 'package:unitary/features/worksheet/presentation/worksheet_screen.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';

import '../../../helpers/repository_overrides.dart';

class _FixedStatusNotifier extends CurrencyStatusNotifier {
  _FixedStatusNotifier(this._initial);

  final CurrencyStatus _initial;

  @override
  CurrencyStatus build() => _initial;
}

void main() {
  late TestRepositories repos;

  setUp(() async {
    repos = await TestRepositories.create();
  });

  Widget buildApp({CurrencyStatus status = const CurrencyStatus()}) {
    return ProviderScope(
      overrides: [
        ...repos.overrides,
        currencyStatusProvider.overrideWith(() => _FixedStatusNotifier(status)),
      ],
      child: MaterialApp(home: WorksheetScreen(onNavigate: (_) {})),
    );
  }

  void selectTemplate(WidgetTester tester, String id) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorksheetScreen)),
    );
    container.read(worksheetProvider.notifier).selectWorksheet(id);
  }

  group('WorksheetScreen — banner', () {
    testWidgets('banner is shown for the Currency worksheet', (tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'currency');
      await tester.pump();

      expect(find.byType(WorksheetBannerWidget), findsOneWidget);
    });

    testWidgets('no banner for a non-currency worksheet', (tester) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pump();

      expect(find.byType(WorksheetBannerWidget), findsNothing);
    });

    testWidgets('banner reflects the last-updated timestamp', (tester) async {
      await tester.pumpWidget(
        buildApp(
          status: CurrencyStatus(
            lastUpdatedAt: DateTime.utc(2026, 6, 6, 10, 0),
          ),
        ),
      );
      selectTemplate(tester, 'currency');
      await tester.pump();

      expect(find.textContaining('Jun 6, 2026'), findsOneWidget);
    });
  });

  group('WorksheetScreen — AppBar refresh action', () {
    testWidgets('refresh action present on the Currency worksheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'currency');
      await tester.pump();

      expect(find.byType(CurrencyRefreshButton), findsOneWidget);
    });

    testWidgets('refresh action absent on a non-currency worksheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      selectTemplate(tester, 'length');
      await tester.pump();

      expect(find.byType(CurrencyRefreshButton), findsNothing);
    });
  });
}
