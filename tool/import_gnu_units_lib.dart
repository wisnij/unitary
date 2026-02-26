/// Core library for the import_gnu_units script.
///
/// Parses GNU Units definitions files and serializes the results to a
/// units-parsed.json map containing only importer-owned fields.
library;

/// Callback that returns the content of a file by path, or null if not found.
typedef FileReader = String? Function(String path);

/// Fixed settings used when evaluating conditionals.
const _unitsSystem = 'si';
const _unitsEnglish = 'US';
const _locale = 'en_US';

/// A single entry parsed from a GNU Units definitions file.
class GnuEntry {
  /// Primary unit identifier (e.g., 'm', 'kilo', 'foot').
  final String id;

  /// Entry type: 'primitive', 'derived', 'alias', 'prefix', or 'unsupported'.
  final String type;

  /// The expression text for the unit definition.
  final String definition;

  /// Full original source line before comment stripping.
  final String gnuUnitsSource;

  /// Source filename.
  final String filename;

  /// 1-based line number of the first line of this entry.
  final int lineNumber;

  /// True for dimensionless primitive units (e.g., radian).
  final bool isDimensionless;

  /// True if this entry belongs in the prefix namespace (source name ended with '-').
  final bool isPrefix;

  /// For alias entries: the target id this aliases.
  final String? target;

  /// For unsupported entries: reason code.
  final String? reason;

  const GnuEntry({
    required this.id,
    required this.type,
    required this.definition,
    required this.gnuUnitsSource,
    required this.filename,
    required this.lineNumber,
    required this.isDimensionless,
    this.isPrefix = false,
    required this.target,
    required this.reason,
  });
}

/// Parses a GNU Units definitions file and returns a list of entries.
///
/// Two-pass approach:
/// 1. First pass: collect all unit IDs and prefix IDs (respecting conditionals)
///    for alias detection.
/// 2. Second pass: classify entries using the first-pass ID sets.
///
/// [readFile] is an optional callback used to resolve `!include` directives.
/// It receives an absolute-or-relative path and should return the file content,
/// or null if the file cannot be read.  When omitted, `!include` directives are
/// silently ignored.
List<GnuEntry> parseGnuUnitsFile(
  String content,
  String filename, {
  FileReader? readFile,
}) {
  // Split into raw lines and process continuations.
  final rawLines = content.split('\n');

  // First pass: collect joined logical lines (with their start line numbers),
  // respecting conditionals, for ID collection.
  // Pass the root filename as the initial visited set so the root file cannot
  // be transitively re-included and cause a cycle.
  final logicalLines = _joinContinuations(
    rawLines,
    filename,
    readFile: readFile,
    visited: {filename},
  );
  final firstPassIds = _collectIds(logicalLines);
  final firstPassPrefixIds = _collectPrefixIds(logicalLines);

  // Second pass: classify entries.
  final entries = <GnuEntry>[];
  for (final logical in logicalLines) {
    final entry = _classifyLine(
      logical.text,
      logical.filename,
      logical.lineNumber,
      firstPassIds,
      firstPassPrefixIds,
    );
    if (entry != null) {
      entries.add(entry);
    }
  }

  return entries;
}

/// Represents a single logical (continuation-joined) line with metadata.
class _LogicalLine {
  /// The text ready for classification and use as gnuUnitsSource: inline
  /// comments stripped, leading/trailing whitespace trimmed, and all
  /// remaining whitespace runs normalized to a single space.
  final String text;

  /// 1-based line number of the first physical line.
  final int lineNumber;

  /// The file this line came from (may differ from the root file when lines
  /// are spliced in via `!include`).
  final String filename;

  _LogicalLine({
    required this.text,
    required this.lineNumber,
    required this.filename,
  });
}

/// Resolves an included filename relative to the directory of the base file.
///
/// If [includedFilename] is absolute (starts with '/') it is returned as-is.
/// Otherwise it is resolved relative to the directory part of [baseFilename].
String _resolveIncludePath(String baseFilename, String includedFilename) {
  if (includedFilename.startsWith('/')) {
    return includedFilename;
  }
  final lastSlash = baseFilename.lastIndexOf('/');
  if (lastSlash < 0) {
    return includedFilename;
  }
  return '${baseFilename.substring(0, lastSlash + 1)}$includedFilename';
}

