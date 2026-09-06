#!/usr/bin/env dart

/// Generates the HTML pages published with the web build.
///
/// Usage:
///   `dart run tool/generate_web_docs.dart`
///
/// Converts each Markdown document in `defaultWebDocs` into a standalone page
/// under `web/`, which `flutter build web` copies verbatim into `build/web`.
/// Generated pages are committed; the `generate-web-docs` pre-commit hook
/// keeps them in step with their sources, and the lint job runs the hooks over
/// all files, so a stale page fails the build.
///
/// Run from the repository root: document paths are repository-relative.
library;

import 'dart:io';

import 'generate_web_docs_lib.dart';

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln('Usage: dart run tool/generate_web_docs.dart');
    exit(2);
  }

  try {
    final written = generateWebDocs();
    if (written.isEmpty) {
      stdout.writeln('All web docs are up to date.');
    } else {
      for (final path in written) {
        stdout.writeln('Wrote $path');
      }
    }
  } on WebDocException catch (e) {
    stderr.writeln('error: ${e.message}');
    exit(1);
  }
}
