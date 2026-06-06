## Context

The `changelog` subcommand in `tool/release.dart` collects commits since the
last tag via `git log`, which returns commits in newest-first (descending
chronological) order by default.  After grouping commits by type into sections
(Added, Changed, Fixed, etc.), the current code does not re-order them — so
items within each section appear newest-first in the generated changelog.

The desired convention is oldest-first (ascending chronological) within each
section, matching natural reading order for tracing the evolution of a release.

## Goals / Non-Goals

**Goals:**

- Items emitted by the `changelog` subcommand within each section group are
  ordered oldest-to-newest (earliest commit first)
- The ordering convention is documented in the spec so manual edits follow the
  same rule

**Non-Goals:**

- Retroactively reordering items in existing versioned changelog entries
- Changing the ordering of section groups themselves (Added before Changed
  before Fixed, etc. — that ordering is already defined and unchanged)

## Decisions

### Reverse item order within each section group

`git log` outputs newest-first; after collecting and grouping commits, the list
for each section is reversed before being written to the changelog.

**Alternative considered**: Pass `--reverse` to `git log`.  Rejected because
`git log --reverse` with `--first-parent` on some Git versions reorders the
entire traversal before applying `--first-parent`, which can cause incorrect
results.  Collecting in default order then reversing each group's list is
simpler and avoids that edge case.

## Risks / Trade-offs

- [Negligible churn] Regenerating the `[Unreleased]` section after this change
  will reorder any existing items in it.  This is expected and desirable — no
  mitigation needed.
