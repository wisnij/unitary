import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unitary/app.dart';
import 'package:unitary/features/freeform/data/freeform_repository.dart';
import 'package:unitary/features/freeform/state/freeform_provider.dart';
import 'package:unitary/features/settings/data/settings_repository.dart';
import 'package:unitary/features/settings/state/settings_provider.dart';
import 'package:unitary/features/worksheet/data/worksheet_repository.dart';
import 'package:unitary/features/worksheet/state/worksheet_provider.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settingsRepo = SettingsRepository(prefs);
    final worksheetRepo = WorksheetRepository(prefs);
    final freeformRepo = FreeformRepository(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
          freeformRepositoryProvider.overrideWithValue(freeformRepo),
        ],
        child: const UnitaryApp(),
      ),
    );
    expect(find.text('Unitary'), findsOneWidget);
  });
}
