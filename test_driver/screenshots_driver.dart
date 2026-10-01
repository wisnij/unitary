import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver solely for the screenshot capture (see `integration_test/screenshots/`
/// and `tool/take_screenshots.sh`) — not used by the regular integration-test
/// suite, which runs driverless via `flutter test`.  Screenshots are written to
/// `<dir>/<name>.png`, where `<dir>` is the `SCREENSHOT_DIR` environment
/// variable, or `doc/screenshots` (the README screenshots) when it is unset.
/// Relative paths are relative to the project root.
Future<void> main() {
  final dir = Platform.environment['SCREENSHOT_DIR'] ?? 'doc/screenshots';
  return integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          final file = File('$dir/$name.png');
          file.createSync(recursive: true);
          file.writeAsBytesSync(bytes);
          return true;
        },
  );
}
