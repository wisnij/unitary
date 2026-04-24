import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/freeform/data/freeform_repository.dart';
import 'features/freeform/state/freeform_provider.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/state/settings_provider.dart';
import 'features/worksheet/data/worksheet_repository.dart';
import 'features/worksheet/state/worksheet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final settingsRepo = SettingsRepository(prefs);
  final worksheetRepo = WorksheetRepository(prefs);
  final freeformRepo = FreeformRepository(prefs);

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
        freeformRepositoryProvider.overrideWithValue(freeformRepo),
      ],
      child: const UnitaryApp(),
    ),
  );
}
