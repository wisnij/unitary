#!/usr/bin/env dart

/// Reads lib/core/domain/data/units-parsed.json and
/// lib/core/domain/data/units-supplementary.json, merges them into
/// lib/core/domain/data/units.json, then generates
/// lib/core/domain/data/builtin_units.dart.
library;

import 'dart:convert';
import 'dart:io';

import 'generate_builtin_units_lib.dart';

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final repoRoot = scriptDir.parent;
  final dataDir = '${repoRoot.path}/lib/core/domain/data';

  // Read units-parsed.json (required).
  final parsedFile = File('$dataDir/units-parsed.json');
  if (!parsedFile.existsSync()) {
    stderr.writeln('Error: ${parsedFile.path} not found.');
    stderr.writeln(
      'Run `dart run tool/import_gnu_units.dart` to generate it.',
    );
    exit(1);
  }
  final parsed =
      jsonDecode(parsedFile.readAsStringSync()) as Map<String, dynamic>;

  // Read units-supplementary.json (optional; empty structure if missing).
  final suppFile = File('$dataDir/units-supplementary.json');
  final supplementary = suppFile.existsSync()
      ? jsonDecode(suppFile.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};

  // Merge parsed + supplementary → units.json.
  final merged = mergeSupplementary(parsed, supplementary);

  const encoder = JsonEncoder.withIndent('  ');

  final jsonFile = File('$dataDir/units.json');
  jsonFile.writeAsStringSync('${encoder.convert(merged)}\n');
  final unitCount = (merged['units'] as Map).length;
  final prefixCount = (merged['prefixes'] as Map).length;
  final unsupportedCount = (merged['unsupported'] as Map? ?? {}).length;
  stdout.writeln(
    'Wrote $unitCount units, $prefixCount prefixes, '
    '$unsupportedCount unsupported to ${jsonFile.path}',
  );

  // Generate builtin_units.dart from merged map.
  final dartCode = generateDartCode(merged);

  final outputFile = File('$dataDir/builtin_units.dart');
  outputFile.writeAsStringSync(dartCode);
  stdout.writeln('Wrote ${outputFile.path}');

  // Run dart format on the output file.
  final formatResult = Process.runSync(
    'dart',
    ['format', outputFile.path],
  );
  if (formatResult.exitCode != 0) {
    stderr.writeln('dart format failed:');
    stderr.writeln(formatResult.stderr);
    exit(formatResult.exitCode);
  }
  stdout.writeln('Formatted ${outputFile.path}');
}
