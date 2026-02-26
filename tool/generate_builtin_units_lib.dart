/// Core library for the generate_builtin_units script.
///
/// Reads a units-parsed.json map and a units-supplementary.json map,
/// merges them into a units.json map, and produces a valid builtin_units.dart
/// source string with const Dart unit objects.
library;

/// Recursively merges [supplementary] into [base].
///
/// Maps are merged key-by-key recursively. All other values (strings, numbers,
/// booleans, lists, null) use [supplementary]'s value verbatim — supplementary
/// wins on conflict.
dynamic recursiveMerge(dynamic base, dynamic supplementary) {
  if (base is Map && supplementary is Map) {
    final result = Map<String, dynamic>.from(base);
    for (final entry in supplementary.entries) {
      final key = entry.key as String;
      result[key] = result.containsKey(key)
          ? recursiveMerge(result[key], entry.value)
          : entry.value;
    }
    return result;
  }
  return supplementary;
}

/// Merges [supplementary] into [parsed] using [recursiveMerge].
///
/// Both maps must use the three-section format (`'units'`, `'prefixes'`,
/// `'unsupported'`). Supplementary fields overlay parsed fields where both
/// exist; supplementary-only sections and entries are added as-is.
Map<String, dynamic> mergeSupplementary(
  Map<String, dynamic> parsed,
  Map<String, dynamic> supplementary,
) => recursiveMerge(parsed, supplementary) as Map<String, dynamic>;

/// Resolves alias chains within each namespace independently.
///
/// Returns `(unitAliases, prefixAliases)` where each map is
/// canonical_id -> extra aliases from alias entries in that namespace.
/// Each namespace is resolved using only its own id→entry map, so an id
/// that exists in both (e.g. 'm' for meter in units and milli in prefixes)
/// is never confused across namespaces.
///
/// Aliases already listed as base aliases of a canonical entry in the same
/// namespace are excluded to avoid double-registration.
(Map<String, List<String>>, Map<String, List<String>>) resolveAliasChains(
  Map<String, dynamic> unitsJson,
) {
  final rawUnits = unitsJson['units'];
  final unitsSection = rawUnits == null
      ? <String, dynamic>{}
      : Map<String, dynamic>.from(rawUnits as Map);
  final rawPrefixes = unitsJson['prefixes'];
  final prefixesSection = rawPrefixes == null
      ? <String, dynamic>{}
      : Map<String, dynamic>.from(rawPrefixes as Map);

  return (
    _resolveNamespaceAliases(unitsSection),
    _resolveNamespaceAliases(prefixesSection),
  );
}

/// Resolves alias chains within a single namespace (units or prefixes).
///
/// Returns canonical_id -> extra aliases derived from alias-type entries that
/// are not already listed in that canonical entry's own `'aliases'` field.
Map<String, List<String>> _resolveNamespaceAliases(
  Map<String, dynamic> section,
) {
  // Build id -> entry lookup restricted to this namespace only.
  final byId = <String, Map<String, dynamic>>{};
  for (final entry in section.entries) {
    byId[entry.key] = Map<String, dynamic>.from(entry.value as Map);
  }

  // Collect base aliases claimed by canonical (non-alias) entries.
  // These are skipped below to avoid double-registration.
  final claimedBaseAliases = <String>{};
  for (final entry in section.entries) {
    final data = byId[entry.key]!;
    if ((data['type'] as String?) == 'alias') {
      continue;
    }
    final aliases = (data['aliases'] as List<dynamic>?)?.cast<String>();
    if (aliases != null) {
      claimedBaseAliases.addAll(aliases);
    }
  }

  final result = <String, List<String>>{};
  for (final entry in section.entries) {
    final aliasId = entry.key;
    final data = byId[aliasId]!;
    if ((data['type'] as String?) != 'alias') {
      continue;
    }

    // Skip aliases already claimed as base aliases of a canonical entry.
    if (claimedBaseAliases.contains(aliasId)) {
      continue;
    }

    var target = data['target'] as String?;

    // Walk chain: follow targets until a non-alias canonical entry is found.
    final seen = <String>{aliasId};
    while (target != null) {
      final targetEntry = byId[target];
      if (targetEntry == null) {
        break;
      }
      if ((targetEntry['type'] as String?) != 'alias') {
        // Found the canonical entry in this namespace.
        result.putIfAbsent(target, () => []).add(aliasId);
        break;
      }
      if (!seen.add(target)) {
        // cycle guard
        break;
      }
      target = targetEntry['target'] as String?;
    }
  }

  return result;
}

