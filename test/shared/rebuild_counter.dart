import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts widget rebuilds by runtime type name during a widget test.
///
/// Uses the framework's [debugOnRebuildDirtyWidget] hook — the same mechanism
/// DevTools' "track widget builds" feature is built on — so counts match what
/// a manual DevTools rebuild-tracking pass reports, and real screens can be
/// probed without modifying application code.  Counting starts at [install]
/// (pump the initial tree first, then install), and private widget types are
/// addressable by their string name (e.g. `'_KeyPanel'`).
class RebuildCounter {
  final Map<String, int> _counts = {};

  /// Starts counting rebuilds.  Pair with [uninstall] in `addTearDown`.
  void install(WidgetTester tester) {
    debugOnRebuildDirtyWidget = (Element element, bool builtOnce) {
      final name = element.widget.runtimeType.toString();
      _counts[name] = (_counts[name] ?? 0) + 1;
    };
  }

  /// Stops counting and detaches the hook.
  void uninstall(WidgetTester tester) {
    debugOnRebuildDirtyWidget = null;
  }

  /// Clears accumulated counts (the hook stays installed).
  void reset() {
    _counts.clear();
  }

  /// Rebuild count recorded for [widgetTypeName] since install/reset.
  int of(String widgetTypeName) {
    return _counts[widgetTypeName] ?? 0;
  }
}
