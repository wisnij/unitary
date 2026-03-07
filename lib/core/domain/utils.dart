/// Strips trailing zeros after the decimal point from a numeric string,
/// and removes the decimal point itself if no fractional digits remain.
///
/// Handles exponential notation: only the significand is trimmed, leaving
/// the exponent portion untouched (e.g. `"1.0e+20"` → `"1e+20"`).
String stripTrailingZeros(String s) {
  final eIndex = s.indexOf('e');
  final significand = eIndex == -1 ? s : s.substring(0, eIndex);
  final suffix = eIndex == -1 ? '' : s.substring(eIndex);
  if (!significand.contains('.')) {
    return s;
  }
  var trimmed = significand;
  while (trimmed.endsWith('0')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }
  if (trimmed.endsWith('.')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }
  return '$trimmed$suffix';
}
