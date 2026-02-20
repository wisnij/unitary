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
  Notation notation = Notation.automatic,
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
  Notation notation = Notation.automatic,
}) {
  if (value == 0) {
    return '0';
  }
  if (value.isInfinite) {
    return value.isNegative ? '-Infinity' : 'Infinity';
  }

  return switch (notation) {
    Notation.automatic => _formatAutomatic(value, precision),
    Notation.scientific => _formatScientific(value, precision),
    Notation.engineering => _formatEngineering(value, precision),
  };
}

String _formatAutomatic(double value, int precision) {
  final result = value.toStringAsPrecision(precision);
  final eIndex = result.indexOf('e');
  final significand = eIndex == -1 ? result : result.substring(0, eIndex);
  final suffix = eIndex == -1 ? '' : result.substring(eIndex);

  if (significand.contains('.')) {
    var trimmed = significand;
    while (trimmed.endsWith('0')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('.')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return '$trimmed$suffix';
  }
  return '$significand$suffix';
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

/// Formats an output unit string for display after a numeric value.
///
/// Rules applied in order:
/// 1. If [unit] contains `+` or `-`, it is wrapped in parentheses to avoid
///    ambiguity with the preceding numeric result.
/// 2. Else if [unit] starts with a digit (`0`–`9`) or `.`, it is prefixed
///    with `× ` (U+00D7) so it does not visually run together with the number.
/// 3. Otherwise, [unit] is returned unchanged.
String formatOutputUnit(String unit) {
  if (unit.contains('+') || unit.contains('-')) {
    return '($unit)';
  }
  if (unit.startsWith(RegExp(r'[0-9.]'))) {
    return '× $unit';
  }
  return unit;
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
