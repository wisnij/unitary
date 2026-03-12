import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/predefined_units.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';
import 'package:unitary/core/domain/parser/ast.dart';

// Test double: a simple UnitaryFunction that returns its first argument.
class _IdentityFunction extends UnitaryFunction {
  final bool _hasInverse;

  _IdentityFunction({
    super.id = 'test',
    super.aliases,
    super.arity = 1,
    super.domain,
    super.range,
    bool hasInverse = false,
  }) : _hasInverse = hasInverse;

  @override
  bool get hasInverse => _hasInverse;

  @override
  Quantity evaluate(List<Quantity> args, [Object? context]) => args[0];

  @override
  Quantity evaluateInverse(List<Quantity> args, [Object? context]) => args[0];
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
  Quantity evaluate(List<Quantity> args, [Object? context]) => _output;
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
      const spec = QuantitySpec();
      expect(spec.quantity, isNull);
      expect(spec.min, isNull);
      expect(spec.max, isNull);
    });

    test('acceptDimensionless defaults to false', () {
      expect(const QuantitySpec().acceptDimensionless, isFalse);
    });

    test('stores quantity', () {
      final q = Quantity(1.0, Dimension({'m': 1}));
      final spec = QuantitySpec(quantity: q);
      expect(spec.quantity?.dimension, q.dimension);
      expect(spec.quantity?.value, q.value);
    });

    test('stores min and max bounds', () {
      const min = Bound(-1.0, closed: true);
      const max = Bound(1.0, closed: true);
      const spec = QuantitySpec(min: min, max: max);
      expect(spec.min, min);
      expect(spec.max, max);
    });

    test('stores acceptDimensionless = true', () {
      const spec = QuantitySpec(acceptDimensionless: true);
      expect(spec.acceptDimensionless, isTrue);
    });

    group('isWithinBounds', () {
      test('no bounds: any value is within', () {
        const spec = QuantitySpec();
        expect(spec.isWithinBounds(0.0), isTrue);
        expect(spec.isWithinBounds(1e100), isTrue);
        expect(spec.isWithinBounds(-1e100), isTrue);
      });

      test('closed min: value above min is within', () {
        const spec = QuantitySpec(min: Bound(0.0, closed: true));
        expect(spec.isWithinBounds(0.0), isTrue);
        expect(spec.isWithinBounds(1.0), isTrue);
      });

      test('closed min: value below min is not within', () {
        const spec = QuantitySpec(min: Bound(0.0, closed: true));
        expect(spec.isWithinBounds(-0.001), isFalse);
      });

      test('open min: value at min is not within', () {
        const spec = QuantitySpec(min: Bound(0.0, closed: false));
        expect(spec.isWithinBounds(0.0), isFalse);
        expect(spec.isWithinBounds(0.001), isTrue);
      });

      test('closed max: value at max is within', () {
        const spec = QuantitySpec(max: Bound(1.0, closed: true));
        expect(spec.isWithinBounds(1.0), isTrue);
        expect(spec.isWithinBounds(0.0), isTrue);
      });

      test('closed max: value above max is not within', () {
        const spec = QuantitySpec(max: Bound(1.0, closed: true));
        expect(spec.isWithinBounds(1.001), isFalse);
      });

      test('open max: value at max is not within', () {
        const spec = QuantitySpec(max: Bound(1.0, closed: false));
        expect(spec.isWithinBounds(1.0), isFalse);
        expect(spec.isWithinBounds(0.999), isTrue);
      });

      test('closed min and max: value inside is within', () {
        const spec = QuantitySpec(
          min: Bound(-1.0, closed: true),
          max: Bound(1.0, closed: true),
        );
        expect(spec.isWithinBounds(-1.0), isTrue);
        expect(spec.isWithinBounds(0.0), isTrue);
        expect(spec.isWithinBounds(1.0), isTrue);
      });

      test('closed min and max: value outside is not within', () {
        const spec = QuantitySpec(
          min: Bound(-1.0, closed: true),
          max: Bound(1.0, closed: true),
        );
        expect(spec.isWithinBounds(-1.001), isFalse);
        expect(spec.isWithinBounds(1.001), isFalse);
      });
    });

    group('boundsString', () {
      test('no bounds → (,)', () {
        expect(const QuantitySpec().boundsString(), '(,)');
      });

      test('closed min only → [0,)', () {
        const spec = QuantitySpec(min: Bound(0.0, closed: true));
        expect(spec.boundsString(), '[0,)');
      });

      test('open min only → (0,)', () {
        const spec = QuantitySpec(min: Bound(0.0, closed: false));
        expect(spec.boundsString(), '(0,)');
      });

      test('closed max only → (,5]', () {
        const spec = QuantitySpec(max: Bound(5.0, closed: true));
        expect(spec.boundsString(), '(,5]');
      });

      test('open max only → (,5)', () {
        const spec = QuantitySpec(max: Bound(5.0, closed: false));
        expect(spec.boundsString(), '(,5)');
      });

      test('closed min and max → [-1,1]', () {
        const spec = QuantitySpec(
          min: Bound(-1.0, closed: true),
          max: Bound(1.0, closed: true),
        );
        expect(spec.boundsString(), '[-1,1]');
      });

      test('open min closed max → (0,1]', () {
        const spec = QuantitySpec(
          min: Bound(0.0, closed: false),
          max: Bound(1.0, closed: true),
        );
        expect(spec.boundsString(), '(0,1]');
      });

      test('closed min open max → [0,1)', () {
        const spec = QuantitySpec(
          min: Bound(0.0, closed: true),
          max: Bound(1.0, closed: false),
        );
        expect(spec.boundsString(), '[0,1)');
      });
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
        () => f.call([Quantity.unity]),
        returnsNormally,
      );
    });

    test('too few arguments throws EvalException naming function', () {
      final f = _IdentityFunction(id: 'myFn', arity: 2);
      expect(
        () => f.call([Quantity.unity]),
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
          QuantitySpec(quantity: Quantity(1.0, Dimension({'m': 1}))),
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
          QuantitySpec(quantity: Quantity(1.0, Dimension({'m': 1}))),
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
            QuantitySpec(
              quantity: Quantity(1.0, radianDim),
              acceptDimensionless: true,
            ),
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
            QuantitySpec(
              quantity: Quantity(1.0, radianDim),
              acceptDimensionless: true,
            ),
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
            QuantitySpec(
              quantity: Quantity(1.0, radianDim),
              acceptDimensionless: true,
            ),
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
        domain: [const QuantitySpec(min: Bound(-1.0, closed: true))],
      );
      expect(
        () => f.call([Quantity.dimensionless(-2.0)]),
        throwsA(isA<EvalException>()),
      );
    });

    test('value equal to closed min is accepted', () {
      final f = _IdentityFunction(
        domain: [const QuantitySpec(min: Bound(-1.0, closed: true))],
      );
      expect(
        () => f.call([Quantity.dimensionless(-1.0)]),
        returnsNormally,
      );
    });

    test('value equal to open min is rejected', () {
      final f = _IdentityFunction(
        domain: [const QuantitySpec(min: Bound(0.0, closed: false))],
      );
      expect(
        () => f.call([Quantity.dimensionless(0.0)]),
        throwsA(isA<EvalException>()),
      );
    });

    test('value above closed max is rejected', () {
      final f = _IdentityFunction(
        domain: [const QuantitySpec(max: Bound(1.0, closed: true))],
      );
      expect(
        () => f.call([Quantity.dimensionless(2.0)]),
        throwsA(isA<EvalException>()),
      );
    });

    test('value equal to closed max is accepted', () {
      final f = _IdentityFunction(
        domain: [const QuantitySpec(max: Bound(1.0, closed: true))],
      );
      expect(
        () => f.call([Quantity.dimensionless(1.0)]),
        returnsNormally,
      );
    });

    test('value equal to open max is rejected', () {
      final f = _IdentityFunction(
        domain: [const QuantitySpec(max: Bound(1.0, closed: false))],
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
        range: QuantitySpec(quantity: Quantity(1.0, Dimension({'m': 1}))),
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
        range: const QuantitySpec(max: Bound(5.0, closed: true)),
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
        () => f.callInverse([Quantity.unity]),
        throwsA(
          isA<EvalException>().having(
            (e) => e.message,
            'message',
            contains('noInverse'),
          ),
        ),
      );
    });

    test('throws EvalException when arg count != 1', () {
      final f = _IdentityFunction(id: 'inv', hasInverse: true);
      expect(
        () => f.callInverse([]),
        throwsA(isA<EvalException>()),
      );
      expect(
        () => f.callInverse([Quantity.unity, Quantity.unity]),
        throwsA(isA<EvalException>()),
      );
    });

    test('validates arg against range spec', () {
      final f = _IdentityFunction(
        id: 'inv',
        hasInverse: true,
        range: QuantitySpec(
          quantity: Quantity.unity,
          min: const Bound(-1.0, closed: true),
          max: const Bound(1.0, closed: true),
        ),
      );
      expect(
        () => f.callInverse([Quantity.dimensionless(2.0)]),
        throwsA(isA<EvalException>()),
      );
      // value within range passes
      expect(f.callInverse([Quantity.dimensionless(0.5)]).value, 0.5);
    });

    test('validates result against domain[0] spec', () {
      final f = _IdentityFunction(
        id: 'inv',
        hasInverse: true,
        domain: [
          QuantitySpec(
            quantity: Quantity.unity,
            min: const Bound(0.0, closed: true),
          ),
        ],
      );
      // _IdentityFunction returns its arg, so result = arg = -1 → domain violation
      expect(
        () => f.callInverse([Quantity.dimensionless(-1.0)]),
        throwsA(isA<EvalException>()),
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
        () => f.callInverse([Quantity.unity]),
        throwsA(isA<EvalException>()),
      );
    });
  });

  // -- PiecewiseFunction --

  group('PiecewiseFunction', () {
    // A simple monotonically increasing table: x ∈ [1,3], y ∈ [10,30]
    // (output unit: kelvin, factor 1.0)
    final kelvinDim = Dimension({'K': 1});

    PiecewiseFunction makeSimple() => PiecewiseFunction(
      id: 'simple',
      outputUnit: Quantity(1.0, Dimension({'K': 1})),
      noerror: false,
      points: const [(1.0, 10.0), (2.0, 20.0), (3.0, 30.0)],
    );

    // A non-monotonic table: x ∈ [0,4], y goes 0→10→5→10→0
    PiecewiseFunction makeNonMonotonic() => PiecewiseFunction(
      id: 'nonmono',
      outputUnit: Quantity(1.0, Dimension({'K': 1})),
      noerror: false,
      points: const [
        (0.0, 0.0),
        (1.0, 10.0),
        (2.0, 5.0),
        (3.0, 10.0),
        (4.0, 0.0),
      ],
    );

    group('class properties', () {
      test('arity is 1', () {
        expect(makeSimple().arity, equals(1));
      });

      test('hasInverse is true', () {
        expect(makeSimple().hasInverse, isTrue);
      });

      test('range quantity dimension matches outputUnit dimension', () {
        final f = makeSimple();
        expect(f.range?.quantity?.dimension, equals(kelvinDim));
      });

      test('range min is minimum y value across all points (closed)', () {
        final f = makeSimple();
        expect(f.range?.min?.value, equals(10.0));
        expect(f.range?.min?.closed, isTrue);
      });

      test('range max is maximum y value across all points (closed)', () {
        final f = makeSimple();
        expect(f.range?.max?.value, equals(30.0));
        expect(f.range?.max?.closed, isTrue);
      });

      test(
        'range min/max use global y extremes for non-monotonic functions',
        () {
          final f = makeNonMonotonic();
          expect(f.range?.min?.value, equals(0.0));
          expect(f.range?.max?.value, equals(10.0));
        },
      );

      test('domain is a single dimensionless spec', () {
        final f = makeSimple();
        expect(f.domain?.length, equals(1));
        expect(
          f.domain?.first.quantity?.dimension,
          equals(Dimension.dimensionless),
        );
      });

      test('domain bounds match x range of points', () {
        final f = makeSimple();
        expect(f.domain?.first.min?.value, equals(1.0));
        expect(f.domain?.first.min?.closed, isTrue);
        expect(f.domain?.first.max?.value, equals(3.0));
        expect(f.domain?.first.max?.closed, isTrue);
      });

      test('throws ArgumentError when constructed with empty points list', () {
        expect(
          () => PiecewiseFunction(
            id: 'empty',
            outputUnit: Quantity(1.0, Dimension({'K': 1})),
            noerror: false,
            points: const [],
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('noerror field is stored', () {
        final f = PiecewiseFunction(
          id: 'f',
          outputUnit: Quantity.unity,
          noerror: true,
          points: const [(0.0, 0.0), (1.0, 1.0)],
        );
        expect(f.noerror, isTrue);
      });
    });

    group('forward evaluation', () {
      test('exact lower boundary returns first y * factor', () {
        final f = makeSimple();
        final result = f.call([Quantity.unity]);
        expect(result.value, closeTo(10.0, 1e-10));
        expect(result.dimension, equals(kelvinDim));
      });

      test('exact upper boundary returns last y * factor', () {
        final f = makeSimple();
        final result = f.call([Quantity.dimensionless(3.0)]);
        expect(result.value, closeTo(30.0, 1e-10));
      });

      test('exact interior control point returns that y', () {
        final f = makeSimple();
        final result = f.call([Quantity.dimensionless(2.0)]);
        expect(result.value, closeTo(20.0, 1e-10));
      });

      test('midpoint of segment is interpolated', () {
        final f = makeSimple();
        final result = f.call([Quantity.dimensionless(1.5)]);
        expect(result.value, closeTo(15.0, 1e-10));
      });

      test('outputUnit.value scales the result', () {
        final f = PiecewiseFunction(
          id: 'f',
          outputUnit: Quantity(2.0, Dimension({'K': 1})),
          noerror: false,
          points: const [(1.0, 10.0), (3.0, 30.0)],
        );
        final result = f.call([Quantity.dimensionless(2.0)]);
        expect(result.value, closeTo(40.0, 1e-10)); // y=20.0, factor=2.0
      });

      test('input below domain throws EvalException', () {
        final f = makeSimple();
        expect(
          () => f.call([Quantity.dimensionless(0.5)]),
          throwsA(isA<EvalException>()),
        );
      });

      test('input above domain throws EvalException', () {
        final f = makeSimple();
        expect(
          () => f.call([Quantity.dimensionless(3.5)]),
          throwsA(isA<EvalException>()),
        );
      });
    });

    group('inverse evaluation', () {
      test('monotonic: returns unique x', () {
        final f = makeSimple();
        final result = f.callInverse([
          Quantity(20.0, Dimension({'K': 1})),
        ]);
        expect(result.value, closeTo(2.0, 1e-10));
        expect(result.dimension.isDimensionless, isTrue);
      });

      test('monotonic: boundary y returns boundary x', () {
        final f = makeSimple();
        final result = f.callInverse([
          Quantity(10.0, Dimension({'K': 1})),
        ]);
        expect(result.value, closeTo(1.0, 1e-10));
      });

      test('non-monotonic: returns smallest matching x', () {
        // y=10 appears at x=1 and x=3; smallest is x=1.
        final f = makeNonMonotonic();
        final result = f.callInverse([
          Quantity(10.0, Dimension({'K': 1})),
        ]);
        expect(result.value, closeTo(1.0, 1e-10));
      });

      test('inverse result is dimensionless', () {
        final f = makeSimple();
        final result = f.callInverse([
          Quantity(20.0, Dimension({'K': 1})),
        ]);
        expect(result.dimension.isDimensionless, isTrue);
      });

      test('y below yMin throws EvalException before segment scan', () {
        final f = makeSimple();
        expect(
          () => f.callInverse([
            Quantity(5.0, Dimension({'K': 1})),
          ]),
          throwsA(isA<EvalException>()),
        );
      });

      test('y above yMax throws EvalException before segment scan', () {
        final f = makeSimple();
        expect(
          () => f.callInverse([
            Quantity(35.0, Dimension({'K': 1})),
          ]),
          throwsA(isA<EvalException>()),
        );
      });

      test('outputUnit.value is applied when converting inverse input', () {
        // outputUnit.value = 0.5, so raw y = quantity.value / 0.5.
        // points: (1,10), (3,30). To get raw y=20, quantity value must be 10.
        final f = PiecewiseFunction(
          id: 'f',
          outputUnit: Quantity(0.5, Dimension({'K': 1})),
          noerror: false,
          points: const [(1.0, 10.0), (3.0, 30.0)],
        );
        final result = f.callInverse([
          Quantity(10.0, Dimension({'K': 1})),
        ]);
        expect(result.value, closeTo(2.0, 1e-10)); // yRaw=20, x=2
      });

      test(
        'outputUnit.value > 1: value in-bounds after normalization succeeds',
        () {
          // outputUnit.value = 10.0; range bounds are raw y in [10, 30].
          // To pass a raw y of 20, the SI quantity value must be 20 * 10 = 200.
          final f = PiecewiseFunction(
            id: 'f',
            outputUnit: Quantity(10.0, Dimension({'K': 1})),
            noerror: false,
            points: const [(1.0, 10.0), (3.0, 30.0)],
          );
          final result = f.callInverse([
            Quantity(200.0, Dimension({'K': 1})),
          ]);
          expect(result.value, closeTo(2.0, 1e-10)); // yRaw=20 → x=2
        },
      );

      test(
        'outputUnit.value > 1: value that appears in-bounds before normalization '
        'but is out-of-bounds after normalization throws EvalException',
        () {
          // outputUnit.value = 10.0; range bounds are raw y in [10, 30].
          // SI value 20.0 would pass a naive [10, 30] check,
          // but normalized: 20.0 / 10.0 = 2.0, which is below the min of 10.
          final f = PiecewiseFunction(
            id: 'f',
            outputUnit: Quantity(10.0, Dimension({'K': 1})),
            noerror: false,
            points: const [(1.0, 10.0), (3.0, 30.0)],
          );
          expect(
            () => f.callInverse([
              Quantity(20.0, Dimension({'K': 1})),
            ]),
            throwsA(isA<EvalException>()),
          );
        },
      );
    });
  });

  // -- DefinedFunction --

  group('DefinedFunction: class properties', () {
    test('arity equals params.length (single param)', () {
      final f = DefinedFunction(
        id: 'f',
        params: ['x'],
        forward: 'x',
      );
      expect(f.arity, equals(1));
    });

    test('arity equals params.length (multi-param)', () {
      final f = DefinedFunction(
        id: 'add',
        params: ['x', 'y'],
        forward: 'x + y',
      );
      expect(f.arity, equals(2));
    });

    test('hasInverse is true when inverse is provided', () {
      final f = DefinedFunction(
        id: 'f',
        params: ['x'],
        forward: 'x + 1',
        inverse: 'f - 1',
      );
      expect(f.hasInverse, isTrue);
    });

    test('hasInverse is false when inverse is null', () {
      final f = DefinedFunction(
        id: 'f',
        params: ['x'],
        forward: 'x',
      );
      expect(f.hasInverse, isFalse);
    });

    test('multi-param function with non-null inverse throws ArgumentError', () {
      expect(
        () => DefinedFunction(
          id: 'bad',
          params: ['x', 'y'],
          forward: 'x + y',
          inverse: 'bad - 1',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('DefinedFunction: forward evaluation', () {
    late UnitRepository repo;
    late EvalContext ctx;

    setUp(() {
      repo = UnitRepository();
      registerPredefinedUnits(repo);
      ctx = EvalContext(repo: repo);
    });

    test('single-param: doubles the argument', () {
      final f = DefinedFunction(
        id: 'double',
        params: ['x'],
        forward: '2 x',
      );
      final result = f.evaluate([Quantity.dimensionless(3.0)], ctx);
      expect(result.value, closeTo(6.0, 1e-10));
      expect(result.isDimensionless, isTrue);
    });

    test('multi-param: adds two arguments', () {
      final f = DefinedFunction(
        id: 'add',
        params: ['x', 'y'],
        forward: 'x + y',
      );
      final result = f.evaluate(
        [Quantity.dimensionless(3.0), Quantity.dimensionless(4.0)],
        ctx,
      );
      expect(result.value, closeTo(7.0, 1e-10));
    });

    test('null context throws EvalException', () {
      final f = DefinedFunction(
        id: 'f',
        params: ['x'],
        forward: 'x',
      );
      expect(
        () => f.evaluate([Quantity.dimensionless(1.0)], null),
        throwsA(isA<EvalException>()),
      );
    });

    test('call() with context evaluates correctly', () {
      final f = DefinedFunction(
        id: 'triple',
        params: ['x'],
        forward: '3 x',
      );
      final result = f.call([Quantity.dimensionless(2.0)], ctx);
      expect(result.value, closeTo(6.0, 1e-10));
    });
  });

  group('DefinedFunction: inverse evaluation', () {
    late UnitRepository repo;
    late EvalContext ctx;

    setUp(() {
      repo = UnitRepository();
      registerPredefinedUnits(repo);
      ctx = EvalContext(repo: repo);
    });

    test(
      'inverse recovers original: incr(x) = x + 1, incr_inv(y) = incr - 1',
      () {
        // Register the function so evaluating 'incr - 1' can reference 'incr' as a bound var.
        final f = DefinedFunction(
          id: 'incr',
          params: ['x'],
          forward: 'x + 1',
          inverse: 'incr - 1',
        );
        repo.registerFunction(f);
        // incr(3) = 4; incr_inv(4) should = 3
        final result = f.callInverse([Quantity.dimensionless(4.0)], ctx);
        expect(result.value, closeTo(3.0, 1e-10));
      },
    );

    test('null context throws EvalException', () {
      final f = DefinedFunction(
        id: 'gfunc',
        params: ['x'],
        forward: 'x',
        inverse: 'gfunc',
      );
      expect(
        () => f.evaluateInverse([Quantity.dimensionless(1.0)], null),
        throwsA(isA<EvalException>()),
      );
    });
  });

  group('DefinedFunction: recursion detection', () {
    late UnitRepository repo;
    late EvalContext ctx;

    setUp(() {
      repo = UnitRepository();
      registerPredefinedUnits(repo);
      ctx = EvalContext(repo: repo);
    });

    test('direct self-recursion throws EvalException (not stack overflow)', () {
      final f = DefinedFunction(
        id: 'selfref',
        params: ['x'],
        forward: 'selfref(x)',
      );
      repo.registerFunction(f);
      expect(
        () => f.call([Quantity.dimensionless(1.0)], ctx),
        throwsA(isA<EvalException>()),
      );
    });

    test('mutual recursion throws EvalException', () {
      final fa = DefinedFunction(
        id: 'fa',
        params: ['x'],
        forward: 'fb(x)',
      );
      final fb = DefinedFunction(
        id: 'fb',
        params: ['x'],
        forward: 'fa(x)',
      );
      repo.registerFunction(fa);
      repo.registerFunction(fb);
      expect(
        () => fa.call([Quantity.dimensionless(1.0)], ctx),
        throwsA(isA<EvalException>()),
      );
    });

    test('non-recursive chain succeeds', () {
      final fa = DefinedFunction(
        id: 'addOne',
        params: ['x'],
        forward: 'x + 1',
      );
      final fb = DefinedFunction(
        id: 'addTwo',
        params: ['x'],
        forward: 'addOne(x) + 1',
      );
      repo.registerFunction(fa);
      repo.registerFunction(fb);
      final result = fb.call([Quantity.dimensionless(5.0)], ctx);
      expect(result.value, closeTo(7.0, 1e-10));
    });
  });
}
