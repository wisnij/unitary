import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'painted_text_color.dart';

const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);

Widget _richText(InlineSpan span) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: RichText(text: span),
  );
}

void main() {
  group('paintedTextColor', () {
    testWidgets('returns the color of the span that holds the text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _richText(
          const TextSpan(
            style: TextStyle(color: _red),
            children: [
              TextSpan(
                text: 'hello',
                style: TextStyle(color: _green),
              ),
            ],
          ),
        ),
      );
      expect(
        paintedTextColor(tester, find.byType(Directionality), 'hello'),
        _green,
      );
    });

    testWidgets('inherits the color of a parent span', (tester) async {
      await tester.pumpWidget(
        _richText(
          const TextSpan(
            style: TextStyle(color: _red),
            children: [TextSpan(text: 'hello')],
          ),
        ),
      );
      expect(
        paintedTextColor(tester, find.byType(Directionality), 'hello'),
        _red,
      );
    });

    testWidgets('returns null when the text is not found', (tester) async {
      await tester.pumpWidget(
        _richText(
          const TextSpan(
            text: 'hello',
            style: TextStyle(color: _red),
          ),
        ),
      );
      expect(
        paintedTextColor(tester, find.byType(Directionality), 'absent'),
        isNull,
      );
    });
  });
}
