import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';
import '../models/user_settings.dart';

/// Provides the [SettingsRepository] instance.
///
/// Must be overridden in [ProviderScope] with an initialized repository.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError(
    'settingsRepositoryProvider must be overridden',
  ),
);

/// Provides the current [UserSettings] and exposes update methods.
final settingsProvider = NotifierProvider<SettingsNotifier, UserSettings>(
  SettingsNotifier.new,
);

/// Manages [UserSettings] state with persistence.
class SettingsNotifier extends Notifier<UserSettings> {
  @override
  UserSettings build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  void updatePrecision(int precision) {
    state = state.copyWith(precision: precision);
    ref.read(settingsRepositoryProvider).save(state);
  }

  void updateNotation(Notation notation) {
    state = state.copyWith(notation: notation);
    ref.read(settingsRepositoryProvider).save(state);
  }

  void updateThemeMode(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
    ref.read(settingsRepositoryProvider).save(state);
  }

  void updateEvaluationMode(EvaluationMode evaluationMode) {
    state = state.copyWith(evaluationMode: evaluationMode);
    ref.read(settingsRepositoryProvider).save(state);
  }
}
