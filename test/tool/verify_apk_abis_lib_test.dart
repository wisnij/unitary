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

/// Non-native entries present in every real app bundle, which the check must
/// ignore.  Includes a top-level `lib/` entry that is not a native library, to
/// show that the bundle root is not simply any path containing `lib/`.
const List<String> otherBundleEntries = [
  'BundleConfig.pb',
  'META-INF/MANIFEST.MF',
  'META-INF/UNITARY-.RSA',
  'base/dex/classes.dex',
  'base/manifest/AndroidManifest.xml',
  'base/root/META-INF/androidx.core_core.version',
];

/// The layout the release bundle is required to have: [validApk]'s native
/// libraries, moved under `base/`.
List<String> validBundle() => [
  ...otherBundleEntries,
  for (final entry in [
    ...completeAbi('arm64-v8a'),
    ...completeAbi('armeabi-v7a'),
  ])
    'base/$entry',
];

void main() {
  group('libraryRootFor', () {
    test('maps an APK to lib/', () {
      expect(libraryRootFor('build/app-release.apk'), apkLibraryRoot);
      expect(apkLibraryRoot, 'lib/');
    });

    test('maps a bundle to base/lib/', () {
      expect(libraryRootFor('unitary-1.0.0.aab'), bundleLibraryRoot);
      expect(bundleLibraryRoot, 'base/lib/');
    });

    test('ignores the case of the extension', () {
      expect(libraryRootFor('APP.APK'), apkLibraryRoot);
      expect(libraryRootFor('App.Aab'), bundleLibraryRoot);
    });

    test('returns null for any other file', () {
      expect(libraryRootFor('unitary-1.0.0.zip'), isNull);
      expect(libraryRootFor('app-release'), isNull);
      expect(libraryRootFor('apk'), isNull);
      expect(libraryRootFor('.aab/app.jar'), isNull);
    });
  });

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

  group('nativeLibraries with the bundle root', () {
    test('groups a bundle exactly as the APK root groups an APK', () {
      expect(
        nativeLibraries(validBundle(), root: bundleLibraryRoot),
        nativeLibraries(validApk()),
      );
    });

    test('ignores top-level lib/ entries', () {
      expect(
        nativeLibraries(['lib/x86_64/libfoo.so'], root: bundleLibraryRoot),
        isEmpty,
      );
    });

    test('ignores directory entries and files directly under base/lib/', () {
      expect(
        nativeLibraries([
          'base/lib/',
          'base/lib/x86_64/',
          'base/lib/stray.so',
        ], root: bundleLibraryRoot),
        isEmpty,
      );
    });
  });

  group('nativeLibraries with the default root', () {
    test('ignores bundle entries under base/lib/', () {
      expect(nativeLibraries(validBundle()), isEmpty);
    });
  });

  group('checkApkAbis with the bundle root', () {
    test('reports no problems for exactly the two complete ARM ABIs', () {
      expect(checkApkAbis(validBundle(), root: bundleLibraryRoot), isEmpty);
    });

    test('reports an x86_64 directory under base/lib/ as unexpected', () {
      expect(
        checkApkAbis([
          ...validBundle(),
          'base/lib/x86_64/libdatastore_shared_counter.so',
        ], root: bundleLibraryRoot),
        [const AbiProblem.unexpectedAbi('x86_64', root: bundleLibraryRoot)],
      );
    });

    test('reports a missing library under base/lib/', () {
      final entries = validBundle()..remove('base/lib/arm64-v8a/libflutter.so');
      expect(checkApkAbis(entries, root: bundleLibraryRoot), [
        const AbiProblem.missingLibrary(
          'arm64-v8a',
          'libflutter.so',
          root: bundleLibraryRoot,
        ),
      ]);
    });

    test('reports both ABIs missing when they are only at the APK root', () {
      expect(
        checkApkAbis([
          ...otherBundleEntries,
          ...completeAbi('arm64-v8a'),
          ...completeAbi('armeabi-v7a'),
        ], root: bundleLibraryRoot),
        [
          const AbiProblem.missingAbi('arm64-v8a', root: bundleLibraryRoot),
          const AbiProblem.missingAbi('armeabi-v7a', root: bundleLibraryRoot),
        ],
      );
    });
  });

  group('checkApkAbis with the default root', () {
    test('reports both ABIs missing for a bundle', () {
      expect(checkApkAbis(validBundle()), [
        const AbiProblem.missingAbi('arm64-v8a'),
        const AbiProblem.missingAbi('armeabi-v7a'),
      ]);
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

  group('AbiProblem.message with the bundle root', () {
    test('describes an unexpected ABI', () {
      expect(
        const AbiProblem.unexpectedAbi(
          'x86_64',
          root: bundleLibraryRoot,
        ).message,
        'unexpected ABI directory base/lib/x86_64/',
      );
    });

    test('describes a missing ABI', () {
      expect(
        const AbiProblem.missingAbi(
          'armeabi-v7a',
          root: bundleLibraryRoot,
        ).message,
        'missing ABI directory base/lib/armeabi-v7a/',
      );
    });

    test('describes a missing library', () {
      expect(
        const AbiProblem.missingLibrary(
          'arm64-v8a',
          'libapp.so',
          root: bundleLibraryRoot,
        ).message,
        'base/lib/arm64-v8a/ is missing libapp.so',
      );
    });
  });

  group('AbiProblem equality', () {
    test('distinguishes the same problem under different roots', () {
      expect(
        const AbiProblem.missingAbi('arm64-v8a'),
        isNot(
          const AbiProblem.missingAbi('arm64-v8a', root: bundleLibraryRoot),
        ),
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
