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

/// Formats [dt] as `"Mmm D, YYYY, h:mm AM/PM"` in local time
/// (e.g. `"Jun 6, 2026, 3:04 PM"`).
///
/// Used for displaying a date together with a wall-clock time, such as the
/// timestamp of the last successful currency exchange-rate sync.  The value is
/// converted to local time before formatting.
String formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  final month = _monthAbbreviations[local.month - 1];
  final h = local.hour;
  final hour = h % 12 == 0 ? 12 : h % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final amPm = h < 12 ? 'AM' : 'PM';
  return '$month ${local.day}, ${local.year}, $hour:$minute $amPm';
}
