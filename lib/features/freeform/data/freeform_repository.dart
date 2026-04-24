import 'package:shared_preferences/shared_preferences.dart';

/// Persists the freeform "Convert from" and "Convert to" field text to
/// [SharedPreferences] as two independent string keys.
class FreeformRepository {
  final SharedPreferences _prefs;

  static const inputKey = 'freeformInput';
  static const outputKey = 'freeformOutput';

  FreeformRepository(this._prefs);

  /// Loads saved field text.  Returns empty strings for any missing key.
  ({String input, String output}) load() {
    return (
      input: _prefs.getString(inputKey) ?? '',
      output: _prefs.getString(outputKey) ?? '',
    );
  }

  /// Saves both field texts to storage.
  Future<void> save(String input, String output) async {
    await Future.wait([
      _prefs.setString(inputKey, input),
      _prefs.setString(outputKey, output),
    ]);
  }
}
