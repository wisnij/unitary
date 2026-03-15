## Why

The changelog has no `[Unreleased]` section, so there is no single place to
curate release notes incrementally between releases.  The release tool
recalculates everything from raw commits at release time, making it impossible
to review or edit notes before they are published.

## What Changes

- Add an `[Unreleased]` section to `CHANGELOG.md`, always placed at the top of
  the entries (immediately below the file header), when there are changes to
  report.
- The `[Unreleased]` heading is formatted as a reference-style link to the
  repository comparison page between the latest named tag and `HEAD` (e.g.
  `[Unreleased]: https://github.com/wisnij/unitary/compare/v0.5.9...HEAD`).
- Add a `changelog` subcommand to `release.dart`: parses conventional commits
  since the last tag using the existing logic and rewrites the `[Unreleased]`
  section of `CHANGELOG.md` (and its link reference).
- When the `release` subcommand runs, it reads the `[Unreleased]` section body
  as the changelog entry for the new version instead of recalculating from
  commits.  If no `[Unreleased]` section is present it falls back to the
  current commit-parsing behaviour.
- After a successful release the `[Unreleased]` section (and its link
  reference) are removed from `CHANGELOG.md`.

## Capabilities

### New Capabilities

- `changelog-unreleased-section`: Formatting, parsing, insertion, and removal
  of the `[Unreleased]` section in `CHANGELOG.md`, including its link
  reference definition; and the new `changelog` subcommand in the release tool.

### Modified Capabilities

- *(none — only implementation details of `release_lib.dart` change; the
  externally-observable changelog format gains the optional section but no
  existing requirement changes.)*

## Impact

- `tool/release_lib.dart` — new pure functions: `formatUnreleasedSection`,
  `formatUnreleasedLinkRef`, `extractUnreleasedBody`, `updateUnreleasedSection`,
  `removeUnreleasedSection`; `updateChangelog` gains awareness of an existing
  `[Unreleased]` section.
- `tool/release.dart` — new `changelog` subcommand; `release` subcommand
  updated to consume the `[Unreleased]` section when present.
- `test/tool/release_lib_test.dart` — new test cases for all new functions and
  modified behaviours.
- `CHANGELOG.md` — gains an `[Unreleased]` section and corresponding link
  reference after the first `dart run tool/release.dart changelog` invocation.
