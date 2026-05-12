## Context

`tool/release.dart` drives the project's changelog and release workflow.  It has two code paths that collect commits:

1. `_runChangelog` — the `changelog` subcommand that regenerates the `[Unreleased]` section.
2. `_runRelease` — the `major`/`minor`/`patch` subcommand's fallback path when no `[Unreleased]` section exists in the changelog.

Both invoke `Process.runSync('git', ['log', '--format=%H %s', ...])`, which walks **all** reachable ancestors.  On a repository where feature branches are merged (not rebased), this includes every commit on the merged branch's history, not just the commits that landed directly on `main`.

`ParsedCommit.parse` already discards commits whose subjects begin with `"Merge "`, but the individual feature-branch commits — which often lack conventional-commit prefixes — still reach `formatUnreleasedSection` / `formatChangelogSection` and appear under the **Other** group.

## Goals / Non-Goals

**Goals:**

- Restrict changelog commit collection to commits that are directly on the main-branch history (the first-parent chain).
- Keep existing behaviour for direct commits (conventional and otherwise) and for user-written conventional subjects on merge commits.

**Non-Goals:**

- Changing how `ParsedCommit.parse` classifies commits — classification logic is unaffected.
- Altering the `--first-parent` strategy for squash-merge vs. regular-merge workflows — both are handled identically by the flag.
- Adding a way to opt out of first-parent traversal.

## Decisions

### Decision: `--first-parent` flag on `git log`

Add `'--first-parent'` to the `logArgs` list in both `_runChangelog` and `_runRelease`.

**Why `--first-parent` over alternatives:**

| Alternative | Problem |
|---|---|
| Filter commits by whether they have a merge-commit parent | Requires a second `git log` call per commit to inspect parentage; complex and slow |
| Walk only commits reachable from `HEAD` but not from any merged branch tip | Requires knowing all merged branch tips; not reliably available post-merge |
| Require squash-merge discipline | Policy enforcement, not a code change; breaks for existing repos |

`--first-parent` is the canonical git mechanism for "only show me what happened on this branch".  It is O(1) to add and has no runtime cost beyond the commits that would otherwise be omitted.

### Decision: Retain the `"Merge "` subject guard

With `--first-parent`, merge commits appear in the output.  Their subjects may be either:
- The git-default `"Merge branch 'X' into main"` or `"Merge pull request #N"` — should be **skipped**.
- A user-written conventional subject (e.g. `"feat: Add feature X"`) — should be **parsed normally**.

The existing `subject.startsWith('Merge ')` guard in `ParsedCommit.parse` already handles this correctly: default-style merge subjects are filtered out, user-written subjects pass through.  No change needed.

## Risks / Trade-offs

**Repositories using rebase-merge** — all commits appear directly on the first-parent chain anyway, so behaviour is unchanged.

**Repositories using squash-merge** — the squash commit is the only commit added to main's history; behaviour is unchanged.

**Repositories using regular merge with no conventional subject** — previously, feature-branch commits appeared in "Other"; after this change they are silently excluded.  This is the desired behaviour.

**History before this change** — commits already in the changelog are unaffected; the change only applies to future `changelog` invocations.

## Open Questions

_(none)_
