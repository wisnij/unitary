import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/state/settings_provider.dart';
import 'features/worksheet/data/worksheet_repository.dart';
import 'features/worksheet/state/worksheet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // Remove stale freeform-persistence keys left over from v0.7 and earlier.
  await Future.wait([
    prefs.remove('freeformInput'),
    prefs.remove('freeformOutput'),
  ]);
  final settingsRepo = SettingsRepository(prefs);
  final worksheetRepo = WorksheetRepository(prefs);

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
      ],
      child: const UnitaryApp(),
    ),
  );
}
