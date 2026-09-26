/// Conversion of Markdown documents into the standalone HTML pages of the
/// project site.
///
/// The document set is data ([defaultWebDocs]), not logic, so publishing a new
/// page is a one-line change here rather than an edit to the conversion.  Each
/// page is self-contained: its styling is inlined, so it renders correctly
/// wherever it is opened.
///
/// Pages are generated in CI into a site directory (by default
/// [defaultOutputDir]), together with the local images they reference.  The
/// workflow then adds the web app build under [appMountPath] and deploys the
/// result to GitHub Pages.  Nothing generated here is committed.
library;

import 'dart:convert';
import 'dart:io';

import 'package:markdown/markdown.dart' as md;

/// Suffix appended to the `<title>` of every page except the site index.
const String siteTitleSuffix = 'Unitary';

/// The site's permanent address, used for canonical links.
///
/// Canonical addresses are extensionless (`/privacy`, not `/privacy.html`), so
/// any host serving the site must resolve them, as GitHub Pages does.
const String siteBaseUrl = 'https://unitary.wisnij.dev';

/// The project's GitHub repository.
const String repoUrl = 'https://github.com/wisnij/unitary';

/// The branch the site is deployed from, and so the revision that links to
/// unpublished repository files point at.
const String repoBranch = 'main';

/// Where the site is assembled when no output directory is given, relative to
/// the repository root.
const String defaultOutputDir = 'build/site';

/// Site directory the web app build is mounted at by the workflow.  No
/// generated file may be written there.
const String appMountPath = 'app';

/// Maximum content width, echoing the app's own `kReadableMaxWidth` of 600 dp.
const String contentMaxWidth = '37.5rem';

/// The link shown in a page's footer.
class FooterLink {
  /// Link text.
  final String label;

  /// Link target: an absolute URL, or a path relative to the page.
  final String href;

  const FooterLink({required this.label, required this.href});
}

/// A Markdown document published as a page of the site.
class WebDoc {
  /// Repository-relative path of the Markdown source, e.g. `PRIVACY.md`.
  final String source;

  /// Site-relative path of the generated page, e.g. `privacy.html`, which is
  /// served at the extensionless `/privacy`.  `index.html` at the site root is
  /// the site index.
  final String output;

  /// The link at the foot of the page.
  final FooterLink footer;

  const WebDoc({
    required this.source,
    required this.output,
    required this.footer,
  });
}

/// The documents published on the site.
const List<WebDoc> defaultWebDocs = <WebDoc>[
  WebDoc(
    source: 'README.md',
    output: 'index.html',
    footer: FooterLink(label: 'Source code on GitHub', href: repoUrl),
  ),
  WebDoc(
    source: 'PRIVACY.md',
    output: 'privacy.html',
    footer: FooterLink(label: '← $siteTitleSuffix', href: './'),
  ),
];

/// Thrown when a document cannot be converted or the site cannot be written.
class WebDocException implements Exception {
  final String message;

  WebDocException(this.message);

  @override
  String toString() => 'WebDocException: $message';
}

/// What a repository path refers to.
enum PathKind { file, directory, missing }

/// Looks up a normalised, repository-relative path (`''` is the root).
typedef PathResolver = PathKind Function(String repoPath);

/// A [PathResolver] backed by the repository checked out at [root].
PathResolver filesystemResolver(String root) => (repoPath) {
  final full = repoPath.isEmpty ? root : '$root/$repoPath';
  return switch (FileSystemEntity.typeSync(full)) {
    FileSystemEntityType.notFound => PathKind.missing,
    FileSystemEntityType.directory => PathKind.directory,
    _ => PathKind.file,
  };
};

/// A rendered page, and the local images it needs published alongside it.
class RenderedPage {
  /// The complete HTML document.
  final String html;

  /// Repository-relative paths of the local images the page references.  Each
  /// is published at the same path in the site.
  final Set<String> images;

  const RenderedPage({required this.html, required this.images});
}

