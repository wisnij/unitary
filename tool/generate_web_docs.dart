#!/usr/bin/env dart

/// Generates the project site's pages.
///
/// Usage:
///   `dart run tool/generate_web_docs.dart [output-dir]`
///
/// Converts each Markdown document in `defaultWebDocs` into a standalone page
/// in the output directory (default `build/site`), and copies in the local
/// images those pages reference.  The directory's previous contents are
/// replaced.  CI runs this on every push and pull request, adds the web app
/// build under `app/`, and deploys the result from `main`; nothing generated
/// here is committed.
///
/// Run from the repository root: document paths are repository-relative.
library;

import 'dart:io';

import 'generate_web_docs_lib.dart';

void main(List<String> args) {
  if (args.length > 1 || args.any((a) => a.startsWith('-'))) {
    stderr.writeln('Usage: dart run tool/generate_web_docs.dart [output-dir]');
    exit(2);
  }
  final outputDir = args.isEmpty ? defaultOutputDir : args.single;

  try {
    final written = generateWebDocs(outputDir: outputDir);
    for (final path in written) {
      stdout.writeln('Wrote $outputDir/$path');
    }
  } on WebDocException catch (e) {
    stderr.writeln('error: ${e.message}');
    exit(1);
  }
}
