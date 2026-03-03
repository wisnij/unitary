import 'dart:math' as math;

import '../models/dimension.dart';
import '../models/function.dart';
import '../models/quantity.dart';
import '../models/unit_repository.dart';

// Dimension used as the return type of inverse trig functions.
final _radianDim = Dimension({'radian': 1});

// Domain spec for trig functions: accepts radian dimension OR pure dimensionless.
QuantitySpec _trigDomainSpec() => QuantitySpec(
  dimension: _radianDim,
  acceptDimensionless: true,
);

// Spec for a dimensionless quantity (no bounds).
QuantitySpec _dimensionlessSpec() => QuantitySpec(
  dimension: Dimension.dimensionless,
);

// Spec for a radian quantity (no bounds).
QuantitySpec _radianSpec() => QuantitySpec(
  dimension: _radianDim,
);

/// sin: sine of an angle in radians; returns dimensionless in [-1, 1].
final sinFn = BuiltinFunction(
  id: 'sin',
  arity: 1,
  domain: [_trigDomainSpec()],
  range: _dimensionlessSpec(),
  impl: (args) => Quantity.dimensionless(math.sin(args[0].value)),
);

/// cos: cosine of an angle in radians; returns dimensionless in [-1, 1].
final cosFn = BuiltinFunction(
  id: 'cos',
  arity: 1,
  domain: [_trigDomainSpec()],
  range: _dimensionlessSpec(),
  impl: (args) => Quantity.dimensionless(math.cos(args[0].value)),
);

/// tan: tangent of an angle in radians; returns dimensionless.
final tanFn = BuiltinFunction(
  id: 'tan',
  arity: 1,
  domain: [_trigDomainSpec()],
  range: _dimensionlessSpec(),
  impl: (args) => Quantity.dimensionless(math.tan(args[0].value)),
);

/// asin: arcsine of a dimensionless value in [-1, 1]; returns radians.
final asinFn = BuiltinFunction(
  id: 'asin',
  arity: 1,
  domain: [
    QuantitySpec(
      dimension: Dimension.dimensionless,
      min: const Bound(-1.0, closed: true),
      max: const Bound(1.0, closed: true),
    ),
  ],
  range: _radianSpec(),
  impl: (args) => Quantity(math.asin(args[0].value), _radianDim),
);

/// acos: arccosine of a dimensionless value in [-1, 1]; returns radians.
final acosFn = BuiltinFunction(
  id: 'acos',
  arity: 1,
  domain: [
    QuantitySpec(
      dimension: Dimension.dimensionless,
      min: const Bound(-1.0, closed: true),
      max: const Bound(1.0, closed: true),
    ),
  ],
  range: _radianSpec(),
  impl: (args) => Quantity(math.acos(args[0].value), _radianDim),
);

/// atan: arctangent of a dimensionless value; returns radians.
final atanFn = BuiltinFunction(
  id: 'atan',
  arity: 1,
  domain: [QuantitySpec(dimension: Dimension.dimensionless)],
  range: _radianSpec(),
  impl: (args) => Quantity(math.atan(args[0].value), _radianDim),
);

/// atan2: two-argument arctangent of (y, x), both dimensionless; returns radians.
final atan2Fn = BuiltinFunction(
  id: 'atan2',
  arity: 2,
  domain: [
    QuantitySpec(dimension: Dimension.dimensionless),
    QuantitySpec(dimension: Dimension.dimensionless),
  ],
  range: _radianSpec(),
  impl: (args) =>
      Quantity(math.atan2(args[0].value, args[1].value), _radianDim),
);

/// ln: natural logarithm of a positive dimensionless value; returns dimensionless.
final lnFn = BuiltinFunction(
  id: 'ln',
  arity: 1,
  domain: [
    QuantitySpec(
      dimension: Dimension.dimensionless,
      min: const Bound(0.0, closed: false),
    ),
  ],
  range: _dimensionlessSpec(),
  impl: (args) => Quantity.dimensionless(math.log(args[0].value)),
);

/// log: base-10 logarithm of a positive dimensionless value; returns dimensionless.
/// Also accessible as `log10`.
final logFn = BuiltinFunction(
  id: 'log',
  aliases: ['log10'],
  arity: 1,
  domain: [
    QuantitySpec(
      dimension: Dimension.dimensionless,
      min: const Bound(0.0, closed: false),
    ),
  ],
  range: _dimensionlessSpec(),
  impl: (args) => Quantity.dimensionless(math.log(args[0].value) / math.ln10),
);

/// log2: base-2 logarithm of a positive dimensionless value; returns dimensionless.
final log2Fn = BuiltinFunction(
  id: 'log2',
  arity: 1,
  domain: [
    QuantitySpec(
      dimension: Dimension.dimensionless,
      min: const Bound(0.0, closed: false),
    ),
  ],
  range: _dimensionlessSpec(),
  impl: (args) => Quantity.dimensionless(math.log(args[0].value) / math.ln2),
);

/// exp: e raised to a dimensionless power; returns dimensionless.
final expFn = BuiltinFunction(
  id: 'exp',
  arity: 1,
  domain: [QuantitySpec(dimension: Dimension.dimensionless)],
  range: _dimensionlessSpec(),
  impl: (args) => Quantity.dimensionless(math.exp(args[0].value)),
);

/// sqrt: square root of a quantity (any dimension, as long as all dimension
/// exponents are divisible by 2).
final sqrtFn = BuiltinFunction(
  id: 'sqrt',
  arity: 1,
  impl: (args) => args[0].power(1 / 2),
);

/// cbrt: cube root of a quantity (any dimension, as long as all dimension
/// exponents are divisible by 3).
final cbrtFn = BuiltinFunction(
  id: 'cbrt',
  arity: 1,
  impl: (args) => args[0].power(1 / 3),
);

/// abs: absolute value of a quantity (any dimension).
final absFn = BuiltinFunction(
  id: 'abs',
  arity: 1,
  impl: (args) => args[0].abs(),
);

/// Registers all built-in functions into [repo].
///
/// After this call, all 14 builtin functions are available via
/// [UnitRepository.findFunction].
void registerBuiltinFunctions(UnitRepository repo) {
  for (final f in [
    sinFn,
    cosFn,
    tanFn,
    asinFn,
    acosFn,
    atanFn,
    atan2Fn,
    lnFn,
    logFn,
    log2Fn,
    expFn,
    sqrtFn,
    cbrtFn,
    absFn,
  ]) {
    repo.registerFunction(f);
  }
}
