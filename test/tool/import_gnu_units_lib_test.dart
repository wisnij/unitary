import 'package:flutter_test/flutter_test.dart';
import '../../tool/import_gnu_units_lib.dart';

void main() {
  group('parseGnuUnitsFile', () {
    group('blank lines and comments', () {
      test('blank lines produce no entries', () {
        const input = '\n\n   \n\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, isEmpty);
      });

      test('comment-only lines produce no entries', () {
        const input = '# This is a comment\n# Another comment\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, isEmpty);
      });

      test('mixed blank and comment lines produce no entries', () {
        const input = '\n# comment\n\n# another\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, isEmpty);
      });

      test('inline comments are stripped from definition', () {
        const input = 'foot 12 inch # exactly 12 inches\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].definition, equals('12 inch'));
      });

      test('inline comment stripping trims whitespace', () {
        const input = 'foot 12 inch   # comment here\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result[0].definition, equals('12 inch'));
      });
    });

    group('line continuation', () {
      test('backslash at end of line joins with next line', () {
        const input = 'foo 12 \\\ninch\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('foo'));
        expect(result[0].definition, equals('12 inch'));
      });

      test('line number is the first line of the continued entry', () {
        const input = 'foo 12 \\\ninch\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result[0].lineNumber, equals(1));
      });

      test('multiple continuations join correctly', () {
        const input = 'foo 12 \\\n\\\ninch\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].definition, equals('12 inch'));
      });
    });

    group('non-definition directive lines', () {
      test('!set produces no entries', () {
        const input = '!set UNITS_SYSTEM si\nmeter !\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });

      test('!message produces no entries', () {
        const input = '!message hello world\nmeter !\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });

      test('!prompt produces no entries', () {
        const input = '!prompt Enter unit: \nmeter !\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });

      test('!include without readFile callback produces no extra entries', () {
        const input = '!include currency.units\nmeter !\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });
    });

    group('!include directive', () {
      test('!include without readFile callback is silently ignored', () {
        const input = '!include extra.units\nmeter !\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });

      test('!include with readFile returning null is silently ignored', () {
        const input = '!include missing.units\nmeter !\n';
        final result = parseGnuUnitsFile(
          input,
          'test.units',
          readFile: (_) => null,
        );
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });

      test('!include splices included entries inline', () {
        const input = '!include extra.units\nmeter !\n';
        final result = parseGnuUnitsFile(
          input,
          'test.units',
          readFile: (path) {
            if (path == 'extra.units') {
              return 'foot 12 inch\n';
            }
            return null;
          },
        );
        expect(result, hasLength(2));
        expect(result[0].id, equals('foot'));
        expect(result[1].id, equals('meter'));
      });

      test('included entries appear before the content after !include', () {
        const input = 'second !\n!include extra.units\nmeter !\n';
        final result = parseGnuUnitsFile(
          input,
          'test.units',
          readFile: (path) {
            if (path == 'extra.units') {
              return 'foot 12 inch\n';
            }
            return null;
          },
        );
        expect(
          result.map((e) => e.id).toList(),
          equals(['second', 'foot', 'meter']),
        );
      });

      test('included entry filename reflects the included file', () {
        const input = '!include extra.units\n';
        final result = parseGnuUnitsFile(
          input,
          'test.units',
          readFile: (path) {
            if (path == 'extra.units') {
              return 'foot 12 inch\n';
            }
            return null;
          },
        );
        expect(result[0].filename, equals('extra.units'));
      });

      test('!include path is resolved relative to parent file directory', () {
        const input = '!include extra.units\n';
        String? resolvedPath;
        parseGnuUnitsFile(
          input,
          'dir/subdir/test.units',
          readFile: (path) {
            resolvedPath = path;
            return '';
          },
        );
        expect(resolvedPath, equals('dir/subdir/extra.units'));
      });

      test('!include inside inactive conditional is skipped', () {
        const input =
            '!locale en_GB\n!include extra.units\n!endlocale\nmeter !\n';
        final result = parseGnuUnitsFile(
          input,
          'test.units',
          readFile: (path) {
            if (path == 'extra.units') {
              return 'foot 12 inch\n';
            }
            return null;
          },
        );
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });

      test('!include inside active conditional is processed', () {
        const input =
            '!locale en_US\n!include extra.units\n!endlocale\nmeter !\n';
        final result = parseGnuUnitsFile(
          input,
          'test.units',
          readFile: (path) {
            if (path == 'extra.units') {
              return 'foot 12 inch\n';
            }
            return null;
          },
        );
        expect(result.map((e) => e.id), containsAll(['foot', 'meter']));
      });

      test('!include circular reference does not loop infinitely', () {
        // fileA includes fileB which includes fileA again.
        const fileAContent = '!include fileB.units\nmeter !\n';
        const fileBContent = '!include fileA.units\nfoot 12 inch\n';
        final result = parseGnuUnitsFile(
          fileAContent,
          'fileA.units',
          readFile: (path) {
            if (path == 'fileB.units') {
              return fileBContent;
            }
            return null;
          },
        );
        // meter from fileA, foot from fileB; fileA is not re-processed from the cycle
        expect(result.map((e) => e.id), containsAll(['meter', 'foot']));
        expect(result.where((e) => e.id == 'meter').length, equals(1));
      });

      test('!include units participate in alias detection', () {
        // The included file defines 'second !' which makes 'sec second'
        // in the parent file an alias (not derived).
        const input = '!include base.units\nsec second\n';
        final result = parseGnuUnitsFile(
          input,
          'test.units',
          readFile: (path) {
            if (path == 'base.units') {
              return 'second !\n';
            }
            return null;
          },
        );
        final sec = result.firstWhere((e) => e.id == 'sec');
        expect(sec.type, equals('alias'));
        expect(sec.target, equals('second'));
      });
    });

    group('conditional directives', () {
      test('!utf8/!endutf8 block is included', () {
        const input = '!utf8\nmeter !\n!endutf8\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });

      test('!locale en_US/!endlocale block is included', () {
        const input = '!locale en_US\nmeter !\n!endlocale\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });

      test('!locale en_GB/!endlocale block is skipped', () {
        const input = '!locale en_GB\nmeter !\n!endlocale\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, isEmpty);
      });

      test('!var UNITS_SYSTEM si included', () {
        const input = '!var UNITS_SYSTEM si\nmeter !\n!endvar\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
      });

      test('!var UNITS_SYSTEM esu skipped', () {
        const input = '!var UNITS_SYSTEM esu\nmeter !\n!endvar\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, isEmpty);
      });

      test('!var with multiple values includes when current value matches', () {
        const input = '!var UNITS_SYSTEM si esu gauss\nmeter !\n!endvar\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
      });

      test('!varnot UNITS_SYSTEM si emu is skipped (si IS in list)', () {
        const input = '!varnot UNITS_SYSTEM si emu\nmeter !\n!endvar\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, isEmpty);
      });

      test('!varnot UNITS_SYSTEM esu emu is included (si is NOT in list)', () {
        const input = '!varnot UNITS_SYSTEM esu emu\nmeter !\n!endvar\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
      });

      test('nested conditionals: outer false makes inner irrelevant', () {
        const input =
            '!locale en_GB\n!var UNITS_SYSTEM si\nmeter !\n!endvar\n!endlocale\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, isEmpty);
      });

      test('nested conditionals: both active includes content', () {
        const input =
            '!locale en_US\n!var UNITS_SYSTEM si\nmeter !\n!endvar\n!endlocale\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
      });

      test('content outside conditional blocks is always included', () {
        const input =
            'meter !\n!locale en_GB\nfoot 12 inch\n!endlocale\nsecond !\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result.map((e) => e.id), containsAll(['meter', 'second']));
        expect(result.map((e) => e.id), isNot(contains('foot')));
      });
    });

    group('entry classification', () {
      test('prefix: name ending with - becomes type prefix', () {
        const input = 'kilo- 1e3\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('kilo'));
        expect(result[0].type, equals('prefix'));
        expect(result[0].definition, equals('1e3'));
      });

      test('prefix: trailing dash is stripped from id', () {
        const input = 'mega- 1e6\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result[0].id, equals('mega'));
      });

      test(
        'prefix alias: prefix-named entry whose definition is a known prefix becomes alias',
        () {
          // 'kilo-' defines a prefix; 'k- kilo' should be an alias of it.
          const input = 'kilo- 1e3\nk- kilo\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          expect(result, hasLength(2));
          final k = result.firstWhere((e) => e.id == 'k');
          expect(k.type, equals('alias'));
          expect(k.target, equals('kilo'));
          expect(k.isPrefix, isTrue);
        },
      );

      test(
        'prefix alias: prefix-named entry whose definition is NOT a prefix is derived prefix',
        () {
          // 'k- 1000' is not an alias; 1000 is not a known prefix.
          const input = 'kilo- 1e3\nk- 1000\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          final k = result.firstWhere((e) => e.id == 'k');
          expect(k.type, equals('prefix'));
          expect(k.isPrefix, isTrue);
        },
      );

      test(
        'prefix alias: multi-token definition is not an alias',
        () {
          // 'k- 1e3 # comment' - even with a comment, multi-token after strip
          // should not be treated as alias.
          const input = 'kilo- 1e3\nk- 1e3 # same value\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          final k = result.firstWhere((e) => e.id == 'k');
          expect(k.type, equals('prefix'));
        },
      );

      test('prefix: isPrefix is true for regular prefix entries', () {
        const input = 'kilo- 1e3\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result[0].isPrefix, isTrue);
      });

      test('primitive: definition ! becomes type primitive', () {
        const input = 'meter !\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('meter'));
        expect(result[0].type, equals('primitive'));
        expect(result[0].isDimensionless, isFalse);
      });

      test(
        'primitive: definition !dimensionless becomes primitive with isDimensionless true',
        () {
          const input = 'radian !dimensionless\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          expect(result, hasLength(1));
          expect(result[0].id, equals('radian'));
          expect(result[0].type, equals('primitive'));
          expect(result[0].isDimensionless, isTrue);
        },
      );

      test('derived: multi-token definition becomes type derived', () {
        const input = 'foot 12 inch\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].id, equals('foot'));
        expect(result[0].type, equals('derived'));
        expect(result[0].definition, equals('12 inch'));
      });

      test(
        'alias detection: single bare identifier in known IDs becomes alias',
        () {
          // 's' appears as a primitive so 'sec' pointing to 's' is an alias.
          const input = 's !\nsec s\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          final sec = result.firstWhere((e) => e.id == 'sec');
          expect(sec.type, equals('alias'));
          expect(sec.target, equals('s'));
        },
      );

      test(
        'alias detection: single bare identifier NOT in known IDs is derived',
        () {
          // 'kilometer' is not a known ID (it is a prefix+unit compound).
          // So 'km' with definition 'kilometer' should be derived, not alias.
          const input = 'km kilometer\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          expect(result, hasLength(1));
          expect(result[0].type, equals('derived'));
        },
      );

      test(
        'alias detection: prefix symbol is not a valid alias target',
        () {
          // 'm-' defines a prefix with stripped id 'm'. Prefix IDs are
          // excluded from the alias-target set. So 'x   m' is derived,
          // not an alias, because 'm' only appears as a prefix symbol.
          const input = 'm-\t1e-3\nx\tm\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          final x = result.firstWhere((e) => e.id == 'x');
          expect(x.type, equals('derived'));
          expect(x.definition, equals('m'));
        },
      );

      test(
        'alias detection: unit ID defined alongside prefix symbol is alias',
        () {
          // 'meter !' defines 'meter' as a unit. 'm   meter' should be an
          // alias even though 'm-   1e-3' also exists (that's a prefix entry,
          // also id=m, and appears first in the result list).
          const input = 'm-\t1e-3\nmeter\t!\nm\tmeter\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          // Both the prefix 'm' and the alias 'm' appear; look for the alias.
          final aliasM = result.firstWhere(
            (e) => e.id == 'm' && e.type == 'alias',
          );
          expect(aliasM.target, equals('meter'));
        },
      );

      test('unsupported (nonlinear): id containing ( is unsupported', () {
        const input =
            'tempC(x) units=K domain=[-273.15,) range=[0,) x + 273.15\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].type, equals('unsupported'));
        expect(result[0].reason, equals('nonlinear_definition'));
      });

      test('unsupported (piecewise): id containing [ is unsupported', () {
        const input = 'gasmark[degR] 0 1.25 1 500 2 575 end\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result, hasLength(1));
        expect(result[0].type, equals('unsupported'));
        expect(result[0].reason, equals('piecewise_linear'));
      });
    });

    group('source metadata', () {
      test('entry records the filename', () {
        const input = 'meter !\n';
        final result = parseGnuUnitsFile(input, 'myfile.units');
        expect(result[0].filename, equals('myfile.units'));
      });

      test('entry records 1-based line number', () {
        const input = '\n\nmeter !\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result[0].lineNumber, equals(3));
      });

      test(
        'gnuUnitsSource is comment-stripped and whitespace-normalized',
        () {
          const input = 'foot 12 inch # comment here\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          expect(result[0].gnuUnitsSource, equals('foot 12 inch'));
        },
      );

      test(
        'gnuUnitsSource for continued lines is the joined normalized text',
        () {
          // Continuation lines are joined and whitespace normalized.
          const input = 'foo 12 \\\ninch\n';
          final result = parseGnuUnitsFile(input, 'test.units');
          expect(result[0].gnuUnitsSource, equals('foo 12 inch'));
        },
      );

      test('line number of continued entry is line of first line', () {
        const input = '\nfoo 12 \\\ninch\n';
        final result = parseGnuUnitsFile(input, 'test.units');
        expect(result[0].lineNumber, equals(2));
      });
    });
  });

  group('entriesToJson', () {
    test('primitive entry: correct fields in units section', () {
      final entries = [
        const GnuEntry(
          id: 'meter',
          type: 'primitive',
          definition: '!',
          gnuUnitsSource: 'meter !',
          filename: 'defs.units',
          lineNumber: 42,
          isDimensionless: false,
          target: null,
          reason: null,
        ),
      ];
      final result = entriesToJson(entries);
      final units = result['units'] as Map<String, dynamic>;
      expect(units, hasLength(1));
      final data = units['meter'] as Map<String, dynamic>;
      expect(data['type'], equals('primitive'));
      expect(data['gnuUnitsSource'], equals('meter !'));
      expect((data['source'] as Map)['file'], equals('defs.units'));
      expect((data['source'] as Map)['line'], equals(42));
      expect(data['definition'], equals('!'));
      expect(data['isDimensionless'], isFalse);
      expect(data.containsKey('target'), isFalse);
      expect(data.containsKey('reason'), isFalse);
      expect(data.containsKey('description'), isFalse);
    });

    test('dimensionless primitive entry: isDimensionless is true', () {
      final entries = [
        const GnuEntry(
          id: 'radian',
          type: 'primitive',
          definition: '!dimensionless',
          gnuUnitsSource: 'radian !dimensionless',
          filename: 'defs.units',
          lineNumber: 1,
          isDimensionless: true,
          target: null,
          reason: null,
        ),
      ];
      final result = entriesToJson(entries);
      final data =
          (result['units'] as Map<String, dynamic>)['radian']
              as Map<String, dynamic>;
      expect(data['isDimensionless'], isTrue);
    });

    test('derived entry: correct fields in units section', () {
      final entries = [
        const GnuEntry(
          id: 'foot',
          type: 'derived',
          definition: '12 inch',
          gnuUnitsSource: 'foot 12 inch',
          filename: 'defs.units',
          lineNumber: 5,
          isDimensionless: false,
          target: null,
          reason: null,
        ),
      ];
      final result = entriesToJson(entries);
      final units = result['units'] as Map<String, dynamic>;
      final data = units['foot'] as Map<String, dynamic>;
      expect(data['type'], equals('derived'));
      expect(data['definition'], equals('12 inch'));
      expect(data.containsKey('isDimensionless'), isFalse);
      expect(data.containsKey('description'), isFalse);
    });

    test('prefix entry: goes in prefixes section', () {
      final entries = [
        const GnuEntry(
          id: 'kilo',
          type: 'prefix',
          definition: '1e3',
          gnuUnitsSource: 'kilo- 1e3',
          filename: 'defs.units',
          lineNumber: 1,
          isDimensionless: false,
          isPrefix: true,
          target: null,
          reason: null,
        ),
      ];
      final result = entriesToJson(entries);
      final prefixes = result['prefixes'] as Map<String, dynamic>;
      expect(prefixes, hasLength(1));
      expect((result['units'] as Map).isEmpty, isTrue);
      final data = prefixes['kilo'] as Map<String, dynamic>;
      expect(data['type'], equals('prefix'));
      expect(data['definition'], equals('1e3'));
    });

    test('isPrefix flag routes to prefixes section', () {
      // A prefix alias has isPrefix: true and type: 'alias'.
      final entries = [
        const GnuEntry(
          id: 'k',
          type: 'alias',
          definition: 'kilo',
          gnuUnitsSource: 'k- kilo',
          filename: 'defs.units',
          lineNumber: 2,
          isDimensionless: false,
          isPrefix: true,
          target: 'kilo',
          reason: null,
        ),
      ];
      final result = entriesToJson(entries);
      final prefixes = result['prefixes'] as Map<String, dynamic>;
      expect(prefixes.containsKey('k'), isTrue);
      expect((result['units'] as Map).containsKey('k'), isFalse);
    });

    test('alias entry: has target field and definition, no description', () {
      final entries = [
        const GnuEntry(
          id: 'sec',
          type: 'alias',
          definition: 's',
          gnuUnitsSource: 'sec s',
          filename: 'defs.units',
          lineNumber: 3,
          isDimensionless: false,
          target: 's',
          reason: null,
        ),
      ];
      final result = entriesToJson(entries);
      final units = result['units'] as Map<String, dynamic>;
      final data = units['sec'] as Map<String, dynamic>;
      expect(data['target'], equals('s'));
      expect(data['definition'], equals('s'));
      expect(data.containsKey('description'), isFalse);
    });

    test(
      'unsupported entry: in unsupported section, has reason, no definition',
      () {
        final entries = [
          const GnuEntry(
            id: 'tempC',
            type: 'unsupported',
            definition: 'tempC(x) [;K] (x+273.15) K',
            gnuUnitsSource: 'tempC(x) [;K] (x+273.15) K',
            filename: 'defs.units',
            lineNumber: 10,
            isDimensionless: false,
            target: null,
            reason: 'nonlinear_definition',
          ),
        ];
        final result = entriesToJson(entries);
        final unsupported = result['unsupported'] as Map<String, dynamic>;
        expect(unsupported.containsKey('tempC'), isTrue);
        final data = unsupported['tempC'] as Map<String, dynamic>;
        expect(data['type'], equals('unsupported'));
        expect(data['reason'], equals('nonlinear_definition'));
        expect(data.containsKey('definition'), isFalse);
        expect(data.containsKey('description'), isFalse);
        // Goes in unsupported section, not units.
        expect((result['units'] as Map).containsKey('tempC'), isFalse);
      },
    );

    test('two entries with same id in different namespaces both appear', () {
      // 'm' can be both a unit primitive and a prefix (milli) independently.
      final entries = [
        const GnuEntry(
          id: 'm',
          type: 'primitive',
          definition: '!',
          gnuUnitsSource: 'm !',
          filename: 'defs.units',
          lineNumber: 1,
          isDimensionless: false,
          target: null,
          reason: null,
        ),
        const GnuEntry(
          id: 'm',
          type: 'prefix',
          definition: '1e-3',
          gnuUnitsSource: 'm- 1e-3',
          filename: 'defs.units',
          lineNumber: 2,
          isDimensionless: false,
          isPrefix: true,
          target: null,
          reason: null,
        ),
      ];
      final result = entriesToJson(entries);
      expect((result['units'] as Map).containsKey('m'), isTrue);
      expect((result['prefixes'] as Map).containsKey('m'), isTrue);
      final unitM =
          (result['units'] as Map<String, dynamic>)['m']
              as Map<String, dynamic>;
      final prefixM =
          (result['prefixes'] as Map<String, dynamic>)['m']
              as Map<String, dynamic>;
      expect(unitM['type'], equals('primitive'));
      expect(prefixM['type'], equals('prefix'));
    });

    test('source metadata is recorded correctly', () {
      final entries = [
        const GnuEntry(
          id: 'foot',
          type: 'derived',
          definition: '12 inch',
          gnuUnitsSource: 'foot 12 inch',
          filename: 'path/to/defs.units',
          lineNumber: 99,
          isDimensionless: false,
          target: null,
          reason: null,
        ),
      ];
      final result = entriesToJson(entries);
      final data =
          (result['units'] as Map<String, dynamic>)['foot']
              as Map<String, dynamic>;
      expect(data['gnuUnitsSource'], equals('foot 12 inch'));
      final source = data['source'] as Map<String, dynamic>;
      expect(source['file'], equals('path/to/defs.units'));
      expect(source['line'], equals(99));
    });

    test('empty input produces empty sections', () {
      final result = entriesToJson([]);
      expect((result['units'] as Map).isEmpty, isTrue);
      expect((result['prefixes'] as Map).isEmpty, isTrue);
      expect((result['unsupported'] as Map).isEmpty, isTrue);
    });
  });
}
