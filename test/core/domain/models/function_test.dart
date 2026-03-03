import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/quantity.dart';

// Test double: a simple UnitaryFunction that returns its first argument.
class _IdentityFunction extends UnitaryFunction {
  final bool _hasInverse;

  _IdentityFunction({
    super.id = 'test',
    super.aliases,
    super.arity = 1,
    super.domain,
    bool hasInverse = false,
  }) : _hasInverse = hasInverse;

  @override
  bool get hasInverse => _hasInverse;

  @override
  Quantity evaluate(List<Quantity> args) => args[0];
}

// Test double: returns a fixed output (for testing range validation).
class _FixedOutputFunction extends UnitaryFunction {
  final Quantity _output;

  _FixedOutputFunction({
    required super.id,
    super.arity = 0,
    super.range,
    required Quantity output,
  }) : _output = output;

  @override
  bool get hasInverse => false;

  @override
  Quantity evaluate(List<Quantity> args) => _output;
}

void main() {
  // -- Bound --

  group('Bound', () {
    test('stores value and closed flag (closed)', () {
      const b = Bound(1.0, closed: true);
      expect(b.value, 1.0);
      expect(b.closed, isTrue);
    });

    test('stores value and closed flag (open)', () {
      const b = Bound(0.0, closed: false);
      expect(b.value, 0.0);
      expect(b.closed, isFalse);
    });

    test('supports negative values', () {
      const b = Bound(-1.0, closed: true);
      expect(b.value, -1.0);
      expect(b.closed, isTrue);
    });
  });

  // -- QuantitySpec --

  group('QuantitySpec', () {
    test('all fields default to null', () {
      final spec = QuantitySpec();
      expect(spec.dimension, isNull);
      expect(spec.min, isNull);
      expect(spec.max, isNull);
    });

    test('acceptDimensionless defaults to false', () {
      expect(QuantitySpec().acceptDimensionless, isFalse);
    });

    test('stores dimension', () {
      final dim = Dimension({'m': 1});
      final spec = QuantitySpec(dimension: dim);
      expect(spec.dimension, dim);
    });

    test('stores min and max bounds', () {
      const min = Bound(-1.0, closed: true);
      const max = Bound(1.0, closed: true);
      final spec = QuantitySpec(min: min, max: max);
      expect(spec.min, min);
      expect(spec.max, max);
    });

    test('stores acceptDimensionless = true', () {
      final spec = QuantitySpec(acceptDimensionless: true);
      expect(spec.acceptDimensionless, isTrue);
    });
  });

  // -- UnitaryFunction (via test double) --

  group('UnitaryFunction: allNames', () {
    test('includes id and all aliases', () {
      final f = _IdentityFunction(id: 'foo', aliases: ['bar', 'baz']);
      expect(f.allNames, ['foo', 'bar', 'baz']);
    });

    test('allNames with no aliases contains only id', () {
      final f = _IdentityFunction(id: 'foo');
      expect(f.allNames, ['foo']);
    });
  });

  group('UnitaryFunction: call() - argument count', () {
    test('correct arg count passes', () {
      final f = _IdentityFunction(arity: 1);
      expect(
        () => f.call([Quantity.dimensionless(1.0)]),
        returnsNormally,
      );
    });

    test('too few arguments throws EvalException naming function', () {
      final f = _IdentityFunction(id: 'myFn', arity: 2);
      expect(
        () => f.call([Quantity.dimensionless(1.0)]),
        throwsA(
          isA<EvalException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('myFn'),
              contains('2'),
              contains('1'),
            ),
          ),
        ),
      );
    });

    test('too many arguments throws EvalException', () {
      final f = _IdentityFunction(id: 'myFn', arity: 1);
      expect(
        () => f.call([
          Quantity.dimensionless(1.0),
          Quantity.dimensionless(2.0),
        ]),
        throwsA(isA<EvalException>()),
      );
    });
  });

  group('UnitaryFunction: call() - dimension validation', () {
    test('wrong argument dimension throws DimensionException', () {
      final f = _IdentityFunction(
        domain: [
          QuantitySpec(dimension: Dimension({'m': 1})),
        ],
      );
      expect(
        () => f.call([Quantity.dimensionless(1.0)]),
        throwsA(isA<DimensionException>()),
      );
    });

    test('correct argument dimension passes', () {
      final f = _IdentityFunction(
        domain: [
          QuantitySpec(dimension: Dimension({'m': 1})),
        ],
      );
      expect(
        () => f.call([
          Quantity(1.0, Dimension({'m': 1})),
        ]),
        returnsNormally,
      );
    });

    test(
      'dimensionless primitive spec accepts pure dimensionless (acceptDimensionless=true)',
      () {
        final radianDim = Dimension({'radian': 1});
        final f = _IdentityFunction(
          domain: [
            QuantitySpec(dimension: radianDim, acceptDimensionless: true),
          ],
        );
        // Pure dimensionless {} accepted even though spec requires {radian: 1}
        expect(
          () => f.call([Quantity.dimensionless(0.0)]),
          returnsNormally,
        );
      },
    );

    test(
      'dimensionless primitive spec rejects wrong dimension (acceptDimensionless=true)',
      () {
        final radianDim = Dimension({'radian': 1});
        final f = _IdentityFunction(
          domain: [
            QuantitySpec(dimension: radianDim, acceptDimensionless: true),
          ],
        );
        // {m: 1} is neither {radian: 1} nor {}
        expect(
          () => f.call([
            Quantity(1.0, Dimension({'m': 1})),
          ]),
          throwsA(isA<DimensionException>()),
        );
      },
    );

    test(
      'dimensionless primitive spec accepts radian quantity',
      () {
        final radianDim = Dimension({'radian': 1});
        final f = _IdentityFunction(
          domain: [
            QuantitySpec(dimension: radianDim, acceptDimensionless: true),
          ],
        );
        expect(
          () => f.call([
            Quantity(1.5708, Dimension({'radian': 1})),
          ]),
          returnsNormally,
        );
      },
    );

    test('null domain means no dimension constraint', () {
      final f = _IdentityFunction(domain: null);
      // Any dimension accepted
      expect(
        () => f.call([
          Quantity(1.0, Dimension({'kg': 1, 'm': 1, 's': -2})),
        ]),
        returnsNormally,
      );
    });
  });

  group('UnitaryFunction: call() - min/max bound validation', () {
    test('value below closed min is rejected', () {
      final f = _IdentityFunction(
        domain: [QuantitySpec(min: const Bound(-1.0, closed: true))],
      );
      expect(
        () => f.call([Quantity.dimensionless(-2.0)]),
        throwsA(isA<EvalException>()),
      );
    });

    test('value equal to closed min is accepted', () {
      final f = _IdentityFunction(
        domain: [QuantitySpec(min: const Bound(-1.0, closed: true))],
      );
      expect(
        () => f.call([Quantity.dimensionless(-1.0)]),
        returnsNormally,
      );
    });

    test('value equal to open min is rejected', () {
      final f = _IdentityFunction(
        domain: [QuantitySpec(min: const Bound(0.0, closed: false))],
      );
      expect(
        () => f.call([Quantity.dimensionless(0.0)]),
        throwsA(isA<EvalException>()),
      );
    });

    test('value above closed max is rejected', () {
      final f = _IdentityFunction(
        domain: [QuantitySpec(max: const Bound(1.0, closed: true))],
      );
      expect(
        () => f.call([Quantity.dimensionless(2.0)]),
        throwsA(isA<EvalException>()),
      );
    });

    test('value equal to closed max is accepted', () {
      final f = _IdentityFunction(
        domain: [QuantitySpec(max: const Bound(1.0, closed: true))],
      );
      expect(
        () => f.call([Quantity.dimensionless(1.0)]),
        returnsNormally,
      );
    });

    test('value equal to open max is rejected', () {
      final f = _IdentityFunction(
        domain: [QuantitySpec(max: const Bound(1.0, closed: false))],
      );
      expect(
        () => f.call([Quantity.dimensionless(1.0)]),
        throwsA(isA<EvalException>()),
      );
    });
  });

  group('UnitaryFunction: call() - return value validation', () {
    test('return value with wrong dimension throws DimensionException', () {
      // Function always returns dimensionless; range requires {m: 1}
      final f = _FixedOutputFunction(
        id: 'badReturn',
        arity: 0,
        range: QuantitySpec(dimension: Dimension({'m': 1})),
        output: Quantity.dimensionless(1.0),
      );
      expect(
        () => f.call([]),
        throwsA(isA<DimensionException>()),
      );
    });

    test('return value violating range bound throws EvalException', () {
      // Function returns 10.0; range max is 5.0 (closed)
      final f = _FixedOutputFunction(
        id: 'limited',
        arity: 0,
        range: QuantitySpec(max: const Bound(5.0, closed: true)),
        output: Quantity.dimensionless(10.0),
      );
      expect(
        () => f.call([]),
        throwsA(isA<EvalException>()),
      );
    });

    test('null range means no return constraint', () {
      final f = _FixedOutputFunction(
        id: 'unconstrained',
        arity: 0,
        range: null,
        output: Quantity(999.0, Dimension({'xyz': 5})),
      );
      expect(() => f.call([]), returnsNormally);
    });
  });

  group('UnitaryFunction: callInverse()', () {
    test('throws EvalException when hasInverse == false', () {
      final f = _IdentityFunction(id: 'noInverse', hasInverse: false);
      expect(
        () => f.callInverse([Quantity.dimensionless(1.0)]),
        throwsA(
          isA<EvalException>().having(
            (e) => e.message,
            'message',
            contains('noInverse'),
          ),
        ),
      );
    });
  });

  // -- BuiltinFunction --

  group('BuiltinFunction', () {
    test('hasInverse is false', () {
      final f = BuiltinFunction(
        id: 'test',
        arity: 1,
        impl: (args) => args[0],
      );
      expect(f.hasInverse, isFalse);
    });

    test('evaluate delegates to impl', () {
      final f = BuiltinFunction(
        id: 'double',
        arity: 1,
        impl: (args) => Quantity.dimensionless(args[0].value * 2),
      );
      final result = f.evaluate([Quantity.dimensionless(3.0)]);
      expect(result.value, 6.0);
    });

    test('callInverse throws EvalException (hasInverse == false)', () {
      final f = BuiltinFunction(
        id: 'myFn',
        arity: 1,
        impl: (args) => args[0],
      );
      expect(
        () => f.callInverse([Quantity.dimensionless(1.0)]),
        throwsA(isA<EvalException>()),
      );
    });
  });
}
