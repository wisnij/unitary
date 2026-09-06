/// Conversion of Markdown documents into standalone HTML pages published with
/// the web build.
///
/// The document set is data ([defaultWebDocs]), not logic, so publishing a new
/// page is a one-line change here rather than an edit to the conversion.  Each
/// page is self-contained: its styling is inlined, so it renders correctly
/// wherever it is opened, including from the release web archive.
///
/// Pages land under `web/`, which `flutter build web` copies verbatim into
/// `build/web`, so they reach both the `gh-pages` deployment and the release
/// archive with no CI involvement.
library;

import 'dart:io';

import 'package:markdown/markdown.dart' as md;

/// Suffix appended to every generated page's `<title>`.
const String siteTitleSuffix = 'Unitary';

/// Maximum content width, echoing the app's own `kReadableMaxWidth` of 600 dp.
const String contentMaxWidth = '37.5rem';

/// A Markdown document published as an HTML page with the web build.
class WebDoc {
  /// Repository-relative path of the Markdown source, e.g. `PRIVACY.md`.
  final String source;

  /// Repository-relative path of the generated page, e.g.
  /// `web/privacy/index.html`.  Must be under `web/`.
  final String output;

  const WebDoc({required this.source, required this.output});
}

/// The documents published with the web build.
const List<WebDoc> defaultWebDocs = <WebDoc>[
  WebDoc(source: 'PRIVACY.md', output: 'web/privacy/index.html'),
];

/// Thrown when a document cannot be converted.
class WebDocException implements Exception {
  final String message;

  WebDocException(this.message);

  @override
  String toString() => 'WebDocException: $message';
}

/// Inlined stylesheet shared by every generated page.
///
/// Inlined rather than linked so a page renders correctly wherever it is
/// opened, including from the release web archive where no sibling stylesheet
/// would be fetched.  The dark palette uses the app's own surface colour.
const String pageStyle =
    '''
:root {
  color-scheme: light dark;
  --bg: #ffffff;
  --fg: #1a1c1e;
  --muted: #43474e;
  --link: #0b57d0;
  --rule: #c4c7c5;
  --code-bg: #f1f3f4;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #060d18;
    --fg: #e2e2e6;
    --muted: #c3c6cf;
    --link: #a8c7fa;
    --rule: #43474e;
    --code-bg: #16202e;
  }
}
body {
  margin: 0;
  padding: 2rem 1.25rem 3rem;
  background: var(--bg);
  color: var(--fg);
  font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
      "Helvetica Neue", Arial, sans-serif;
  overflow-wrap: break-word;
}
main, footer {
  max-width: $contentMaxWidth;
  margin-inline: auto;
}
h1, h2, h3 {
  line-height: 1.25;
}
h1 {
  font-size: 1.75rem;
  margin: 0 0 0.5em;
}
h2 {
  font-size: 1.25rem;
  margin-top: 2em;
  padding-bottom: 0.3em;
  border-bottom: 1px solid var(--rule);
}
h3 {
  font-size: 1.05rem;
  margin-top: 1.75em;
}
a {
  color: var(--link);
}
ul, ol {
  padding-left: 1.4em;
}
li {
  margin: 0.35em 0;
}
code {
  background: var(--code-bg);
  padding: 0.15em 0.35em;
  border-radius: 3px;
  font-size: 0.9em;
}
pre {
  background: var(--code-bg);
  padding: 1em;
  border-radius: 4px;
  overflow-x: auto;
}
pre code {
  background: none;
  padding: 0;
}
table {
  border-collapse: collapse;
}
th, td {
  border: 1px solid var(--rule);
  padding: 0.4em 0.7em;
  text-align: left;
}
footer {
  margin-top: 3rem;
  padding-top: 1rem;
  border-top: 1px solid var(--rule);
  font-size: 0.9em;
}
footer a {
  color: var(--muted);
  text-decoration: none;
}
footer a:hover {
  text-decoration: underline;
}''';

/// Matches the first level-1 heading, tolerating attributes such as an id.
final RegExp _h1Pattern = RegExp(
  '<h1[^>]*>(.*?)</h1>',
  dotAll: true,
  caseSensitive: false,
);

/// Matches any `href` attribute value in rendered HTML.
final RegExp _hrefPattern = RegExp('''href=["']([^"']*)["']''');

/// Matches an HTML tag, for reducing heading markup to plain text.
final RegExp _tagPattern = RegExp('<[^>]+>');

