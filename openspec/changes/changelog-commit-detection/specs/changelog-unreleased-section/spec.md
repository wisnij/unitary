## ADDED Requirements

### Requirement: First-parent commit traversal
The release tool SHALL pass `--first-parent` to every `git log` invocation that collects commits for changelog generation, so that only commits directly on the main-branch history are included.  Commits reachable solely through merged-branch parents are excluded.

#### Scenario: Feature-branch commits excluded after merge
- **WHEN** a feature branch containing non-conventional commits (e.g. `"wip: thing"`, `"fix typo"`) has been merged into main
- **AND** `dart run tool/release.dart changelog` is invoked
- **THEN** those feature-branch commits do NOT appear in the `[Unreleased]` section

#### Scenario: Conventional merge-commit subject is included
- **WHEN** a merge commit on the main-branch history has a conventional-commit subject (e.g. `"feat: Add feature X"`)
- **AND** `dart run tool/release.dart changelog` is invoked
- **THEN** that commit IS included in the `[Unreleased]` section under the correct group

#### Scenario: Default-style merge-commit subject is still excluded
- **WHEN** a merge commit on the main-branch history has an auto-generated subject starting with `"Merge "` (e.g. `"Merge branch 'feature' into main"`)
- **AND** `dart run tool/release.dart changelog` is invoked
- **THEN** that commit does NOT appear in the `[Unreleased]` section

#### Scenario: First-parent traversal also applies to release subcommand
- **WHEN** `dart run tool/release.dart patch` is invoked
- **AND** no `[Unreleased]` section is present (fallback commit-parse path)
- **THEN** only first-parent commits are used to build the versioned changelog entry
