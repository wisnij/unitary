/// Core library for the release script.
///
/// Contains pure, testable logic for version management, commit parsing,
/// and changelog generation.
library;

enum BumpType { major, minor, patch }

class Version {
  final int major;
  final int minor;
  final int patch;

  Version(this.major, this.minor, this.patch);

  /// Parses a version string like "1.2.3" or "1.2.3+4" (build suffix is stripped).
  factory Version.parse(String input) {
    // Strip +build suffix if present.
    final plusIndex = input.indexOf('+');
    final versionPart = plusIndex >= 0 ? input.substring(0, plusIndex) : input;

    final parts = versionPart.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid version format: "$input"');
    }

    final parsed = <int>[];
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0) {
        throw FormatException('Invalid version component: "$part" in "$input"');
      }
      parsed.add(n);
    }

    return Version(parsed[0], parsed[1], parsed[2]);
  }

  Version bump(BumpType type) {
    switch (type) {
      case BumpType.major:
        return Version(major + 1, 0, 0);
      case BumpType.minor:
        return Version(major, minor + 1, 0);
      case BumpType.patch:
        return Version(major, minor, patch + 1);
    }
  }

  @override
  String toString() => '$major.$minor.$patch';

  @override
  bool operator ==(Object other) =>
      other is Version &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);
}

class ParsedCommit {
  final String hash;
  final String type;
  final String? scope;
  final String message;

  ParsedCommit({
    required this.hash,
    required this.type,
    this.scope,
    required this.message,
  });

  static const _knownTypes = {
    'feat',
    'fix',
    'refactor',
    'perf',
    'docs',
    'test',
    'chore',
    'build',
    'ci',
    'style',
  };

  static final _conventionalPattern = RegExp(r'^(\w+)(?:\(([^)]+)\))?:\s*(.*)');

  /// Parses a git log line in the format `<hash> <subject>`.
  /// Returns null for merge commits.
  static ParsedCommit? parse(String line) {
    final spaceIndex = line.indexOf(' ');
    if (spaceIndex < 0) {
      return null;
    }

    final hash = line.substring(0, spaceIndex);
    final subject = line.substring(spaceIndex + 1);

    // Skip merge commits.
    if (subject.startsWith('Merge ')) {
      return null;
    }

    final match = _conventionalPattern.firstMatch(subject);
    if (match != null) {
      final prefix = match.group(1)!;
      if (_knownTypes.contains(prefix)) {
        return ParsedCommit(
          hash: hash,
          type: prefix,
          scope: match.group(2),
          message: match.group(3)!.trim(),
        );
      }
    }

    return ParsedCommit(hash: hash, type: 'other', message: subject.trim());
  }

  static const _sectionMapping = {
    'feat': 'Added',
    'fix': 'Fixed',
    'refactor': 'Changed',
    'perf': 'Changed',
    'docs': 'Documentation',
    'other': 'Other',
  };

  /// Returns the changelog section name, or null if this commit type should
  /// be omitted from the changelog (`test`, `chore`, `build`, `ci`, `style`).
  String? get changelogSection => _sectionMapping[type];
}

/// Section display order for changelog output.
const _sectionOrder = ['Added', 'Changed', 'Fixed', 'Documentation', 'Other'];

const _repoUrl = 'https://github.com/wisnij/unitary';

/// Formats a changelog section for the given version, date, and commits.
String formatChangelogSection(
  String version,
  String previousVersion,
  String date,
  List<ParsedCommit> commits,
) {
  final sections = <String, List<String>>{};

  for (final commit in commits) {
    final section = commit.changelogSection;
    if (section == null) {
      continue;
    }
    sections.putIfAbsent(section, () => []).add(commit.message);
  }

  final buffer = StringBuffer();
  final heading = '[$version] - $date';
  buffer.writeln(heading);
  buffer.writeln('-' * heading.length);

  for (final section in _sectionOrder) {
    final entries = sections[section];
    if (entries == null || entries.isEmpty) {
      continue;
    }
    buffer.writeln();
    buffer.writeln('### $section');
    buffer.writeln();
    for (final entry in entries) {
      buffer.writeln('- $entry');
    }
  }

  return buffer.toString();
}

/// Formats a link reference definition for the given version.
String formatLinkReference(String version, String previousVersion) {
  return '[$version]: $_repoUrl/compare/v$previousVersion...v$version';
}