/// Joins continuation lines, evaluates conditional directives, and returns
/// logical lines with their metadata.
///
/// [filename] is the path of the file being parsed; used to resolve relative
/// `!include` paths.  [readFile] provides file content for `!include` directives.
/// [visited] is the set of already-open file paths, used to break include cycles.
List<_LogicalLine> _joinContinuations(
  List<String> rawLines,
  String filename, {
  FileReader? readFile,
  Set<String> visited = const <String>{},
}) {
  final result = <_LogicalLine>[];

  // Conditional stack: each entry is whether that level is active.
  // A line is active only when all stack levels are true.
  final condStack = <bool>[];

  bool isActive() => condStack.every((b) => b);

  var i = 0;
  while (i < rawLines.length) {
    final startLine = i + 1; // 1-based
    // Join continuation lines.
    final physicalParts = <String>[];
    while (i < rawLines.length) {
      final raw = rawLines[i];
      i++;
      if (raw.endsWith('\\')) {
        physicalParts.add(raw.substring(0, raw.length - 1));
      } else {
        physicalParts.add(raw);
        break;
      }
    }
    final joined = physicalParts.join('');

    // Strip inline comments, trim, and normalize all internal whitespace
    // to a single space.  This normalized form is used for both parsing
    // (classification) and as the gnuUnitsSource stored in units.json.
    final commentIdx = joined.indexOf('#');
    final afterComment = commentIdx >= 0
        ? joined.substring(0, commentIdx)
        : joined;
    final text = afterComment.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Skip blank lines.
    if (text.isEmpty) {
      continue;
    }

    // Handle conditional and non-definition directives.
    if (text.startsWith('!')) {
      final parts = text.split(RegExp(r'\s+'));
      final directive = parts[0].toLowerCase();

      switch (directive) {
        case '!utf8':
          condStack.add(true); // UTF-8 is always enabled.
        case '!endutf8':
          if (condStack.isNotEmpty) {
            condStack.removeLast();
          }
        case '!locale':
          final localeArg = parts.length > 1 ? parts[1] : '';
          condStack.add(isActive() && localeArg == _locale);
        case '!endlocale':
          if (condStack.isNotEmpty) {
            condStack.removeLast();
          }
        case '!var':
          if (isActive() && parts.length >= 3) {
            final varName = parts[1].toUpperCase();
            final values = parts.sublist(2);
            final effectiveValue = _effectiveValue(varName);
            condStack.add(
              effectiveValue != null && values.contains(effectiveValue),
            );
          } else {
            condStack.add(false);
          }
        case '!varnot':
          if (isActive() && parts.length >= 3) {
            final varName = parts[1].toUpperCase();
            final values = parts.sublist(2);
            final effectiveValue = _effectiveValue(varName);
            condStack.add(
              effectiveValue != null && !values.contains(effectiveValue),
            );
          } else {
            condStack.add(false);
          }
        case '!endvar':
          if (condStack.isNotEmpty) {
            condStack.removeLast();
          }
        case '!include':
          // File inclusion: parse the named file and splice its logical lines
          // inline at this point, as if its contents appeared here.
          // Only processed when inside an active conditional block.
          if (isActive() && readFile != null && parts.length > 1) {
            final includePath = _resolveIncludePath(filename, parts[1]);
            if (!visited.contains(includePath)) {
              final includedContent = readFile(includePath);
              if (includedContent != null) {
                final includedLines = includedContent.split('\n');
                final includedLogical = _joinContinuations(
                  includedLines,
                  includePath,
                  readFile: readFile,
                  // Add includePath to visited so it cannot re-include itself or
                  // any ancestor file in the current include chain.
                  visited: {...visited, includePath},
                );
                result.addAll(includedLogical);
              }
            }
          }
        // Non-definition directives: !set, !message, !prompt, !include, etc.
        // These produce no entries.
        default:
          break;
      }
      continue;
    }

    // Skip if not in an active conditional block.
    if (isActive()) {
      result.add(
        _LogicalLine(
          text: text,
          lineNumber: startLine,
          filename: filename,
        ),
      );
    }
  }

  return result;
}

