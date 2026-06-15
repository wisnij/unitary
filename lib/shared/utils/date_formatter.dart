const _monthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats [date] as `"Mmm D, YYYY"` (e.g. `"Jun 6, 2026"`).
///
/// Used for displaying date-only values (no time component), such as the
/// source date of a fetched currency exchange rate.
String formatShortDate(DateTime date) {
  final month = _monthAbbreviations[date.month - 1];
  return '$month ${date.day}, ${date.year}';
}