/// Formats the tag message for an annotated git tag.
///
/// Includes the version as the first line, followed by a blank line and
/// the changelog section body (everything after the heading and dashes).
String formatTagMessage(String version, String changelogSection) {
  final lines = changelogSection.split('\n');

  // Skip the heading line and the dashes line.
  var bodyStart = 0;
  for (var i = 0; i < lines.length; i++) {
    if (RegExp(r'^-+\s*$').hasMatch(lines[i])) {
      bodyStart = i + 1;
      break;
    }
  }

  // Skip leading blank lines in the body.
  while (bodyStart < lines.length && lines[bodyStart].trim().isEmpty) {
    bodyStart++;
  }

  // Trim trailing blank lines.
  var bodyEnd = lines.length;
  while (bodyEnd > bodyStart && lines[bodyEnd - 1].trim().isEmpty) {
    bodyEnd--;
  }

  final body = lines.sublist(bodyStart, bodyEnd).join('\n');
  if (body.isEmpty) {
    return 'Release v$version';
  }
  return 'Release v$version\n\n$body';
}

/// Replaces the version line in pubspec.yaml content.
/// Handles versions with or without +build suffixes.
String updatePubspecVersion(String content, String newVersion) {
  final pattern = RegExp(r'^version:\s*\S+', multiLine: true);
  if (!pattern.hasMatch(content)) {
    throw StateError('No version line found in pubspec.yaml');
  }
  return content.replaceFirst(pattern, 'version: $newVersion');
}

/// Inserts a new version section into the changelog after the file header.
///
/// The header is everything up to and including the first blank line after
/// the introductory text (the line following the "Semantic Versioning" link
/// or the first double-newline after content).
///
/// If [newLinkRef] is provided, it is inserted before the existing link
/// reference block at the end of the file (or appended with a blank line
/// separator if no link reference block exists yet).
String updateChangelog(
  String content,
  String newSection, [
  String? newLinkRef,
]) {
  // Find the insertion point: after the header block.
  // The header ends at the first blank line that follows at least one
  // non-blank line of content.
  final lines = content.split('\n');
  var insertIndex = 0;
  var foundContent = false;

  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim().isNotEmpty) {
      foundContent = true;
    } else if (foundContent) {
      // First blank line after content — check if we're past the header.
      // The header ends after the "Semantic Versioning" paragraph or after
      // two consecutive blank-ish regions.
      // Simple heuristic: look for a blank line that's followed by either
      // EOF or a version heading (atx ## or setext ---).
      final remaining = lines.skip(i + 1).join('\n').trim();
      if (remaining.isEmpty ||
          remaining.startsWith('## ') ||
          _startsWithSetextH2(remaining)) {
        insertIndex = i + 1;
        break;
      }
      // Otherwise keep scanning (we're still in the header).
    }
  }

  // If we never found the insertion point, append after all content.
  if (insertIndex == 0) {
    insertIndex = lines.length;
  }

  final before = lines.sublist(0, insertIndex).join('\n');
  final after = lines.sublist(insertIndex).join('\n');

  var result = '$before\n\n$newSection\n$after';

  if (newLinkRef != null) {
    final resultLines = result.split('\n');
    final linkRefPattern = RegExp(r'^\[[\d.]+\]:');

    var linkRefIndex = -1;
    for (var i = 0; i < resultLines.length; i++) {
      if (linkRefPattern.hasMatch(resultLines[i])) {
        linkRefIndex = i;
        break;
      }
    }

    if (linkRefIndex >= 0) {
      resultLines.insert(linkRefIndex, newLinkRef);
      result = resultLines.join('\n');
    } else {
      result = '$result\n$newLinkRef\n';
    }
  }

  return result;
}

/// Returns true if the text starts with a setext-style h2 heading
/// (a non-blank line followed by a line of dashes).
bool _startsWithSetextH2(String text) {
  final lines = text.split('\n');
  return lines.length >= 2 &&
      lines[0].trim().isNotEmpty &&
      RegExp(r'^-+\s*$').hasMatch(lines[1]);
}

/// Returns the line index of the `[Unreleased]` setext heading in [lines],
/// or -1 if not present.
int _findUnreleasedHeading(List<String> lines) {
  for (var i = 0; i < lines.length - 1; i++) {
    if (lines[i] == '[Unreleased]' &&
        RegExp(r'^-+\s*$').hasMatch(lines[i + 1])) {
      return i;
    }
  }
  return -1;
}

/// Returns the line index of the first setext h2 heading at or after
/// [fromIndex], or [lines.length] if none is found.
int _findNextSectionStart(List<String> lines, int fromIndex) {
  for (var i = fromIndex; i < lines.length - 1; i++) {
    if (lines[i].trim().isNotEmpty &&
        RegExp(r'^-+\s*$').hasMatch(lines[i + 1])) {
      return i;
    }
  }
  return lines.length;
}