/// Returns the effective value for a variable name.
String? _effectiveValue(String varName) {
  switch (varName) {
    case 'UNITS_SYSTEM':
      return _unitsSystem;
    case 'UNITS_ENGLISH':
      return _unitsEnglish;
    default:
      return null;
  }
}

/// First pass: collect unit IDs from logical lines, excluding prefix entries.
///
/// Prefix symbols (e.g., 'm' from 'm-') must not appear in the alias-target
/// set because they share symbols with units (e.g., 'm' = meter). Only
/// non-prefix entries contribute IDs that can be alias targets.
Set<String> _collectIds(List<_LogicalLine> logicalLines) {
  final ids = <String>{};
  for (final line in logicalLines) {
    final text = line.text;
    if (text.isEmpty) {
      continue;
    }
    final spaceIdx = text.indexOf(RegExp(r'\s'));
    final nameToken = spaceIdx >= 0 ? text.substring(0, spaceIdx) : text;
    // Skip prefix entries (name ends with '-'); their stripped symbol must
    // not be used as an alias target to avoid cross-namespace collisions.
    if (nameToken.isEmpty || nameToken.endsWith('-')) {
      continue;
    }
    ids.add(nameToken);
  }
  return ids;
}

/// First pass: collect prefix IDs (stripped of trailing '-') from logical lines.
///
/// Used alongside [_collectIds] so that [_classifyLine] can detect prefix aliases:
/// a prefix-named entry (name ending in '-') whose definition is a single token
/// matching a known prefix ID is an alias rather than a new distinct prefix.
Set<String> _collectPrefixIds(List<_LogicalLine> logicalLines) {
  final ids = <String>{};
  for (final line in logicalLines) {
    final text = line.text;
    if (text.isEmpty) {
      continue;
    }
    final spaceIdx = text.indexOf(RegExp(r'\s'));
    final nameToken = spaceIdx >= 0 ? text.substring(0, spaceIdx) : text;
    if (nameToken.length <= 1 || !nameToken.endsWith('-')) {
      continue;
    }
    ids.add(nameToken.substring(0, nameToken.length - 1));
  }
  return ids;
}

