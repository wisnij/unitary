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

  group('formatDateTime', () {
    // Local DateTime values are used so the test is independent of the host
    // timezone (formatDateTime converts to local time before formatting).
    test('formats an afternoon time in 12-hour form', () {
      expect(
        formatDateTime(DateTime(2026, 6, 6, 15, 4)),
        'Jun 6, 2026, 3:04 PM',
      );
    });

    test('formats a morning time', () {
      expect(
        formatDateTime(DateTime(2026, 6, 16, 9, 30)),
        'Jun 16, 2026, 9:30 AM',
      );
    });

    test('renders midnight as 12 AM', () {
      expect(
        formatDateTime(DateTime(2026, 1, 1, 0, 0)),
        'Jan 1, 2026, 12:00 AM',
      );
    });

    test('renders noon as 12 PM', () {
      expect(
        formatDateTime(DateTime(2026, 12, 31, 12, 5)),
        'Dec 31, 2026, 12:05 PM',
      );
    });

    test('zero-pads the minutes', () {
      expect(
        formatDateTime(DateTime(2026, 3, 9, 8, 7)),
        'Mar 9, 2026, 8:07 AM',
      );
    });
  });
}
