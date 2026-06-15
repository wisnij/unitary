import 'package:flutter_test/flutter_test.dart';

import 'package:unitary/shared/utils/date_formatter.dart';

void main() {
  group('formatShortDate', () {
    test('formats a single-digit day', () {
      expect(formatShortDate(DateTime.utc(2026, 6, 6)), 'Jun 6, 2026');
    });

    test('formats a double-digit day', () {
      expect(formatShortDate(DateTime.utc(2026, 6, 16)), 'Jun 16, 2026');
    });

    test('formats every month abbreviation', () {
      const expected = [
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
      for (var month = 1; month <= 12; month++) {
        final result = formatShortDate(DateTime.utc(2026, month, 1));
        expect(result, '${expected[month - 1]} 1, 2026');
      }
    });
  });
}
