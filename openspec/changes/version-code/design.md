## Context

Android identifies builds by two independent values: the **version name**
(`versionName`, a display string) and the **version code** (`versionCode`, a
monotonically increasing integer that the package manager and Play both order
builds by).  Flutter derives both from a single `pubspec.yaml` line of the form
`version: X.Y.Z+BUILD` — the part before `+` becomes the name, the part after
becomes the code.

Unitary's pubspec has never carried the `+BUILD` half:

```yaml
version: 0.9.7
```

so Flutter substitutes a default of 1.  Confirmed against a real artifact:

```
package: name='dev.wisnij.unitary' versionCode='1' versionName='0.9.5'
```

Every one of the 38 published releases carries version code 1.  No Gradle change
is needed to fix this — `android/app/build.gradle.kts` already reads
`versionCode = flutter.versionCode`, which is populated from the pubspec build
number.  The entire problem is the missing suffix.

Version bumping is not ad-hoc here: `tool/release.dart` and its testable
`tool/release_lib.dart` already own the whole release flow — parsing the current
version, bumping major/minor/patch, rewriting `pubspec.yaml`, generating the
changelog section, committing, and tagging.  Notably the existing code is already
shaped for build suffixes it never produced: `Version.parse` strips a `+build`
suffix if present, and `updatePubspecVersion`'s doc comment says it "handles
versions with or without +build suffixes".  So this change extends a prepared
seam rather than opening a new one.

## Goals / Non-Goals

**Goals:**

- Every release carries a version code strictly greater than the previous
  release's, so Play accepts successive uploads and Android treats a newer APK
  as an upgrade.
- The version code is derived, not tracked — no second number that can drift out
  of sync with the version name or be forgotten during a release.
- The value is reproducible: the same checkout produces the same code locally and
  in CI, without consulting git history or a build clock.
- A version that cannot be encoded correctly fails loudly at release time rather
  than silently producing a colliding code.

**Non-Goals:**

- Changing the version *name*, tag naming (`vX.Y.Z`), changelog format, or
  anything the About screen displays.
- Retroactively fixing the published releases that carry version code 1; they
  stay as they are.
- Anything in the signing or Play-submission path — this change exists to unblock
  `release-signing`, not to overlap it.

## Decisions

### D1: Derive the version code from the semantic version

Four schemes were considered:

| Scheme | Monotonic | Reproducible offline | Failure mode |
|---|---|---|---|
| **Derived from semver** | Yes, if components stay in range | Yes | Encoding overflow (guarded — see D2) |
| Hand-maintained `+N` counter | Only if remembered | Yes | Silently forgetting to bump; Play rejects the upload much later |
| Git-derived (commit or tag count) | Yes | **No** — needs full history; a shallow clone or an export produces a different number | Surprising drift between environments |
| Timestamp (e.g. `YYMMDDHH`) | Yes | No — depends on build time, so rebuilding a tag yields a different code | Two builds of the same commit are not identical |

**Chosen: derived from semver.**  It keeps the version name as the single source
of truth, which is the property that eliminates the whole class of
forgot-to-bump errors.  It is also the only option besides a hand counter that
lets a clean checkout of a tag reproduce the exact artifact — the git-derived and
timestamp schemes both make a build depend on something outside the tree.

### D2: `MAJOR × 10000 + MINOR × 100 + PATCH`, with an explicit range guard

`1.0.0` → `10000`; `1.2.3` → `10203`; the current `0.9.7` → `907`.

The formula is readable at a glance — the decimal digits of the code spell the
version — which matters when the number appears in a Play Console listing or an
`aapt2` dump with no other context.

It allocates two decimal digits each to minor and patch, so **a minor or patch
component of 100 or more breaks monotonicity**: `1.100.0` would encode as
`20000`, colliding with `2.0.0`.  Rather than treat that as a documented
footgun, the computation SHALL reject it: attempting to encode an
out-of-range component is an error at release time, when it is trivially
fixable, rather than a duplicate version code discovered at upload time.  Ten
releases of history put the observed maximums at minor 9 and patch 7, so the
ceiling is remote — but it is a real edge, and a guard costs one comparison.

A wider `MAJOR × 1000000 + MINOR × 1000 + PATCH` was considered and rejected: it
raises the ceiling to 999 per component, still finite, still needing the same
guard, at the cost of readability.  Android's own ceiling
(version codes must stay below 2100000000) is not a practical constraint for
either scheme.

### D3: Computed and written by the release tooling

`tool/release_lib.dart`'s `Version` gains the derived code, and the release
bump writes `version: X.Y.Z+CODE` to `pubspec.yaml`.  The alternative —
computing the code at build time and passing `--build-number` from CI — was
rejected on two counts: it would leave local release builds with a different
version code from CI builds of the same commit, and it would put the value
somewhere no one reads, whereas the pubspec line is the first place anyone looks.

Because the value is written by the tool but stored in a hand-editable file, it
can drift if someone edits `pubspec.yaml` directly.  The release tool therefore
verifies consistency when it runs, failing if the recorded code does not match
the one derived from the recorded name.  A pre-commit hook was considered — the
repository already uses that pattern to keep generated files in sync — and
deferred as heavier than the risk warrants, since the release tool is the only
supported path for changing the version and it now checks itself.

### D4: Seed the current version rather than waiting for the next release

`pubspec.yaml` is updated to `0.9.7+907` as part of this change, so the working
tree is consistent immediately and a local release build produces a sensible
version code before 1.0.0 is cut.  Leaving it bare until the next bump would mean
the repository spends the whole `release-signing` change in a state where test
builds still report version code 1, which is exactly the condition being
verified against.

### D5: The transition from version code 1 is naturally monotonic

Every published release carries code 1; the first release under this scheme
carries at least `907`, and 1.0.0 carries `10000`.  Since the new values exceed
the old, Android and Play both see an ordinary increase and no special handling
is required.  This is worth stating because the reverse — a scheme whose first
value undercut the deployed one — would have been unrecoverable, and it is the
kind of property that is obvious only once checked.

## Risks / Trade-offs

**A minor or patch component reaching 100 would break ordering.** → Rejected at
computation time (D2) rather than documented and hoped about.  If the project
ever genuinely needs a three-digit component, the scheme widens — but that is a
deliberate migration, made with the constraint visible, not a silent collision.

**Re-releasing a fixed build under the same version name is impossible.** →
Accepted, and arguably correct: two artifacts with the same version name should
not exist.  A botched release is superseded by a patch bump, which the release
tooling already makes a one-command operation.

**A hand-edited `pubspec.yaml` could carry an inconsistent code.** → The release
tool verifies name/code consistency on every run, so the drift cannot survive
into a release.

**The published version-code-1 releases remain indistinguishable to the package
manager.** → Not fixed and not fixable; those artifacts are already distributed.
Superseded in practice by `release-signing`, which breaks update continuity from
those builds anyway.

## Migration Plan

1. Add the derived version code and its range guard to `Version`, with tests.
2. Write the suffix from the release bump path, with tests over the pubspec
   round-trip.
3. Seed `pubspec.yaml` with `0.9.7+907`.
4. Confirm a locally built release APK reports the expected version code via
   `aapt2 dump badging`.

Rollback is trivial at any point before a release is cut: revert the pubspec line
and the tooling change.  After a release, the version code has been observed by
installs and must only ever increase — so a rollback would mean continuing
forward with a higher number, never reusing a lower one.

## Open Questions

- None blocking.  The scheme, its guard, and its placement are settled; the only
  judgement call deferred is whether to add a pre-commit consistency hook later,
  which is recorded in D3 as deliberately deferred rather than unresolved.
