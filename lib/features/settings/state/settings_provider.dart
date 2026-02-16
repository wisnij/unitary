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
final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((
  ref,
) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

/// Manages [UserSettings] state with persistence.
class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.load());

  void updatePrecision(int precision) {
    state = state.copyWith(precision: precision);
    _repository.save(state);
  }

  void updateNotation(Notation notation) {
    state = state.copyWith(notation: notation);
    _repository.save(state);
  }

  void updateDarkMode(bool? darkMode) {
    if (darkMode == null) {
      state = state.copyWith(clearDarkMode: true);
    } else {
      state = state.copyWith(darkMode: darkMode);
    }
    _repository.save(state);
  }

  void updateEvaluationMode(EvaluationMode evaluationMode) {
    state = state.copyWith(evaluationMode: evaluationMode);
    _repository.save(state);
  }
}
