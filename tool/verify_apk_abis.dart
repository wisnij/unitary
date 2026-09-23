#!/usr/bin/env dart

/// Release APK native-library layout check for Unitary.
///
/// Usage:
///   `dart run tool/verify_apk_abis.dart <apk>`
///
/// Lists the APK's entries with `unzip -Z1` and exits non-zero unless its
/// native libraries are exactly the `arm64-v8a` and `armeabi-v7a` directories,
/// each holding `libflutter.so` and `libapp.so`.  Run by both APK build jobs in
/// CI, and usable against a local build.
///
/// Exit codes: 0 when the layout is valid, 1 when it is not, and 2 for a usage
/// error or when the APK cannot be listed.
library;

import 'dart:io';

import 'verify_apk_abis_lib.dart';

const String _usage = '''
Usage: dart run tool/verify_apk_abis.dart <apk>

Checks that the APK's native libraries are exactly the arm64-v8a and
armeabi-v7a directories, each containing libflutter.so and libapp.so.
''';

void main(List<String> args) {
  if (args.length != 1 || args.first == '-h' || args.first == '--help') {
    _fail(_usage);
  }
  final apk = args.first;
  if (!File(apk).existsSync()) {
    _fail('Error: no such file: $apk\n\n$_usage');
  }

  final ProcessResult listing;
  try {
    listing = Process.runSync('unzip', ['-Z1', apk]);
  } on ProcessException catch (e) {
    _fail('Error: could not run unzip: ${e.message}');
  }
  if (listing.exitCode != 0) {
    _fail(
      'Error: unzip -Z1 failed for $apk (exit ${listing.exitCode})\n'
      '${listing.stderr}',
    );
  }

  final entries = (listing.stdout as String)
      .split('\n')
      .map((line) => line.trimRight())
      .where((line) => line.isNotEmpty);
  final libraries = nativeLibraries(entries);
  final problems = checkApkAbis(entries);

  stdout.writeln('Native libraries in $apk:');
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
