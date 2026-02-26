import 'package:flutter_test/flutter_test.dart';
import '../../tool/generate_builtin_units_lib.dart';

void main() {
  // Converts a flat list (old format with 'id' field) to the new JSON structure.
  Map<String, dynamic> makeJson(List<Map<String, dynamic>> entries) {
    final units = <String, dynamic>{};
    final prefixes = <String, dynamic>{};
    final unsupported = <String, dynamic>{};
    for (final entry in entries) {
      final id = entry['id'] as String;
      final data = Map<String, dynamic>.from(entry)..remove('id');
      final type = entry['type'] as String?;
      if (type == 'prefix') {
        prefixes[id] = data;
      } else if (type == 'unsupported') {
        unsupported[id] = data;
      } else {
        units[id] = data;
      }
    }
    return {'units': units, 'prefixes': prefixes, 'unsupported': unsupported};
  }

  group('recursiveMerge', () {
    test('non-map supplementary wins verbatim over non-map base', () {
      expect(recursiveMerge('base', 'supplementary'), equals('supplementary'));
      expect(recursiveMerge(1, 2), equals(2));
      expect(recursiveMerge(true, false), equals(false));
    });

    test('non-map supplementary wins verbatim over map base', () {
      expect(
        recursiveMerge({'a': 1}, 'supplementary'),
        equals('supplementary'),
      );
    });

    test('maps are merged; supplementary key wins on conflict', () {
      final base = <String, dynamic>{'a': 'base_a', 'b': 'base_b'};
      final supp = <String, dynamic>{'a': 'supp_a', 'c': 'supp_c'};
      final result = recursiveMerge(base, supp) as Map<String, dynamic>;
      expect(result['a'], equals('supp_a'));
      expect(result['b'], equals('base_b'));
      expect(result['c'], equals('supp_c'));
    });

    test('base key is kept when absent in supplementary', () {
      final base = <String, dynamic>{'a': 'base_a', 'b': 'base_b'};
      final supp = <String, dynamic>{'a': 'supp_a'};
      final result = recursiveMerge(base, supp) as Map<String, dynamic>;
      expect(result['b'], equals('base_b'));
    });

    test('deeply nested maps merge correctly', () {
      final base = <String, dynamic>{
        'outer': <String, dynamic>{'inner': 'base_inner', 'only_base': 'x'},
      };
      final supp = <String, dynamic>{
        'outer': <String, dynamic>{'inner': 'supp_inner', 'only_supp': 'y'},
      };
      final result = recursiveMerge(base, supp) as Map<String, dynamic>;
      final outer = result['outer'] as Map<String, dynamic>;
      expect(outer['inner'], equals('supp_inner'));
      expect(outer['only_base'], equals('x'));
      expect(outer['only_supp'], equals('y'));
    });
  });

  group('mergeSupplementary', () {
    test('supplementary adds fields to parsed entry', () {
      final parsed = <String, dynamic>{
        'units': <String, dynamic>{
          'meter': <String, dynamic>{
            'type': 'primitive',
            'definition': '!',
            'gnuUnitsSource': 'meter !',
          },
        },
        'prefixes': <String, dynamic>{},
        'unsupported': <String, dynamic>{},
      };
      final supplementary = <String, dynamic>{
        'units': <String, dynamic>{
          'meter': <String, dynamic>{
            'description': 'SI base unit of length',
            'aliases': ['m', 'metre'],
            'category': 'length',
          },
        },
      };
      final result = mergeSupplementary(parsed, supplementary);
      final meter =
          (result['units'] as Map<String, dynamic>)['meter']
              as Map<String, dynamic>;
      expect(meter['type'], equals('primitive'));
      expect(meter['definition'], equals('!'));
      expect(meter['description'], equals('SI base unit of length'));
      expect(meter['aliases'], equals(['m', 'metre']));
      expect(meter['category'], equals('length'));
    });

    test('supplementary-only entry appears in its section', () {
      final parsed = <String, dynamic>{
        'units': <String, dynamic>{},
        'prefixes': <String, dynamic>{},
        'unsupported': <String, dynamic>{
          'tempC': <String, dynamic>{
            'type': 'unsupported',
            'reason': 'nonlinear_definition',
          },
        },
      };
      final supplementary = <String, dynamic>{
        'units': <String, dynamic>{
          'tempC': <String, dynamic>{
            'type': 'affine',
            'factor': 1.0,
            'offset': 273.15,
            'baseUnitId': 'K',
            'category': 'temperature',
          },
        },
      };
      final result = mergeSupplementary(parsed, supplementary);
      final tempCUnit =
          (result['units'] as Map<String, dynamic>)['tempC']
              as Map<String, dynamic>;
      expect(tempCUnit['type'], equals('affine'));
    });

    test('parsed-only entry appears unchanged', () {
      final parsed = <String, dynamic>{
        'units': <String, dynamic>{
          'foot': <String, dynamic>{
            'type': 'derived',
            'definition': '12 inch',
            'gnuUnitsSource': 'foot 12 inch',
          },
        },
        'prefixes': <String, dynamic>{},
        'unsupported': <String, dynamic>{},
      };
      final result = mergeSupplementary(parsed, <String, dynamic>{});
      final foot =
          (result['units'] as Map<String, dynamic>)['foot']
              as Map<String, dynamic>;
      expect(foot['type'], equals('derived'));
      expect(foot['definition'], equals('12 inch'));
    });

    test(
      'cross-section: tempC in parsed unsupported + supplementary units -> both sections',
      () {
        final parsed = <String, dynamic>{
          'units': <String, dynamic>{},
          'prefixes': <String, dynamic>{},
          'unsupported': <String, dynamic>{
            'tempC': <String, dynamic>{
              'type': 'unsupported',
              'reason': 'nonlinear_definition',
            },
          },
        };
        final supplementary = <String, dynamic>{
          'units': <String, dynamic>{
            'tempC': <String, dynamic>{
              'type': 'affine',
              'factor': 1.0,
              'offset': 273.15,
              'baseUnitId': 'K',
            },
          },
        };
        final result = mergeSupplementary(parsed, supplementary);
        expect((result['units'] as Map).containsKey('tempC'), isTrue);
        expect((result['unsupported'] as Map).containsKey('tempC'), isTrue);
        expect(
          ((result['units'] as Map<String, dynamic>)['tempC'] as Map)['type'],
          equals('affine'),
        );
        expect(
          ((result['unsupported'] as Map<String, dynamic>)['tempC']
              as Map)['type'],
          equals('unsupported'),
        );
      },
    );

    test('empty supplementary produces parsed-only output', () {
      final parsed = <String, dynamic>{
        'units': <String, dynamic>{
          'meter': <String, dynamic>{'type': 'primitive', 'definition': '!'},
        },
        'prefixes': <String, dynamic>{},
        'unsupported': <String, dynamic>{},
      };
      final result = mergeSupplementary(parsed, <String, dynamic>{});
      final units = result['units'] as Map<String, dynamic>;
      expect(units.length, equals(1));
      final meter = units['meter'] as Map<String, dynamic>;
      expect(meter['type'], equals('primitive'));
      expect(meter['definition'], equals('!'));
    });
  });

  group('resolveAliasChains', () {
    test('returns empty maps for empty input', () {
      final (unitAliases, prefixAliases) = resolveAliasChains(
        {'units': {}, 'prefixes': {}, 'unsupported': {}},
      );
      expect(unitAliases, isEmpty);
      expect(prefixAliases, isEmpty);
    });

    test('returns empty maps when no alias entries', () {
      final entries = [
        {'id': 'meter', 'type': 'primitive'},
        {'id': 'foot', 'type': 'derived', 'definition': '0.3048 m'},
      ];
      final (unitAliases, prefixAliases) = resolveAliasChains(
        makeJson(entries),
      );
      expect(unitAliases, isEmpty);
      expect(prefixAliases, isEmpty);
    });

    test('unit alias resolves to canonical unit', () {
      final entries = [
        {'id': 'm', 'type': 'primitive'},
        {'id': 'meter', 'type': 'alias', 'target': 'm'},
      ];
      final (unitAliases, _) = resolveAliasChains(makeJson(entries));
      expect(unitAliases['m'], equals(['meter']));
    });

    test('chained unit alias resolves to canonical', () {
      final entries = [
        {'id': 'm', 'type': 'primitive'},
        {'id': 'meter', 'type': 'alias', 'target': 'm'},
        {'id': 'metres', 'type': 'alias', 'target': 'meter'},
      ];
      final (unitAliases, _) = resolveAliasChains(makeJson(entries));
      expect(unitAliases['m'], containsAll(['meter', 'metres']));
    });

    test('extra unit aliases do not include canonical own aliases field', () {
      final entries = [
        {
          'id': 'm',
          'type': 'primitive',
          'aliases': ['metre'],
        },
        {'id': 'meter', 'type': 'alias', 'target': 'm'},
      ];
      final (unitAliases, _) = resolveAliasChains(makeJson(entries));
      expect(unitAliases['m'], equals(['meter']));
    });

    test('multiple unit aliases pointing to same canonical', () {
      final entries = [
        {'id': 's', 'type': 'primitive'},
        {'id': 'second', 'type': 'alias', 'target': 's'},
        {'id': 'sec', 'type': 'alias', 'target': 's'},
      ];
      final (unitAliases, _) = resolveAliasChains(makeJson(entries));
      expect(unitAliases['s'], containsAll(['second', 'sec']));
    });

    test('non-alias unit entries do not appear in result', () {
      final entries = [
        {'id': 'm', 'type': 'primitive'},
        {'id': 'ft', 'type': 'derived', 'definition': '0.3048 m'},
        {'id': 'meter', 'type': 'alias', 'target': 'm'},
      ];
      final (unitAliases, _) = resolveAliasChains(makeJson(entries));
      expect(unitAliases.containsKey('ft'), isFalse);
      expect(unitAliases.containsKey('meter'), isFalse);
    });

    test('prefix alias resolves within prefix namespace only', () {
      final json = <String, dynamic>{
        'units': <String, dynamic>{},
        'prefixes': <String, dynamic>{
          'kilo': <String, dynamic>{'type': 'prefix', 'definition': '1000'},
          'k': <String, dynamic>{'type': 'alias', 'target': 'kilo'},
        },
        'unsupported': <String, dynamic>{},
      };
      final (unitAliases, prefixAliases) = resolveAliasChains(json);
      expect(prefixAliases['kilo'], equals(['k']));
      expect(unitAliases, isEmpty);
    });

    test('same id in both namespaces resolves independently', () {
      // 'm' is meter (canonical unit) and milli alias (prefix).
      // Unit aliases of 'm' must not bleed into prefix aliases and vice versa.
      final json = <String, dynamic>{
        'units': <String, dynamic>{
          'm': <String, dynamic>{'type': 'primitive'},
          'meter': <String, dynamic>{'type': 'alias', 'target': 'm'},
        },
        'prefixes': <String, dynamic>{
          'milli': <String, dynamic>{'type': 'prefix', 'definition': '1e-3'},
          'm': <String, dynamic>{'type': 'alias', 'target': 'milli'},
        },
        'unsupported': <String, dynamic>{},
      };
      final (unitAliases, prefixAliases) = resolveAliasChains(json);
      // 'meter' is an extra alias of the unit 'm', not of 'milli'.
      expect(unitAliases['m'], equals(['meter']));
      expect(prefixAliases.containsKey('m'), isFalse);
      // 'm' (prefix alias) resolves to 'milli', not to the unit 'm'.
      expect(prefixAliases['milli'], equals(['m']));
      expect(unitAliases.containsKey('milli'), isFalse);
    });
  });

  group('generateDartCode', () {
    group('file header', () {
      test('begins with do-not-edit comment', () {
        final code = generateDartCode(
          {'units': {}, 'prefixes': {}, 'unsupported': {}},
        );
        expect(code, startsWith('// GENERATED CODE - DO NOT EDIT BY HAND'));
      });

      test('includes import for unit.dart', () {
        final code = generateDartCode(
          {'units': {}, 'prefixes': {}, 'unsupported': {}},
        );
        expect(code, contains("import '../models/unit.dart'"));
      });

      test('includes import for unit_repository.dart', () {
        final code = generateDartCode(
          {'units': {}, 'prefixes': {}, 'unsupported': {}},
        );
        expect(code, contains("import '../models/unit_repository.dart'"));
      });

      test('includes registerBuiltinUnits function', () {
        final code = generateDartCode(
          {'units': {}, 'prefixes': {}, 'unsupported': {}},
        );
        expect(
          code,
          contains('void registerBuiltinUnits(UnitRepository repo)'),
        );
      });
    });

    group('primitive unit emission', () {
      test('emits PrimitiveUnit with repo.register', () {
        final entries = [
          {'id': 'm', 'type': 'primitive', 'category': 'length'},
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains('const PrimitiveUnit('));
        expect(code, contains("id: 'm'"));
        expect(code, contains('repo.register('));
      });

      test('no aliases field when aliases is absent', () {
        final entries = [
          {'id': 'm', 'type': 'primitive', 'category': 'length'},
        ];
        final code = generateDartCode(makeJson(entries));
        // Should not include aliases: [] in emitted code
        final registerSection = _extractRegistration(code, 'm');
        expect(registerSection, isNot(contains('aliases:')));
      });

      test('no aliases field when aliases is empty list', () {
        final entries = [
          {
            'id': 'm',
            'type': 'primitive',
            'category': 'length',
            'aliases': <String>[],
          },
        ];
        final code = generateDartCode(makeJson(entries));
        final registerSection = _extractRegistration(code, 'm');
        expect(registerSection, isNot(contains('aliases:')));
      });

      test('includes aliases when present', () {
        final entries = [
          {
            'id': 'm',
            'type': 'primitive',
            'category': 'length',
            'aliases': ['meter', 'metre'],
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains("aliases: ['meter', 'metre']"));
      });

      test('includes description when non-empty', () {
        final entries = [
          {
            'id': 'm',
            'type': 'primitive',
            'category': 'length',
            'description': 'SI base unit of length',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains("description: 'SI base unit of length'"));
      });

      test('omits description when absent', () {
        final entries = [
          {'id': 'm', 'type': 'primitive', 'category': 'length'},
        ];
        final code = generateDartCode(makeJson(entries));
        final registerSection = _extractRegistration(code, 'm');
        expect(registerSection, isNot(contains('description:')));
      });

      test('omits description when empty string', () {
        final entries = [
          {
            'id': 'm',
            'type': 'primitive',
            'category': 'length',
            'description': '',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        final registerSection = _extractRegistration(code, 'm');
        expect(registerSection, isNot(contains('description:')));
      });

      test('includes isDimensionless: true when true', () {
        final entries = [
          {
            'id': 'radian',
            'type': 'primitive',
            'category': 'dimensionless',
            'isDimensionless': true,
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains('isDimensionless: true'));
      });

      test('omits isDimensionless when false', () {
        final entries = [
          {
            'id': 'm',
            'type': 'primitive',
            'category': 'length',
            'isDimensionless': false,
          },
        ];
        final code = generateDartCode(makeJson(entries));
        final registerSection = _extractRegistration(code, 'm');
        expect(registerSection, isNot(contains('isDimensionless:')));
      });

      test('omits isDimensionless when absent', () {
        final entries = [
          {'id': 'm', 'type': 'primitive', 'category': 'length'},
        ];
        final code = generateDartCode(makeJson(entries));
        final registerSection = _extractRegistration(code, 'm');
        expect(registerSection, isNot(contains('isDimensionless:')));
      });
    });

    group('derived unit emission', () {
      test('emits DerivedUnit with expression', () {
        final entries = [
          {
            'id': 'ft',
            'type': 'derived',
            'category': 'length',
            'definition': '12 inch',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains('const DerivedUnit('));
        expect(code, contains("id: 'ft'"));
        expect(code, contains("expression: '12 inch'"));
        expect(code, contains('repo.register('));
      });

      test('includes aliases when present', () {
        final entries = [
          {
            'id': 'ft',
            'type': 'derived',
            'category': 'length',
            'definition': '12 inch',
            'aliases': ['foot', 'feet'],
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains("aliases: ['foot', 'feet']"));
      });

      test('omits aliases when not present', () {
        final entries = [
          {
            'id': 'ft',
            'type': 'derived',
            'category': 'length',
            'definition': '12 inch',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        final registerSection = _extractRegistration(code, 'ft');
        expect(registerSection, isNot(contains('aliases:')));
      });
    });

    group('prefix unit emission', () {
      test('emits PrefixUnit with registerPrefix call', () {
        final entries = [
          {
            'id': 'kilo',
            'type': 'prefix',
            'category': 'prefix',
            'definition': '1000',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains('const PrefixUnit('));
        expect(code, contains("id: 'kilo'"));
        expect(code, contains("expression: '1000'"));
        expect(code, contains('repo.registerPrefix('));
      });

      test('prefix does not use repo.register', () {
        final entries = [
          {
            'id': 'kilo',
            'type': 'prefix',
            'category': 'prefix',
            'definition': '1000',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        // Should use registerPrefix, not register for prefix
        expect(code, isNot(contains('repo.register(const PrefixUnit')));
      });
    });

    group('affine unit emission', () {
      test('emits AffineUnit with factor, offset, baseUnitId', () {
        final entries = [
          {
            'id': 'tempC',
            'type': 'affine',
            'category': 'temperature',
            'factor': 1.0,
            'offset': 273.15,
            'baseUnitId': 'K',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains('const AffineUnit('));
        expect(code, contains("id: 'tempC'"));
        expect(code, contains('factor:'));
        expect(code, contains('offset:'));
        expect(code, contains("baseUnitId: 'K'"));
        expect(code, contains('repo.register('));
      });

      test('affine factor value is formatted with decimal point', () {
        final entries = [
          {
            'id': 'tempK',
            'type': 'affine',
            'category': 'temperature',
            'factor': 1.0,
            'offset': 0.0,
            'baseUnitId': 'K',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        // The value 1.0 should appear as a double literal
        expect(code, matches(RegExp(r'factor:\s*1\.0')));
        expect(code, matches(RegExp(r'offset:\s*0\.0')));
      });
    });

    group('unsupported entries', () {
      test('unsupported entry is omitted from output', () {
        final entries = [
          {
            'id': 'tempC(x)',
            'type': 'unsupported',
            'category': 'temperature',
            'reason': 'nonlinear_definition',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, isNot(contains("id: 'tempC(x)'")));
      });

      test('alias entry is omitted directly', () {
        final entries = [
          {'id': 'm', 'type': 'primitive', 'category': 'length'},
          {
            'id': 'meter',
            'type': 'alias',
            'target': 'm',
            'category': 'length',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        // alias is not registered directly
        expect(code, isNot(contains("id: 'meter'")));
      });

      test('alias is folded into canonical unit aliases', () {
        final entries = [
          {'id': 'm', 'type': 'primitive', 'category': 'length'},
          {
            'id': 'meter',
            'type': 'alias',
            'target': 'm',
            'category': 'length',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        // The 'meter' alias should appear in the 'm' unit's aliases
        expect(code, contains("aliases: ['meter']"));
      });

      test('alias folded with existing aliases from canonical unit', () {
        final entries = [
          {
            'id': 'm',
            'type': 'primitive',
            'category': 'length',
            'aliases': ['metre'],
          },
          {
            'id': 'meter',
            'type': 'alias',
            'target': 'm',
            'category': 'length',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        // Should contain both 'metre' (existing) and 'meter' (from alias entry)
        expect(code, contains("aliases: ['metre', 'meter']"));
      });

      test('alias in prefixes section is omitted from direct emission', () {
        final json = {
          'units': <String, dynamic>{},
          'prefixes': {
            'kilo': {
              'type': 'prefix',
              'category': 'prefix',
              'definition': '1000',
            },
            'k': {'type': 'alias', 'target': 'kilo'},
          },
          'unsupported': <String, dynamic>{},
        };
        final code = generateDartCode(json);
        expect(code, isNot(contains("id: 'k'")));
      });

      test(
        'alias in prefixes section is folded into canonical prefix aliases',
        () {
          final json = {
            'units': <String, dynamic>{},
            'prefixes': {
              'kilo': {
                'type': 'prefix',
                'category': 'prefix',
                'definition': '1000',
              },
              'k': {'type': 'alias', 'target': 'kilo'},
            },
            'unsupported': <String, dynamic>{},
          };
          final code = generateDartCode(json);
          expect(code, contains("aliases: ['k']"));
        },
      );

      test('prefix alias folded with existing aliases on canonical prefix', () {
        final json = {
          'units': <String, dynamic>{},
          'prefixes': {
            'kilo': {
              'type': 'prefix',
              'category': 'prefix',
              'definition': '1000',
              'aliases': ['K'],
            },
            'k': {'type': 'alias', 'target': 'kilo'},
          },
          'unsupported': <String, dynamic>{},
        };
        final code = generateDartCode(json);
        expect(code, contains("aliases: ['K', 'k']"));
      });
    });

    group('structure', () {
      test('produces _registerPrefixes and _registerUnits functions', () {
        final code = generateDartCode(
          {'units': {}, 'prefixes': {}, 'unsupported': {}},
        );
        expect(code, contains('void _registerPrefixes(UnitRepository repo)'));
        expect(code, contains('void _registerUnits(UnitRepository repo)'));
      });

      test('units go into _registerUnits, prefixes into _registerPrefixes', () {
        final json = <String, dynamic>{
          'units': <String, dynamic>{
            'm': <String, dynamic>{'type': 'primitive'},
            'ft': <String, dynamic>{'type': 'derived', 'definition': '12 inch'},
          },
          'prefixes': <String, dynamic>{
            'kilo': <String, dynamic>{'type': 'prefix', 'definition': '1000'},
          },
          'unsupported': <String, dynamic>{},
        };
        final code = generateDartCode(json);
        final unitsFn = _extractFunctionBody(code, '_registerUnits');
        final prefixesFn = _extractFunctionBody(code, '_registerPrefixes');
        expect(unitsFn, contains("id: 'm'"));
        expect(unitsFn, contains("id: 'ft'"));
        expect(prefixesFn, contains("id: 'kilo'"));
        expect(prefixesFn, isNot(contains("id: 'm'")));
        expect(unitsFn, isNot(contains("id: 'kilo'")));
      });
    });

    group('double formatting', () {
      test('integer-valued double includes decimal point', () {
        final entries = [
          {
            'id': 'tempK',
            'type': 'affine',
            'category': 'temperature',
            'factor': 1.0,
            'offset': 0.0,
            'baseUnitId': 'K',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        // Verify the doubles have decimal notation
        expect(code, contains('1.0'));
        expect(code, contains('0.0'));
      });
    });

    group('string escaping in generated literals', () {
      test('single quote in unit id is escaped', () {
        // GNU Units uses "'" for arcminute. Must produce valid Dart syntax.
        final entries = [
          {
            'id': "'",
            'type': 'derived',
            'category': 'angle',
            'definition': 'degree/60',
            'description': '',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        // The id literal must be '\'' not ''' (which would be a syntax error).
        expect(code, contains("id: '\\'',"));
      });

      test('single quote in alias is escaped', () {
        final entries = [
          {
            'id': 'arcminute',
            'type': 'derived',
            'category': 'angle',
            'aliases': ["'"],
            'definition': 'degree/60',
            'description': '',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains("'\\''")); // the escaped alias in the list
      });

      test('backslash in expression is escaped', () {
        final entries = [
          {
            'id': 'backslashunit',
            'type': 'derived',
            'category': 'test',
            'definition': r'a\b',
            'description': '',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains(r"expression: 'a\\b'"));
      });

      test('dollar sign in expression is escaped', () {
        final entries = [
          {
            'id': 'dollarunit',
            'type': 'derived',
            'category': 'test',
            'definition': r'$100',
            'description': '',
          },
        ];
        final code = generateDartCode(makeJson(entries));
        expect(code, contains(r"expression: '\$100'"));
      });
    });
  });
}

/// Extracts the text of a function call containing [id] from [code].
/// Returns the portion of code around the register call for unit [id].
String _extractRegistration(String code, String id) {
  final start = code.indexOf("id: '$id'");
  if (start < 0) {
    return '';
  }
  // Find the enclosing repo.register( call - go backwards
  final registerIdx = code.lastIndexOf('repo.register', start);
  if (registerIdx < 0) {
    return code.substring(start, start + 200);
  }
  // Find the matching closing paren
  var depth = 0;
  var end = registerIdx;
  for (var i = registerIdx; i < code.length; i++) {
    if (code[i] == '(') {
      depth++;
    } else if (code[i] == ')') {
      depth--;
      if (depth == 0) {
        end = i + 1;
        break;
      }
    }
  }
  return code.substring(registerIdx, end);
}

/// Extracts the body of a function *definition* named [functionName] from [code].
/// Looks for `void functionName(` to find the definition, not a call site.
String _extractFunctionBody(String code, String functionName) {
  // Match the function definition: `void <name>(` or similar.
  final pattern = RegExp('void $functionName\\(');
  final match = pattern.firstMatch(code);
  if (match == null) {
    return '';
  }
  final start = match.start;
  // Find the opening brace of the function body.
  final braceStart = code.indexOf('{', start);
  if (braceStart < 0) {
    return '';
  }
  var depth = 0;
  var end = braceStart;
  for (var i = braceStart; i < code.length; i++) {
    if (code[i] == '{') {
      depth++;
    } else if (code[i] == '}') {
      depth--;
      if (depth == 0) {
        end = i + 1;
        break;
      }
    }
  }
  return code.substring(braceStart, end);
}
