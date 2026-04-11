/// Core library for the generate_predefined_units script.
///
/// Reads a units-parsed.json map and a units-supplementary.json map,
/// merges them into a units.json map, and produces a valid predefined_units.dart
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
/// Both maps use the section format (`'units'`, `'prefixes'`, `'unsupported'`,
/// `'dimensions'`). Supplementary fields overlay parsed fields where both
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

/// Resolves function alias chains in the units section.
///
/// Returns a map of canonical function id -> extra alias ids derived from
/// `function_alias`-type entries that point to that function.
Map<String, List<String>> resolveFunctionAliases(
  Map<String, dynamic> unitsJson,
) {
  final rawUnits = unitsJson['units'];
  final unitsSection = rawUnits == null
      ? <String, dynamic>{}
      : Map<String, dynamic>.from(rawUnits as Map);

  final byId = <String, Map<String, dynamic>>{};
  for (final entry in unitsSection.entries) {
    byId[entry.key] = Map<String, dynamic>.from(entry.value as Map);
  }

  // Collect base aliases claimed by canonical function entries.
  final claimedBaseAliases = <String>{};
  for (final entry in unitsSection.entries) {
    final data = byId[entry.key]!;
    if ((data['type'] as String?) == 'function_alias') {
      continue;
    }
    final aliases = (data['aliases'] as List<dynamic>?)?.cast<String>();
    if (aliases != null) {
      claimedBaseAliases.addAll(aliases);
    }
  }

  final result = <String, List<String>>{};
  for (final entry in unitsSection.entries) {
    final aliasId = entry.key;
    final data = byId[aliasId]!;
    if ((data['type'] as String?) != 'function_alias') {
      continue;
    }
    if (claimedBaseAliases.contains(aliasId)) {
      continue;
    }

    var target = data['target'] as String?;
    final seen = <String>{aliasId};
    while (target != null) {
      final targetEntry = byId[target];
      if (targetEntry == null) {
        break;
      }
      if ((targetEntry['type'] as String?) != 'function_alias') {
        // Found the canonical function.
        result.putIfAbsent(target, () => []).add(aliasId);
        break;
      }
      if (!seen.add(target)) {
        break;
      }
      target = targetEntry['target'] as String?;
    }
  }

  return result;
}

/// Generates predefined_units.dart source from a units JSON map.
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

  // Collect piecewise entries from the units section.
  final piecewiseEntries = <(String, Map<String, dynamic>)>[];
  for (final entry in unitsSection.entries) {
    final id = entry.key;
    final data = Map<String, dynamic>.from(entry.value as Map);
    if ((data['type'] as String?) == 'piecewise') {
      piecewiseEntries.add((id, data));
    }
  }

  // Collect defined_function entries and resolve function aliases.
  final extraFunctionAliases = resolveFunctionAliases(unitsJson);
  final definedFunctionEntries = <(String, Map<String, dynamic>)>[];
  for (final entry in unitsSection.entries) {
    final id = entry.key;
    final data = Map<String, dynamic>.from(entry.value as Map);
    if ((data['type'] as String?) == 'defined_function') {
      definedFunctionEntries.add((id, data));
    }
  }

  final buf = StringBuffer();

  // File header.
  buf.writeln('// GENERATED CODE - DO NOT EDIT BY HAND');
  buf.writeln(
    '// Run `dart run tool/generate_predefined_units.dart` to regenerate.',
  );
  buf.writeln();
  final needsFunctionImports =
      piecewiseEntries.isNotEmpty || definedFunctionEntries.isNotEmpty;
  if (needsFunctionImports) {
    buf.writeln("import '../models/function.dart';");
    buf.writeln("import '../models/unit.dart';");
    buf.writeln("import '../models/unit_repository.dart';");
    buf.writeln("import '../parser/expression_parser.dart';");
  } else {
    buf.writeln("import '../models/unit.dart';");
    buf.writeln("import '../models/unit_repository.dart';");
  }
  buf.writeln();

  // Dimension labels constant.
  final rawDimensions = unitsJson['dimensions'];
  final dimensionsSection = rawDimensions == null
      ? <String, dynamic>{}
      : Map<String, dynamic>.from(rawDimensions as Map);
  buf.writeln(
    '/// Maps canonical dimension representation to human-readable group label.',
  );
  buf.writeln('const Map<String, String> predefinedDimensionLabels = {');
  for (final entry in dimensionsSection.entries) {
    final key = entry.key;
    final data = entry.value as Map<String, dynamic>;
    final label = data['label'] as String;
    buf.writeln('  ${_q(key)}: ${_q(label)},');
  }
  buf.writeln('};');
  buf.writeln();

  // Top-level registerPredefinedUnits function.
  buf.writeln('/// Registers all predefined units into the given [repo].');
  buf.writeln('void registerPredefinedUnits(UnitRepository repo) {');
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

  // Piecewise function registration (emitted only when entries exist).
  if (piecewiseEntries.isNotEmpty) {
    buf.writeln();
    buf.writeln(
      '/// Registers all piecewise-linear functions into the given [repo].',
    );
    buf.writeln(
      '/// Must be called after [registerPredefinedUnits] so that output',
    );
    buf.writeln('/// units are already registered and can be resolved.');
    buf.writeln('void registerPiecewiseFunctions(UnitRepository repo) {');
    for (final (id, data) in piecewiseEntries) {
      _emitPiecewise(buf, id, data);
    }
    buf.writeln('}');
  }

  // Defined function registration (emitted only when entries exist).
  if (definedFunctionEntries.isNotEmpty) {
    buf.writeln();
    buf.writeln(
      '/// Registers all defined functions into the given [repo].',
    );
    buf.writeln(
      '/// Must be called after [registerPredefinedUnits] so that domain',
    );
    buf.writeln(
      '/// and range units are already registered and can be resolved.',
    );
    buf.writeln('void registerDefinedFunctions(UnitRepository repo) {');
    for (final (id, data) in definedFunctionEntries) {
      final extraAliases = extraFunctionAliases[id] ?? [];
      _emitDefinedFunction(buf, id, extraAliases, data);
    }
    buf.writeln('}');
  }

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
    case 'defined_function' || 'function_alias':
      // Handled separately in registerDefinedFunctions; skip here.
      break;
    default:
      // Skip anything else (piecewise, unsupported, etc.).
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

