import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/models/browse_entry.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

// A minimal test function for registry tests.
class _TestFn extends UnitaryFunction {
  _TestFn(String id, {super.aliases}) : super(id: id, arity: 1);

  @override
  bool get hasInverse => false;

  @override
  List<String> get params => const ['x'];

  @override
  String? get definitionDisplay => null;

  @override
  String? get inverseDisplay => null;

  @override
  Quantity evaluate(List<Quantity> args, [Object? context]) => args[0];
}

// A test function with a configurable range, used for findConformable tests.
class _TestFnWithRange extends UnitaryFunction {
  _TestFnWithRange(
    String id, {
    required Quantity? rangeQty,
    super.aliases,
  }) : super(
         id: id,
         arity: 1,
         range: rangeQty == null ? null : QuantitySpec(quantity: rangeQty),
       );

  @override
  bool get hasInverse => false;

  @override
  List<String> get params => const ['x'];

  @override
  String? get definitionDisplay => null;

  @override
  String? get inverseDisplay => null;

  @override
  Quantity evaluate(List<Quantity> args, [Object? context]) => args[0];
}

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
          repo.resolveUnit(repo.getUnit('kg')).dimension,
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
        const DerivedUnit(id: 'in', aliases: ['inch'], expression: '0.0254 m'),
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
        const DerivedUnit(id: 'in', aliases: ['inch'], expression: '0.0254 m'),
      );
      expect(repo.findUnit('inches')?.id, 'in');
    });

    test('plural stripping: hours → hour', () {
      repo.register(const PrimitiveUnit(id: 's'));
      repo.register(
        const DerivedUnit(id: 'hr', aliases: ['hour'], expression: '3600 s'),
      );
      expect(repo.findUnit('hours')?.id, 'hr');
    });

    test('irregular plural via explicit alias: feet', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(
        const DerivedUnit(
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
      repo.register(const DerivedUnit(id: 'gas', expression: '1 m'));
      // "gas" should find 'gas' unit exactly, not strip 's' → "ga"
      expect(repo.findUnit('gas')?.id, 'gas');
    });

    test('plural stripping: removes trailing ies → y', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      repo.register(
        const DerivedUnit(
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
      repo.register(const DerivedUnit(id: 'henry', expression: '1 m'));
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
      repo.register(const DerivedUnit(id: 'gauss', expression: '1 m'));
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
      repo.register(const DerivedUnit(id: 'km', expression: '1000 m'));
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
        const DerivedUnit(id: 'g', aliases: ['gram'], expression: '0.001 kg'),
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
      repo.register(const DerivedUnit(id: 'henry', expression: '1 m'));
      // "millihenries" → milli + "henries" → "henry" via ies stripping
      final result = repo.findUnitWithPrefix('millihenries');
      expect(result.prefix, isNotNull);
      expect(result.prefix!.id, 'milli');
      expect(result.unit?.id, 'henry');
    });
  });

  group('UnitRepository.findPrefix', () {
    setUp(() {
      repo.registerPrefix(
        const PrefixUnit(id: 'k', aliases: ['kilo'], expression: '1000'),
      );
      repo.registerPrefix(
        const PrefixUnit(id: 'm', aliases: ['milli'], expression: '0.001'),
      );
    });

    test('finds prefix by canonical id', () {
      final prefix = repo.findPrefix('k');
      expect(prefix, isNotNull);
      expect(prefix!.id, 'k');
    });

    test('finds prefix by alias', () {
      final prefix = repo.findPrefix('kilo');
      expect(prefix, isNotNull);
      expect(prefix!.id, 'k');
    });

    test('returns null for unknown name', () {
      expect(repo.findPrefix('notaprefix'), isNull);
    });

    test('returns null for a unit name that is not a prefix', () {
      repo.register(const PrimitiveUnit(id: 'mol', aliases: ['mole']));
      expect(repo.findPrefix('mol'), isNull);
      expect(repo.findPrefix('mole'), isNull);
    });

    test('finds prefix via plural stripping', () {
      // "kilos" → strip 's' → "kilo" alias
      expect(repo.findPrefix('kilos')?.id, 'k');
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

  group('UnitRepository.registerFunction and findFunction', () {
    test('finds function by id', () {
      repo.registerFunction(_TestFn('foo'));
      expect(repo.findFunction('foo'), isNotNull);
      expect(repo.findFunction('foo')!.id, 'foo');
    });

    test('finds function by alias', () {
      repo.registerFunction(_TestFn('foo', aliases: ['bar']));
      expect(repo.findFunction('bar'), isNotNull);
      expect(repo.findFunction('bar')!.id, 'foo');
    });

    test('returns null for unregistered name', () {
      expect(repo.findFunction('unknown'), isNull);
    });

    test('plural form of function name is not matched', () {
      repo.registerFunction(_TestFn('foo'));
      expect(repo.findFunction('foos'), isNull);
    });

    test('prefixed form of function name is not matched', () {
      repo.registerFunction(_TestFn('sin'));
      expect(repo.findFunction('ksin'), isNull);
    });
  });

  group('UnitRepository.registerFunction collision detection', () {
    test('throws on duplicate function id', () {
      repo.registerFunction(_TestFn('foo'));
      expect(
        () => repo.registerFunction(_TestFn('foo')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when function alias collides with existing function', () {
      repo.registerFunction(_TestFn('foo'));
      expect(
        () => repo.registerFunction(_TestFn('bar', aliases: ['foo'])),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when function name collides with unit', () {
      repo.register(const PrimitiveUnit(id: 'm'));
      expect(
        () => repo.registerFunction(_TestFn('m')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when function name collides with prefix', () {
      repo.registerPrefix(
        const PrefixUnit(id: 'kilo', aliases: ['k'], expression: '1000'),
      );
      expect(
        () => repo.registerFunction(_TestFn('kilo')),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('UnitRepository.register() collision with functions', () {
    test('throws when unit id collides with function', () {
      repo.registerFunction(_TestFn('sin'));
      expect(
        () => repo.register(const PrimitiveUnit(id: 'sin')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when unit alias collides with function', () {
      repo.registerFunction(_TestFn('sin'));
      expect(
        () => repo.register(const PrimitiveUnit(id: 'x', aliases: ['sin'])),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('UnitRepository.withPredefinedUnits() function registry', () {
    late UnitRepository fullRepo;

    setUp(() {
      fullRepo = UnitRepository.withPredefinedUnits();
    });

    test('all 9 standard builtins findable via findFunction', () {
      for (final name in [
        'sin',
        'cos',
        'tan',
        'asin',
        'acos',
        'atan',
        'ln',
        'log',
        'exp',
      ]) {
        expect(
          fullRepo.findFunction(name),
          isNotNull,
          reason: "'$name' should be findable in withPredefinedUnits()",
        );
      }
    });

    test('findFunction("log2") returns null', () {
      expect(fullRepo.findFunction('log2'), isNull);
    });

    test('findFunction("log10") returns null', () {
      expect(fullRepo.findFunction('log10'), isNull);
    });
  });

  group('ConformableEntry', () {
    test('constructed for a derived unit', () {
      const entry = ConformableEntry(
        name: 'cal',
        definitionExpression: '4.184 J',
      );
      expect(entry.name, 'cal');
      expect(entry.definitionExpression, '4.184 J');
      expect(entry.functionLabel, isNull);
    });

    test('constructed for a function', () {
      const entry = ConformableEntry(
        name: 'tempC',
        functionLabel: '[function]',
      );
      expect(entry.name, 'tempC');
      expect(entry.definitionExpression, isNull);
      expect(entry.functionLabel, '[function]');
    });

    test('constructed for a primitive unit', () {
      const entry = ConformableEntry(name: 'm');
      expect(entry.name, 'm');
      expect(entry.definitionExpression, isNull);
      expect(entry.functionLabel, isNull);
      expect(entry.aliasFor, isNull);
    });

    test('constructed for an alias', () {
      const entry = ConformableEntry(name: 'metre', aliasFor: 'm');
      expect(entry.name, 'metre');
      expect(entry.aliasFor, 'm');
      expect(entry.definitionExpression, isNull);
      expect(entry.functionLabel, isNull);
    });
  });

  group('UnitRepository.findConformable', () {
    late UnitRepository repo;
    // Length dimension: {m: 1}
    late Dimension lengthDim;
    // Mass dimension: {kg: 1}
    late Dimension massDim;

    setUp(() {
      repo = UnitRepository();
      repo.register(const PrimitiveUnit(id: 'm', aliases: ['metre', 'meter']));
      repo.register(const PrimitiveUnit(id: 'kg'));
      repo.register(
        const DerivedUnit(id: 'ft', expression: '0.3048 m'),
      );
      lengthDim = Dimension({'m': 1});
      massDim = Dimension({'kg': 1});
    });

    test('returns units with matching dimension', () {
      final entries = repo.findConformable(lengthDim);
      final names = entries.map((e) => e.name).toList();
      expect(names, containsAll(['m', 'ft']));
    });

    test('excludes units with non-matching dimension', () {
      final entries = repo.findConformable(lengthDim);
      final names = entries.map((e) => e.name).toSet();
      expect(names, isNot(contains('kg')));
    });

    test('excludes PrefixUnit entries', () {
      repo.registerPrefix(
        const PrefixUnit(id: 'kilo', expression: '1000', aliases: ['k']),
      );
      // kilo resolves as a dimensionless scalar — but the key check is type.
      final entries = repo.findConformable(Dimension.dimensionless);
      final names = entries.map((e) => e.name).toSet();
      expect(names, isNot(contains('kilo')));
    });

    test('silently excludes unresolvable units', () {
      // A DerivedUnit whose expression references an unknown unit will throw.
      repo.register(
        const DerivedUnit(id: 'bad_unit', expression: 'undefined_unit_xyz'),
      );
      expect(
        () => repo.findConformable(lengthDim),
        returnsNormally,
      );
      final names = repo.findConformable(lengthDim).map((e) => e.name).toSet();
      expect(names, isNot(contains('bad_unit')));
    });

    test('results are sorted case-insensitively', () {
      repo.register(const DerivedUnit(id: 'Zeta', expression: '2 m'));
      repo.register(const DerivedUnit(id: 'alpha_m', expression: '3 m'));
      repo.register(const DerivedUnit(id: 'Beta_m', expression: '4 m'));
      final entries = repo.findConformable(lengthDim);
      final names = entries.map((e) => e.name).toList();
      // Find the relative positions of our three new units.
      final iAlpha = names.indexOf('alpha_m');
      final iBeta = names.indexOf('Beta_m');
      final iZeta = names.indexOf('Zeta');
      expect(iAlpha, lessThan(iBeta));
      expect(iBeta, lessThan(iZeta));
    });

    test('derived unit entry has definitionExpression, null functionLabel', () {
      final entry = repo
          .findConformable(lengthDim)
          .firstWhere((e) => e.name == 'ft');
      expect(entry.definitionExpression, '0.3048 m');
      expect(entry.functionLabel, isNull);
    });

    test(
      'primitive unit entry has null definitionExpression and functionLabel',
      () {
        final entry = repo
            .findConformable(lengthDim)
            .firstWhere((e) => e.name == 'm');
        expect(entry.definitionExpression, isNull);
        expect(entry.functionLabel, isNull);
      },
    );

    test(
      'non-piecewise function with matching range is included with [function] label',
      () {
        final rangeQty = Quantity(1.0, lengthDim);
        repo.registerFunction(_TestFnWithRange('myFunc', rangeQty: rangeQty));
        final entry = repo
            .findConformable(lengthDim)
            .firstWhere((e) => e.name == 'myFunc');
        expect(entry.functionLabel, '[function]');
        expect(entry.definitionExpression, isNull);
      },
    );

    test(
      'PiecewiseFunction with matching range gets [piecewise linear function] label',
      () {
        final rangeQty = Quantity(1.0, lengthDim);
        repo.registerFunction(
          PiecewiseFunction(
            id: 'pwFunc',
            points: const [(0.0, 0.0), (1.0, 1.0)],
            noerror: false,
            outputUnit: rangeQty,
          ),
        );
        final entry = repo
            .findConformable(lengthDim)
            .firstWhere((e) => e.name == 'pwFunc');
        expect(entry.functionLabel, '[piecewise linear function]');
      },
    );

    test('function with null range is excluded', () {
      repo.registerFunction(_TestFnWithRange('noRange', rangeQty: null));
      final names = repo.findConformable(lengthDim).map((e) => e.name).toSet();
      expect(names, isNot(contains('noRange')));
    });

    test('function with non-matching range dimension is excluded', () {
      final massRangeQty = Quantity(1.0, massDim);
      repo.registerFunction(
        _TestFnWithRange('massFunc', rangeQty: massRangeQty),
      );
      final names = repo.findConformable(lengthDim).map((e) => e.name).toSet();
      expect(names, isNot(contains('massFunc')));
    });

    test('repeated calls return equivalent results', () {
      final first = repo.findConformable(lengthDim);
      final second = repo.findConformable(lengthDim);
      expect(
        first.map((e) => e.name).toList(),
        equals(second.map((e) => e.name).toList()),
      );
    });

    test('unit aliases are included with aliasFor set', () {
      final entries = repo.findConformable(lengthDim);
      final names = entries.map((e) => e.name).toSet();
      expect(names, containsAll(['metre', 'meter']));

      // 'm' is a primitive, so alias entries have no definitionExpression.
      final metreEntry = entries.firstWhere((e) => e.name == 'metre');
      expect(metreEntry.aliasFor, 'm');
      expect(metreEntry.definitionExpression, isNull);
      expect(metreEntry.functionLabel, isNull);
    });

    test('derived unit alias carries the target expression', () {
      repo.register(
        const DerivedUnit(
          id: 'km',
          expression: '1000 m',
          aliases: ['kilometre'],
        ),
      );
      final entries = repo.findConformable(lengthDim);
      final aliasEntry = entries.firstWhere((e) => e.name == 'kilometre');
      expect(aliasEntry.aliasFor, 'km');
      expect(aliasEntry.definitionExpression, '1000 m');
      expect(aliasEntry.functionLabel, isNull);
    });

    test('unit aliases are sorted among other entries', () {
      final entries = repo.findConformable(lengthDim);
      final names = entries.map((e) => e.name).toList();
      // 'meter' and 'metre' sort between 'm' and ... check ordering is correct.
      final iM = names.indexOf('m');
      final iMeter = names.indexOf('meter');
      final iMetre = names.indexOf('metre');
      expect(iM, lessThan(iMeter));
      expect(iMeter, lessThan(iMetre));
    });

    test('function aliases are included with aliasFor set', () {
      final rangeQty = Quantity(1.0, lengthDim);
      repo.registerFunction(
        _TestFnWithRange('myFunc', rangeQty: rangeQty, aliases: ['myAlias']),
      );
      final entries = repo.findConformable(lengthDim);
      final aliasEntry = entries.firstWhere((e) => e.name == 'myAlias');
      expect(aliasEntry.aliasFor, 'myFunc');
      expect(aliasEntry.functionLabel, '[function]');
      expect(aliasEntry.definitionExpression, isNull);
    });
  });

  group('buildBrowseCatalog', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();

      repo.register(const PrimitiveUnit(id: 'm', aliases: ['meter', 'metre']));
      repo.register(
        const DerivedUnit(
          id: 'km',
          aliases: ['kilometre'],
          expression: '1000 m',
        ),
      );
      repo.register(const PrimitiveUnit(id: 'kg'));
      repo.registerPrefix(
        const PrefixUnit(id: 'kilo', aliases: ['k'], expression: '1e3'),
      );
      repo.registerFunction(_TestFn('myFunc', aliases: ['myAlias']));
    });

    test('primary unit entries are present', () {
      final catalog = repo.buildBrowseCatalog();
      final names = catalog.map((e) => e.name).toSet();
      expect(names, containsAll(['m', 'km', 'kg']));
    });

    test('unit aliases appear as separate entries', () {
      final catalog = repo.buildBrowseCatalog();
      final meterAlias = catalog.firstWhere((e) => e.name == 'meter');
      expect(meterAlias.primaryId, 'm');
      expect(meterAlias.aliasFor, 'm');
      expect(meterAlias.isAlias, isTrue);
      expect(meterAlias.kind, BrowseEntryKind.unit);
    });

    test('prefix entries are present', () {
      final catalog = repo.buildBrowseCatalog();
      final names = catalog.map((e) => e.name).toSet();
      expect(names, containsAll(['kilo', 'k']));
    });

    test('prefix alias entry has aliasFor set', () {
      final catalog = repo.buildBrowseCatalog();
      final kAlias = catalog.firstWhere((e) => e.name == 'k');
      expect(kAlias.primaryId, 'kilo');
      expect(kAlias.aliasFor, 'kilo');
      expect(kAlias.kind, BrowseEntryKind.prefix);
    });

    test('function entries are present', () {
      final catalog = repo.buildBrowseCatalog();
      final names = catalog.map((e) => e.name).toSet();
      expect(names, containsAll(['myFunc', 'myAlias']));
    });

    test('function alias entry has aliasFor set', () {
      final catalog = repo.buildBrowseCatalog();
      final alias = catalog.firstWhere((e) => e.name == 'myAlias');
      expect(alias.primaryId, 'myFunc');
      expect(alias.aliasFor, 'myFunc');
      expect(alias.kind, BrowseEntryKind.function);
    });

    test('primitive unit summaryLine is [primitive unit]', () {
      final catalog = repo.buildBrowseCatalog();
      final m = catalog.firstWhere((e) => e.name == 'm');
      expect(m.summaryLine, '[primitive unit]');
    });

    test('derived unit summaryLine is expression', () {
      final catalog = repo.buildBrowseCatalog();
      final km = catalog.firstWhere((e) => e.name == 'km');
      expect(km.summaryLine, '1000 m');
    });

    test('alias inherits summaryLine from primary', () {
      final catalog = repo.buildBrowseCatalog();
      final alias = catalog.firstWhere((e) => e.name == 'kilometre');
      expect(alias.summaryLine, '1000 m');
    });

    test('function summaryLine is [function]', () {
      final catalog = repo.buildBrowseCatalog();
      final fn = catalog.firstWhere((e) => e.name == 'myFunc');
      expect(fn.summaryLine, '[function]');
    });

    test('unresolvable unit has null dimension', () {
      repo.register(const DerivedUnit(id: 'bad', expression: 'unknownXYZ'));
      final catalog = repo.buildBrowseCatalog();
      final bad = catalog.firstWhere((e) => e.name == 'bad');
      expect(bad.dimension, isNull);
    });

    test('PrefixUnit instances are not included in unit entries', () {
      final catalog = repo.buildBrowseCatalog();
      // 'kilo' and 'k' should appear as prefix kind, not unit kind
      for (final e in catalog.where((e) => e.name == 'kilo' || e.name == 'k')) {
        expect(e.kind, BrowseEntryKind.prefix);
      }
    });
  });

  group('UnitRepository.resolveUnit caching', () {
    test('second call returns same quantity (cached)', () {
      final repo = UnitRepository();
      repo.register(const PrimitiveUnit(id: 'base'));
      repo.register(const DerivedUnit(id: 'unit', expression: '5 base'));
      final unit = repo.getUnit('unit');
      final first = repo.resolveUnit(unit);
      final second = repo.resolveUnit(unit);
      expect(second.value, equals(first.value));
      expect(second.dimension, equals(first.dimension));
    });

    test('failed resolution re-throws on every call', () {
      final repo = UnitRepository();
      repo.register(const DerivedUnit(id: 'bad', expression: 'bad'));
      final unit = repo.getUnit('bad');
      expect(() => repo.resolveUnit(unit), throwsA(isA<EvalException>()));
      // Second call must also throw, not silently succeed or change type.
      expect(() => repo.resolveUnit(unit), throwsA(isA<EvalException>()));
    });
  });

  group('UnitRepository.resolveUnit cache key collision', () {
    // Builds a repo with a DerivedUnit 'm' = 1000 base and a PrefixUnit
    // 'm' = 0.001.  Without namespace-qualified cache keys these collide and
    // whichever is resolved first poisons the entry for the other.
    UnitRepository buildCollisionRepo() {
      final repo = UnitRepository();
      repo.register(const PrimitiveUnit(id: 'base'));
      repo.register(const DerivedUnit(id: 'm', expression: '1000 base'));
      repo.registerPrefix(const PrefixUnit(id: 'm', expression: '0.001'));
      return repo;
    }

    test('unit resolved before prefix', () {
      final repo = buildCollisionRepo();
      final unitQ = repo.resolveUnit(repo.getUnit('m'));
      final prefixQ = repo.resolveUnit(repo.findPrefix('m')!);
      expect(unitQ.value, closeTo(1000.0, 1e-10));
      expect(unitQ.dimension, Dimension({'base': 1}));
      expect(prefixQ.value, closeTo(0.001, 1e-10));
      expect(prefixQ.isDimensionless, isTrue);
    });

    test('prefix resolved before unit', () {
      final repo = buildCollisionRepo();
      final prefixQ = repo.resolveUnit(repo.findPrefix('m')!);
      final unitQ = repo.resolveUnit(repo.getUnit('m'));
      expect(unitQ.value, closeTo(1000.0, 1e-10));
      expect(unitQ.dimension, Dimension({'base': 1}));
      expect(prefixQ.value, closeTo(0.001, 1e-10));
      expect(prefixQ.isDimensionless, isTrue);
    });
  });
}
