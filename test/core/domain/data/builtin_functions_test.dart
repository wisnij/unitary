import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:unitary/core/domain/data/builtin_functions.dart';
import 'package:unitary/core/domain/errors.dart';
import 'package:unitary/core/domain/models/dimension.dart';
import 'package:unitary/core/domain/models/function.dart';
import 'package:unitary/core/domain/models/quantity.dart';
import 'package:unitary/core/domain/models/unit_repository.dart';

void main() {
  group('BuiltinFunction structure', () {
    final allBuiltins = [
      sinFn,
      cosFn,
      tanFn,
      asinFn,
      acosFn,
      atanFn,
      lnFn,
      logFn,
      expFn,
    ];

    test('hasInverse is false for all 9 builtins', () {
      for (final f in allBuiltins) {
        expect(
          f.hasInverse,
          isFalse,
          reason: '${f.id}.hasInverse should be false',
        );
      }
    });

    test('arity is 1 for all 9 builtins', () {
      for (final f in allBuiltins) {
        expect(f.arity, 1, reason: '${f.id}.arity should be 1');
      }
    });

    test('atan2: arity is 2', () {
      expect(atan2Fn.arity, 2);
    });

    test('atan2: hasInverse is false', () {
      expect(atan2Fn.hasInverse, isFalse);
    });

    test('atan2: domain is two dimensionless specs', () {
      expect(atan2Fn.domain?.length, 2);
      expect(atan2Fn.domain![0].quantity?.dimension, Dimension.dimensionless);
      expect(atan2Fn.domain![1].quantity?.dimension, Dimension.dimensionless);
    });

    test('atan2: range is radian', () {
      expect(atan2Fn.range?.quantity?.dimension, Dimension({'radian': 1}));
    });

    test('log has no aliases', () {
      expect(logFn.aliases, isEmpty);
    });

    group('domain specs', () {
      final radianDim = Dimension({'radian': 1});
      final dimensionlessDim = Dimension.dimensionless;

      test('sin: domain accepts radian + pure dimensionless', () {
        expect(sinFn.domain, isNotNull);
        final spec = sinFn.domain![0];
        expect(spec.quantity?.dimension, radianDim);
        expect(spec.acceptDimensionless, isTrue);
      });

      test('cos: domain accepts radian + pure dimensionless', () {
        final spec = cosFn.domain![0];
        expect(spec.quantity?.dimension, radianDim);
        expect(spec.acceptDimensionless, isTrue);
      });

      test('tan: domain accepts radian + pure dimensionless', () {
        final spec = tanFn.domain![0];
        expect(spec.quantity?.dimension, radianDim);
        expect(spec.acceptDimensionless, isTrue);
      });

      test('asin: domain dimensionless, min=-1 closed, max=1 closed', () {
        final spec = asinFn.domain![0];
        expect(spec.quantity?.dimension, dimensionlessDim);
        expect(spec.min?.value, -1.0);
        expect(spec.min?.closed, isTrue);
        expect(spec.max?.value, 1.0);
        expect(spec.max?.closed, isTrue);
      });

      test('acos: domain dimensionless, min=-1 closed, max=1 closed', () {
        final spec = acosFn.domain![0];
        expect(spec.quantity?.dimension, dimensionlessDim);
        expect(spec.min?.value, -1.0);
        expect(spec.min?.closed, isTrue);
        expect(spec.max?.value, 1.0);
        expect(spec.max?.closed, isTrue);
      });

      test('atan: domain dimensionless, no bounds', () {
        final spec = atanFn.domain![0];
        expect(spec.quantity?.dimension, dimensionlessDim);
        expect(spec.min, isNull);
        expect(spec.max, isNull);
      });

      test('ln: domain dimensionless, min=0 open', () {
        final spec = lnFn.domain![0];
        expect(spec.quantity?.dimension, dimensionlessDim);
        expect(spec.min?.value, 0.0);
        expect(spec.min?.closed, isFalse);
      });

      test('log: domain dimensionless, min=0 open', () {
        final spec = logFn.domain![0];
        expect(spec.quantity?.dimension, dimensionlessDim);
        expect(spec.min?.value, 0.0);
        expect(spec.min?.closed, isFalse);
      });

      test('exp: domain dimensionless, no bounds', () {
        final spec = expFn.domain![0];
        expect(spec.quantity?.dimension, dimensionlessDim);
        expect(spec.min, isNull);
        expect(spec.max, isNull);
      });
    });

    group('range specs', () {
      final radianDim = Dimension({'radian': 1});
      final dimensionlessDim = Dimension.dimensionless;

      test('sin: range dimensionless', () {
        expect(sinFn.range?.quantity?.dimension, dimensionlessDim);
      });

      test('cos: range dimensionless', () {
        expect(cosFn.range?.quantity?.dimension, dimensionlessDim);
      });

      test('tan: range dimensionless', () {
        expect(tanFn.range?.quantity?.dimension, dimensionlessDim);
      });

      test('asin: range radian', () {
        expect(asinFn.range?.quantity?.dimension, radianDim);
      });

      test('acos: range radian', () {
        expect(acosFn.range?.quantity?.dimension, radianDim);
      });

      test('atan: range radian', () {
        expect(atanFn.range?.quantity?.dimension, radianDim);
      });

      test('ln: range dimensionless', () {
        expect(lnFn.range?.quantity?.dimension, dimensionlessDim);
      });

      test('log: range dimensionless', () {
        expect(logFn.range?.quantity?.dimension, dimensionlessDim);
      });

      test('exp: range dimensionless', () {
        expect(expFn.range?.quantity?.dimension, dimensionlessDim);
      });
    });
  });

  group('BuiltinFunction evaluation', () {
    final radianDim = Dimension({'radian': 1});

    group('sin', () {
      test('sin(0) → 0 (dimensionless)', () {
        final result = sinFn.call([Quantity.dimensionless(0.0)]);
        expect(result.value, closeTo(0.0, 1e-10));
        expect(result.isDimensionless, isTrue);
      });

      test('sin(π/2 rad) → 1.0', () {
        final result = sinFn.call([
          Quantity(math.pi / 2, radianDim),
        ]);
        expect(result.value, closeTo(1.0, 1e-10));
        expect(result.isDimensionless, isTrue);
      });
    });

    group('cos', () {
      test('cos(0) → 1.0', () {
        final result = cosFn.call([Quantity.dimensionless(0.0)]);
        expect(result.value, closeTo(1.0, 1e-10));
      });

      test('cos(π rad) → -1.0', () {
        final result = cosFn.call([Quantity(math.pi, radianDim)]);
        expect(result.value, closeTo(-1.0, 1e-10));
      });
    });

    group('tan', () {
      test('tan(0) → 0.0', () {
        final result = tanFn.call([Quantity.dimensionless(0.0)]);
        expect(result.value, closeTo(0.0, 1e-10));
      });
    });

    group('asin', () {
      test('asin(1.0) → π/2 rad', () {
        final result = asinFn.call([Quantity.dimensionless(1.0)]);
        expect(result.value, closeTo(math.pi / 2, 1e-10));
        expect(result.dimension, radianDim);
      });

      test('asin(1.5) throws BoundsException (max bound violated)', () {
        expect(
          () => asinFn.call([Quantity.dimensionless(1.5)]),
          throwsA(isA<BoundsException>()),
        );
      });
    });

    group('acos', () {
      test('acos(1.0) → 0 rad', () {
        final result = acosFn.call([Quantity.dimensionless(1.0)]);
        expect(result.value, closeTo(0.0, 1e-10));
        expect(result.dimension, radianDim);
      });

      test('acos(-2.0) throws BoundsException (min bound violated)', () {
        expect(
          () => acosFn.call([Quantity.dimensionless(-2.0)]),
          throwsA(isA<BoundsException>()),
        );
      });
    });

    group('atan', () {
      test('atan(1.0) → π/4 rad', () {
        final result = atanFn.call([Quantity.dimensionless(1.0)]);
        expect(result.value, closeTo(math.pi / 4, 1e-10));
        expect(result.dimension, radianDim);
      });
    });

    group('atan2', () {
      test('atan2(1, 1) → π/4 rad', () {
        final result = atan2Fn.call([
          Quantity.dimensionless(1.0),
          Quantity.dimensionless(1.0),
        ]);
        expect(result.value, closeTo(math.pi * 1 / 4, 1e-10));
        expect(result.dimension, radianDim);
      });

      test('atan2(1, -1) → 3π/4 rad', () {
        final result = atan2Fn.call([
          Quantity.dimensionless(1.0),
          Quantity.dimensionless(-1.0),
        ]);
        expect(result.value, closeTo(math.pi * 3 / 4, 1e-10));
        expect(result.dimension, radianDim);
      });

      test('atan2(-1, -1) → -3π/4 rad', () {
        final result = atan2Fn.call([
          Quantity.dimensionless(-1.0),
          Quantity.dimensionless(-1.0),
        ]);
        expect(result.value, closeTo(math.pi * -3 / 4, 1e-10));
        expect(result.dimension, radianDim);
      });

      test('atan2(-1, 1) → -π/4 rad', () {
        final result = atan2Fn.call([
          Quantity.dimensionless(-1.0),
          Quantity.dimensionless(1.0),
        ]);
        expect(result.value, closeTo(math.pi * -1 / 4, 1e-10));
        expect(result.dimension, radianDim);
      });
    });

    group('ln', () {
      test('ln(e) → 1.0', () {
        final result = lnFn.call([Quantity.dimensionless(math.e)]);
        expect(result.value, closeTo(1.0, 1e-10));
        expect(result.isDimensionless, isTrue);
      });

      test('ln(0) throws BoundsException (open min bound violated)', () {
        expect(
          () => lnFn.call([Quantity.dimensionless(0.0)]),
          throwsA(isA<BoundsException>()),
        );
      });

      test('ln(-1) throws BoundsException (min bound violated)', () {
        expect(
          () => lnFn.call([Quantity.dimensionless(-1.0)]),
          throwsA(isA<BoundsException>()),
        );
      });
    });

    group('log (base 10)', () {
      test('log(100) → 2.0', () {
        final result = logFn.call([Quantity.dimensionless(100.0)]);
        expect(result.value, closeTo(2.0, 1e-10));
        expect(result.isDimensionless, isTrue);
      });

      test('log(0) throws BoundsException (open min bound violated)', () {
        expect(
          () => logFn.call([Quantity.dimensionless(0.0)]),
          throwsA(isA<BoundsException>()),
        );
      });

      test('log(-1) throws BoundsException (min bound violated)', () {
        expect(
          () => logFn.call([Quantity.dimensionless(-1.0)]),
          throwsA(isA<BoundsException>()),
        );
      });
    });

    group('exp', () {
      test('exp(1) → e', () {
        final result = expFn.call([Quantity.dimensionless(1.0)]);
        expect(result.value, closeTo(math.e, 1e-10));
        expect(result.isDimensionless, isTrue);
      });
    });
  });

  group('registerBuiltinFunctions', () {
    late UnitRepository repo;

    setUp(() {
      repo = UnitRepository();
      registerBuiltinFunctions(repo);
    });

    test('all standard builtins findable via findFunction', () {
      for (final name in [
        'sin',
        'cos',
        'tan',
        'asin',
        'acos',
        'atan',
        'atan2',
        'ln',
        'log',
        'exp',
      ]) {
        expect(
          repo.findFunction(name),
          isNotNull,
          reason: "'$name' should be findable after registration",
        );
      }
    });

    test('log2 is not registered', () {
      expect(repo.findFunction('log2'), isNull);
    });

    test('log10 is not registered', () {
      expect(repo.findFunction('log10'), isNull);
    });

    test('sqrt, cbrt, abs also registered', () {
      expect(repo.findFunction('sqrt'), isNotNull);
      expect(repo.findFunction('cbrt'), isNotNull);
      expect(repo.findFunction('abs'), isNotNull);
    });

    test('returned function is a BuiltinFunction', () {
      expect(repo.findFunction('sin'), isA<BuiltinFunction>());
    });
  });
}
