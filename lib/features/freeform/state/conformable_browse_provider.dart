import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incremented each time the user requests a conformable-units browse.
///
/// [HomeScreen] increments this counter when the browse button is pressed.
/// [FreeformScreen] listens for changes and responds by force-evaluating the
/// input expression and opening the conformable-units modal bottom sheet.
final conformableBrowseRequestProvider =
    NotifierProvider<ConformableBrowseNotifier, int>(
      ConformableBrowseNotifier.new,
    );

/// Notifier for [conformableBrowseRequestProvider].
class ConformableBrowseNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Signals a new browse request.
  void trigger() => state++;
}