void _emitPiecewise(
  StringBuffer buf,
  String id,
  Map<String, dynamic> entry,
) {
  final outputUnit = (entry['outputUnit'] as String?) ?? '';
  final noerror = (entry['noerror'] as bool?) ?? false;
  final rawPoints = (entry['points'] as List<dynamic>?) ?? [];
  final points = rawPoints.map((p) {
    final pair = p as List<dynamic>;
    final x = (pair[0] as num).toDouble();
    final y = (pair[1] as num).toDouble();
    return '(${_formatDouble(x)}, ${_formatDouble(y)})';
  }).toList();

  buf.writeln('  {');
  buf.writeln(
    '    final output = ExpressionParser(repo: repo).evaluate(${_q(outputUnit)});',
  );
  buf.writeln('    repo.registerFunction(PiecewiseFunction(');
  buf.writeln('      id: ${_q(id)},');
  buf.writeln('      outputUnit: output,');
  buf.writeln('      outputUnitExpression: ${_q(outputUnit)},');
  buf.writeln('      noerror: $noerror,');
  buf.writeln('      points: const [${points.join(', ')}],');
  buf.writeln('    ));');
  buf.writeln('  }');
}

/// IDs of built-in functions registered by [registerBuiltinFunctions].
///
/// Defined functions with the same name are skipped to avoid duplicate
/// registration errors; the built-in implementation takes precedence.
const _builtinFunctionIds = {
  'sin',
  'cos',
  'tan',
  'asin',
  'acos',
  'atan',
  'ln',
  'log',
  'exp',
  'sqrt',
  'cbrt',
  'abs',
};

