import 'package:flutter_test/flutter_test.dart';
import '../../tool/release_lib.dart';

void main() {
  group('Version', () {
    group('parsing', () {
      test('parses major.minor.patch', () {
        final v = Version.parse('1.2.3');
        expect(v.major, 1);
        expect(v.minor, 2);
        expect(v.patch, 3);
      });

      test('parses version with +build suffix and strips it', () {
        final v = Version.parse('0.1.0+1');
        expect(v.major, 0);
        expect(v.minor, 1);
        expect(v.patch, 0);
      });

      test('parses 0.0.0', () {
        final v = Version.parse('0.0.0');
        expect(v.major, 0);
        expect(v.minor, 0);
        expect(v.patch, 0);
      });

      test('throws on invalid format', () {
        expect(() => Version.parse('1.2'), throwsFormatException);
        expect(() => Version.parse('abc'), throwsFormatException);
        expect(() => Version.parse('1.2.3.4'), throwsFormatException);
        expect(() => Version.parse(''), throwsFormatException);
      });

      test('throws on negative numbers', () {
        expect(() => Version.parse('-1.0.0'), throwsFormatException);
      });
    });

    group('bumping', () {
      test('bump major resets minor and patch', () {
        final v = Version(1, 2, 3);
        final bumped = v.bump(BumpType.major);
        expect(bumped.toString(), '2.0.0');
      });

      test('bump minor resets patch', () {
        final v = Version(1, 2, 3);
        final bumped = v.bump(BumpType.minor);
        expect(bumped.toString(), '1.3.0');
      });

      test('bump patch increments patch only', () {
        final v = Version(1, 2, 3);
        final bumped = v.bump(BumpType.patch);
        expect(bumped.toString(), '1.2.4');
      });

      test('bump major from 0.x.y', () {
        final v = Version(0, 2, 0);
        final bumped = v.bump(BumpType.major);
        expect(bumped.toString(), '1.0.0');
      });
    });

    group('formatting', () {
      test('toString produces major.minor.patch', () {
        expect(Version(0, 1, 0).toString(), '0.1.0');
        expect(Version(10, 20, 30).toString(), '10.20.30');
      });
    });

    group('equality', () {
      test('equal versions are equal', () {
        expect(Version(1, 2, 3), equals(Version(1, 2, 3)));
      });

      test('different versions are not equal', () {
        expect(Version(1, 2, 3), isNot(equals(Version(1, 2, 4))));
      });

      test('hashCode is consistent with equality', () {
        expect(Version(1, 2, 3).hashCode, Version(1, 2, 3).hashCode);
      });
    });
  });

  group('ParsedCommit', () {
    group('parsing', () {
      test('parses feat: prefix', () {
        final c = ParsedCommit.parse('abc1234 feat: add new feature')!;
        expect(c.hash, 'abc1234');
        expect(c.type, 'feat');
        expect(c.scope, isNull);
        expect(c.message, 'add new feature');
      });

      test('parses fix: prefix', () {
        final c = ParsedCommit.parse('abc1234 fix: correct bug')!;
        expect(c.type, 'fix');
        expect(c.message, 'correct bug');
      });

      test('parses prefix with scope', () {
        final c = ParsedCommit.parse('abc1234 feat(parser): add functions')!;
        expect(c.type, 'feat');
        expect(c.scope, 'parser');
        expect(c.message, 'add functions');
      });

      test('parses all recognized prefixes', () {
        for (final prefix in [
          'feat',
          'fix',
          'refactor',
          'perf',
          'docs',
          'test',
          'chore',
          'build',
          'ci',
          'style',
        ]) {
          final c = ParsedCommit.parse('abc1234 $prefix: some message')!;
          expect(
            c.type,
            prefix,
            reason: 'prefix "$prefix" should be recognized',
          );
        }
      });

      test('unrecognized prefix becomes type "other"', () {
        final c = ParsedCommit.parse('abc1234 some random commit message')!;
        expect(c.type, 'other');
        expect(c.message, 'some random commit message');
      });

      test('returns null for merge commits', () {
        final c = ParsedCommit.parse(
          "abc1234 Merge branch 'feature' into main",
        );
        expect(c, isNull);
      });

      test('returns null for Merge pull request commits', () {
        final c = ParsedCommit.parse(
          'abc1234 Merge pull request #42 from user/branch',
        );
        expect(c, isNull);
      });

      test('handles colon with no space after prefix', () {
        final c = ParsedCommit.parse('abc1234 feat:no space')!;
        expect(c.type, 'feat');
        expect(c.message, 'no space');
      });

      test('handles extra whitespace in message', () {
        final c = ParsedCommit.parse('abc1234 feat:   extra spaces  ')!;
        expect(c.type, 'feat');
        expect(c.message, 'extra spaces');
      });

      test('handles full-length hash', () {
        final hash = 'a' * 40;
        final c = ParsedCommit.parse('$hash feat: message')!;
        expect(c.hash, hash);
        expect(c.type, 'feat');
      });
    });

    group('changelogSection', () {
      test('feat maps to Added', () {
        final c = ParsedCommit.parse('abc feat: x');
        expect(c!.changelogSection, 'Added');
      });

      test('fix maps to Fixed', () {
        final c = ParsedCommit.parse('abc fix: x');
        expect(c!.changelogSection, 'Fixed');
      });

      test('refactor maps to Changed', () {
        final c = ParsedCommit.parse('abc refactor: x');
        expect(c!.changelogSection, 'Changed');
      });

      test('perf maps to Changed', () {
        final c = ParsedCommit.parse('abc perf: x');
        expect(c!.changelogSection, 'Changed');
      });

      test('docs maps to Documentation', () {
        final c = ParsedCommit.parse('abc docs: x');
        expect(c!.changelogSection, 'Documentation');
      });

      test('test, chore, build, ci, style are omitted (null)', () {
        for (final prefix in ['test', 'chore', 'build', 'ci', 'style']) {
          final c = ParsedCommit.parse('abc $prefix: x');
          expect(
            c!.changelogSection,
            isNull,
            reason: '"$prefix" should be omitted from changelog',
          );
        }
      });

      test('other maps to Other', () {
        final c = ParsedCommit.parse('abc some untyped message');
        expect(c!.changelogSection, 'Other');
      });
    });
  });

  group('formatChangelogSection', () {
    test('groups commits by category', () {
      final commits = [
        ParsedCommit.parse('aaa feat: add feature A')!,
        ParsedCommit.parse('bbb fix: fix bug B')!,
        ParsedCommit.parse('ccc feat: add feature C')!,
      ];
      final result = formatChangelogSection(
        '1.0.0',
        '0.9.0',
        '2026-01-01',
        commits,
      );
      expect(result, contains('[1.0.0] - 2026-01-01\n---'));
      expect(result, isNot(contains('[1.0.0](')));
      expect(result, contains('### Added'));
      expect(result, contains('- add feature A'));
      expect(result, contains('- add feature C'));
      expect(result, contains('### Fixed'));
      expect(result, contains('- fix bug B'));
    });

    test('omits empty categories', () {
      final commits = [ParsedCommit.parse('aaa feat: add feature A')!];
      final result = formatChangelogSection(
        '1.0.0',
        '0.9.0',
        '2026-01-01',
        commits,
      );
      expect(result, contains('### Added'));
      expect(result, isNot(contains('### Fixed')));
      expect(result, isNot(contains('### Changed')));
    });

    test('omits test/chore/build/ci/style commits', () {
      final commits = [
        ParsedCommit.parse('aaa feat: add feature')!,
        ParsedCommit.parse('bbb test: add test')!,
        ParsedCommit.parse('ccc chore: cleanup')!,
      ];
      final result = formatChangelogSection(
        '1.0.0',
        '0.9.0',
        '2026-01-01',
        commits,
      );
      expect(result, contains('- add feature'));
      expect(result, isNot(contains('add test')));
      expect(result, isNot(contains('cleanup')));
    });

    test('handles empty commits list', () {
      final result = formatChangelogSection('1.0.0', '0.9.0', '2026-01-01', []);
      expect(result, contains('[1.0.0] - 2026-01-01\n---'));
      expect(result, isNot(contains('[1.0.0](')));
      // Should still have the header even with no entries
    });

    test('includes Other section for untyped commits', () {
      final commits = [ParsedCommit.parse('aaa some random change')!];
      final result = formatChangelogSection(
        '1.0.0',
        '0.9.0',
        '2026-01-01',
        commits,
      );
      expect(result, contains('### Other'));
      expect(result, contains('- some random change'));
    });

    test('orders sections: Added, Changed, Fixed, Documentation, Other', () {
      final commits = [
        ParsedCommit.parse('aaa random thing')!,
        ParsedCommit.parse('bbb fix: a fix')!,
        ParsedCommit.parse('ccc docs: update docs')!,
        ParsedCommit.parse('ddd feat: a feature')!,
        ParsedCommit.parse('eee refactor: a refactor')!,
      ];
      final result = formatChangelogSection(
        '1.0.0',
        '0.9.0',
        '2026-01-01',
        commits,
      );
      final addedIndex = result.indexOf('### Added');
      final changedIndex = result.indexOf('### Changed');
      final fixedIndex = result.indexOf('### Fixed');
      final docsIndex = result.indexOf('### Documentation');
      final otherIndex = result.indexOf('### Other');
      expect(addedIndex, lessThan(changedIndex));
      expect(changedIndex, lessThan(fixedIndex));
      expect(fixedIndex, lessThan(docsIndex));
      expect(docsIndex, lessThan(otherIndex));
    });
  });

  group('formatTagMessage', () {
    test('includes version and changelog body', () {
      final commits = [
        ParsedCommit.parse('aaa feat: add feature A')!,
        ParsedCommit.parse('bbb fix: fix bug B')!,
      ];
      final section = formatChangelogSection(
        '1.0.0',
        '0.9.0',
        '2026-01-01',
        commits,
      );
      final result = formatTagMessage('1.0.0', section);
      expect(result, startsWith('Release v1.0.0\n\n'));
      expect(result, contains('### Added'));
      expect(result, contains('- add feature A'));
      expect(result, contains('### Fixed'));
      expect(result, contains('- fix bug B'));
    });

    test('strips heading and dashes from changelog section', () {
      final commits = [ParsedCommit.parse('aaa feat: add feature')!];
      final section = formatChangelogSection(
        '2.0.0',
        '1.9.0',
        '2026-03-01',
        commits,
      );
      final result = formatTagMessage('2.0.0', section);
      expect(result, isNot(contains('[2.0.0] -')));
      expect(result, isNot(contains('-----')));
    });

    test('does not have trailing blank lines', () {
      final commits = [ParsedCommit.parse('aaa feat: add feature')!];
      final section = formatChangelogSection(
        '1.0.0',
        '0.9.0',
        '2026-01-01',
        commits,
      );
      final result = formatTagMessage('1.0.0', section);
      expect(result, isNot(endsWith('\n')));
    });

    test('falls back to simple message with no commits', () {
      final section = formatChangelogSection(
        '1.0.0',
        '0.9.0',
        '2026-01-01',
        [],
      );
      final result = formatTagMessage('1.0.0', section);
      expect(result, 'Release v1.0.0');
    });
  });

  group('updatePubspecVersion', () {
    test('replaces version line', () {
      const content = 'name: myapp\nversion: 0.1.0\n\nenvironment:\n';
      final result = updatePubspecVersion(content, '0.2.0');
      expect(result, contains('version: 0.2.0'));
      expect(result, isNot(contains('0.1.0')));
    });

    test('strips +build suffix when replacing', () {
      const content = 'name: myapp\nversion: 0.1.0+1\n\nenvironment:\n';
      final result = updatePubspecVersion(content, '0.2.0');
      expect(result, contains('version: 0.2.0'));
      expect(result, isNot(contains('+1')));
    });

    test('preserves surrounding content', () {
      const content =
          'name: myapp\nversion: 0.1.0+1\n\nenvironment:\n  sdk: ^3.0.0\n';
      final result = updatePubspecVersion(content, '0.2.0');
      expect(result, contains('name: myapp'));
      expect(result, contains('environment:'));
      expect(result, contains('sdk: ^3.0.0'));
    });

    test('throws if no version line found', () {
      const content = 'name: myapp\n\nenvironment:\n';
      expect(() => updatePubspecVersion(content, '0.2.0'), throwsStateError);
    });
  });

  group('formatLinkReference', () {
    test('produces correct reference line', () {
      final result = formatLinkReference('1.0.0', '0.9.0');
      expect(
        result,
        '[1.0.0]: https://github.com/wisnij/unitary/compare/v0.9.0...v1.0.0',
      );
    });

    test('uses repoUrl prefix', () {
      final result = formatLinkReference('1.0.0', '0.9.0');
      expect(result, startsWith('[1.0.0]: https://github.com/wisnij/unitary'));
    });
  });

  group('updateChangelog', () {
    const header =
        'Changelog\n'
        '=========\n'
        '\n'
        'All notable changes to this project will be documented in this file.\n'
        '\n'
        'The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),\n'
        'and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).\n';

    const existingEntry =
        '\n'
        '\n'
        '[0.1.0] - 2026-01-01\n'
        '---------------------\n'
        '\n'
        '- Initial release\n';

    test('inserts new section after header', () {
      const content = header + existingEntry;
      const newSection =
          '[0.2.0] - 2026-02-01\n'
          '---------------------\n'
          '\n'
          '### Added\n'
          '\n'
          '- New feature\n';
      final result = updateChangelog(content, newSection);
      final headerEnd = result.indexOf('Semantic Versioning');
      final newSectionStart = result.indexOf('[0.2.0]');
      final oldSectionStart = result.indexOf('[0.1.0]');
      expect(newSectionStart, greaterThan(headerEnd));
      expect(newSectionStart, lessThan(oldSectionStart));
    });

    test('preserves existing entries', () {
      const content = header + existingEntry;
      const newSection =
          '[0.2.0] - 2026-02-01\n---------------------\n\n- New stuff\n';
      final result = updateChangelog(content, newSection);
      expect(result, contains('[0.1.0] - 2026-01-01'));
      expect(result, contains('- Initial release'));
    });

    test('works with header-only changelog', () {
      final result = updateChangelog(
        header,
        '[0.1.0] - 2026-01-01\n---------------------\n\n- First\n',
      );
      expect(result, contains('Changelog'));
      expect(result, contains('[0.1.0]'));
    });

    test('inserts link ref before existing link ref block', () {
      const existingLinkRef =
          '\n[0.1.0]: https://github.com/wisnij/unitary/compare/v0.0.1...v0.1.0\n';
      const content = header + existingEntry + existingLinkRef;
      const newSection =
          '[0.2.0] - 2026-02-01\n'
          '--------------------\n'
          '\n'
          '- New stuff\n';
      const newLinkRef =
          '[0.2.0]: https://github.com/wisnij/unitary/compare/v0.1.0...v0.2.0';
      final result = updateChangelog(content, newSection, newLinkRef);
      final newLinkIndex = result.indexOf('[0.2.0]: ');
      final oldLinkIndex = result.indexOf('[0.1.0]: ');
      expect(newLinkIndex, greaterThanOrEqualTo(0));
      expect(oldLinkIndex, greaterThanOrEqualTo(0));
      expect(newLinkIndex, lessThan(oldLinkIndex));
    });

    test('appends link ref when no link ref block exists', () {
      const content = header + existingEntry;
      const newSection =
          '[0.2.0] - 2026-02-01\n'
          '--------------------\n'
          '\n'
          '- New stuff\n';
      const newLinkRef =
          '[0.2.0]: https://github.com/wisnij/unitary/compare/v0.1.0...v0.2.0';
      final result = updateChangelog(content, newSection, newLinkRef);
      expect(result, contains(newLinkRef));
      // Link ref appears after the version headings
      expect(
        result.indexOf(newLinkRef),
        greaterThan(result.indexOf('[0.1.0] - 2026-01-01')),
      );
      // One blank line before the link ref
      expect(result, contains('\n\n$newLinkRef\n'));
    });
  });

  group('formatUnreleasedSection', () {
    test('returns null when no commits produce changelog entries', () {
      final commits = [
        ParsedCommit.parse('aaa test: add test')!,
        ParsedCommit.parse('bbb chore: cleanup')!,
        ParsedCommit.parse('ccc ci: update workflow')!,
      ];
      expect(formatUnreleasedSection(commits), isNull);
    });

    test('returns null for empty commit list', () {
      expect(formatUnreleasedSection([]), isNull);
    });

    test('heading is exactly [Unreleased] with 12 dashes', () {
      final commits = [ParsedCommit.parse('aaa feat: add feature')!];
      final result = formatUnreleasedSection(commits)!;
      final lines = result.split('\n');
      expect(lines[0], '[Unreleased]');
      expect(lines[1], '------------');
      expect(lines[1].length, '[Unreleased]'.length);
    });

    test('body uses same section groups as versioned entries', () {
      final commits = [
        ParsedCommit.parse('aaa feat: add feature')!,
        ParsedCommit.parse('bbb fix: fix bug')!,
        ParsedCommit.parse('ccc refactor: improve code')!,
        ParsedCommit.parse('ddd docs: update docs')!,
      ];
      final result = formatUnreleasedSection(commits)!;
      expect(result, contains('### Added'));
      expect(result, contains('- add feature'));
      expect(result, contains('### Fixed'));
      expect(result, contains('- fix bug'));
      expect(result, contains('### Changed'));
      expect(result, contains('- improve code'));
      expect(result, contains('### Documentation'));
      expect(result, contains('- update docs'));
    });

    test('omits empty section groups', () {
      final commits = [ParsedCommit.parse('aaa feat: add feature')!];
      final result = formatUnreleasedSection(commits)!;
      expect(result, contains('### Added'));
      expect(result, isNot(contains('### Fixed')));
      expect(result, isNot(contains('### Changed')));
    });

    test('omits test/chore/build/ci/style commits', () {
      final commits = [
        ParsedCommit.parse('aaa feat: keep this')!,
        ParsedCommit.parse('bbb test: skip this')!,
        ParsedCommit.parse('ccc style: skip this too')!,
      ];
      final result = formatUnreleasedSection(commits)!;
      expect(result, contains('keep this'));
      expect(result, isNot(contains('skip this')));
    });

    test('sections are in the standard order', () {
      final commits = [
        ParsedCommit.parse('aaa fix: a fix')!,
        ParsedCommit.parse('bbb feat: a feature')!,
        ParsedCommit.parse('ccc docs: some docs')!,
      ];
      final result = formatUnreleasedSection(commits)!;
      expect(
        result.indexOf('### Added'),
        lessThan(result.indexOf('### Fixed')),
      );
      expect(
        result.indexOf('### Fixed'),
        lessThan(result.indexOf('### Documentation')),
      );
    });
  });

  group('formatUnreleasedLinkRef', () {
    test('produces correct reference line', () {
      final result = formatUnreleasedLinkRef('0.5.9');
      expect(
        result,
        '[Unreleased]: https://github.com/wisnij/unitary/compare/v0.5.9...HEAD',
      );
    });

    test('uses repoUrl prefix', () {
      final result = formatUnreleasedLinkRef('1.2.3');
      expect(
        result,
        startsWith('[Unreleased]: https://github.com/wisnij/unitary'),
      );
    });

    test('interpolates lastTag correctly', () {
      final result = formatUnreleasedLinkRef('2.0.0');
      expect(result, contains('v2.0.0...HEAD'));
    });
  });

  group('extractUnreleasedBody', () {
    const header =
        'Changelog\n'
        '=========\n'
        '\n'
        'All notable changes.\n'
        '\n'
        'The format is based on Keep a Changelog.\n';

    test('returns null when no [Unreleased] section present', () {
      const content =
          '$header'
          '\n\n'
          '[0.1.0] - 2026-01-01\n'
          '---------------------\n'
          '\n'
          '### Added\n'
          '\n'
          '- Initial release\n';
      expect(extractUnreleasedBody(content), isNull);
    });

    test('returns body when [Unreleased] section is present', () {
      const content =
          '$header'
          '\n\n'
          '[Unreleased]\n'
          '------------\n'
          '\n'
          '### Added\n'
          '\n'
          '- New thing\n'
          '\n\n'
          '[0.1.0] - 2026-01-01\n'
          '---------------------\n'
          '\n'
          '- Initial release\n';
      final body = extractUnreleasedBody(content)!;
      expect(body, contains('### Added'));
      expect(body, contains('- New thing'));
      expect(body, isNot(contains('[0.1.0]')));
    });

    test('trims leading and trailing blank lines from body', () {
      const content =
          '$header'
          '\n\n'
          '[Unreleased]\n'
          '------------\n'
          '\n'
          '### Added\n'
          '\n'
          '- Item\n'
          '\n';
      final body = extractUnreleasedBody(content)!;
      expect(body, isNot(startsWith('\n')));
      expect(body, isNot(endsWith('\n')));
    });

    test('returns null when [Unreleased] section has empty body', () {
      const content =
          '$header'
          '\n\n'
          '[Unreleased]\n'
          '------------\n'
          '\n'
          '\n'
          '[0.1.0] - 2026-01-01\n'
          '---------------------\n'
          '\n'
          '- Initial release\n';
      expect(extractUnreleasedBody(content), isNull);
    });

    test('body does not include the next versioned section', () {
      const content =
          '$header'
          '\n\n'
          '[Unreleased]\n'
          '------------\n'
          '\n'
          '### Fixed\n'
          '\n'
          '- Fix A\n'
          '\n\n'
          '[0.5.9] - 2026-03-14\n'
          '--------------------\n'
          '\n'
          '### Added\n'
          '\n'
          '- Feature B\n';
      final body = extractUnreleasedBody(content)!;
      expect(body, contains('Fix A'));
      expect(body, isNot(contains('Feature B')));
      expect(body, isNot(contains('[0.5.9]')));
    });
  });

  group('updateUnreleasedSection', () {
    const header =
        'Changelog\n'
        '=========\n'
        '\n'
        'All notable changes.\n'
        '\n'
        'The format is based on Keep a Changelog.\n';

    const versionEntry =
        '\n\n'
        '[0.1.0] - 2026-01-01\n'
        '---------------------\n'
        '\n'
        '- Initial release\n';

    const versionLinkRef =
        '\n[0.1.0]: https://github.com/wisnij/unitary/compare/v0.0.1...v0.1.0\n';

    const newSection =
        '[Unreleased]\n'
        '------------\n'
        '\n'
        '### Added\n'
        '\n'
        '- New feature\n';

    const newLinkRef =
        '[Unreleased]: https://github.com/wisnij/unitary/compare/v0.1.0...HEAD';

    test('inserts [Unreleased] section before existing versioned entries', () {
      const content = header + versionEntry + versionLinkRef;
      final result = updateUnreleasedSection(content, newSection, newLinkRef);
      final unreleasedIndex = result.indexOf('[Unreleased]');
      final versionIndex = result.indexOf('[0.1.0] - 2026-01-01');
      expect(unreleasedIndex, greaterThanOrEqualTo(0));
      expect(unreleasedIndex, lessThan(versionIndex));
    });

    test('inserts [Unreleased] link ref before versioned link refs', () {
      const content = header + versionEntry + versionLinkRef;
      final result = updateUnreleasedSection(content, newSection, newLinkRef);
      final unreleasedLinkIndex = result.indexOf('[Unreleased]: ');
      final versionLinkIndex = result.indexOf('[0.1.0]: ');
      expect(unreleasedLinkIndex, greaterThanOrEqualTo(0));
      expect(unreleasedLinkIndex, lessThan(versionLinkIndex));
    });

    test('replaces existing [Unreleased] section in-place', () {
      const oldSection =
          '[Unreleased]\n'
          '------------\n'
          '\n'
          '### Fixed\n'
          '\n'
          '- Old fix\n';
      const oldLinkRef =
          '\n[Unreleased]: https://github.com/wisnij/unitary/compare/v0.0.9...HEAD\n';
      const content = '$header\n\n$oldSection$versionEntry$oldLinkRef';
      final result = updateUnreleasedSection(content, newSection, newLinkRef);
      expect(result, contains('- New feature'));
      expect(result, isNot(contains('- Old fix')));
    });

    test('updates link ref when replacing existing section', () {
      const oldSection =
          '[Unreleased]\n'
          '------------\n'
          '\n'
          '### Fixed\n'
          '\n'
          '- Old fix\n';
      const oldLinkRef =
          '\n[Unreleased]: https://github.com/wisnij/unitary/compare/v0.0.9...HEAD\n';
      const content = '$header\n\n$oldSection$versionEntry$oldLinkRef';
      final result = updateUnreleasedSection(content, newSection, newLinkRef);
      expect(result, contains(newLinkRef));
      expect(result, isNot(contains('v0.0.9...HEAD')));
    });

    test('appends link ref when no link ref block exists', () {
      const content = header + versionEntry;
      final result = updateUnreleasedSection(content, newSection, newLinkRef);
      expect(result, contains(newLinkRef));
    });
  });

  group('removeUnreleasedSection', () {
    const header =
        'Changelog\n'
        '=========\n'
        '\n'
        'All notable changes.\n'
        '\n'
        'The format is based on Keep a Changelog.\n';

    const unreleasedSection =
        '\n\n'
        '[Unreleased]\n'
        '------------\n'
        '\n'
        '### Added\n'
        '\n'
        '- Pending feature\n';

    const unreleasedLinkRef =
        '[Unreleased]: https://github.com/wisnij/unitary/compare/v0.1.0...HEAD\n';

    const versionEntry =
        '\n\n'
        '[0.1.0] - 2026-01-01\n'
        '---------------------\n'
        '\n'
        '- Initial release\n';

    const versionLinkRef =
        '[0.1.0]: https://github.com/wisnij/unitary/compare/v0.0.1...v0.1.0\n';

    test('removes [Unreleased] heading, dashes, and body', () {
      const content = '$header$unreleasedSection$versionEntry\n$versionLinkRef';
      final result = removeUnreleasedSection(content);
      expect(result, isNot(contains('[Unreleased]\n')));
      expect(result, isNot(contains('### Added')));
      expect(result, isNot(contains('- Pending feature')));
    });

    test('removes [Unreleased]: link reference', () {
      const content =
          '$header$unreleasedSection$versionEntry\n$unreleasedLinkRef$versionLinkRef';
      final result = removeUnreleasedSection(content);
      expect(result, isNot(contains('[Unreleased]:')));
    });

    test('preserves versioned entries', () {
      const content = '$header$unreleasedSection$versionEntry\n$versionLinkRef';
      final result = removeUnreleasedSection(content);
      expect(result, contains('[0.1.0] - 2026-01-01'));
      expect(result, contains('- Initial release'));
    });

    test('preserves versioned link references', () {
      const content =
          '$header$unreleasedSection$versionEntry\n$unreleasedLinkRef$versionLinkRef';
      final result = removeUnreleasedSection(content);
      expect(result, contains(versionLinkRef.trim()));
    });

    test('is a no-op when no [Unreleased] section present', () {
      const content = '$header$versionEntry\n$versionLinkRef';
      final result = removeUnreleasedSection(content);
      expect(result, content);
    });
  });
}
