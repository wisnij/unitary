#!/usr/bin/env dart

/// Release APK and app bundle native-library layout check for Unitary.
///
/// Usage:
///   `dart run tool/verify_apk_abis.dart <apk-or-aab>`
///
/// Lists the archive's entries with `unzip -Z1` and exits non-zero unless its
/// native libraries are exactly the `arm64-v8a` and `armeabi-v7a` directories,
/// each holding `libflutter.so` and `libapp.so`.  The extension says where to
/// look: under `lib/` for an `.apk`, under `base/lib/` for an `.aab`.  Run on
/// both artifacts by both Android build jobs in CI, and usable against a local
/// build.
///
/// Exit codes: 0 when the layout is valid, 1 when it is not, and 2 for a usage
/// error, an unrecognised extension, or when the archive cannot be listed.
library;

import 'dart:io';

import 'verify_apk_abis_lib.dart';

const String _usage = '''
Usage: dart run tool/verify_apk_abis.dart <apk-or-aab>

Checks that the native libraries in an APK (under lib/) or an app bundle
(under base/lib/) are exactly the arm64-v8a and armeabi-v7a directories, each
containing libflutter.so and libapp.so.  The file's extension, .apk or .aab,
selects the format.
''';

void main(List<String> args) {
  if (args.length != 1 || args.first == '-h' || args.first == '--help') {
    _fail(_usage);
  }
  final archive = args.first;
  final root = libraryRootFor(archive);
  if (root == null) {
    _fail('Error: expected an .apk or .aab file: $archive\n\n$_usage');
  }
  if (!File(archive).existsSync()) {
    _fail('Error: no such file: $archive\n\n$_usage');
  }

  final ProcessResult listing;
  try {
    listing = Process.runSync('unzip', ['-Z1', archive]);
  } on ProcessException catch (e) {
    _fail('Error: could not run unzip: ${e.message}');
  }
  if (listing.exitCode != 0) {
    _fail(
      'Error: unzip -Z1 failed for $archive (exit ${listing.exitCode})\n'
      '${listing.stderr}',
    );
  }

  final entries = (listing.stdout as String)
      .split('\n')
      .map((line) => line.trimRight())
      .where((line) => line.isNotEmpty);
  final libraries = nativeLibraries(entries, root: root);
  final problems = checkApkAbis(entries, root: root);

  stdout.writeln('Native libraries under $root in $archive:');
  final description = describeNativeLibraries(libraries);
  if (description.isEmpty) {
    stdout.writeln('  (none)');
  }
  for (final line in description) {
    stdout.writeln('  $line');
  }

  if (problems.isEmpty) {
    stdout.writeln(
      'OK: exactly ${(expectedAbis.toList()..sort()).join(' and ')}, '
      'each with ${(requiredLibraries.toList()..sort()).join(' and ')}',
    );
    exit(0);
  }
  stderr.writeln('FAILED:');
  for (final problem in problems) {
    stderr.writeln('  ${problem.message}');
  }
  exit(1);
}

/// Prints [message] to stderr and exits with status 2.
Never _fail(String message) {
  stderr.write(message.endsWith('\n') ? message : '$message\n');
  exit(2);
}
