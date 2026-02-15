import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/services/unit_resolver.dart';

void main() {
  late UnitRepository repo;

  setUp(() {
    repo = UnitRepository();
  });

  group('UnitRepository.register', () {
    test('registers a unit and looks up by id', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      final unit = repo.findUnit('m');
      expect(unit, isNotNull);
      expect(unit!.id, 'm');
    });

    test('looks up by alias', () {
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter', 'metre']));
      expect(repo.findUnit('meter')?.id, 'm');
      expect(repo.findUnit('metre')?.id, 'm');
    });

    test('throws on name collision with existing id', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      expect(
        () => repo.register(const PrimitiveUnit(id: 'm')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on alias collision with existing name', () {
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter']));
      expect(
        () => repo.register(const PrimitiveUnit(id: 'x', aliases: ['meter'])),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('collision error message includes conflicting unit id', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      expect(
        () => repo.register(const PrimitiveUnit(id: 'x', aliases: ['m'])),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains("'m'"),
          ),
        ),
      );
    });

    test(
      'primitive unit resolves with correct dimension after registration',
      () {
        repo.register(const PrimitiveUnit(id: 'kg'));
        expect(
          resolveUnit(repo.getUnit('kg'), repo).dimension,
          Dimension({'kg': 1}),
        );
      },
    );
  });

  group('UnitRepository.findUnit', () {
    test('returns null for unknown names', () {
      expect(repo.findUnit('unknown'), isNull);
    });

    test('returns null for empty string', () {
      expect(repo.findUnit(''), isNull);
    });

    test('plural stripping: removes trailing s', () {
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter']));
      // "meters" → strip 's' → "meter" → found
      expect(repo.findUnit('meters')?.id, 'm');
    });

    test('plural stripping: removes trailing es', () {
      repo.register(
        const CompoundUnit(id: 'in', aliases: ['inch'], expression: '0.0254 m'),
      );
      repo.register(const PrimitiveUnit(id: 'm'));
      // "inches" → strip 'es' → "inch" → found
      expect(repo.findUnit('inches')?.id, 'in');
    });

    test('plural stripping: tries es before s', () {
      // Register a unit with alias "inch" — "inches" should find it via
      // stripping 'es' → "inch", not via stripping 's' → "inche"
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(
        const CompoundUnit(id: 'in', aliases: ['inch'], expression: '0.0254 m'),
      );
      expect(repo.findUnit('inches')?.id, 'in');
    });

    test('plural stripping: hours → hour', () {
      repo.register(const PrimitiveUnit(id: 's'));
      repo.register(
        const CompoundUnit(id: 'hr', aliases: ['hour'], expression: '3600 s'),
      );
      expect(repo.findUnit('hours')?.id, 'hr');
    });

    test('irregular plural via explicit alias: feet', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(
        const CompoundUnit(
          id: 'ft',
          aliases: ['foot', 'feet'],
          expression: '0.3048 m',
        ),
      );
      // "feet" is an explicit alias, not found via stripping
      expect(repo.findUnit('feet')?.id, 'ft');
    });

    test('plural stripping does not match too-short strings', () {
      repo.register(const PrimitiveUnit(id: 's'));
      // "s" should not be stripped further (length 1)
      expect(repo.findUnit('s')?.id, 's');
      // "es" has length 2, stripping 'es' gives empty string — should not crash
      expect(repo.findUnit('es'), isNull);
    });

    test('exact match takes priority over plural stripping', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      // Register a unit whose id ends with 's'
      repo.register(const CompoundUnit(id: 'gas', expression: '1 m'));
      // "gas" should find 'gas' unit exactly, not strip 's' → "ga"
      expect(repo.findUnit('gas')?.id, 'gas');
    });

    test('plural stripping: removes trailing ies → y', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(
        const CompoundUnit(
          id: 'Jy',
          aliases: ['jansky'],
          expression: '1e-26 m',
        ),
      );
      // "janskies" → strip 'ies' + 'y' → "jansky" → found
      expect(repo.findUnit('janskies')?.id, 'Jy');
    });

    test('plural stripping: tries ies before es and s', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      // A unit ending in 'y' whose ies-plural could also be mis-stripped.
      repo.register(const CompoundUnit(id: 'henry', expression: '1 m'));
      // "henries" → strip 'ies' + 'y' → "henry" → found
      // (not strip 'es' → "henri" or strip 's' → "henrie")
      expect(repo.findUnit('henries')?.id, 'henry');
    });

    test('plural stripping: ies does not match too-short strings', () {
      // "pies" has length 4, stripping 'ies' gives "p" + "y" = "py" — not found
      expect(repo.findUnit('pies'), isNull);
      // "ies" has length 3, should not attempt ies stripping (length <= 4)
      expect(repo.findUnit('ies'), isNull);
    });

    test('plural stripping: s works for simple unit names', () {
      repo.register(const PrimitiveUnit(id: 'kg', aliases: ['kilogram']));
      expect(repo.findUnit('kilograms')?.id, 'kg');
    });

    test('plural stripping: es works for unit names ending in s', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(const CompoundUnit(id: 'gauss', expression: '1 m'));
      // "gausses" → strip 'es' → "gauss" → found
      expect(repo.findUnit('gausses')?.id, 'gauss');
    });
  });

  group('UnitRepository.getUnit', () {
    test('returns unit for known name', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      expect(repo.getUnit('m').id, 'm');
    });

    test('throws ArgumentError for unknown name', () {
      expect(() => repo.getUnit('unknown'), throwsA(isA<ArgumentError>()));
    });

    test('error message includes the unknown name', () {
      expect(
        () => repo.getUnit('xyz'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains("'xyz'"),
          ),
        ),
      );
    });
  });

  group('UnitRepository.dimensionlessIds', () {
    test('empty repo has no dimensionless ids', () {
      expect(repo.dimensionlessIds, isEmpty);
    });

    test('non-dimensionless primitive units are not tracked', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      expect(repo.dimensionlessIds, isEmpty);
    });

    test('dimensionless primitive units are tracked', () {
      repo.register(const PrimitiveUnit(id: 'rad', isDimensionless: true));
      expect(repo.dimensionlessIds, {'rad'});
    });

    test('tracks multiple dimensionless units', () {
      repo.register(const PrimitiveUnit(id: 'rad', isDimensionless: true));
      repo.register(const PrimitiveUnit(id: 'sr', isDimensionless: true));
      expect(repo.dimensionlessIds, {'rad', 'sr'});
    });

    test('mixes dimensionless and non-dimensionless primitives', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(const PrimitiveUnit(id: 'rad', isDimensionless: true));
      repo.register(const PrimitiveUnit(id: 'kg'));
      expect(repo.dimensionlessIds, {'rad'});
    });

    test('non-primitive units are not tracked', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(const CompoundUnit(id: 'km', expression: '1000 m'));
      expect(repo.dimensionlessIds, isEmpty);
    });

    test('returned set is unmodifiable', () {
      repo.register(const PrimitiveUnit(id: 'rad', isDimensionless: true));
      expect(() => repo.dimensionlessIds.add('x'), throwsUnsupportedError);
    });
  });

  group('UnitRepository.registerPrefix', () {
    test('registers a prefix unit', () {
      repo.registerPrefix(
        const PrefixUnit(id: 'kilo', aliases: ['k'], expression: '1000'),
      );
      expect(repo.allPrefixes.length, 1);
      expect(repo.allPrefixes.first.id, 'kilo');
    });

    test('prefix is not in regular unit lookup', () {
      repo.registerPrefix(
        const PrefixUnit(id: 'kilo', aliases: ['k'], expression: '1000'),
      );
      expect(repo.findUnit('kilo'), isNull);
      expect(repo.findUnit('k'), isNull);
    });

    test('throws on prefix name collision', () {
      repo.registerPrefix(
        const PrefixUnit(id: 'kilo', aliases: ['k'], expression: '1000'),
      );
      expect(
        () => repo.registerPrefix(
          const PrefixUnit(id: 'kilo2', aliases: ['k'], expression: '1000'),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('UnitRepository.findUnitWithPrefix', () {
    setUp(() {
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter']));
      repo.register(const PrimitiveUnit(id: 'kg', aliases: ['kilogram']));
      repo.register(
        const CompoundUnit(id: 'g', aliases: ['gram'], expression: '0.001 kg'),
      );
      repo.registerPrefix(
        const PrefixUnit(id: 'kilo', aliases: ['k'], expression: '1000'),
      );
      repo.registerPrefix(
        const PrefixUnit(id: 'milli', aliases: ['m'], expression: '0.001'),
      );
      repo.registerPrefix(
        const PrefixUnit(id: 'deca', aliases: ['da'], expression: '10'),
      );
      repo.registerPrefix(
        const PrefixUnit(id: 'deci', aliases: ['d'], expression: '0.1'),
      );
    });

    test('exact match wins over prefix splitting', () {
      final result = repo.findUnitWithPrefix('kilogram');
      expect(result.prefix, isNull);
      expect(result.unit?.id, 'kg');
    });

    test('plural match wins over prefix splitting', () {
      final result = repo.findUnitWithPrefix('meters');
      expect(result.prefix, isNull);
      expect(result.unit?.id, 'm');
    });

    test('prefix + base unit works', () {
      final result = repo.findUnitWithPrefix('kilometer');
      expect(result.prefix, isNotNull);
      expect(result.prefix!.id, 'kilo');
      expect(result.unit?.id, 'm');
    });

    test('prefix + plural base works', () {
      final result = repo.findUnitWithPrefix('kilometers');
      expect(result.prefix, isNotNull);
      expect(result.prefix!.id, 'kilo');
      expect(result.unit?.id, 'm');
    });

    test('prefix by alias works', () {
      final result = repo.findUnitWithPrefix('kgram');
      expect(result.prefix, isNotNull);
      expect(result.prefix!.id, 'kilo');
      expect(result.unit?.id, 'g');
    });

    test('longest prefix wins', () {
      // "dameter" should match "da" (deca) + "meter", not "d" (deci) + "ameter"
      final result = repo.findUnitWithPrefix('dameter');
      expect(result.prefix, isNotNull);
      expect(result.prefix!.id, 'deca');
      expect(result.unit?.id, 'm');
    });

    test('no match returns both null', () {
      final result = repo.findUnitWithPrefix('unknown');
      expect(result.prefix, isNull);
      expect(result.unit, isNull);
    });

    test('prefix + unknown remainder returns both null', () {
      final result = repo.findUnitWithPrefix('kilofoo');
      expect(result.prefix, isNull);
      expect(result.unit, isNull);
    });

    test('standalone prefix resolves as unit', () {
      final result = repo.findUnitWithPrefix('kilo');
      expect(result.prefix, isNull);
      expect(result.unit, isNotNull);
      expect(result.unit!.id, 'kilo');
      expect(result.unit!.isPrefix, isTrue);
    });

    test('short prefix alias splits correctly', () {
      // "mm" should split into prefix "m" (milli) + unit "m" (meter)
      final result = repo.findUnitWithPrefix('mm');
      expect(result.prefix, isNotNull);
      expect(result.prefix!.id, 'milli');
      expect(result.unit?.id, 'm');
    });

    test('empty string returns both null', () {
      final result = repo.findUnitWithPrefix('');
      expect(result.prefix, isNull);
      expect(result.unit, isNull);
    });

    test('prefix + ies-plural base works', () {
      repo.register(const CompoundUnit(id: 'henry', expression: '1 m'));
      // "millihenries" → milli + "henries" → "henry" via ies stripping
      final result = repo.findUnitWithPrefix('millihenries');
      expect(result.prefix, isNotNull);
      expect(result.prefix!.id, 'milli');
      expect(result.unit?.id, 'henry');
    });
  });

  group('UnitRepository.allUnits', () {
    test('empty repo has no units', () {
      expect(repo.allUnits, isEmpty);
    });

    test('returns all registered units', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(const PrimitiveUnit(id: 'kg'));
      final ids = repo.allUnits.map((u) => u.id).toSet();
      expect(ids, {'m', 'kg'});
    });

    test('does not include duplicate entries for aliases', () {
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter', 'metre']));
      expect(repo.allUnits.length, 1);
    });

    test('does not include prefix units', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.registerPrefix(
        const PrefixUnit(id: 'kilo', aliases: ['k'], expression: '1000'),
      );
      expect(repo.allUnits.length, 1);
    });
  });
}
