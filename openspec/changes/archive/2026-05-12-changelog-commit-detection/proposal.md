## Why

The release tool uses plain `git log` which walks all reachable ancestors, including every intermediate commit on merged feature branches.  After a typical feature-branch merge, this floods the changelog's "Other" section with work-in-progress commits the user never intended to expose.

## What Changes

- Both the `changelog` subcommand and the `release` (major/minor/patch) subcommand add `--first-parent` to their `git log` invocations, restricting traversal to commits directly on the main-branch history.
- The existing guard that skips commits whose subjects start with `"Merge "` is retained: with `--first-parent` those merge commits appear in the output, and the guard correctly excludes the git-default `"Merge branch …"` / `"Merge pull request …"` subjects while still allowing user-written conventional-commit subjects (e.g. `"feat: …"`) on merge commits to pass through.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `changelog-unreleased-section`: commit selection gains a first-parent traversal requirement — only commits on the first-parent chain are included in changelog output.

## Impact

- `tool/release.dart`: two `git log` call sites updated (one in `_runChangelog`, one in `_runRelease`).
- `tool/release_lib.dart`: no logic changes; the existing parse path is unaffected.
- `test/tool/release_lib_test.dart` (or equivalent): existing tests unchanged; new tests cover first-parent commit list handling (probably just a documentation note that commit-list construction is the caller's responsibility, already covered by `release.dart` integration).
- No public API changes; no dependency additions.
