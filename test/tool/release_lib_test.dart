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

    group('version code', () {
      test('derives the code from the semantic version', () {
        expect(Version(1, 0, 0).versionCode, 1000000);
        expect(Version(1, 2, 3).versionCode, 1002003);
        expect(Version(0, 9, 7).versionCode, 9007);
      });

      test('derives the code from the version part alone', () {
        expect(Version.parse('1.2.3+1002003').versionCode, 1002003);
        // A stale or wrong recorded suffix does not influence the result.
        expect(Version.parse('1.2.3+1').versionCode, 1002003);
      });

      test('clears the code carried by every published release', () {
        expect(Version(0, 9, 7).versionCode, greaterThan(1));
      });

      test('increases strictly with every kind of bump', () {
        final versions = [
          Version(0, 0, 0),
          Version(0, 9, 7),
          Version(1, 0, 0),
          Version(1, 2, 3),
          // Near the top of the encodable range: every bump of this one
          // still lands inside it.
          Version(9, 998, 998),
        ];
        for (final version in versions) {
          for (final type in BumpType.values) {
            expect(
              version.bump(type).versionCode,
              greaterThan(version.versionCode),
              reason: 'bumping $version by $type must increase its code',
            );
          }
        }
      });

      test('a bump past the ceiling throws rather than colliding', () {
        // Monotonicity holds only across encodable versions. Bumping a
        // component that is already at its ceiling produces a version whose
        // code would collide with the next component up, so the guard rejects
        // it instead of returning the smaller-or-equal value.
        expect(
          () => Version(1, 0, 999).bump(BumpType.patch).versionCode,
          throwsRangeError,
        );
        expect(
          () => Version(1, 999, 0).bump(BumpType.minor).versionCode,
          throwsRangeError,
        );
      });

      test('orders a chain of successive releases', () {
        final chain = [
          Version(0, 9, 7),
          Version(0, 9, 8),
          Version(0, 10, 0),
          Version(1, 0, 0),
          Version(1, 0, 1),
        ];
        for (var i = 1; i < chain.length; i++) {
          expect(chain[i].versionCode, greaterThan(chain[i - 1].versionCode));
        }
      });

      test('throws when the minor component is out of range', () {
        expect(() => Version(1, 1000, 0).versionCode, throwsRangeError);
        expect(() => Version(1, 1001, 0).versionCode, throwsRangeError);
      });

      test('throws when the patch component is out of range', () {
        expect(() => Version(1, 0, 1000).versionCode, throwsRangeError);
      });

      test('accepts the largest encodable minor and patch components', () {
        expect(Version(1, 999, 999).versionCode, 1999999);
      });

      test('throws when the code would exceed the Android maximum', () {
        expect(() => Version(2100, 0, 1).versionCode, throwsRangeError);
        expect(() => Version(2101, 0, 0).versionCode, throwsRangeError);
      });

      test('accepts the largest version code Android allows', () {
        expect(Version(2100, 0, 0).versionCode, 2100000000);
        expect(Version(2100, 0, 0).versionCode, Version.maxAndroidVersionCode);
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

      test('conventional subject on a merge commit is parsed normally', () {
        // With --first-parent, a merge commit whose subject was manually set to
        // a conventional form (e.g. "feat: ...") passes through the guard and is
        // classified like any other commit.
        final c = ParsedCommit.parse(
          'abc1234 feat: Remove freeform persistence',
        );
        expect(c, isNotNull);
        expect(c!.type, 'feat');
        expect(c.message, 'Remove freeform persistence');
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

    test('items within a section appear oldest-first', () {
      // Simulates git log order: newer commits first.
      final commits = [
        ParsedCommit.parse('ccc feat: newest feature')!,
        ParsedCommit.parse('bbb feat: middle feature')!,
        ParsedCommit.parse('aaa feat: oldest feature')!,
      ];
      final result = formatChangelogSection(
        '1.0.0',
        '0.9.0',
        '2026-01-01',
        commits,
      );
      final oldestIndex = result.indexOf('- oldest feature');
      final middleIndex = result.indexOf('- middle feature');
      final newestIndex = result.indexOf('- newest feature');
      expect(oldestIndex, lessThan(middleIndex));
      expect(middleIndex, lessThan(newestIndex));
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

    test('writes the name and derived code for a bumped version', () {
      const content = 'name: myapp\nversion: 0.9.7+9007\n\nenvironment:\n';
      final newVersion = Version.parse('0.9.7').bump(BumpType.patch);
      final result = updatePubspecVersion(content, newVersion.pubspecVersion);
      expect(result, contains('version: 0.9.8+9008'));
    });

    test('leaves no stale code behind when replacing a suffixed version', () {
      const content = 'name: myapp\nversion: 1.2.3+1002003\n\nenvironment:\n';
      final result = updatePubspecVersion(
        content,
        Version(1, 3, 0).pubspecVersion,
      );
      expect(result, contains('version: 1.3.0+1003000'));
      expect(result, isNot(contains('1002003')));
      expect('+'.allMatches(result).length, 1);
    });

    test('writes a suffix onto a version line that had none', () {
      const content = 'name: myapp\nversion: 0.9.7\n\nenvironment:\n';
      final result = updatePubspecVersion(
        content,
        Version(0, 9, 8).pubspecVersion,
      );
      expect(result, contains('version: 0.9.8+9008'));
      expect('+'.allMatches(result).length, 1);
    });
  });

  group('pubspecVersion', () {
    test('joins the version name and its derived code', () {
      expect(Version(1, 2, 3).pubspecVersion, '1.2.3+1002003');
      expect(Version(0, 9, 7).pubspecVersion, '0.9.7+9007');
      expect(Version(1, 0, 0).pubspecVersion, '1.0.0+1000000');
    });

    test('round-trips through Version.parse', () {
      final version = Version(1, 2, 3);
      expect(Version.parse(version.pubspecVersion), equals(version));
    });

    test('throws when the code cannot be derived', () {
      expect(() => Version(1, 1000, 0).pubspecVersion, throwsRangeError);
    });
  });

  group('checkVersionCodeConsistency', () {
    test('accepts a version whose code matches its name', () {
      expect(checkVersionCodeConsistency('1.2.3+1002003'), isNull);
      expect(checkVersionCodeConsistency('0.9.7+9007'), isNull);
      expect(checkVersionCodeConsistency('1.0.0+1000000'), isNull);
    });

    test('reports a code that disagrees with the name', () {
      final message = checkVersionCodeConsistency('1.2.3+1');
      expect(message, isNotNull);
      expect(message, contains('1002003'));
    });

    test('reports a missing code', () {
      final message = checkVersionCodeConsistency('1.2.3');
      expect(message, isNotNull);
      expect(message, contains('1002003'));
    });

    test('reports a non-numeric code', () {
      final message = checkVersionCodeConsistency('1.2.3+abc');
      expect(message, isNotNull);
      expect(message, contains('1002003'));
    });

    test('reports a version whose code cannot be derived', () {
      final message = checkVersionCodeConsistency('1.1000.0+1');
      expect(message, isNotNull);
      expect(message, contains('minor'));
    });

    test('rejects a malformed version name', () {
      expect(
        () => checkVersionCodeConsistency('nonsense'),
        throwsFormatException,
      );
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

    test('items within a section appear oldest-first', () {
      // Simulates git log order: newer commits first.
      final commits = [
        ParsedCommit.parse('ccc feat: newest feature')!,
        ParsedCommit.parse('bbb feat: middle feature')!,
        ParsedCommit.parse('aaa feat: oldest feature')!,
      ];
      final result = formatUnreleasedSection(commits)!;
      final oldestIndex = result.indexOf('- oldest feature');
      final middleIndex = result.indexOf('- middle feature');
      final newestIndex = result.indexOf('- newest feature');
      expect(oldestIndex, lessThan(middleIndex));
      expect(middleIndex, lessThan(newestIndex));
    });

    test(
      'first-parent list: feature-branch commits absent, merge commit included',
      () {
        // Simulates the commit list produced by `git log --first-parent`:
        // only the merge commit (conventional subject) and direct main commits
        // appear; individual feature-branch commits (wip, fix typo, etc.) are
        // never in the list.
        final commits = [
          ParsedCommit.parse('aaa feat: Add worksheet persistence')!,
          ParsedCommit.parse('bbb fix: Correct rounding in formatter')!,
          ParsedCommit.parse('ccc chore: bump SDK constraint')!,
        ];
        final result = formatUnreleasedSection(commits)!;
        expect(result, contains('Add worksheet persistence'));
        expect(result, contains('Correct rounding in formatter'));
        expect(result, isNot(contains('wip')));
        expect(result, isNot(contains('fix typo')));
      },
    );
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