/// Inlined stylesheet shared by every generated page.
///
/// Inlined rather than linked so a page renders correctly wherever it is
/// opened, with no sibling stylesheet to fetch.  The dark palette uses the
/// app's own surface colour.
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
img {
  max-width: 100%;
  height: auto;
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
  display: block;
  max-width: 100%;
  overflow-x: auto;
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

const HtmlEscape _attributeEscape = HtmlEscape(HtmlEscapeMode.attribute);
const HtmlEscape _textEscape = HtmlEscape(HtmlEscapeMode.element);

/// Matches the first level-1 heading, tolerating attributes such as an id.
final RegExp _h1Pattern = RegExp(
  '<h1[^>]*>(.*?)</h1>',
  dotAll: true,
  caseSensitive: false,
);

/// Matches an HTML tag, for reducing heading markup to plain text.
final RegExp _tagPattern = RegExp('<[^>]+>');

/// Matches an `<a>` or `<img>` start tag, capturing the name and attributes.
final RegExp _linkTagPattern = RegExp(
  r'<(a|img)\b([^>]*)>',
  caseSensitive: false,
);

/// Matches a URL scheme (`https:`, `mailto:`, `data:`, ...).
final RegExp _schemePattern = RegExp('^[a-zA-Z][a-zA-Z0-9+.-]*:');

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

/// Whether [doc] is the site index, served at `/`.
bool isSiteIndex(WebDoc doc) => doc.output == 'index.html';

/// The extensionless site path [output] is served at: `''` for the root
/// index, `doc/` for `doc/index.html`, `privacy` for `privacy.html`.
String sitePathFor(String output) {
  if (!output.endsWith('.html')) {
    throw WebDocException('Output "$output" is not an .html file');
  }
  final stem = output.substring(0, output.length - '.html'.length);
  if (stem == 'index') {
    return '';
  }
  if (stem.endsWith('/index')) {
    return stem.substring(0, stem.length - 'index'.length);
  }
  return stem;
}

/// The canonical address of the page generated at [output].
String canonicalUrlFor(String output) => '$siteBaseUrl/${sitePathFor(output)}';

/// The directory segments of a site-relative file path.
List<String> _directoryOf(String path) {
  final segments = path.split('/');
  return segments.sublist(0, segments.length - 1);
}

/// A relative URL from the page at [fromOutput] to the site path [to].
///
/// [to] names a directory when it is empty or ends in `/`, and a file
/// otherwise.
String relativeUrl(String fromOutput, String to) {
  final from = _directoryOf(fromOutput);
  final isDirectory = to.isEmpty || to.endsWith('/');
  final target = to.split('/').where((s) => s.isNotEmpty).toList();
  final targetDirectory = isDirectory
      ? target
      : target.sublist(0, target.length - 1);

  var common = 0;
  while (common < from.length &&
      common < targetDirectory.length &&
      from[common] == targetDirectory[common]) {
    common++;
  }

  final rest = target.sublist(common).join('/');
  final url =
      '../' * (from.length - common) +
      rest +
      (isDirectory && rest.isNotEmpty ? '/' : '');
  return url.isEmpty ? './' : url;
}

/// Resolves [linkPath] against [sourceDirectory] into a normalised
/// repository-relative path, or null if it would leave the repository.
///
/// A root-absolute [linkPath] resolves against the repository root, as GitHub
/// renders it.
String? _resolveRepoPath(List<String> sourceDirectory, String linkPath) {
  String decoded;
  try {
    decoded = Uri.decodeFull(linkPath.replaceAll('&amp;', '&'));
  } on ArgumentError {
    decoded = linkPath;
  }
  final segments = decoded.startsWith('/') ? <String>[] : [...sourceDirectory];
  for (final part in decoded.split('/')) {
    if (part.isEmpty || part == '.') {
      continue;
    }
    if (part == '..') {
      if (segments.isEmpty) {
        return null;
      }
      segments.removeLast();
    } else {
      segments.add(part);
    }
  }
  return segments.join('/');
}

/// Splits [url] into its path and its query-and-fragment suffix.
(String, String) _splitSuffix(String url) {
  final cut = url.indexOf(RegExp('[?#]'));
  return cut < 0 ? (url, '') : (url.substring(0, cut), url.substring(cut));
}

/// Whether [url] is left untouched: empty, fragment- or query-only, or
/// absolute (with a scheme, or protocol-relative).
bool _isExternalOrLocal(String url) =>
    url.isEmpty ||
    url.startsWith('#') ||
    url.startsWith('?') ||
    url.startsWith('//') ||
    _schemePattern.hasMatch(url);

/// Rewrites the relative links and image references in rendered [html] for
/// publication as [doc].
///
/// Links resolve against the source document's directory.  A link to a
/// document in [docs] points at its page; any other existing file or directory
/// points at GitHub; a missing target throws.  Local images are kept (made
/// relative to the page) and recorded in [images] for publishing.
String _resolveLinks(
  String html, {
  required WebDoc doc,
  required List<WebDoc> docs,
  required PathResolver resolve,
  required Set<String> images,
}) {
  final sourceDirectory = _directoryOf(doc.source);

  String rewriteHref(String href) {
    final (path, suffix) = _splitSuffix(href);
    final target = _resolveRepoPath(sourceDirectory, path);
    if (target == null) {
      throw WebDocException(
        '${doc.source} links to "$href", which is outside the repository',
      );
    }
    for (final other in docs) {
      if (other.source == target) {
        return _attributeEscape.convert(
              relativeUrl(doc.output, sitePathFor(other.output)),
            ) +
            suffix;
      }
    }
    final url = switch (resolve(target)) {
      PathKind.file => '$repoUrl/blob/$repoBranch/${Uri.encodeFull(target)}',
      PathKind.directory =>
        target.isEmpty
            ? repoUrl
            : '$repoUrl/tree/$repoBranch/${Uri.encodeFull(target)}',
      PathKind.missing => throw WebDocException(
        '${doc.source} links to "$href", which does not exist',
      ),
    };
    return _attributeEscape.convert(url) + suffix;
  }

  String rewriteSrc(String src) {
    final (path, suffix) = _splitSuffix(src);
    final target = _resolveRepoPath(sourceDirectory, path);
    if (target == null || resolve(target) != PathKind.file) {
      throw WebDocException(
        '${doc.source} references image "$src", which is not a file in the '
        'repository',
      );
    }
    images.add(target);
    return _attributeEscape.convert(relativeUrl(doc.output, target)) + suffix;
  }

  return html.replaceAllMapped(_linkTagPattern, (tag) {
    final name = tag.group(1)!.toLowerCase();
    final attribute = name == 'a' ? 'href' : 'src';
    final rewrite = name == 'a' ? rewriteHref : rewriteSrc;
    final attributes = tag.group(2)!.replaceAllMapped(
      RegExp(
        '(\\s$attribute\\s*=\\s*)(["\'])(.*?)\\2',
        caseSensitive: false,
      ),
      (m) {
        final value = m.group(3)!;
        final rewritten = _isExternalOrLocal(value) ? value : rewrite(value);
        return '${m.group(1)}${m.group(2)}$rewritten${m.group(2)}';
      },
    );
    return '<${tag.group(1)}$attributes>';
  });
}

/// Renders a complete HTML page for [doc] from its Markdown [markdown].
///
/// [resolve] answers what repository paths refer to, for link resolution.
RenderedPage renderPage(
  WebDoc doc,
  String markdown, {
  List<WebDoc> docs = defaultWebDocs,
  required PathResolver resolve,
}) {
  final rendered = renderMarkdown(markdown);
  final heading = extractTitle(rendered, source: doc.source);
  final images = <String>{};
  final body = _resolveLinks(
    rendered,
    doc: doc,
    docs: docs,
    resolve: resolve,
    images: images,
  );
  final title = isSiteIndex(doc) ? heading : '$heading — $siteTitleSuffix';
  final canonical = _attributeEscape.convert(canonicalUrlFor(doc.output));
  final footerHref = _attributeEscape.convert(doc.footer.href);
  final footerLabel = _textEscape.convert(doc.footer.label);

  final html =
      '''
<!DOCTYPE html>
<!--
  GENERATED FILE - do not edit.
  Generated from ${doc.source} by tool/generate_web_docs.dart.
-->
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title</title>
<link rel="canonical" href="$canonical">
<style>
$pageStyle
</style>
</head>
<body>
<main>
$body</main>
<footer><a href="$footerHref">$footerLabel</a></footer>
</body>
</html>
''';
  return RenderedPage(html: html, images: images);
}

/// The absolute, normalised form of [path], with symbolic links resolved in
/// whatever part of it already exists.
String _canonicalPath(String path) {
  final segments = <String>[];
  for (final part in File(path).absolute.path.split('/')) {
    if (part.isEmpty || part == '.') {
      continue;
    }
    if (part == '..') {
      if (segments.isNotEmpty) {
        segments.removeLast();
      }
    } else {
      segments.add(part);
    }
  }

  // Resolve symlinks in the longest existing prefix, so that a path through a
  // symlinked directory compares equal to its target.
  for (var i = segments.length; i >= 0; i--) {
    final prefix = '/${segments.sublist(0, i).join('/')}';
    if (FileSystemEntity.typeSync(prefix) != FileSystemEntityType.notFound) {
      final resolved = Directory(prefix).resolveSymbolicLinksSync();
      final rest = segments.sublist(i);
      final base = resolved == '/' ? '' : resolved;
      return rest.isEmpty
          ? (base.isEmpty ? '/' : base)
          : '$base/${rest.join('/')}';
    }
  }
  return '/${segments.join('/')}';
}

/// Throws unless [outputDir] is safe to replace wholesale.
///
/// Inside the repository, only a directory strictly within `build/` is
/// accepted, so a stray argument cannot delete sources or the Flutter build.
/// Outside it, anything is accepted except an ancestor of the repository.
void _checkOutputDir(String outputDir, String root) {
  final out = _canonicalPath(outputDir);
  final repo = _canonicalPath(root);
  if (out == repo || repo.startsWith(out == '/' ? '/' : '$out/')) {
    throw WebDocException(
      'Output directory "$outputDir" contains the repository',
    );
  }
  if (out.startsWith('$repo/') && !out.startsWith('$repo/build/')) {
    throw WebDocException(
      'Output directory "$outputDir" is inside the repository but not '
      'within build/',
    );
  }
}

/// Throws unless [path] is a site-relative path that generated files may use.
void _checkSitePath(String path, {required String what}) {
  final segments = path.split('/');
  if (path.isEmpty ||
      path.startsWith('/') ||
      segments.contains('..') ||
      segments.first == appMountPath) {
    throw WebDocException(
      '$what "$path" is not a usable site path (it must be relative, stay '
      'within the site, and not be under $appMountPath/)',
    );
  }
}

/// Generates the site: every document in [docs] plus the images they
/// reference, read from the repository at [root] and written to [outputDir]
/// (by default [defaultOutputDir] under [root]).
///
/// Everything is rendered before anything is written, so a failure leaves
/// any existing output untouched.  On success the output directory's previous
/// contents are replaced.  Returns the site-relative paths written, sorted.
List<String> generateWebDocs({
  List<WebDoc> docs = defaultWebDocs,
  String root = '.',
  String? outputDir,
}) {
  final out = outputDir ?? '$root/$defaultOutputDir';
  _checkOutputDir(out, root);

  final resolve = filesystemResolver(root);
  final pages = <String, String>{};
  final images = <String>{};
  for (final doc in docs) {
    _checkSitePath(doc.output, what: 'Output of ${doc.source}');
    if (pages.containsKey(doc.output)) {
      throw WebDocException(
        'More than one document is published at ${doc.output}',
      );
    }
    final sourceFile = File('$root/${doc.source}');
    if (!sourceFile.existsSync()) {
      throw WebDocException('Source document ${doc.source} does not exist');
    }
    final page = renderPage(
      doc,
      sourceFile.readAsStringSync(),
      docs: docs,
      resolve: resolve,
    );
    pages[doc.output] = page.html;
    images.addAll(page.images);
  }
  for (final image in images) {
    _checkSitePath(image, what: 'Image');
    if (pages.containsKey(image)) {
      throw WebDocException('Image $image collides with a generated page');
    }
  }

  final outDir = Directory(out);
  if (outDir.existsSync()) {
    outDir.deleteSync(recursive: true);
  }
  for (final MapEntry(key: path, value: html) in pages.entries) {
    File('$out/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(html);
  }
  for (final image in images) {
    File('$out/$image').parent.createSync(recursive: true);
    File('$root/$image').copySync('$out/$image');
  }
  return [...pages.keys, ...images]..sort();
}
