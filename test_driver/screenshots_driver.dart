import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver solely for the README screenshot capture (see
/// `integration_test/screenshots/` and `tool/take_screenshots.sh`) — not
/// used by the regular integration-test suite, which runs driverless via
/// `flutter test`.  Screenshots are written to `doc/screenshots/<name>.png`
/// relative to the project root.
Future<void> main() {
  return integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          final file = File('doc/screenshots/$name.png');
          file.createSync(recursive: true);
          file.writeAsBytesSync(bytes);
          return true;
        },
  );
}
