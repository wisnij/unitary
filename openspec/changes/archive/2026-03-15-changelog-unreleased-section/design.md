## Context

`tool/release_lib.dart` is a pure library of formatting and mutation functions
for `CHANGELOG.md` and `pubspec.yaml`.  `tool/release.dart` is the executable
that calls those functions, shells out to git, reads/writes files, and handles
the confirm prompt.  `CHANGELOG.md` uses setext-style h2 headings
(`[X.Y.Z] - YYYY-MM-DD` followed by a `---` underline) and reference-style
link definitions at the end of the file.

Currently the `release` subcommand is the only mode; it computes the entire
changelog entry from raw commits at the time the release is cut.  There is no
place to curate notes incrementally.

The `_repoUrl` constant (`https://github.com/wisnij/unitary`) already exists in
`release_lib.dart` and is used for versioned link references.  The same constant
will be used for the `[Unreleased]` link.

## Goals / Non-Goals

**Goals:**

- Add `[Unreleased]` section support per keepachangelog.com: section always at
  the top of entries, heading links to a comparison between the latest tag and
  `HEAD`.
- New `changelog` subcommand: parses commits since last tag and (re)writes the
  `[Unreleased]` section and its link reference.
- `release` subcommand: consumes the `[Unreleased]` body as the new version's
  entry when the section is present; falls back to commit-parsing when absent;
  strips the `[Unreleased]` section on success.
- All new logic lives in testable `release_lib.dart` functions with no I/O.

**Non-Goals:**

- Manual-edit assistance or merge of user edits with generated content.
- Changing the format of versioned entries.
- Migrating or back-filling existing `CHANGELOG.md` entries.
- Validating that the `[Unreleased]` section was generated from the current last
  tag (the user is responsible for keeping it current before releasing).

## Decisions

### 1. Section heading format: setext h2

`[Unreleased]` is written as a setext-style h2 with a `---` underline whose
length exactly matches the heading text (`[Unreleased]` = 12 characters, so 12
dashes).  This is consistent with versioned entries and with the project's
Markdown style rules.

ATX style (`## [Unreleased]`) was rejected as inconsistent with project
conventions.

### 2. Link reference format

```
[Unreleased]: https://github.com/wisnij/unitary/compare/v{lastTag}...HEAD
```

`formatUnreleasedLinkRef(String lastTag)` constructs this string.  It is
inserted before the existing versioned link references (i.e. first in the block,
since it represents the newest range), matching the existing ordering convention.

### 3. Section detection

A heading is recognised as the `[Unreleased]` section when a line matches
`^\[Unreleased\]$` (exact, case-sensitive, no trailing date) and the following
line matches `^-+$`.  This is the same two-line setext detection already used in
`_startsWithSetextH2`.

### 4. New functions in `release_lib.dart`

| Function | Responsibility |
|---|---|
| `formatUnreleasedSection(List<ParsedCommit>)` | Formats a full `[Unreleased]` section string (heading + dashes + body) from a commit list, using the same section-grouping logic as `formatChangelogSection`. |
| `formatUnreleasedLinkRef(String lastTag)` | Returns the `[Unreleased]:` link reference line. |
| `extractUnreleasedBody(String changelog)` | Returns the body text of the `[Unreleased]` section (everything after the heading/dashes, up to the next section or EOF), or `null` if no section is present. |
| `updateUnreleasedSection(String changelog, String section, String linkRef)` | Replaces an existing `[Unreleased]` section (and its link ref) in-place, or inserts it at the top of entries and inserts the link ref before the existing link-ref block. |
| `removeUnreleasedSection(String changelog)` | Strips the `[Unreleased]` heading, dashes, body, and its link reference from the changelog string. |

`updateChangelog` is unchanged.  The release flow calls `removeUnreleasedSection`
first, then `updateChangelog`, rather than extending `updateChangelog` to handle
both cases.  This keeps each function single-purpose.

### 5. `changelog` subcommand: full rewrite, not append

Each invocation of `dart run tool/release.dart changelog` completely replaces
the `[Unreleased]` section with a fresh parse of all commits since the last tag.
Appending only new commits was considered but rejected: it requires tracking
which commits are already included, and it would silently discard manually
removed entries on the next run anyway.

The consequence is that manually edited entries are overwritten on the next
`changelog` run.  This is documented in the dry-run output and the usage string.

### 6. Release flow with an `[Unreleased]` section present

1. Detect whether `[Unreleased]` section exists in `CHANGELOG.md`.
2. If yes: call `extractUnreleasedBody` to get the body; call
   `removeUnreleasedSection` to strip it; use the extracted body (prefixed with
   the new version heading and dashes) as the changelog section passed to
   `updateChangelog`.
3. If no: compute the changelog section from commits as before.
4. In both cases, generate a versioned link reference and proceed as normal.

The tag message (`formatTagMessage`) receives the versioned changelog section in
both paths, so its behaviour is unchanged.

### 7. `--dry-run` for `changelog`

Prints the formatted `[Unreleased]` section and link reference to stdout
without writing any files, mirroring the existing `--dry-run` behaviour of the
`release` subcommand.

## Risks / Trade-offs

- **Manually edited entries are overwritten by `changelog`.**  A user who curates
  the section by hand and then runs `dart run tool/release.dart changelog` will
  lose their edits.  Mitigation: the dry-run output clearly states "Would
  replace `[Unreleased]` section"; the usage string warns that this command
  overwrites the section.

- **Stale section at release time.**  If `changelog` has not been run since
  new commits landed, the `[Unreleased]` section may be missing those commits
  when `release` consumes it.  Mitigation: out of scope — the user is
  responsible for running `changelog` before `release` if they want the section
  to be current.  The fallback to commit-parsing (when no section is present)
  provides a safe path.

- **`extractUnreleasedBody` returns formatted bullet lines, not raw commits.**
  The body used during release is whatever text is in the `[Unreleased]` section
  at the time (generated or hand-edited).  The `formatTagMessage` function
  already handles arbitrary body text, so this is compatible.

## Open Questions

*(none)*
