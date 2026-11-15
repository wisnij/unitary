import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:unitary/features/about/presentation/markdown_style.dart';

/// Returns the app-style theme for [brightness], with the font geometry that
/// `Theme.of` adds, so that its text styles have sizes.
ThemeData _theme(Brightness brightness) {
  final theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    ),
  );
  return ThemeData.localize(
    theme,
    theme.typography.geometryThemeFor(ScriptCategory.englishLike),
  );
}

/// Returns the color that [text] is painted in within [span], following
/// style inheritance from parent spans.  Returns null if [text] is not found
/// or no span on the path sets a color.
Color? _effectiveColor(InlineSpan span, String text, [Color? inherited]) {
  if (span is! TextSpan) {
    return null;
  }
  final color = span.style?.color ?? inherited;
  if ((span.text ?? '').contains(text)) {
    return color;
  }
  for (final child in span.children ?? const <InlineSpan>[]) {
    final found = _effectiveColor(child, text, color);
    if (found != null) {
      return found;
    }
  }
  return null;
}

void main() {
  group('themedMarkdownStyleSheet', () {
    for (final brightness in Brightness.values) {
      group('with a ${brightness.name} theme', () {
        final theme = _theme(brightness);
        final sheet = themedMarkdownStyleSheet(theme);

        test('takes body text styles from the theme', () {
          final body = theme.textTheme.bodyMedium;
          expect(body?.color, isNotNull);
          expect(sheet.p, body);
          expect(sheet.blockquote, body);
          expect(sheet.img, body);
          expect(sheet.listBullet, body);
          expect(sheet.tableBody, body);
        });

        test('takes heading styles from the theme', () {
          expect(sheet.h1, theme.textTheme.headlineSmall);
          expect(sheet.h2, theme.textTheme.titleLarge);
          expect(sheet.h3, theme.textTheme.titleMedium);
          expect(sheet.h4, theme.textTheme.bodyLarge);
          expect(sheet.h5, theme.textTheme.bodyLarge);
          expect(sheet.h6, theme.textTheme.bodyLarge);
        });

        test('derives the code style from the body style', () {
          final body = theme.textTheme.bodyMedium!;
          expect(sheet.code?.color, body.color);
          expect(sheet.code?.fontFamily, 'monospace');
          expect(sheet.code?.fontSize, body.fontSize! * 0.85);
          expect(sheet.code?.backgroundColor, theme.cardTheme.color);
        });

        test('colors the checkbox with the primary color', () {
          expect(sheet.checkbox?.color, theme.primaryColor);
        });

        test('colors block decorations from the theme', () {
          final blockquote = sheet.blockquoteDecoration! as BoxDecoration;
          expect(blockquote.color, theme.colorScheme.surfaceContainerHighest);
          expect(
            (blockquote.border! as Border).left.color,
            theme.colorScheme.primary,
          );

          final codeblock = sheet.codeblockDecoration! as BoxDecoration;
          expect(codeblock.color, theme.cardTheme.color ?? theme.cardColor);

          final rule = sheet.horizontalRuleDecoration! as BoxDecoration;
          expect((rule.border! as Border).top.color, theme.dividerColor);

          expect(sheet.tableBorder?.top.color, theme.dividerColor);
        });
      });
    }

    test('rejects a theme whose body text has no font size', () {
      expect(() => themedMarkdownStyleSheet(ThemeData()), throwsArgumentError);
    });

    testWidgets('paragraph text is painted in the dark theme text color', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(Brightness.dark),
          home: Scaffold(
            body: Builder(
              builder: (context) => Markdown(
                data: 'Hello world',
                styleSheet: themedMarkdownStyleSheet(Theme.of(context)),
              ),
            ),
          ),
        ),
      );

      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byType(Markdown),
          matching: find.byType(RichText),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(Markdown)));
      expect(theme.brightness, Brightness.dark);
      expect(
        _effectiveColor(richText.text, 'Hello world'),
        theme.textTheme.bodyMedium!.color,
      );
    });
  });
}