/// Formats an `[Unreleased]` changelog section from [commits].
///
/// Returns null if no commits produce any changelog entries (i.e. all commits
/// are of omitted types such as `test`, `chore`, `build`, `ci`, or `style`).
String? formatUnreleasedSection(List<ParsedCommit> commits) {
  final sections = <String, List<String>>{};

  for (final commit in commits) {
    final section = commit.changelogSection;
    if (section == null) {
      continue;
    }
    sections.putIfAbsent(section, () => []).add(commit.message);
  }

  if (sections.isEmpty) {
    return null;
  }

  const heading = '[Unreleased]';
  final buffer = StringBuffer();
  buffer.writeln(heading);
  buffer.writeln('-' * heading.length);

  for (final section in _sectionOrder) {
    final entries = sections[section];
    if (entries == null || entries.isEmpty) {
      continue;
    }
    buffer.writeln();
    buffer.writeln('### $section');
    buffer.writeln();
    for (final entry in entries) {
      buffer.writeln('- $entry');
    }
  }

  return buffer.toString();
}

/// Formats the `[Unreleased]` link reference definition pointing to [lastTag].
String formatUnreleasedLinkRef(String lastTag) {
  return '[Unreleased]: $_repoUrl/compare/v$lastTag...HEAD';
}

/// Extracts the body of the `[Unreleased]` section from [changelog].
///
/// Returns the body text (the content after the heading and dashes lines),
/// with leading and trailing blank lines stripped. Returns null if the
/// `[Unreleased]` section is absent or has an empty body.
String? extractUnreleasedBody(String changelog) {
  final lines = changelog.split('\n');
  final headingIndex = _findUnreleasedHeading(lines);
  if (headingIndex < 0) {
    return null;
  }

  final bodyStart = headingIndex + 2;
  var bodyEnd = _findNextSectionStart(lines, bodyStart);

  // Trim trailing blank lines.
  while (bodyEnd > bodyStart && lines[bodyEnd - 1].trim().isEmpty) {
    bodyEnd--;
  }

  // Trim leading blank lines.
  var actualStart = bodyStart;
  while (actualStart < bodyEnd && lines[actualStart].trim().isEmpty) {
    actualStart++;
  }

  if (actualStart >= bodyEnd) {
    return null;
  }

  return lines.sublist(actualStart, bodyEnd).join('\n');
}

/// Inserts or replaces the `[Unreleased]` section and its link reference in
/// [changelog].
///
/// If an `[Unreleased]` section is already present it is removed first, then
/// the new [section] is inserted at the top of the entry list (immediately
/// after the file header). The [linkRef] is inserted before the first
/// versioned link reference, or appended if none exist.
String updateUnreleasedSection(
  String changelog,
  String section,
  String linkRef,
) {
  // Remove any existing [Unreleased] section (and its link ref) first,
  // then re-insert fresh — this handles both insert and replace uniformly.
  var result = removeUnreleasedSection(changelog);

  // Find the insertion point: after the header block (same heuristic as
  // updateChangelog).
  final lines = result.split('\n');
  var insertIndex = 0;
  var foundContent = false;

  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim().isNotEmpty) {
      foundContent = true;
    } else if (foundContent) {
      final remaining = lines.skip(i + 1).join('\n').trim();
      if (remaining.isEmpty ||
          remaining.startsWith('## ') ||
          _startsWithSetextH2(remaining)) {
        insertIndex = i + 1;
        break;
      }
    }
  }

  if (insertIndex == 0) {
    insertIndex = lines.length;
  }

  final before = lines.sublist(0, insertIndex).join('\n');
  final after = lines.sublist(insertIndex).join('\n');
  result = '$before\n\n$section\n$after';

  // Insert [Unreleased]: link reference before existing versioned link refs,
  // or append it if none exist.
  final resultLines = result.split('\n');
  final versionedLinkPattern = RegExp(r'^\[[\d.]+\]:');
  var versionedLinkIndex = -1;
  for (var i = 0; i < resultLines.length; i++) {
    if (versionedLinkPattern.hasMatch(resultLines[i])) {
      versionedLinkIndex = i;
      break;
    }
  }

  if (versionedLinkIndex >= 0) {
    resultLines.insert(versionedLinkIndex, linkRef);
    return resultLines.join('\n');
  } else {
    return '$result\n$linkRef\n';
  }
}

/// Removes the `[Unreleased]` section and its link reference from [changelog].
///
/// Returns [changelog] unchanged if no `[Unreleased]` section is present.
String removeUnreleasedSection(String changelog) {
  var lines = changelog.split('\n');
  final headingIndex = _findUnreleasedHeading(lines);

  if (headingIndex >= 0) {
    final bodyStart = headingIndex + 2;
    final nextSectionIndex = _findNextSectionStart(lines, bodyStart);
    lines = [
      ...lines.sublist(0, headingIndex),
      ...lines.sublist(nextSectionIndex),
    ];
  }

  // Remove [Unreleased]: link reference line.
  lines = lines.where((l) => !RegExp(r'^\[Unreleased\]:').hasMatch(l)).toList();

  return lines.join('\n');
}
