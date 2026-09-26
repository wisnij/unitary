import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate_web_docs_lib.dart';

/// A minimal well-formed document: setext H1 plus a paragraph.
const String sampleMarkdown = '''
Privacy Policy
==============

Unitary collects nothing.
''';

const WebDoc sampleDoc = WebDoc(
  source: 'PRIVACY.md',
  output: 'privacy.html',
  footer: FooterLink(label: '← Unitary', href: './'),
);

const WebDoc indexDoc = WebDoc(
  source: 'README.md',
  output: 'index.html',
  footer: FooterLink(label: 'Source code on GitHub', href: repoUrl),
);

/// A fake repository layout: every listed path is a file, and every proper
/// prefix of one is a directory.
PathResolver fakeRepo(Iterable<String> files) {
  final fileSet = files.toSet();
  final dirs = <String>{''};
  for (final f in fileSet) {
    final parts = f.split('/');
    for (var i = 1; i < parts.length; i++) {
      dirs.add(parts.sublist(0, i).join('/'));
    }
  }
  return (path) {
    if (fileSet.contains(path)) {
      return PathKind.file;
    }
    if (dirs.contains(path)) {
      return PathKind.directory;
    }
    return PathKind.missing;
  };
}

/// A repository holding the two sample documents plus some linkable files.
final PathResolver sampleRepo = fakeRepo([
  'README.md',
  'PRIVACY.md',
  'CONTRIBUTING.md',
  'doc/architecture.md',
  'doc/terminology.md',
  'doc/screenshots/freeform.png',
]);

/// Renders [markdown] as [doc] against [sampleRepo].
RenderedPage render(
  String markdown, {
  WebDoc doc = sampleDoc,
  List<WebDoc> docs = const [sampleDoc, indexDoc],
  PathResolver? resolve,
}) => renderPage(doc, markdown, docs: docs, resolve: resolve ?? sampleRepo);

/// The full HTML of [markdown] rendered as [doc].
String pageFor(String markdown, {WebDoc doc = sampleDoc}) =>
    render(markdown, doc: doc).html;

/// A document whose body is [body] under a throwaway heading.
String withBody(String body) => 'Title\n=====\n\n$body\n';

Matcher throwsWebDoc(List<String> fragments) => throwsA(
  fragments.fold<TypeMatcher<WebDocException>>(
    isA<WebDocException>(),
    (m, f) => m.having((e) => e.message, 'message', contains(f)),
  ),
);

