import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns the color in which [text] is painted by a [RichText] under
/// [within], or null if no such text is found or no color applies to it.
///
/// The color is resolved the way painting resolves it: a span without a color
/// of its own inherits the color of its parent span.  The style of a
/// [RichText]'s root span is often only the ambient `DefaultTextStyle`, with
/// the real style on a child span, so reading the root style alone can report
/// a color that is never painted.
Color? paintedTextColor(WidgetTester tester, Finder within, String text) {
  final richTexts = tester.widgetList<RichText>(
    find.descendant(of: within, matching: find.byType(RichText)),
  );
  for (final richText in richTexts) {
    final color = _colorOf(richText.text, text, null);
    if (color != null) {
      return color;
    }
  }
  return null;
}

Color? _colorOf(InlineSpan span, String text, Color? inherited) {
  if (span is! TextSpan) {
    return null;
  }
  final color = span.style?.color ?? inherited;
  if ((span.text ?? '').contains(text)) {
    return color;
  }
  for (final child in span.children ?? const <InlineSpan>[]) {
    final found = _colorOf(child, text, color);
    if (found != null) {
      return found;
    }
  }
  return null;
}
