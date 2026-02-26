#!/usr/bin/env dart

/// Reads tool/gnu_units/definitions.units and writes
/// lib/core/domain/data/units-parsed.json with importer-owned fields only.
library;

import 'dart:convert';
import 'dart:io';

import 'import_gnu_units_lib.dart';

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final repoRoot = scriptDir.parent;

  final definitionsFile = File(
    '${scriptDir.path}/gnu_units/definitions.units',
  );
  if (!definitionsFile.existsSync()) {
    stderr.writeln('Error: ${definitionsFile.path} not found.');
    stderr.writeln(
      'Place the GNU Units definitions.units file in tool/gnu_units/',
    );
    exit(1);
  }

  final definitionsContent = definitionsFile.readAsStringSync();
  final newEntries = parseGnuUnitsFile(
    definitionsContent,
    definitionsFile.path,
    readFile: (path) {
      final file = File(path);
      if (!file.existsSync()) {
        return null;
      }
      return file.readAsStringSync();
    },
  );

  stdout.writeln(
    'Parsed ${newEntries.length} entries from ${definitionsFile.path}',
  );

  final parsed = entriesToJson(newEntries);

  const encoder = JsonEncoder.withIndent('  ');

  final parsedFile = File(
    '${repoRoot.path}/lib/core/domain/data/units-parsed.json',
  );
  parsedFile.writeAsStringSync('${encoder.convert(parsed)}\n');
  final unitCount = (parsed['units'] as Map).length;
  final prefixCount = (parsed['prefixes'] as Map).length;
  final unsupportedCount = (parsed['unsupported'] as Map).length;
  stdout.writeln(
    'Wrote $unitCount units, $prefixCount prefixes, '
    '$unsupportedCount unsupported to ${parsedFile.path}',
  );
}
