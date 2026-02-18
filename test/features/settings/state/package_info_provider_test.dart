import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:unitary/features/settings/state/package_info_provider.dart';

void main() {
  group('packageInfoProvider', () {
    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'unitary',
        packageName: 'com.wisnij.unitary',
        version: '1.2.3',
        buildNumber: '42',
        buildSignature: '',
      );
    });

    test('resolves to PackageInfo with expected version', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final info = await container.read(packageInfoProvider.future);
      expect(info.version, '1.2.3');
    });
  });
}