/// Renders [markdown] to HTML.
///
/// Uses the GitHub-web extension set, so tables and fenced code blocks work
/// and headings carry ids, which lets a published document deep-link to its
/// own sections.
String renderMarkdown(String markdown) =>
    md.markdownToHtml(markdown, extensionSet: md.ExtensionSet.gitHubWeb);

/// Extracts the text of the first level-1 heading in rendered [html].
///
/// Throws a [WebDocException] naming [source] when there is none: an untitled
/// page is never what was intended.
String extractTitle(String html, {required String source}) {
  final match = _h1Pattern.firstMatch(html);
  if (match == null) {
    throw WebDocException(
      '$source has no level-1 heading, so its page would have no title',
    );
  }
  final text = match.group(1)!.replaceAll(_tagPattern, '').trim();
  if (text.isEmpty) {
    throw WebDocException('$source has an empty level-1 heading');
  }
  return text;
}

/// Relative href from [output]'s directory back to the web root.
///
/// Derived from the page's depth below `web/` rather than configured per
/// document, so a more deeply nested page still points at the app.  Always
/// relative: a standalone page receives no `--base-href` substitution, so a
/// root-absolute link would resolve to the hosting domain, not to the app.
String backLinkFor(String output) {
  if (!output.startsWith('web/')) {
    throw WebDocException('Output "$output" is not under web/');
  }
  // Drop the leading "web" and the file name; what remains is the depth.
  final depth = output.split('/').length - 2;
  return depth == 0 ? './' : '../' * depth;
}

/// Whether [href] points at a Markdown file, and so must be converted.
bool _isMarkdownLink(String href) {
  if (href.isEmpty || href.startsWith('#')) {
    return false;
  }
  if ((Uri.tryParse(href)?.scheme ?? '').isNotEmpty) {
    return false;
  }
  return _linkPath(href).toLowerCase().endsWith('.md');
}

/// The path part of [href], without any query or fragment.
String _linkPath(String href) => href.split('#').first.split('?').first;

/// Throws a [WebDocException] if [html] links to a `.md` file that is not the
/// source of some document in [docs].
///
/// Such a link would publish dead.  Rewriting them is deliberately out of
/// scope; failing here surfaces them at generation time instead.
void checkLinks(
  String html, {
  required String source,
  required List<WebDoc> docs,
}) {
  final converted = docs.map((d) => d.source).toSet();
  for (final match in _hrefPattern.allMatches(html)) {
    final href = match.group(1)!;
    if (!_isMarkdownLink(href)) {
      continue;
    }
    final target = _linkPath(href);
    if (!converted.contains(target)) {
      throw WebDocException(
        '$source links to "$target", which is not a converted document.  '
        'Add it to the document set, or link to its published location.',
      );
    }
  }
}

/// Renders a complete HTML page for [doc] from its Markdown [markdown].
String renderPage(
  WebDoc doc,
  String markdown, {
  List<WebDoc> docs = defaultWebDocs,
}) {
  final body = renderMarkdown(markdown);
  final title = extractTitle(body, source: doc.source);
  checkLinks(body, source: doc.source, docs: docs);
  final backLink = backLinkFor(doc.output);

  return '''
<!DOCTYPE html>
<!--
  GENERATED FILE - do not edit.
  Generated from ${doc.source} by tool/generate_web_docs.dart.
-->
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title — $siteTitleSuffix</title>
<style>
$pageStyle
</style>
</head>
<body>
<main>
$body</main>
<footer><a href="$backLink">← $siteTitleSuffix</a></footer>
</body>
</html>
''';
}

/// Writes [contents] to [file] unless it already holds exactly that.
///
/// Returns whether anything was written.
bool writeIfChanged(File file, String contents) {
  if (file.existsSync() && file.readAsStringSync() == contents) {
    return false;
  }
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
  return true;
}

/// Generates every document in [docs], resolving paths against [root].
///
/// Returns the output paths that were actually written.
List<String> generateWebDocs({
  List<WebDoc> docs = defaultWebDocs,
  String root = '.',
}) {
  final written = <String>[];
  for (final doc in docs) {
    final sourceFile = File('$root/${doc.source}');
    if (!sourceFile.existsSync()) {
      throw WebDocException('Source document ${doc.source} does not exist');
    }
    final page = renderPage(doc, sourceFile.readAsStringSync(), docs: docs);
    if (writeIfChanged(File('$root/${doc.output}'), page)) {
      written.add(doc.output);
    }
  }
  return written;
}