void _emitDefinedFunction(
  StringBuffer buf,
  String id,
  List<String> extraAliases,
  Map<String, dynamic> entry,
) {
  // Skip defined functions whose name conflicts with a registered builtin.
  if (_builtinFunctionIds.contains(id)) {
    return;
  }
  final params =
      ((entry['params'] as List<dynamic>?)?.cast<String>()) ?? <String>[];
  final forward = (entry['forward'] as String?) ?? '';
  final inverse = entry['inverse'] as String?;
  final noerror = (entry['noerror'] as bool?) ?? false;
  final domainUnits =
      ((entry['domainUnits'] as List<dynamic>?)?.cast<String>()) ?? <String>[];
  final domainBounds =
      ((entry['domainBounds'] as List<dynamic>?)?.cast<String>()) ?? <String>[];
  final rangeUnit = entry['rangeUnit'] as String?;
  final rangeBounds =
      ((entry['rangeBounds'] as List<dynamic>?)?.cast<String>()) ?? <String>[];
  final description = (entry['description'] as String?) ?? '';

  // Compute combined alias list (base + extra), deduplicating.
  final baseAliases =
      (entry['aliases'] as List<dynamic>?)?.cast<String>() ?? [];
  final seen = <String>{};
  final allAliases = <String>[];
  for (final a in [...baseAliases, ...extraAliases]) {
    if (seen.add(a)) {
      allAliases.add(a);
    }
  }

  buf.writeln('  {');

  // Resolve domain units.
  for (var i = 0; i < domainUnits.length; i++) {
    buf.writeln(
      '    final domainUnit$i = ExpressionParser(repo: repo).evaluate(${_q(domainUnits[i])});',
    );
  }

  // Resolve range unit.
  if (rangeUnit != null) {
    buf.writeln(
      '    final rangeUnit = ExpressionParser(repo: repo).evaluate(${_q(rangeUnit)});',
    );
  }

  buf.writeln('    repo.registerFunction(DefinedFunction(');
  buf.writeln('      id: ${_q(id)},');
  if (allAliases.isNotEmpty) {
    buf.writeln('      aliases: [${allAliases.map(_q).join(', ')}],');
  }
  if (description.isNotEmpty) {
    buf.writeln('      description: ${_q(description)},');
  }
  buf.writeln(
    '      params: [${params.map(_q).join(', ')}],',
  );
  buf.writeln('      forward: ${_q(forward)},');
  if (inverse != null) {
    buf.writeln('      inverse: ${_q(inverse)},');
  }
  buf.writeln('      noerror: $noerror,');

  // Emit domain spec if we have domain units or bounds.
  if (domainUnits.isNotEmpty || domainBounds.isNotEmpty) {
    buf.writeln('      domain: [');
    final count = domainUnits.isNotEmpty
        ? domainUnits.length
        : domainBounds.length;
    for (var i = 0; i < count; i++) {
      final hasQuantity = i < domainUnits.length;
      final constPrefix = hasQuantity ? '' : 'const ';
      buf.write('        ${constPrefix}QuantitySpec(');
      if (hasQuantity) {
        buf.write(
          'quantity: domainUnit$i, unitExpression: ${_q(domainUnits[i])}',
        );
      }
      if (i < domainBounds.length) {
        // Parse the bounds string, e.g. "[170,283.15]" or "(0,)".
        final boundsSpec = _parseBoundsSpec(
          domainBounds[i],
          constOuter: !hasQuantity,
        );
        if (hasQuantity) {
          buf.write(', ');
        }
        if (boundsSpec.min != null) {
          buf.write('min: ${boundsSpec.min}');
        }
        if (boundsSpec.max != null) {
          if (boundsSpec.min != null) {
            buf.write(', ');
          }
          buf.write('max: ${boundsSpec.max}');
        }
      }
      buf.writeln('),');
    }
    buf.writeln('      ],');
  }

  // Emit range spec if we have a range unit or bounds.
  if (rangeUnit != null || rangeBounds.isNotEmpty) {
    final parts = <String>[];
    if (rangeUnit != null) {
      parts.add('quantity: rangeUnit');
      parts.add('unitExpression: ${_q(rangeUnit)}');
    }
    // Use 'const' when there is no runtime 'quantity' arg.
    final isConstSpec = rangeUnit == null;
    if (rangeBounds.isNotEmpty) {
      final boundsSpec = _parseBoundsSpec(
        rangeBounds[0],
        constOuter: isConstSpec,
      );
      if (boundsSpec.min != null) {
        parts.add('min: ${boundsSpec.min}');
      }
      if (boundsSpec.max != null) {
        parts.add('max: ${boundsSpec.max}');
      }
    }
    final constPrefix = isConstSpec ? 'const ' : '';
    buf.writeln(
      '      range: ${constPrefix}QuantitySpec(${parts.join(', ')}),',
    );
  }

  buf.writeln('    ));');
  buf.writeln('  }');
}

/// Parsed min/max from an interval bounds string like `[170,283.15]` or `(0,)`.
class _BoundsSpec {
  final String?
  min; // Dart code for the Bound, e.g. 'Bound(170.0, closed: true)'
  final String? max;

  _BoundsSpec(this.min, this.max);
}

/// Parses an interval string like `[170,283.15]`, `(0,)`, `[3,)` into
/// [_BoundsSpec] with Dart [Bound] constructor call strings.
///
/// If [constOuter] is true, the `const` keyword is omitted from the [Bound]
/// constructors because the surrounding expression is already `const`.
_BoundsSpec _parseBoundsSpec(String interval, {bool constOuter = false}) {
  if (interval.isEmpty) {
    return _BoundsSpec(null, null);
  }
  final openChar = interval[0];
  final closeChar = interval[interval.length - 1];
  final inner = interval.substring(1, interval.length - 1); // strip brackets
  final commaIdx = inner.indexOf(',');
  if (commaIdx < 0) {
    return _BoundsSpec(null, null);
  }
  final lowerStr = inner.substring(0, commaIdx).trim();
  final upperStr = inner.substring(commaIdx + 1).trim();

  final boundPrefix = constOuter ? '' : 'const ';

  String? min;
  if (lowerStr.isNotEmpty) {
    final closed = openChar == '[';
    final value = double.tryParse(lowerStr) ?? 0.0;
    min = '${boundPrefix}Bound(${_formatDouble(value)}, closed: $closed)';
  }

  String? max;
  if (upperStr.isNotEmpty) {
    final closed = closeChar == ']';
    final value = double.tryParse(upperStr) ?? 0.0;
    max = '${boundPrefix}Bound(${_formatDouble(value)}, closed: $closed)';
  }

  return _BoundsSpec(min, max);
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
