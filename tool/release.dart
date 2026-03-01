#!/usr/bin/env dart

/// Release script for Unitary.
///
/// Usage: `dart run tool/release.dart <major|minor|patch> [--dry-run]`
///
/// Bumps the version, generates a changelog entry from conventional commits,
/// updates pubspec.yaml and CHANGELOG.md, commits, and tags.
library;

import 'dart:io';
import 'release_lib.dart';

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final positional = args.where((a) => !a.startsWith('--')).toList();

  if (positional.length != 1 ||
      !['major', 'minor', 'patch'].contains(positional[0])) {
    stderr.writeln(
      'Usage: dart run tool/release.dart <major|minor|patch> [--dry-run]',
    );
    exit(1);
  }

  final bumpType = BumpType.values.byName(positional[0]);

  if (!dryRun) {
    // Verify working tree is clean.
    final diffResult = Process.runSync('git', ['diff', '--quiet']);
    final diffCachedResult = Process.runSync('git', [
      'diff',
      '--cached',
      '--quiet',
    ]);
    if (diffResult.exitCode != 0 || diffCachedResult.exitCode != 0) {
      stderr.writeln(
        'Error: Working tree is not clean. Commit or stash changes first.',
      );
      exit(1);
    }

    // Warn if not on main branch.
    final branchResult = Process.runSync('git', ['branch', '--show-current']);
    final currentBranch = (branchResult.stdout as String).trim();
    if (currentBranch != 'main') {
      stderr.writeln(
        'Warning: Not on main branch (currently on "$currentBranch").',
      );
    }
  }

  // Read current version from pubspec.yaml.
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Error: pubspec.yaml not found.');
    exit(1);
  }
  final pubspecContent = pubspecFile.readAsStringSync();
  final versionMatch = RegExp(
    r'^version:\s*(\S+)',
    multiLine: true,
  ).firstMatch(pubspecContent);
  if (versionMatch == null) {
    stderr.writeln('Error: No version line found in pubspec.yaml.');
    exit(1);
  }
  final currentVersion = Version.parse(versionMatch.group(1)!);
  final newVersion = currentVersion.bump(bumpType);

  // Get commits since last tag.
  final lastTag = 'v$currentVersion';
  final tagCheckResult = Process.runSync('git', ['tag', '-l', lastTag]);
  final hasLastTag = (tagCheckResult.stdout as String).trim().isNotEmpty;

  final logArgs = ['log', '--format=%H %s'];
  if (hasLastTag) {
    logArgs.add('$lastTag..HEAD');
  }
  final logResult = Process.runSync('git', logArgs);
  final logOutput = (logResult.stdout as String).trim();
  final logLines = logOutput.isEmpty ? <String>[] : logOutput.split('\n');

  // Parse commits.
  final commits = <ParsedCommit>[];
  for (final line in logLines) {
    final commit = ParsedCommit.parse(line);
    if (commit != null) {
      commits.add(commit);
    }
  }

  // Generate changelog section.
  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  final changelogSection = formatChangelogSection(
    '$newVersion',
    '$currentVersion',
    dateStr,
    commits,
  );
  final linkRef = formatLinkReference('$newVersion', '$currentVersion');

  // Dry-run mode: print what would happen and exit.
  if (dryRun) {
    stdout.writeln('Dry run: $currentVersion -> $newVersion');
    stdout.writeln('Commits since $lastTag: ${commits.length}');
    stdout.writeln();
    stdout.writeln('Changelog entry:');
    stdout.writeln(changelogSection);
    stdout.writeln('Link reference:');
    stdout.writeln(linkRef);
    stdout.writeln();
    stdout.writeln('Would update pubspec.yaml and CHANGELOG.md');
    stdout.writeln('Would commit and tag as v$newVersion');
    return;
  }

  // Update CHANGELOG.md.
  final changelogFile = File('CHANGELOG.md');
  if (changelogFile.existsSync()) {
    final changelogContent = changelogFile.readAsStringSync();
    changelogFile.writeAsStringSync(
      updateChangelog(changelogContent, changelogSection, linkRef),
    );
  } else {
    changelogFile.writeAsStringSync('''# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

$changelogSection''');
  }

  // Update pubspec.yaml.
  pubspecFile.writeAsStringSync(
    updatePubspecVersion(pubspecContent, '$newVersion'),
  );

  // Show summary and prompt.
  stdout.writeln('Release: $currentVersion -> $newVersion');
  stdout.writeln();
  stdout.writeln('Changelog entry:');
  stdout.writeln(changelogSection);
  stdout.write('Proceed with commit and tag? [y/N] ');
  final answer = stdin.readLineSync()?.trim().toLowerCase();
  if (answer != 'y') {
    stdout.writeln('Aborted.');
    return;
  }

  // Commit and tag.
  Process.runSync('git', ['add', 'CHANGELOG.md', 'pubspec.yaml']);
  final commitResult = Process.runSync('git', [
    'commit',
    '-m',
    'release: v$newVersion',
  ]);
  if (commitResult.exitCode != 0) {
    stderr.writeln('Error: git commit failed.');
    stderr.writeln(commitResult.stderr);
    exit(1);
  }

  final tagMessage = formatTagMessage('$newVersion', changelogSection);
  final tagResult = Process.runSync('git', [
    'tag',
    '-a',
    'v$newVersion',
    '-m',
    tagMessage,
    '--cleanup=whitespace',
  ]);
  if (tagResult.exitCode != 0) {
    stderr.writeln('Error: git tag failed.');
    stderr.writeln(tagResult.stderr);
    exit(1);
  }

  stdout.writeln();
  stdout.writeln('Successfully released v$newVersion');
  stdout.writeln('Run: git push && git push --tags');
}