/// Generates builtin_units.dart source from a units JSON map.
///
/// [unitsJson] must have three sections: `'units'`, `'prefixes'`,
/// `'unsupported'`. Each section maps unit id to entry data (no `id` field
/// inside the entry body).
String generateDartCode(Map<String, dynamic> unitsJson) {
  // Resolve alias chains within each namespace independently.
  final (extraUnitAliases, extraPrefixAliases) = resolveAliasChains(unitsJson);

  final rawUnits = unitsJson['units'];
  final unitsSection = rawUnits == null
      ? <String, dynamic>{}
      : Map<String, dynamic>.from(rawUnits as Map);
  final rawPrefixes = unitsJson['prefixes'];
  final prefixesSection = rawPrefixes == null
      ? <String, dynamic>{}
      : Map<String, dynamic>.from(rawPrefixes as Map);

  // Build namespace-specific sets of IDs that appear as base aliases on
  // canonical entries. Such IDs must be skipped during emission to avoid
  // double-registration: they are already registered as aliases of their
  // canonical unit.  Prefix and unit namespaces are kept separate so that
  // a prefix alias (e.g. 'm' for milli) does not suppress a unit with the
  // same id (e.g. 'm' for meter).
  final unitClaimedBaseAliasIds = <String>{};
  for (final entry in unitsSection.entries) {
    final data = entry.value as Map<String, dynamic>;
    if ((data['type'] as String?) == 'alias') {
      continue;
    }
    final aliases = (data['aliases'] as List<dynamic>?)?.cast<String>();
    if (aliases != null) {
      unitClaimedBaseAliasIds.addAll(aliases);
    }
  }
  final prefixClaimedBaseAliasIds = <String>{};
  for (final entry in prefixesSection.entries) {
    final data = entry.value as Map<String, dynamic>;
    if ((data['type'] as String?) == 'alias') {
      continue;
    }
    final aliases = (data['aliases'] as List<dynamic>?)?.cast<String>();
    if (aliases != null) {
      prefixClaimedBaseAliasIds.addAll(aliases);
    }
  }

  // Collect prefix entries, skipping aliases and claimed base-alias IDs.
  final prefixEntries = <(String, Map<String, dynamic>)>[];
  for (final entry in prefixesSection.entries) {
    final id = entry.key;
    final data = Map<String, dynamic>.from(entry.value as Map);
    if ((data['type'] as String?) == 'alias') {
      continue;
    }
    if (prefixClaimedBaseAliasIds.contains(id)) {
      continue;
    }
    prefixEntries.add((id, data));
  }

  // Collect unit entries, skipping aliases and claimed base-alias IDs.
  final unitEntries = <(String, Map<String, dynamic>)>[];
  for (final entry in unitsSection.entries) {
    final id = entry.key;
    final data = Map<String, dynamic>.from(entry.value as Map);
    if ((data['type'] as String?) == 'alias') {
      continue;
    }
    if (unitClaimedBaseAliasIds.contains(id)) {
      continue;
    }
    unitEntries.add((id, data));
  }

  final buf = StringBuffer();

  // File header.
  buf.writeln('// GENERATED CODE - DO NOT EDIT BY HAND');
  buf.writeln(
    '// Run `dart run tool/generate_builtin_units.dart` to regenerate.',
  );
  buf.writeln();
  buf.writeln("import '../models/unit.dart';");
  buf.writeln("import '../models/unit_repository.dart';");
  buf.writeln();

  // Top-level registerBuiltinUnits function.
  buf.writeln('/// Registers all built-in units into the given [repo].');
  buf.writeln('void registerBuiltinUnits(UnitRepository repo) {');
  buf.writeln('  _registerUnits(repo);');
  buf.writeln('  _registerPrefixes(repo);');
  buf.writeln('}');

  // Unit registration function.
  buf.writeln();
  buf.writeln('void _registerUnits(UnitRepository repo) {');
  for (final (id, data) in unitEntries) {
    _emitEntry(buf, id, data, extraUnitAliases);
  }
  buf.writeln('}');

  // Prefix registration function.
  buf.writeln();
  buf.writeln('void _registerPrefixes(UnitRepository repo) {');
  for (final (id, data) in prefixEntries) {
    _emitEntry(buf, id, data, extraPrefixAliases);
  }
  buf.writeln('}');

  return buf.toString();
}

