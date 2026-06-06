## Why

When multiple items appear in the same changelog section (e.g., Added, Changed, Fixed),
they are currently added in an unspecified order.  Ordering them from oldest to newest
(chronological ascending) within each section makes it easier to trace the evolution
of changes across a release and aligns with how readers naturally scan history.

## What Changes

- Items within each changelog section (Added, Changed, Fixed, Documentation, Other)
  SHALL be ordered oldest-first (ascending chronological order)
- The `changelog` subcommand in the release tool currently groups commits by type;
  within each group, commits SHALL be ordered oldest-to-newest (earliest commit first)
- Manual changelog edits should follow the same convention

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `changelog-unreleased-section`: Item ordering within each section group is now
  specified as oldest-to-newest (ascending chronological order), both for generated
  entries from the `changelog` subcommand and for the consumed body used by `release`

## Impact

- `tool/release.dart`: The `changelog` subcommand's commit-to-section grouping
  must emit items in oldest-first order (reverse the current `git log` output, which
  defaults to newest-first)
- `CHANGELOG.md`: Existing entries are unaffected; new entries added going forward
  follow the oldest-first ordering convention
- No public API or dependency changes
