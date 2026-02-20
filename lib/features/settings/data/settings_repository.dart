import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_settings.dart';

/// Persists [UserSettings] to [SharedPreferences] as individual keys.
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const _keyPrecision = 'precision';
  static const _keyNotation = 'notation';
  static const _keyThemeMode = 'themeMode';
  static const _keyEvaluationMode = 'evaluationMode';

  /// Loads settings from storage, using defaults for missing keys.
  UserSettings load() {
    final defaults = UserSettings.defaults();
    return UserSettings(
      precision: _prefs.getInt(_keyPrecision) ?? defaults.precision,
      notation: _loadEnum(
        _keyNotation,
        Notation.values,
        defaults.notation,
      ),
      themeMode: _loadThemeMode(),
      evaluationMode: _loadEnum(
        _keyEvaluationMode,
        EvaluationMode.values,
        defaults.evaluationMode,
      ),
    );
  }

  /// Saves all settings to storage.
  Future<void> save(UserSettings settings) async {
    await _prefs.setInt(_keyPrecision, settings.precision);
    await _prefs.setString(_keyNotation, settings.notation.name);
    await _prefs.setString(_keyEvaluationMode, settings.evaluationMode.name);
    await _prefs.setString(
      _keyThemeMode,
      _themeModeToString(settings.themeMode),
    );
  }

  T _loadEnum<T extends Enum>(String key, List<T> values, T defaultValue) {
    final name = _prefs.getString(key);
    if (name == null) {
      return defaultValue;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return defaultValue;
  }

  ThemeMode _loadThemeMode() {
    final s = _prefs.getString(_keyThemeMode);
    return _themeModeFromString(s);
  }

  static String _themeModeToString(ThemeMode m) => switch (m) {
    ThemeMode.system => 'system',
    ThemeMode.dark => 'dark',
    ThemeMode.light => 'light',
  };

  static ThemeMode _themeModeFromString(String? s) => switch (s) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };
}