void main() {
  group('Title derivation', () {
    test('title comes from a setext H1', () {
      final page = pageFor(sampleMarkdown);

      expect(page, contains('<title>Privacy Policy — Unitary</title>'));
    });

    test('title comes from an ATX H1 too', () {
      final page = pageFor('# Data Handling\n\nNothing is collected.\n');

      expect(page, contains('<title>Data Handling — Unitary</title>'));
    });

    test('the H1 is retained in the rendered body', () {
      final page = pageFor(sampleMarkdown);

      expect(page, matches(RegExp('<h1[^>]*>Privacy Policy</h1>')));
    });

    test('headings carry ids, so sections can be deep-linked', () {
      final page = pageFor(sampleMarkdown);

      expect(page, contains('<h1 id="privacy-policy">'));
    });

    test('inline markup in the H1 is stripped from the title', () {
      final page = pageFor('Privacy *Policy*\n================\n\nText.\n');

      expect(page, contains('<title>Privacy Policy — Unitary</title>'));
    });

    test('a document with no H1 fails, naming the document', () {
      expect(
        () => pageFor('Just a paragraph, no heading.\n'),
        throwsWebDoc(['PRIVACY.md']),
      );
    });

    test('the site index uses its heading alone as the title', () {
      final page = pageFor('Unitary\n=======\n\nHello.\n', doc: indexDoc);

      expect(page, contains('<title>Unitary</title>'));
      expect(page, isNot(contains('Unitary — Unitary')));
    });

    test('an index.html below the site root is not the site index', () {
      const nested = WebDoc(
        source: 'doc/terminology.md',
        output: 'doc/index.html',
        footer: FooterLink(label: 'Home', href: '../'),
      );

      final page = pageFor('Terms\n=====\n\nText.\n', doc: nested);

      expect(page, contains('<title>Terms — Unitary</title>'));
    });
  });

  group('Page shell', () {
    late String page;

    setUp(() {
      page = pageFor(sampleMarkdown);
    });

    test('declares a character encoding', () {
      expect(page, contains('<meta charset="utf-8">'));
    });

    test('declares a viewport for mobile rendering', () {
      expect(
        page,
        contains(
          '<meta name="viewport" content="width=device-width, '
          'initial-scale=1">',
        ),
      );
    });

    test('is a complete HTML document', () {
      expect(page, startsWith('<!DOCTYPE html>'));
      expect(page, contains('<html lang="en">'));
      expect(page, contains('</html>'));
    });

    test('inlines its styling', () {
      expect(page, contains('<style>'));
    });

    test('references no external stylesheet', () {
      expect(page, isNot(contains('rel="stylesheet"')));
    });

    test('adapts to the dark colour-scheme preference', () {
      expect(page, contains('prefers-color-scheme: dark'));
    });

    test('constrains images to the content width', () {
      expect(pageStyle, matches(RegExp(r'img\s*\{[^}]*max-width:\s*100%')));
    });

    test('lets wide tables scroll instead of overflowing', () {
      expect(pageStyle, matches(RegExp(r'table\s*\{[^}]*overflow-x:\s*auto')));
    });

    test('carries a generated-file marker naming its source', () {
      expect(page, contains('GENERATED FILE'));
      expect(page, contains('PRIVACY.md'));
      expect(page, contains('tool/generate_web_docs.dart'));
    });
  });

  group('Canonical address', () {
    test('a named page is canonical at its extensionless path', () {
      expect(canonicalUrlFor('privacy.html'), '$siteBaseUrl/privacy');
    });

    test('the site index is canonical at the site root', () {
      expect(canonicalUrlFor('index.html'), '$siteBaseUrl/');
    });

    test('a nested index is canonical at its directory', () {
      expect(canonicalUrlFor('doc/index.html'), '$siteBaseUrl/doc/');
    });

    test('a nested page keeps its directory', () {
      expect(
        canonicalUrlFor('doc/architecture.html'),
        '$siteBaseUrl/doc/architecture',
      );
    });

    test('the site base URL is the custom domain', () {
      expect(siteBaseUrl, 'https://unitary.wisnij.dev');
    });

    test('the rendered page declares its canonical address', () {
      expect(
        pageFor(sampleMarkdown),
        contains(
          '<link rel="canonical" href="https://unitary.wisnij.dev/privacy">',
        ),
      );
    });

    test('the rendered index declares the site root', () {
      expect(
        pageFor('Unitary\n=======\n\nHello.\n', doc: indexDoc),
        contains('<link rel="canonical" href="https://unitary.wisnij.dev/">'),
      );
    });

    test('an output without .html is rejected', () {
      expect(() => canonicalUrlFor('privacy'), throwsWebDoc(['privacy']));
    });
  });

  group('Footer', () {
    test('renders the declared label and href', () {
      final page = pageFor(sampleMarkdown);

      expect(page, contains('<footer><a href="./">← Unitary</a></footer>'));
    });

    test('the index footer links to the repository', () {
      final page = pageFor('Unitary\n=======\n\nHello.\n', doc: indexDoc);

      expect(
        page,
        contains(
          '<footer><a href="https://github.com/wisnij/unitary">Source code '
          'on GitHub</a></footer>',
        ),
      );
    });

    test('label and href are HTML-escaped', () {
      const doc = WebDoc(
        source: 'PRIVACY.md',
        output: 'privacy.html',
        footer: FooterLink(label: 'A & <B>', href: './?a=1&b=2'),
      );

      final page = pageFor(sampleMarkdown, doc: doc);

      expect(page, contains('href="./?a=1&amp;b=2"'));
      expect(page, contains('>A &amp; &lt;B&gt;</a>'));
    });
  });

  group('Link resolution', () {
    test('a link to a converted document points at its page', () {
      final page = pageFor(
        withBody('See [privacy](PRIVACY.md).'),
        doc: indexDoc,
      );

      expect(page, contains('href="privacy"'));
    });

    test('a link to the index document points at the site root', () {
      final page = pageFor(withBody('Back to [home](README.md).'));

      expect(page, contains('href="./"'));
    });

    test('a link to an unpublished file goes to GitHub', () {
      final page = pageFor(withBody('See [arch](doc/architecture.md).'));

      expect(
        page,
        contains(
          'href="https://github.com/wisnij/unitary/blob/main/'
          'doc/architecture.md"',
        ),
      );
    });

    test('a link to a directory goes to its GitHub tree', () {
      final page = pageFor(withBody('See [docs](doc/).'));

      expect(
        page,
        contains('href="https://github.com/wisnij/unitary/tree/main/doc"'),
      );
    });

    test('a fragment is preserved when rewriting', () {
      final page = pageFor(withBody('[dim](doc/terminology.md#dimension)'));

      expect(
        page,
        contains(
          'href="https://github.com/wisnij/unitary/blob/main/'
          'doc/terminology.md#dimension"',
        ),
      );
    });

    test('a fragment is preserved on a converted-document link', () {
      final page = pageFor(
        withBody('[net](PRIVACY.md#network-access)'),
        doc: indexDoc,
      );

      expect(page, contains('href="privacy#network-access"'));
    });

    test('a query is preserved when rewriting', () {
      final page = pageFor(withBody('[c](CONTRIBUTING.md?plain=1)'));

      expect(
        page,
        contains(
          'href="https://github.com/wisnij/unitary/blob/main/'
          'CONTRIBUTING.md?plain=1"',
        ),
      );
    });

    test('reference-style links are resolved too', () {
      final page = pageFor(withBody('See [c][r].\n\n[r]: CONTRIBUTING.md'));

      expect(
        page,
        contains(
          'href="https://github.com/wisnij/unitary/blob/main/CONTRIBUTING.md"',
        ),
      );
    });

    test('links resolve against the source document\'s directory', () {
      const nested = WebDoc(
        source: 'doc/terminology.md',
        output: 'terminology.html',
        footer: FooterLink(label: 'Home', href: './'),
      );

      final page = render(
        withBody('[a](architecture.md) [r](../CONTRIBUTING.md)'),
        doc: nested,
      ).html;

      expect(
        page,
        contains(
          'href="https://github.com/wisnij/unitary/blob/main/'
          'doc/architecture.md"',
        ),
      );
      expect(
        page,
        contains(
          'href="https://github.com/wisnij/unitary/blob/main/CONTRIBUTING.md"',
        ),
      );
    });

    test('a converted-document link is relative to a nested page', () {
      const nested = WebDoc(
        source: 'doc/terminology.md',
        output: 'doc/terminology.html',
        footer: FooterLink(label: 'Home', href: '../'),
      );

      final page = render(
        withBody('[p](../PRIVACY.md) [h](../README.md)'),
        doc: nested,
        docs: const [sampleDoc, indexDoc, nested],
      ).html;

      expect(page, contains('href="../privacy"'));
      expect(page, contains('href="../"'));
    });

    test('a root-absolute link resolves against the repository root', () {
      const nested = WebDoc(
        source: 'doc/terminology.md',
        output: 'terminology.html',
        footer: FooterLink(label: 'Home', href: './'),
      );

      final page = render(withBody('[c](/CONTRIBUTING.md)'), doc: nested).html;

      expect(
        page,
        contains(
          'href="https://github.com/wisnij/unitary/blob/main/CONTRIBUTING.md"',
        ),
      );
    });

    test('a link to a missing file fails, naming source and target', () {
      expect(
        () => pageFor(withBody('See [gone](doc/missing.md).')),
        throwsWebDoc(['PRIVACY.md', 'doc/missing.md']),
      );
    });

    test('a link escaping the repository fails', () {
      expect(
        () => pageFor(withBody('[up](../outside.md)')),
        throwsWebDoc(['PRIVACY.md', '../outside.md']),
      );
    });

    test('external links are unchanged', () {
      final page = pageFor(
        withBody('[a](https://example.com/x.md) [b](http://example.com/y)'),
      );

      expect(page, contains('href="https://example.com/x.md"'));
      expect(page, contains('href="http://example.com/y"'));
    });

    test('mailto links are unchanged', () {
      final page = pageFor(withBody('[mail](mailto:someone@example.com)'));

      expect(page, contains('href="mailto:someone@example.com"'));
    });

    test('fragment-only links are unchanged', () {
      final page = pageFor(withBody('[top](#title)'));

      expect(page, contains('href="#title"'));
    });
  });

  group('Images', () {
    test('a local image is recorded for publishing and kept in place', () {
      final result = render(
        withBody('![shot](doc/screenshots/freeform.png)'),
        doc: indexDoc,
      );

      expect(result.images, {'doc/screenshots/freeform.png'});
      expect(result.html, contains('src="doc/screenshots/freeform.png"'));
    });

    test('an image is referenced relative to a nested page', () {
      const nested = WebDoc(
        source: 'README.md',
        output: 'doc/readme.html',
        footer: FooterLink(label: 'Home', href: '../'),
      );

      final result = render(
        withBody('![shot](doc/screenshots/freeform.png)'),
        doc: nested,
      );

      expect(result.images, {'doc/screenshots/freeform.png'});
      expect(result.html, contains('src="screenshots/freeform.png"'));
    });

    test('a missing image fails, naming source and path', () {
      expect(
        () => pageFor(withBody('![gone](doc/screenshots/nope.png)')),
        throwsWebDoc(['PRIVACY.md', 'doc/screenshots/nope.png']),
      );
    });

    test('an image naming a directory fails', () {
      expect(
        () => pageFor(withBody('![dir](doc/screenshots)')),
        throwsWebDoc(['PRIVACY.md', 'doc/screenshots']),
      );
    });

    test('a remote image is neither rewritten nor recorded', () {
      final result = render(
        withBody('![badge](https://img.shields.io/badge/x-y-blue.svg)'),
      );

      expect(result.images, isEmpty);
      expect(
        result.html,
        contains('src="https://img.shields.io/badge/x-y-blue.svg"'),
      );
    });

    test('a linked badge keeps its external link and image', () {
      final result = render(
        withBody(
          '[![CI](https://example.com/badge.svg)](https://example.com/ci)',
        ),
      );

      expect(result.images, isEmpty);
      expect(result.html, contains('href="https://example.com/ci"'));
      expect(result.html, contains('src="https://example.com/badge.svg"'));
    });
  });

  group('generateWebDocs', () {
    late Directory repo;
    late String out;

    setUp(() {
      repo = Directory.systemTemp.createTempSync('web_docs_gen');
      File('${repo.path}/PRIVACY.md').writeAsStringSync(sampleMarkdown);
      File('${repo.path}/README.md').writeAsStringSync(
        'Unitary\n=======\n\n![shot](doc/screenshots/freeform.png)\n\n'
        '[Privacy](PRIVACY.md) and [arch](doc/architecture.md).\n',
      );
      File('${repo.path}/doc/screenshots/freeform.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync([137, 80, 78, 71]);
      File('${repo.path}/doc/architecture.md').writeAsStringSync('# Arch\n');
      out = '${repo.path}/build/site';
    });

    tearDown(() {
      repo.deleteSync(recursive: true);
    });

    List<String> generate({List<WebDoc> docs = const [sampleDoc, indexDoc]}) =>
        generateWebDocs(docs: docs, root: repo.path, outputDir: out);

    test('writes every page and referenced image', () {
      final written = generate();

      expect(written, [
        'doc/screenshots/freeform.png',
        'index.html',
        'privacy.html',
      ]);
      expect(
        File('$out/privacy.html').readAsStringSync(),
        matches(RegExp('<h1[^>]*>Privacy Policy</h1>')),
      );
      expect(
        File('$out/doc/screenshots/freeform.png').readAsBytesSync(),
        [137, 80, 78, 71],
      );
    });

    test('rewrites links in the generated index', () {
      generate();

      final index = File('$out/index.html').readAsStringSync();
      expect(index, contains('href="privacy"'));
      expect(
        index,
        contains('$repoUrl/blob/main/doc/architecture.md'),
      );
    });

    test('replaces the output directory on each run', () {
      File('$out/stale.html')
        ..createSync(recursive: true)
        ..writeAsStringSync('old');

      generate();

      expect(File('$out/stale.html').existsSync(), isFalse);
      expect(File('$out/privacy.html').existsSync(), isTrue);
    });

    test('a missing source fails, naming the document', () {
      expect(
        () => generate(
          docs: const [
            WebDoc(
              source: 'MISSING.md',
              output: 'missing.html',
              footer: FooterLink(label: 'Home', href: './'),
            ),
          ],
        ),
        throwsWebDoc(['MISSING.md']),
      );
    });

    test('two documents with the same output fail', () {
      expect(
        () => generate(
          docs: const [
            sampleDoc,
            WebDoc(
              source: 'README.md',
              output: 'privacy.html',
              footer: FooterLink(label: 'Home', href: './'),
            ),
          ],
        ),
        throwsWebDoc(['privacy.html']),
      );
    });

    test('an output under app/ is refused, since the app is mounted there', () {
      expect(
        () => generate(
          docs: const [
            WebDoc(
              source: 'PRIVACY.md',
              output: 'app/privacy.html',
              footer: FooterLink(label: 'Home', href: '../'),
            ),
          ],
        ),
        throwsWebDoc(['app/privacy.html']),
      );
    });

    group('refuses an output directory', () {
      for (final dir in ['web', 'web/site', 'lib/site', '.', 'build']) {
        test('at $dir, before touching anything', () {
          final target = Directory('${repo.path}/$dir')
            ..createSync(recursive: true);
          final marker = File('${target.path}/keep.txt')
            ..writeAsStringSync('keep');

          expect(
            () => generateWebDocs(
              docs: const [sampleDoc],
              root: repo.path,
              outputDir: target.path,
            ),
            throwsA(isA<WebDocException>()),
          );
          expect(marker.existsSync(), isTrue);
        });
      }

      test('that contains the repository', () {
        expect(
          () => generateWebDocs(
            docs: const [sampleDoc],
            root: repo.path,
            outputDir: repo.parent.path,
          ),
          throwsA(isA<WebDocException>()),
        );
        expect(File('${repo.path}/PRIVACY.md').existsSync(), isTrue);
      });
    });

    test('accepts an output directory outside the repository', () {
      final elsewhere = Directory.systemTemp.createTempSync('web_docs_out');
      addTearDown(() => elsewhere.deleteSync(recursive: true));

      generateWebDocs(
        docs: const [sampleDoc],
        root: repo.path,
        outputDir: '${elsewhere.path}/site',
      );

      expect(File('${elsewhere.path}/site/privacy.html').existsSync(), isTrue);
    });
  });

  group('Declared document set', () {
    test('publishes the README as the site index', () {
      expect(
        defaultWebDocs.any(
          (d) => d.source == 'README.md' && d.output == 'index.html',
        ),
        isTrue,
      );
    });

    test('publishes the privacy policy at /privacy', () {
      expect(
        defaultWebDocs.any(
          (d) => d.source == 'PRIVACY.md' && d.output == 'privacy.html',
        ),
        isTrue,
      );
    });

    test('the index footer links to the repository', () {
      final index = defaultWebDocs.singleWhere((d) => d.output == 'index.html');

      expect(index.footer.href, repoUrl);
      expect(repoUrl, 'https://github.com/wisnij/unitary');
    });

    test('the privacy footer links to the home page', () {
      final privacy = defaultWebDocs.singleWhere(
        (d) => d.output == 'privacy.html',
      );

      expect(privacy.footer.href, './');
    });

    test('generates cleanly against the real repository', () {
      final out = Directory.systemTemp.createTempSync('web_docs_real');
      addTearDown(() => out.deleteSync(recursive: true));

      final written = generateWebDocs(outputDir: '${out.path}/site');

      expect(written, containsAll(['index.html', 'privacy.html']));
      expect(written, contains(startsWith('doc/screenshots/')));
    });

    test('in-page anchors in the README match its heading ids', () {
      final html = renderPage(
        defaultWebDocs.singleWhere((d) => d.source == 'README.md'),
        File('README.md').readAsStringSync(),
        resolve: filesystemResolver('.'),
      ).html;
      final anchors = RegExp(
        'href="#([^"]+)"',
      ).allMatches(html).map((m) => m.group(1)!).toSet();

      expect(anchors, isNotEmpty);
      for (final anchor in anchors) {
        expect(html, contains('id="$anchor"'), reason: '#$anchor');
      }
    });
  });
}
