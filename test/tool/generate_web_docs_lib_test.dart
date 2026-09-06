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
  output: 'web/privacy/index.html',
);

/// Renders [markdown] as [sampleDoc] and returns the full page.
String pageFor(String markdown, {List<WebDoc> docs = const [sampleDoc]}) =>
    renderPage(sampleDoc, markdown, docs: docs);

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
        throwsA(
          isA<WebDocException>().having(
            (e) => e.message,
            'message',
            contains('PRIVACY.md'),
          ),
        ),
      );
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
      expect(page, isNot(contains('<link')));
    });

    test('adapts to the dark colour-scheme preference', () {
      expect(page, contains('prefers-color-scheme: dark'));
    });

    test('carries a generated-file marker naming its source', () {
      expect(page, contains('GENERATED FILE'));
      expect(page, contains('PRIVACY.md'));
      expect(page, contains('tool/generate_web_docs.dart'));
    });
  });

  group('Back-link derivation', () {
    test('one level up for a page one directory below web/', () {
      expect(backLinkFor('web/privacy/index.html'), '../');
    });

    test('two levels up for a page two directories below web/', () {
      expect(backLinkFor('web/doc/architecture/index.html'), '../../');
    });

    test('stays in place for a page directly under web/', () {
      expect(backLinkFor('web/privacy.html'), './');
    });

    test('is never root-absolute', () {
      for (final output in [
        'web/privacy.html',
        'web/privacy/index.html',
        'web/doc/architecture/index.html',
      ]) {
        expect(backLinkFor(output), isNot(startsWith('/')));
      }
    });

    test('an output outside web/ is rejected', () {
      expect(
        () => backLinkFor('doc/privacy.html'),
        throwsA(isA<WebDocException>()),
      );
    });

    test('the rendered page uses the derived back-link', () {
      expect(pageFor(sampleMarkdown), contains('href="../"'));
    });
  });

  group('Unresolved link checking', () {
    test('a link to an unconverted .md fails, naming source and target', () {
      expect(
        () => pageFor('Title\n=====\n\nSee [the readme](README.md).\n'),
        throwsA(
          isA<WebDocException>()
              .having((e) => e.message, 'names source', contains('PRIVACY.md'))
              .having((e) => e.message, 'names target', contains('README.md')),
        ),
      );
    });

    test('a link to a converted document is accepted', () {
      final docs = [
        sampleDoc,
        const WebDoc(
          source: 'doc/terminology.md',
          output: 'web/doc/index.html',
        ),
      ];

      expect(
        () => pageFor(
          'Title\n=====\n\nSee [terms](doc/terminology.md).\n',
          docs: docs,
        ),
        returnsNormally,
      );
    });

    test('external http and https links are unaffected', () {
      expect(
        () => pageFor(
          'Title\n=====\n\n[a](https://example.com/x.md) '
          '[b](http://example.com/y.md)\n',
        ),
        returnsNormally,
      );
    });

    test('reference-style links are checked too', () {
      expect(
        () => pageFor(
          'Title\n=====\n\nSee [the readme][r].\n\n[r]: README.md\n',
        ),
        throwsA(isA<WebDocException>()),
      );
    });

    test('anchor-only links are unaffected', () {
      expect(
        () => pageFor('Title\n=====\n\n[top](#title)\n'),
        returnsNormally,
      );
    });
  });

  group('writeIfChanged', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('web_docs_test');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('writes a file that does not exist yet', () {
      final file = File('${tempDir.path}/out.html');

      expect(writeIfChanged(file, 'hello'), isTrue);
      expect(file.readAsStringSync(), 'hello');
    });

    test('leaves byte-identical content untouched', () {
      final file = File('${tempDir.path}/out.html')..writeAsStringSync('hello');
      final before = file.lastModifiedSync();

      expect(writeIfChanged(file, 'hello'), isFalse);
      expect(file.lastModifiedSync(), before);
    });

    test('rewrites changed content', () {
      final file = File('${tempDir.path}/out.html')..writeAsStringSync('hello');

      expect(writeIfChanged(file, 'goodbye'), isTrue);
      expect(file.readAsStringSync(), 'goodbye');
    });

    test('creates missing parent directories', () {
      final file = File('${tempDir.path}/nested/deeper/out.html');

      expect(writeIfChanged(file, 'hello'), isTrue);
      expect(file.readAsStringSync(), 'hello');
    });
  });

  group('generateWebDocs', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('web_docs_gen');
      File('${tempDir.path}/PRIVACY.md')
        ..createSync(recursive: true)
        ..writeAsStringSync(sampleMarkdown);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('converts every declared document', () {
      final written = generateWebDocs(
        docs: const [sampleDoc],
        root: tempDir.path,
      );

      expect(written, ['web/privacy/index.html']);
      expect(
        File('${tempDir.path}/web/privacy/index.html').readAsStringSync(),
        matches(RegExp('<h1[^>]*>Privacy Policy</h1>')),
      );
    });

    test('a second run with no source change writes nothing', () {
      generateWebDocs(docs: const [sampleDoc], root: tempDir.path);

      expect(
        generateWebDocs(docs: const [sampleDoc], root: tempDir.path),
        isEmpty,
      );
    });

    test('a missing source fails, naming the document', () {
      expect(
        () => generateWebDocs(
          docs: const [
            WebDoc(source: 'MISSING.md', output: 'web/x/index.html'),
          ],
          root: tempDir.path,
        ),
        throwsA(
          isA<WebDocException>().having(
            (e) => e.message,
            'message',
            contains('MISSING.md'),
          ),
        ),
      );
    });
  });

  group('Declared document set', () {
    test('publishes the privacy policy', () {
      expect(
        defaultWebDocs.any(
          (d) =>
              d.source == 'PRIVACY.md' && d.output == 'web/privacy/index.html',
        ),
        isTrue,
      );
    });

    test('every output is under web/', () {
      for (final doc in defaultWebDocs) {
        expect(doc.output, startsWith('web/'));
      }
    });
  });
}
