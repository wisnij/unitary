## Why

Unitary has no privacy policy.  The Play Store requires one as a **hosted
URL** before an app can be submitted, so its absence is one of the two
remaining blockers on Phase 10 (the other, release signing, closed on
September 5, 2026).  The README already promises the app contains no "ads,
paywalls, subscriptions, in-app purchases, tracking, data harvesting, or any
other monetization scheme", but that claim currently lives only in marketing
prose, and Play cross-checks the Data safety declaration against the policy
document rather than against a README.

The content is unusually simple — the app collects nothing, and a grep of
`lib/` for URLs outside the generated units database returns exactly two hits,
one of which is the GitHub project link.  The real work is publishing it
durably: keeping a single source of truth, getting HTML onto a deploy branch
that is force-overwritten from `build/web` on every push to `main`, and making
sure the published page cannot silently drift from the document in the
repository.

## What Changes

- Add `PRIVACY.md` at the repository root as the **single source of truth**,
  alongside `LICENSE.md` and `CONTRIBUTING.md`.
- Add `tool/generate_web_docs.dart` + `tool/generate_web_docs_lib.dart`, a
  **general** Markdown→HTML generator for pages published with the web build.
  It is deliberately not privacy-specific: the document set is data, so
  `doc/` pages can be added later without rewriting the tool.
- Commit the generated `web/privacy/index.html`.  Flutter copies `web/`
  verbatim into `build/web`, so the page reaches both the `gh-pages` deploy
  and the release web zip with **no CI changes at all**.
- Add a `generate-web-docs` pre-commit hook.  The existing lint job already
  runs `pre-commit/action` with its `--all-files` default and fails when a
  hook modifies a file, so drift between `PRIVACY.md` and the published page
  fails the build without any new CI step.
- Add `web/.nojekyll`, disabling GitHub Pages' Jekyll build on the deploy
  branch.  This is a fix, not just a precaution: `.last_build_id` is committed
  to `gh-pages` and returns **404** on the live site today, while its
  non-dotfile neighbours return 200 — Jekyll is silently dropping a deployed
  file.  It also defuses a live trap on `assets/LICENSE.md`, which the web
  app fetches at runtime and which survives only because it happens to carry
  no YAML front matter.
- Bundle `PRIVACY.md` as a Flutter asset and render it in-app through a
  `PrivacyScreen` mirroring the existing `LicenseScreen`, reached from a new
  "Privacy policy" tile on the About screen.  Each build therefore carries
  the policy that describes *that build's* behaviour, readable offline, while
  the document names its effective date and links to the canonical hosted
  copy for the current version.
- Link the policy from the README's no-monetization paragraph.
- Promote `markdown` from a transitive dependency to a direct
  **`dev_dependency`**.  It is already resolved in `pubspec.lock` via
  `flutter_markdown_plus`, so nothing new is downloaded, and `tool/` code
  never ships in the app.

## Capabilities

### New Capabilities

- `web-doc-generation`: the Markdown→HTML pipeline for pages published
  alongside the web app — the document set, how titles and relative
  back-links are derived, the self-contained page shell, the failure mode for
  unresolvable cross-document links, the committed-and-hook-enforced
  generated output, and the requirement that the deploy branch be published
  verbatim rather than post-processed.
- `privacy-policy`: the policy document itself — that it exists, what it must
  disclose truthfully, where it is hosted, how it is bundled into and
  rendered by the app, and the paths by which users reach it from the app and
  the README.

### Modified Capabilities

- `about-menu`: the About screen requirement currently enumerates "four
  entries in order: Version, Build (conditional), License terms, Project
  home".  A fifth entry is added, and the ordering requirement changes.

## Impact

**New files:** `PRIVACY.md`, `web/privacy/index.html` (generated),
`web/.nojekyll`, `tool/generate_web_docs.dart`,
`tool/generate_web_docs_lib.dart`,
`test/tool/generate_web_docs_lib_test.dart`,
`lib/features/about/presentation/privacy_screen.dart`,
`test/features/about/presentation/privacy_screen_test.dart`.

**Modified files:** `pubspec.yaml` (dev dependency, plus `PRIVACY.md` in the
Flutter `assets:` list beside `LICENSE.md`),
`.pre-commit-config.yaml` (new hook), `README.md` (link),
`lib/features/about/about_constants.dart` (new URL constant),
`lib/features/about/presentation/about_screen.dart` (new tile),
`test/features/about/presentation/about_screen_test.dart` (tests mirroring
the existing "License terms" navigation pair).

**CI:** unchanged.  Both web-producing jobs (`deploy-web`, `build-web`)
already copy everything under `web/`, and the `lint` job already runs the
pre-commit hooks.

**Published URL:** `https://wisnij.github.io/unitary/privacy/`.  Verified that
GitHub Pages 301-redirects directory paths lacking a trailing slash, so
`…/unitary/privacy` is also reachable and is the form used in prose links.
The canonical trailing-slash form is what gets registered with Play.

**Coverage gate:** `about_constants.dart` gains a third constant and remains
declaration-only, so it stays on `check_coverage_lib.dart`'s
`defaultExpectedAbsent` allowlist; that entry's comment ("Two const
declarations") needs updating.  `privacy_screen.dart` is new code inside the
90% floor and needs widget tests, mirroring `license_screen_test.dart`.

**Not in scope:** the Play Console Data safety declaration (Phase 10 task 7),
which must stay consistent with this document but is submitted separately.
