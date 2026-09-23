import 'package:flutter_test/flutter_test.dart';

import '../../tool/verify_apk_abis_lib.dart';

/// Entry names for a complete ABI directory: the Flutter engine, the app's AOT
/// snapshot, and the DataStore library every current build also carries.
List<String> completeAbi(String abi) => [
  'lib/$abi/libapp.so',
  'lib/$abi/libdatastore_shared_counter.so',
  'lib/$abi/libflutter.so',
];

/// Non-native entries present in every real APK, which the check must ignore.
const List<String> otherEntries = [
  'AndroidManifest.xml',
  'classes.dex',
  'assets/flutter_assets/AssetManifest.bin',
  'META-INF/CERT.RSA',
  'res/mipmap-hdpi-v4/ic_launcher.png',
];

/// The layout the release APK is required to have.
List<String> validApk() => [
  ...otherEntries,
  ...completeAbi('arm64-v8a'),
  ...completeAbi('armeabi-v7a'),
];

void main() {
  group('nativeLibraries', () {
    test('groups library names by ABI directory', () {
      expect(nativeLibraries(validApk()), {
        'arm64-v8a': {
          'libapp.so',
          'libdatastore_shared_counter.so',
          'libflutter.so',
        },
        'armeabi-v7a': {
          'libapp.so',
          'libdatastore_shared_counter.so',
          'libflutter.so',
        },
      });
    });

    test('ignores entries outside lib/', () {
      expect(nativeLibraries(otherEntries), isEmpty);
    });

    test('ignores directory entries and files directly under lib/', () {
      expect(
        nativeLibraries(['lib/', 'lib/x86_64/', 'lib/stray.so']),
        isEmpty,
      );
    });
  });

  group('checkApkAbis', () {
    test('reports no problems for exactly the two complete ARM ABIs', () {
      expect(checkApkAbis(validApk()), isEmpty);
    });

    test('ignores entries outside lib/', () {
      expect(
        checkApkAbis([...validApk(), 'assets/lib/x86_64/libfoo.so']),
        isEmpty,
      );
    });

    test('reports a complete extra x86_64 directory as unexpected', () {
      expect(checkApkAbis([...validApk(), ...completeAbi('x86_64')]), [
        const AbiProblem.unexpectedAbi('x86_64'),
      ]);
    });

    test('reports a partial x86_64 directory as unexpected', () {
      expect(
        checkApkAbis([
          ...validApk(),
          'lib/x86_64/libdatastore_shared_counter.so',
        ]),
        [const AbiProblem.unexpectedAbi('x86_64')],
      );
    });

    test('reports a partial x86 directory as unexpected', () {
      expect(checkApkAbis([...validApk(), 'lib/x86/libfoo.so']), [
        const AbiProblem.unexpectedAbi('x86'),
      ]);
    });

    test('reports libflutter.so missing from armeabi-v7a', () {
      final entries = validApk()..remove('lib/armeabi-v7a/libflutter.so');
      expect(checkApkAbis(entries), [
        const AbiProblem.missingLibrary('armeabi-v7a', 'libflutter.so'),
      ]);
    });

    test('reports libapp.so missing from arm64-v8a', () {
      final entries = validApk()..remove('lib/arm64-v8a/libapp.so');
      expect(checkApkAbis(entries), [
        const AbiProblem.missingLibrary('arm64-v8a', 'libapp.so'),
      ]);
    });

    test('reports an expected ABI directory that is absent entirely', () {
      expect(checkApkAbis([...otherEntries, ...completeAbi('arm64-v8a')]), [
        const AbiProblem.missingAbi('armeabi-v7a'),
      ]);
    });

    test('reports both ABIs missing when there are no lib/ entries', () {
      expect(checkApkAbis(otherEntries), [
        const AbiProblem.missingAbi('arm64-v8a'),
        const AbiProblem.missingAbi('armeabi-v7a'),
      ]);
    });

    test('reports every problem, not only the first', () {
      final entries = [
        ...otherEntries,
        'lib/arm64-v8a/libapp.so',
        ...completeAbi('x86_64'),
        'lib/x86/libfoo.so',
      ];
      expect(checkApkAbis(entries), [
        const AbiProblem.unexpectedAbi('x86'),
        const AbiProblem.unexpectedAbi('x86_64'),
        const AbiProblem.missingAbi('armeabi-v7a'),
        const AbiProblem.missingLibrary('arm64-v8a', 'libflutter.so'),
      ]);
    });

    test('pins the expected ABIs and required libraries', () {
      expect(expectedAbis, {'arm64-v8a', 'armeabi-v7a'});
      expect(requiredLibraries, {'libflutter.so', 'libapp.so'});
    });
  });

  group('AbiProblem.message', () {
    test('describes an unexpected ABI', () {
      expect(
        const AbiProblem.unexpectedAbi('x86_64').message,
        'unexpected ABI directory lib/x86_64/',
      );
    });

    test('describes a missing ABI', () {
      expect(
        const AbiProblem.missingAbi('armeabi-v7a').message,
        'missing ABI directory lib/armeabi-v7a/',
      );
    });

    test('describes a missing library', () {
      expect(
        const AbiProblem.missingLibrary('arm64-v8a', 'libapp.so').message,
        'lib/arm64-v8a/ is missing libapp.so',
      );
    });
  });

  group('describeNativeLibraries', () {
    test('lists each ABI with its libraries, sorted', () {
      expect(
        describeNativeLibraries({
          'armeabi-v7a': {'libflutter.so', 'libapp.so'},
          'arm64-v8a': {'libflutter.so'},
        }),
        [
          'arm64-v8a: libflutter.so',
          'armeabi-v7a: libapp.so, libflutter.so',
        ],
      );
    });

    test('is empty when there are no native libraries', () {
      expect(describeNativeLibraries({}), isEmpty);
    });
  });
}