/// Classifies a single logical line into a GnuEntry or null.
GnuEntry? _classifyLine(
  String text,
  String filename,
  int lineNumber,
  Set<String> knownIds,
  Set<String> knownPrefixIds,
) {
  if (text.isEmpty) {
    return null;
  }

  // Split into name token and the rest.
  final spaceIdx = text.indexOf(RegExp(r'\s'));
  if (spaceIdx < 0) {
    // Only a name token with no definition — skip.
    return null;
  }

  final nameToken = text.substring(0, spaceIdx);
  final definitionText = text.substring(spaceIdx).trim();

  if (nameToken.isEmpty || definitionText.isEmpty) {
    return null;
  }

  // Check for unsupported types first (by name token shape).
  if (nameToken.contains('(')) {
    return GnuEntry(
      id: nameToken,
      type: 'unsupported',
      definition: definitionText,
      gnuUnitsSource: text,
      filename: filename,
      lineNumber: lineNumber,
      isDimensionless: false,
      target: null,
      reason: 'nonlinear_definition',
    );
  }

  if (nameToken.contains('[')) {
    return GnuEntry(
      id: nameToken,
      type: 'unsupported',
      definition: definitionText,
      gnuUnitsSource: text,
      filename: filename,
      lineNumber: lineNumber,
      isDimensionless: false,
      target: null,
      reason: 'piecewise_linear',
    );
  }

  // Prefix: name ends with '-'.
  if (nameToken.endsWith('-')) {
    final id = nameToken.substring(0, nameToken.length - 1);
    // If the definition matches a known prefix id but NOT a known unit, it's a
    // prefix alias (e.g., 'k- kilo' where kilo is a known prefix).
    if (knownPrefixIds.contains(definitionText) &&
        !knownIds.contains(definitionText)) {
      return GnuEntry(
        id: id,
        type: 'alias',
        definition: definitionText,
        gnuUnitsSource: text,
        filename: filename,
        lineNumber: lineNumber,
        isDimensionless: false,
        isPrefix: true,
        target: definitionText,
        reason: null,
      );
    }
    return GnuEntry(
      id: id,
      type: 'prefix',
      definition: definitionText,
      gnuUnitsSource: text,
      filename: filename,
      lineNumber: lineNumber,
      isDimensionless: false,
      isPrefix: true,
      target: null,
      reason: null,
    );
  }

  // Primitive: definition is '!'.
  if (definitionText == '!') {
    return GnuEntry(
      id: nameToken,
      type: 'primitive',
      definition: '!',
      gnuUnitsSource: text,
      filename: filename,
      lineNumber: lineNumber,
      isDimensionless: false,
      target: null,
      reason: null,
    );
  }

  // Dimensionless primitive: definition is '!dimensionless'.
  if (definitionText == '!dimensionless') {
    return GnuEntry(
      id: nameToken,
      type: 'primitive',
      definition: '!dimensionless',
      gnuUnitsSource: text,
      filename: filename,
      lineNumber: lineNumber,
      isDimensionless: true,
      target: null,
      reason: null,
    );
  }

  // Alias detection: definition is a single bare identifier in known IDs.
  if (knownIds.contains(definitionText)) {
    return GnuEntry(
      id: nameToken,
      type: 'alias',
      definition: definitionText,
      gnuUnitsSource: text,
      filename: filename,
      lineNumber: lineNumber,
      isDimensionless: false,
      target: definitionText,
      reason: null,
    );
  }

  // Derived: everything else.
  return GnuEntry(
    id: nameToken,
    type: 'derived',
    definition: definitionText,
    gnuUnitsSource: text,
    filename: filename,
    lineNumber: lineNumber,
    isDimensionless: false,
    target: null,
    reason: null,
  );
}

/// Converts a list of parsed GNU Units entries into a JSON map with three
/// sections: `'units'`, `'prefixes'`, and `'unsupported'`.
///
/// Only importer-owned fields are included: `type`, `gnuUnitsSource`,
/// `source`, `definition` (for non-unsupported entries), `isDimensionless`
/// (for primitive entries), `target` (for alias entries), and `reason` (for
/// unsupported entries). No pass-through fields (description, aliases,
/// category) are included.
Map<String, dynamic> entriesToJson(List<GnuEntry> entries) {
  final units = <String, dynamic>{};
  final prefixes = <String, dynamic>{};
  final unsupported = <String, dynamic>{};

  for (final entry in entries) {
    final map = <String, dynamic>{
      'type': entry.type,
      'gnuUnitsSource': entry.gnuUnitsSource,
      'source': {'file': entry.filename, 'line': entry.lineNumber},
    };
    if (entry.type != 'unsupported') {
      map['definition'] = entry.definition;
    }
    if (entry.type == 'primitive') {
      map['isDimensionless'] = entry.isDimensionless;
    }
    if (entry.type == 'alias') {
      map['target'] = entry.target;
    }
    if (entry.type == 'unsupported') {
      map['reason'] = entry.reason;
    }

    // isPrefix is set by the parser for prefix-namespace entries (name ended
    // with '-'); fall back to type-based detection for hand-crafted GnuEntry
    // test fixtures that don't set isPrefix explicitly.
    final isPrefix = entry.isPrefix || entry.type == 'prefix';
    if (isPrefix) {
      prefixes[entry.id] = map;
    } else if (entry.type == 'unsupported') {
      unsupported[entry.id] = map;
    } else {
      units[entry.id] = map;
    }
  }

  return {'units': units, 'prefixes': prefixes, 'unsupported': unsupported};
}
