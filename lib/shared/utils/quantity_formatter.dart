import 'dart:math' as math;

import '../../core/domain/models/quantity.dart';
import '../../features/settings/models/user_settings.dart';

/// Formats a [Quantity] as a string with value and unit label.
///
/// Dimensionless quantities show only the value. Dimensioned quantities
/// append the canonical dimension representation.
String formatQuantity(
  Quantity quantity, {
  required int precision,
  Notation notation = Notation.decimal,
}) {
  final valueStr = formatValue(
    quantity.value,
    precision: precision,
    notation: notation,
  );
  if (quantity.isDimensionless) {
    return valueStr;
  }
  return '$valueStr ${quantity.dimension.canonicalRepresentation()}';
}

/// Formats a numeric [value] as a string according to [notation] and
/// [precision].
String formatValue(
  double value, {
  required int precision,
  Notation notation = Notation.decimal,
}) {
  if (value == 0) {
    return '0';
  }
  if (value.isInfinite) {
    return value.isNegative ? '-Infinity' : 'Infinity';
  }

  return switch (notation) {
    Notation.decimal => _formatDecimal(value, precision),
    Notation.scientific => _formatScientific(value, precision),
    Notation.engineering => _formatEngineering(value, precision),
  };
}

String _formatDecimal(double value, int precision) {
  final result = value.toStringAsFixed(precision);
  // Strip trailing zeros after decimal point.
  if (result.contains('.')) {
    var trimmed = result;
    while (trimmed.endsWith('0')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('.')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
  return result;
}

/// Computes floor(log10(absValue)) robustly by cross-checking the
/// floating-point log against a power-of-10 round-trip.
int _log10Floor(double absVal) {
  var exp = (math.log(absVal) / math.ln10).floor();
  // Correct for floating-point imprecision: if 10^(exp+1) <= absVal,
  // then exp was too low.
  if (math.pow(10.0, exp + 1) <= absVal) {
    exp++;
  }
  // If 10^exp > absVal, exp was too high.
  if (math.pow(10.0, exp) > absVal) {
    exp--;
  }
  return exp;
}

String _formatScientific(double value, int precision) {
  final negative = value < 0;
  final absVal = value.abs();
  final exponent = _log10Floor(absVal);
  final mantissa = absVal / math.pow(10.0, exponent);

  final mantissaStr = mantissa.toStringAsFixed(precision);
  final sign = negative ? '-' : '';
  final expSign = exponent >= 0 ? '+' : '';
  return '$sign${mantissaStr}e$expSign$exponent';
}

String _formatEngineering(double value, int precision) {
  final negative = value < 0;
  final absVal = value.abs();
  final rawExponent = _log10Floor(absVal);
  // Round exponent down to nearest multiple of 3.
  // Use floorDiv to handle negative exponents correctly.
  final exponent = _floorDiv(rawExponent, 3) * 3;
  final mantissa = absVal / math.pow(10.0, exponent);

  final mantissaStr = mantissa.toStringAsFixed(precision);
  final sign = negative ? '-' : '';
  final expSign = exponent >= 0 ? '+' : '';
  return '$sign${mantissaStr}e$expSign$exponent';
}

/// Floor division that works correctly for negative numbers.
int _floorDiv(int a, int b) {
  final result = a ~/ b;
  // Dart's ~/ truncates toward zero; adjust for negative results.
  if ((a ^ b) < 0 && result * b != a) {
    return result - 1;
  }
  return result;
}
