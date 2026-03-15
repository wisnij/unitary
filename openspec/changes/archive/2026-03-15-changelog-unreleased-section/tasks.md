## 1. Pure library functions (`release_lib.dart`)

- [x] 1.1 Add `formatUnreleasedSection(List<ParsedCommit> commits)` — same grouping logic as `formatChangelogSection` but heading is `[Unreleased]` with 12-dash underline and no date
- [x] 1.2 Add `formatUnreleasedLinkRef(String lastTag)` — returns `[Unreleased]: {repoUrl}/compare/v{lastTag}...HEAD`
- [x] 1.3 Add `extractUnreleasedBody(String changelog)` — returns body text of the `[Unreleased]` section, or `null` if absent
- [x] 1.4 Add `updateUnreleasedSection(String changelog, String section, String linkRef)` — inserts or replaces the `[Unreleased]` section at the top of entries and updates its link reference
- [x] 1.5 Add `removeUnreleasedSection(String changelog)` — strips the `[Unreleased]` heading, dashes, body, and link reference

## 2. Tests for new library functions (`test/tool/release_lib_test.dart`)

- [x] 2.1 Test `formatUnreleasedSection`: heading is `[Unreleased]`, underline is 12 dashes, body groups match commits, empty groups omitted
- [x] 2.2 Test `formatUnreleasedLinkRef`: correct URL with lastTag interpolated
- [x] 2.3 Test `extractUnreleasedBody`: returns body when section present; returns `null` when absent; handles empty body
- [x] 2.4 Test `changelog` empty-entry cases (via lib logic): no entries → section not inserted when absent; no entries → existing section removed: inserts section when absent (correct position, link ref first in block); replaces existing section in-place; link ref updated on replace
- [x] 2.5 Test `updateUnreleasedSection`: inserts section when absent (correct position, link ref first in block); replaces existing section in-place; link ref updated on replace
- [x] 2.6 Test `removeUnreleasedSection`: removes heading, dashes, body, and link ref; no-op when section absent; versioned entries and link refs untouched: removes heading, dashes, body, and link ref; no-op when section absent; versioned entries and link refs untouched

## 3. `changelog` subcommand (`release.dart`)

- [x] 3.1 Extend argument parsing to accept `changelog` as a valid positional argument (alongside `major`/`minor`/`patch`)
- [x] 3.2 Implement `changelog` subcommand: get last tag, run `git log` since last tag, parse commits; if no commits produce changelog entries, call `removeUnreleasedSection` (no-op when absent) and write; otherwise call `formatUnreleasedSection` + `formatUnreleasedLinkRef` + `updateUnreleasedSection` and write `CHANGELOG.md`
- [x] 3.3 Implement `--dry-run` for `changelog`: print formatted section and link ref to stdout, do not write files

## 4. `release` subcommand — consume Unreleased section (`release.dart`)

- [x] 4.1 After reading `CHANGELOG.md`, call `extractUnreleasedBody` to detect an existing `[Unreleased]` section
- [x] 4.2 If `[Unreleased]` body is present: construct the versioned changelog section by prepending the new `[X.Y.Z] - date` heading to the extracted body; skip commit-parsing
- [x] 4.3 Call `removeUnreleasedSection` on the changelog content before calling `updateChangelog`, so the `[Unreleased]` section is absent from the committed file
- [x] 4.4 Update dry-run output to indicate whether the entry came from `[Unreleased]` or from commits

## 5. Update `CHANGELOG.md`

- [x] 5.1 Run `dart run tool/release.dart changelog` to generate the initial `[Unreleased]` section covering commits since `v0.5.9`
