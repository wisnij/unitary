import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the style sheet for rendering a Markdown document in [theme].
///
/// `flutter_markdown_plus` reads its default styles from the Flutter SDK's own
/// `Theme`, which is a different class from the `material_ui` one this app
/// uses.  It therefore never sees the app theme, and falls back to light
/// default styles that are unreadable in dark mode.  Passing this style sheet
/// to a `Markdown` widget supplies the theme-dependent styles explicitly.
///
/// The values mirror `MarkdownStyleSheet.fromTheme`, so that this function can
/// be replaced by the package's own default once the package supports
/// `material_ui`.
MarkdownStyleSheet themedMarkdownStyleSheet(ThemeData theme) {
  final body = theme.textTheme.bodyMedium;
  final bodyFontSize = body?.fontSize;
  if (body == null || bodyFontSize == null) {
    throw ArgumentError.value(
      theme,
      'theme',
      'textTheme.bodyMedium must have a font size',
    );
  }

  return MarkdownStyleSheet(
    a: const TextStyle(color: Colors.blue),
    p: body,
    pPadding: EdgeInsets.zero,
    code: body.copyWith(
      backgroundColor: theme.cardTheme.color,
      fontFamily: 'monospace',
      fontSize: bodyFontSize * 0.85,
    ),
    h1: theme.textTheme.headlineSmall,
    h1Padding: EdgeInsets.zero,
    h2: theme.textTheme.titleLarge,
    h2Padding: EdgeInsets.zero,
    h3: theme.textTheme.titleMedium,
    h3Padding: EdgeInsets.zero,
    h4: theme.textTheme.bodyLarge,
    h4Padding: EdgeInsets.zero,
    h5: theme.textTheme.bodyLarge,
    h5Padding: EdgeInsets.zero,
    h6: theme.textTheme.bodyLarge,
    h6Padding: EdgeInsets.zero,
    em: const TextStyle(fontStyle: FontStyle.italic),
    strong: const TextStyle(fontWeight: FontWeight.bold),
    del: const TextStyle(decoration: TextDecoration.lineThrough),
    blockquote: body,
    img: body,
    checkbox: body.copyWith(color: theme.primaryColor),
    blockSpacing: 8.0,
    listIndent: 24.0,
    listBullet: body,
    listBulletPadding: const EdgeInsets.only(right: 4),
    tableHead: const TextStyle(fontWeight: FontWeight.w600),
    tableBody: body,
    tableHeadAlign: TextAlign.center,
    tablePadding: const EdgeInsets.only(bottom: 4.0),
    tableBorder: TableBorder.all(color: theme.dividerColor),
    tableColumnWidth: const FlexColumnWidth(),
    tableCellsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    tableCellsDecoration: const BoxDecoration(),
    blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    blockquoteDecoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(3),
      border: Border(
        left: BorderSide(color: theme.colorScheme.primary, width: 3),
      ),
    ),
    codeblockPadding: const EdgeInsets.all(8.0),
    codeblockDecoration: BoxDecoration(
      color: theme.cardTheme.color ?? theme.cardColor,
      borderRadius: BorderRadius.circular(2.0),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(width: 5.0, color: theme.dividerColor),
      ),
    ),
  );
}
