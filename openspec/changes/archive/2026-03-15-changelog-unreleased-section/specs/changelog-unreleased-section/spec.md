## ADDED Requirements

### Requirement: Unreleased section format
The changelog `[Unreleased]` section SHALL use a setext-style h2 heading with
the text `[Unreleased]` (no date) followed by a `---` underline whose length
exactly matches the heading text (12 dashes).  The body uses the same
section groups and ordering as versioned entries (Added, Changed, Fixed,
Documentation, Other).

#### Scenario: Heading renders as setext h2
- **WHEN** the `[Unreleased]` section is written to the changelog
- **THEN** the heading line is exactly `[Unreleased]`
- **THEN** the next line is exactly `------------` (12 dashes)

#### Scenario: Body uses standard section groups
- **WHEN** the `[Unreleased]` section body is generated from commits
- **THEN** commits are grouped under the same headings used for versioned entries
  (Added, Changed, Fixed, Documentation, Other)
- **THEN** section groups with no entries are omitted

### Requirement: Unreleased section placement
The `[Unreleased]` section SHALL always appear at the top of the entry list,
immediately after the file header block and before any versioned entry.

#### Scenario: Unreleased section precedes all versioned entries
- **WHEN** `CHANGELOG.md` contains an `[Unreleased]` section
- **THEN** the `[Unreleased]` heading appears before any `[X.Y.Z]` heading in
  the file

### Requirement: Unreleased link reference
The `[Unreleased]` link reference SHALL follow the format
`[Unreleased]: {repoUrl}/compare/v{lastTag}...HEAD`, where `{lastTag}` is the
most recent version tag (e.g. `v0.5.9`).  It SHALL be placed at the start of
the link-reference block (before any versioned link references).

#### Scenario: Link reference points to HEAD comparison
- **WHEN** the last release tag is `v0.5.9`
- **THEN** the link reference line is
  `[Unreleased]: https://github.com/wisnij/unitary/compare/v0.5.9...HEAD`

#### Scenario: Link reference is first in the block
- **WHEN** `CHANGELOG.md` has existing versioned link references
- **THEN** the `[Unreleased]:` line appears before all `[X.Y.Z]:` lines

### Requirement: `changelog` subcommand
The release tool SHALL accept a `changelog` positional argument that parses
conventional commits since the last tag and (re)writes the `[Unreleased]`
section and its link reference in `CHANGELOG.md`.  Each invocation replaces
the section wholesale; it does not append.

#### Scenario: Section is created when absent and entries exist
- **WHEN** `dart run tool/release.dart changelog` is invoked
- **AND** `CHANGELOG.md` has no `[Unreleased]` section
- **AND** at least one commit since the last tag produces a changelog entry
- **THEN** an `[Unreleased]` section is inserted at the top of entries
- **THEN** an `[Unreleased]` link reference is inserted before versioned link
  references

#### Scenario: Section is not created when no entries would be generated
- **WHEN** `dart run tool/release.dart changelog` is invoked
- **AND** `CHANGELOG.md` has no `[Unreleased]` section
- **AND** all commits since the last tag are of omitted types (`test`, `chore`,
  `build`, `ci`, `style`) or there are no commits
- **THEN** `CHANGELOG.md` is not modified

#### Scenario: Existing section is removed when no entries would be generated
- **WHEN** `dart run tool/release.dart changelog` is invoked
- **AND** `CHANGELOG.md` already has an `[Unreleased]` section
- **AND** all commits since the last tag are of omitted types or there are no
  commits
- **THEN** the existing `[Unreleased]` section and its link reference are
  removed from `CHANGELOG.md`

#### Scenario: Section is replaced when present and entries exist
- **WHEN** `dart run tool/release.dart changelog` is invoked
- **AND** `CHANGELOG.md` already has an `[Unreleased]` section
- **AND** at least one commit since the last tag produces a changelog entry
- **THEN** the existing `[Unreleased]` section (heading, dashes, body) is
  replaced with a freshly generated one
- **THEN** the `[Unreleased]` link reference is updated

#### Scenario: Commits are parsed using conventional-commit rules
- **WHEN** `dart run tool/release.dart changelog` is invoked
- **THEN** only commits since the last version tag are included
- **THEN** the same commit type → section mapping is used as for versioned
  entries (`feat` → Added, `fix` → Fixed, `refactor`/`perf` → Changed, etc.)
- **THEN** commit types that are omitted from versioned entries (`test`,
  `chore`, `build`, `ci`, `style`) are also omitted from the Unreleased section

### Requirement: `changelog --dry-run`
When invoked with `--dry-run`, the `changelog` subcommand SHALL print the
formatted `[Unreleased]` section and link reference to stdout without writing
any files.

#### Scenario: Dry run prints and exits without writing
- **WHEN** `dart run tool/release.dart changelog --dry-run` is invoked
- **THEN** the formatted `[Unreleased]` section is printed to stdout
- **THEN** `CHANGELOG.md` is not modified

### Requirement: `release` consumes Unreleased section when present
When the `release` subcommand (major/minor/patch) runs and `CHANGELOG.md`
contains an `[Unreleased]` section, the release tool SHALL use the body of
that section as the changelog entry for the new version instead of
recalculating entries from commits.

#### Scenario: Unreleased body becomes the versioned entry
- **WHEN** `dart run tool/release.dart patch` is invoked
- **AND** `CHANGELOG.md` has an `[Unreleased]` section with body content
- **THEN** the new versioned changelog entry uses the body from the
  `[Unreleased]` section (not a fresh commit parse)

#### Scenario: Tag message uses Unreleased body
- **WHEN** the `[Unreleased]` body is consumed during release
- **THEN** the annotated git tag message is derived from the same body

### Requirement: `release` removes Unreleased section on success
After a successful release commit and tag, the `[Unreleased]` section and its
link reference SHALL be removed from `CHANGELOG.md`.  (They are already absent
from the committed file because the removal happens before the commit.)

#### Scenario: Unreleased section absent after release
- **WHEN** `dart run tool/release.dart patch` completes successfully
- **AND** an `[Unreleased]` section was present before the release
- **THEN** `CHANGELOG.md` contains no `[Unreleased]` heading
- **THEN** `CHANGELOG.md` contains no `[Unreleased]:` link reference

### Requirement: `release` falls back to commit-parsing when Unreleased absent
When the `release` subcommand runs and no `[Unreleased]` section is present in
`CHANGELOG.md`, behaviour SHALL be identical to the current implementation
(parse commits since last tag and generate the changelog entry on the fly).

#### Scenario: Release proceeds normally without Unreleased section
- **WHEN** `dart run tool/release.dart patch` is invoked
- **AND** `CHANGELOG.md` has no `[Unreleased]` section
- **THEN** the changelog entry is generated from commits since the last tag
- **THEN** `CHANGELOG.md` and `pubspec.yaml` are updated as before
