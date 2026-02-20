import 'package:flutter/material.dart';

/// Number notation style for result formatting.
enum Notation {
  automatic('Automatic'),
  scientific('Scientific'),
  engineering('Engineering')
  ;

  final String label;
  const Notation(this.label);
}

/// When expression evaluation is triggered.
enum EvaluationMode {
  realtime('Real-time'),
  onSubmit('On submit')
  ;

  final String label;
  const EvaluationMode(this.label);
}

/// Immutable user settings model.
class UserSettings {
  final int precision;
  final Notation notation;
  final ThemeMode themeMode;
  final EvaluationMode evaluationMode;

  UserSettings({
    this.precision = 8,
    this.notation = Notation.automatic,
    this.themeMode = ThemeMode.system,
    this.evaluationMode = EvaluationMode.realtime,
  }) {
    if (precision < 2 || precision > 10) {
      throw ArgumentError.value(
        precision,
        'precision',
        'Must be between 2 and 10',
      );
    }
  }

  factory UserSettings.defaults() => UserSettings();

  /// Creates a copy with the given fields replaced.
  UserSettings copyWith({
    int? precision,
    Notation? notation,
    ThemeMode? themeMode,
    EvaluationMode? evaluationMode,
  }) {
    return UserSettings(
      precision: precision ?? this.precision,
      notation: notation ?? this.notation,
      themeMode: themeMode ?? this.themeMode,
      evaluationMode: evaluationMode ?? this.evaluationMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          precision == other.precision &&
          notation == other.notation &&
          themeMode == other.themeMode &&
          evaluationMode == other.evaluationMode;

  @override
  int get hashCode =>
      Object.hash(precision, notation, themeMode, evaluationMode);

  @override
  String toString() =>
      'UserSettings(precision: $precision, notation: $notation, '
      'themeMode: $themeMode, evaluationMode: $evaluationMode)';
}
