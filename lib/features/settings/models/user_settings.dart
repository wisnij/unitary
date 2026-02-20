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
  final bool? darkMode;
  final EvaluationMode evaluationMode;

  UserSettings({
    this.precision = 8,
    this.notation = Notation.automatic,
    this.darkMode,
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
  ///
  /// Because [darkMode] is nullable, use [clearDarkMode] to explicitly set
  /// it to null (follow system theme).
  UserSettings copyWith({
    int? precision,
    Notation? notation,
    bool? darkMode,
    bool clearDarkMode = false,
    EvaluationMode? evaluationMode,
  }) {
    return UserSettings(
      precision: precision ?? this.precision,
      notation: notation ?? this.notation,
      darkMode: clearDarkMode ? null : (darkMode ?? this.darkMode),
      evaluationMode: evaluationMode ?? this.evaluationMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          precision == other.precision &&
          notation == other.notation &&
          darkMode == other.darkMode &&
          evaluationMode == other.evaluationMode;

  @override
  int get hashCode =>
      Object.hash(precision, notation, darkMode, evaluationMode);

  @override
  String toString() =>
      'UserSettings(precision: $precision, notation: $notation, '
      'darkMode: $darkMode, evaluationMode: $evaluationMode)';
}