/// Emits a single unit registration into [buf].
void _emitEntry(
  StringBuffer buf,
  String id,
  Map<String, dynamic> entry,
  Map<String, List<String>> extraAliases,
) {
  final type = entry['type'] as String?;

  // Compute the combined alias list, deduplicating while preserving order.
  // Duplicates can arise when supplementary lists an alias explicitly AND
  // resolveAliasChains also finds it via an alias entry in the parsed file.
  final baseAliases =
      (entry['aliases'] as List<dynamic>?)?.cast<String>() ?? [];
  final extra = extraAliases[id] ?? [];
  final seen = <String>{};
  final allAliases = <String>[];
  for (final a in [...baseAliases, ...extra]) {
    if (seen.add(a)) {
      allAliases.add(a);
    }
  }

  final description = (entry['description'] as String?) ?? '';

  switch (type) {
    case 'primitive':
      _emitPrimitive(buf, id, allAliases, description, entry);
    case 'derived':
      _emitDerived(buf, id, allAliases, description, entry);
    case 'prefix':
      _emitPrefix(buf, id, allAliases, description, entry);
    case 'affine':
      _emitAffine(buf, id, allAliases, description, entry);
    default:
      // Skip anything else.
      break;
  }
}

void _emitPrimitive(
  StringBuffer buf,
  String id,
  List<String> aliases,
  String description,
  Map<String, dynamic> entry,
) {
  final isDimensionless = entry['isDimensionless'] == true;

  buf.writeln('  repo.register(');
  buf.writeln('    const PrimitiveUnit(');
  buf.writeln('      id: ${_q(id)},');
  if (aliases.isNotEmpty) {
    buf.writeln('      aliases: [${aliases.map(_q).join(', ')}],');
  }
  if (description.isNotEmpty) {
    buf.writeln('      description: ${_q(description)},');
  }
  if (isDimensionless) {
    buf.writeln('      isDimensionless: true,');
  }
  buf.writeln('    ),');
  buf.writeln('  );');
}

void _emitDerived(
  StringBuffer buf,
  String id,
  List<String> aliases,
  String description,
  Map<String, dynamic> entry,
) {
  final definition = (entry['definition'] as String?) ?? '';

  buf.writeln('  repo.register(');
  buf.writeln('    const DerivedUnit(');
  buf.writeln('      id: ${_q(id)},');
  if (aliases.isNotEmpty) {
    buf.writeln('      aliases: [${aliases.map(_q).join(', ')}],');
  }
  if (description.isNotEmpty) {
    buf.writeln('      description: ${_q(description)},');
  }
  buf.writeln('      expression: ${_q(definition)},');
  buf.writeln('    ),');
  buf.writeln('  );');
}

void _emitPrefix(
  StringBuffer buf,
  String id,
  List<String> aliases,
  String description,
  Map<String, dynamic> entry,
) {
  final definition = (entry['definition'] as String?) ?? '';

  buf.writeln('  repo.registerPrefix(');
  buf.writeln('    const PrefixUnit(');
  buf.writeln('      id: ${_q(id)},');
  if (aliases.isNotEmpty) {
    buf.writeln('      aliases: [${aliases.map(_q).join(', ')}],');
  }
  if (description.isNotEmpty) {
    buf.writeln('      description: ${_q(description)},');
  }
  buf.writeln('      expression: ${_q(definition)},');
  buf.writeln('    ),');
  buf.writeln('  );');
}

void _emitAffine(
  StringBuffer buf,
  String id,
  List<String> aliases,
  String description,
  Map<String, dynamic> entry,
) {
  final factor = entry['factor'] as num;
  final offset = entry['offset'] as num;
  final baseUnitId = entry['baseUnitId'] as String;

  buf.writeln('  repo.register(');
  buf.writeln('    const AffineUnit(');
  buf.writeln('      id: ${_q(id)},');
  if (aliases.isNotEmpty) {
    buf.writeln('      aliases: [${aliases.map(_q).join(', ')}],');
  }
  if (description.isNotEmpty) {
    buf.writeln('      description: ${_q(description)},');
  }
  buf.writeln('      factor: ${_formatDouble(factor.toDouble())},');
  buf.writeln('      offset: ${_formatDouble(offset.toDouble())},');
  buf.writeln('      baseUnitId: ${_q(baseUnitId)},');
  buf.writeln('    ),');
  buf.writeln('  );');
}

/// Quotes a string as a single-quoted Dart string literal.
///
/// Escapes backslashes, single quotes, and dollar signs so the result is
/// always valid Dart syntax regardless of the input content (e.g., unit
/// names like "'" for arcminute).
String _q(String s) {
  final escaped = s.replaceAllMapped(
    RegExp(r"([\\\'$])"),
    (Match m) => '\\${m[1]}',
  );
  return "'$escaped'";
}

/// Formats a double so it always contains a `.` or `e`.
String _formatDouble(double value) {
  final s = value.toString();
  if (s.contains('.') || s.contains('e')) {
    return s;
  }
  return '$s.0';
}
