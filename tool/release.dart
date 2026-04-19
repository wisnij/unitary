#!/usr/bin/env dart

/// Release script for Unitary.
///
/// Usage:
///   `dart run tool/release.dart <major|minor|patch> [--dry-run]`
///   `dart run tool/release.dart changelog [--dry-run]`
///
/// The `changelog` subcommand regenerates the [Unreleased] section of
/// CHANGELOG.md from conventional commits since the last tag.  Each run
/// replaces the section wholesale.  If no commits produce changelog entries,
/// any existing [Unreleased] section is removed.
///
/// The `major`/`minor`/`patch` subcommands bump the version, then either
/// consume the existing [Unreleased] section (if present) or generate a
/// changelog entry from commits, update pubspec.yaml and CHANGELOG.md,
/// commit, and tag.
library;

import 'dart:io';
import 'release_lib.dart';

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final positional = args.where((a) => !a.startsWith('--')).toList();

  if (positional.length != 1 ||
      !['major', 'minor', 'patch', 'changelog'].contains(positional[0])) {
    stderr.writeln(
      'Usage: dart run tool/release.dart <major|minor|patch|changelog> [--dry-run]',
    );
    exit(1);
  }

  final subcommand = positional[0];

  if (subcommand == 'changelog') {
    _runChangelog(dryRun: dryRun);
    return;
  }

  _runRelease(BumpType.values.byName(subcommand), dryRun: dryRun);
}

void _runChangelog({required bool dryRun}) {
  // Read current version from pubspec.yaml to determine the last tag.
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
  final lastTag = 'v$currentVersion';

  // Get commits since last tag.
  final tagCheckResult = Process.runSync('git', ['tag', '-l', lastTag]);
  final hasLastTag = (tagCheckResult.stdout as String).trim().isNotEmpty;

  final logArgs = ['log', '--format=%H %s'];
  if (hasLastTag) {
    logArgs.add('$lastTag..HEAD');
  }
  final logResult = Process.runSync('git', logArgs);
  final logOutput = (logResult.stdout as String).trim();
  final logLines = logOutput.isEmpty ? <String>[] : logOutput.split('\n');

  final commits = <ParsedCommit>[];
  for (final line in logLines) {
    final commit = ParsedCommit.parse(line);
    if (commit != null) {
      commits.add(commit);
    }
  }

  final section = formatUnreleasedSection(commits);
  final linkRef = section != null
      ? formatUnreleasedLinkRef('$currentVersion')
      : null;

  final changelogFile = File('CHANGELOG.md');
  final changelogContent = changelogFile.existsSync()
      ? changelogFile.readAsStringSync()
      : null;
  final hasUnreleased =
      changelogContent != null &&
      extractUnreleasedBody(changelogContent) != null;

  if (dryRun) {
    stdout.writeln('Dry run: updating [Unreleased] section');
    stdout.writeln('Commits since $lastTag: ${commits.length}');
    stdout.writeln();
    if (section == null) {
      if (hasUnreleased) {
        stdout.writeln(
          'No changelog entries — would remove existing [Unreleased] section.',
        );
      } else {
        stdout.writeln(
          'No changelog entries and no [Unreleased] section — nothing to do.',
        );
      }
    } else {
      stdout.writeln(
        hasUnreleased
            ? 'Would replace [Unreleased] section:'
            : 'Would insert [Unreleased] section:',
      );
      stdout.writeln(section);
      stdout.writeln('Link reference:');
      stdout.writeln(linkRef);
    }
    return;
  }

  if (changelogContent == null) {
    if (section == null) {
      stdout.writeln(
        'No changelog entries and no CHANGELOG.md — nothing to do.',
      );
      exit(1);
    }
    changelogFile.writeAsStringSync(
      'Changelog\n'
      '=========\n'
      '\n'
      'All notable changes to this project will be documented in this file.\n'
      '\n'
      'The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),\n'
      'and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).\n',
    );
  }

  final currentContent = changelogFile.readAsStringSync();
  final String newContent;
  if (section == null) {
    newContent = removeUnreleasedSection(currentContent);
  } else {
    newContent = updateUnreleasedSection(currentContent, section, linkRef!);
  }

  if (newContent == currentContent) {
    stdout.writeln('No changes to CHANGELOG.md.');
    exit(1);
  } else {
    changelogFile.writeAsStringSync(newContent);
    if (section == null) {
      stdout.writeln('Removed [Unreleased] section from CHANGELOG.md.');
    } else {
      stdout.writeln('Updated [Unreleased] section in CHANGELOG.md.');
    }
  }
}

void _runRelease(BumpType bumpType, {required bool dryRun}) {
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

  // Read CHANGELOG.md and check for an [Unreleased] section.
  final changelogFile = File('CHANGELOG.md');
  final changelogContent = changelogFile.existsSync()
      ? changelogFile.readAsStringSync()
      : '';
  final unreleasedBody = extractUnreleasedBody(changelogContent);

  // Get commits since last tag (needed for fallback and dry-run output).
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

  final commits = <ParsedCommit>[];
  for (final line in logLines) {
    final commit = ParsedCommit.parse(line);
    if (commit != null) {
      commits.add(commit);
    }
  }

  // Generate changelog section: use [Unreleased] body if present, else commits.
  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final String changelogSection;
  if (unreleasedBody != null) {
    final heading = '[$newVersion] - $dateStr';
    changelogSection = '$heading\n${'-' * heading.length}\n\n$unreleasedBody\n';
  } else {
    changelogSection = formatChangelogSection(
      '$newVersion',
      '$currentVersion',
      dateStr,
      commits,
    );
  }

  final linkRef = formatLinkReference('$newVersion', '$currentVersion');

  // Dry-run mode: print what would happen and exit.
  if (dryRun) {
    stdout.writeln('Dry run: $currentVersion -> $newVersion');
    if (unreleasedBody != null) {
      stdout.writeln('Source: [Unreleased] section from CHANGELOG.md');
    } else {
      stdout.writeln('Commits since $lastTag: ${commits.length}');
    }
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

  // Update CHANGELOG.md: remove [Unreleased] section (if any), then insert
  // the new versioned section.
  final baseContent = unreleasedBody != null
      ? removeUnreleasedSection(changelogContent)
      : changelogContent;

  if (changelogFile.existsSync()) {
    changelogFile.writeAsStringSync(
      updateChangelog(baseContent, changelogSection, linkRef),
    );
  } else {
    changelogFile.writeAsStringSync(
      'Changelog\n'
      '=========\n'
      '\n'
      'All notable changes to this project will be documented in this file.\n'
      '\n'
      'The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),\n'
      'and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).\n'
      '\n'
      '$changelogSection',
    );
  }

  // Update pubspec.yaml.
  pubspecFile.writeAsStringSync(
    updatePubspecVersion(pubspecContent, '$newVersion'),
  );

  // Show summary and prompt.
  stdout.writeln('Release: $currentVersion -> $newVersion');
  if (unreleasedBody != null) {
    stdout.writeln('(Changelog entry from [Unreleased] section)');
  }
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
