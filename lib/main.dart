import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/domain/models/unit.dart';
import 'core/domain/models/unit_repository.dart';
import 'core/domain/models/unit_repository_provider.dart';
import 'features/currency/data/currency_rate_repository.dart';
import 'features/currency/state/currency_provider.dart';
import 'features/freeform/data/freeform_history_repository.dart';
import 'features/freeform/state/freeform_history_provider.dart';
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
  final historyRepo = FreeformHistoryRepository(prefs);
  final currencyRateRepo = CurrencyRateRepository(prefs);

  // Apply stored currency rates to the unit repository before the first frame
  // so that currency conversions are live from launch.
  final unitRepo = UnitRepository.withPredefinedUnits();
  final storedRates = currencyRateRepo.load();
  if (storedRates != null) {
    final descriptors = unitRepo.buildCurrencyDescriptors();
    final byUnitId = {for (final d in descriptors) d.unitId: d};
    for (final entry in storedRates.rates.entries) {
      final descriptor = byUnitId[entry.key];
      if (descriptor == null) {
        continue;
      }
      unitRepo.registerDynamic(
        DerivedUnit(
          id: descriptor.unitId,
          aliases: descriptor.originalUnit.aliases,
          description: descriptor.originalUnit.description,
          expression: descriptor.expressionFor(entry.value.rate),
        ),
      );
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        unitRepositoryProvider.overrideWithValue(unitRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        worksheetRepositoryProvider.overrideWithValue(worksheetRepo),
        freeformHistoryRepositoryProvider.overrideWithValue(historyRepo),
        currencyRateRepositoryProvider.overrideWithValue(currencyRateRepo),
      ],
      child: const UnitaryApp(),
    ),
  );
}
