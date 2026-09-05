## Context

Phase 10 task 4 requires a privacy policy hosted at a stable URL.  Three
properties of the existing deployment constrain how that can be done, and all
three were verified rather than assumed.

**The `gh-pages` branch is entirely derived.**  `.github/workflows/ci.yml`'s
`deploy-web` job runs:

```
flutter build web --base-href /unitary/ --release --wasm
git --work-tree build/web add --all
git commit -m "Automatic deployment of $(git describe)"
git push origin HEAD:gh-pages --force
```

`git add --all` against a work-tree of `build/web` stages every file there
*and* the deletion of everything from `main` that is absent, so the branch
tree is exactly `build/web` (confirmed: `git ls-tree -r origin/gh-pages`
yields 42 files, all Flutter web output).  Nothing hand-maintained survives on
that branch.  Committing a file to `gh-pages` directly, checking it out in a
worktree, or serving Pages from `/docs` on `main` are therefore all
non-starters.

**Everything under `web/` is copied verbatim into `build/web`.**  From the
Flutter tool source (`build_system/targets/web.dart:625`), the build lists
`web/` recursively and `copySync`s every file except `index.html` and
`flutter_bootstrap.js`, preserving relative paths.  So a file committed under
`web/` reaches `gh-pages` — and the release web zip — with no CI change.
`listSync` includes dotfiles, so `web/.nojekyll` rides the same path.

**GitHub Pages runs Jekyll on the branch.**  `gh api repos/wisnij/unitary/pages`
reports `build_type: "legacy"`, and there is no `.nojekyll` and no
`_config.yml`.  Jekyll is currently a near-passthrough, but not a complete
one — see D3.

Only one endpoint exists in the app: grepping `lib/` for URLs outside the
generated `predefined_units.dart` returns the Frankfurter rates API and the
GitHub project link, nothing else.  `AndroidManifest.xml` declares only
`INTERNET`.

## Goals / Non-Goals

**Goals:**

- One source of truth for the policy text, in the repository, reviewable in
  diffs.
- A stable hosted URL suitable for registration with the Play Console.
- Structural impossibility of drift between the repository document and the
  published page.
- A generator useful beyond this one document, so publishing `doc/` pages
  later is a configuration change rather than a rewrite.
- A policy that is *truthful under scrutiny*, including the disclosures that
  a naive "we collect nothing" would gloss over.

**Non-Goals:**

- Rendering the policy inside the app.  See D4.
- Publishing the `doc/` pages.  The generator is built to accommodate them;
  actually converting them is separate work with its own layout decisions.
- The Play Console Data safety declaration (Phase 10 task 7).  It must agree
  with this document, but it is submitted through the console, not the repo.
- Any change to what the app collects or transmits.  This change documents
  existing behaviour; it does not alter it.

## Decisions

### D1: `PRIVACY.md` is the source; the HTML is generated and committed

The alternatives were hand-writing `web/privacy/index.html` alone (no
Markdown source, so the policy is not readable as a document in the repo),
hand-writing both files (silent drift between two copies of a legal
document — the failure this change most needs to prevent), and generating the
HTML in CI without committing it.

Generation in CI was rejected on four counts.  Two jobs build the web output
(`deploy-web` for `gh-pages`, `build-web` for the release zip), so the step
would be duplicated and the release zip would silently lack the page if the
second copy were forgotten.  `flutter run -d chrome` would not serve the page
locally.  The rendered legal text would never appear in a pull-request diff.
And breakage would surface at deploy time rather than commit time.

Committing generated output is also the settled house convention: three
existing pre-commit hooks (`import-gnu-units`, `generate-predefined-units`,
`generate-icons`) commit their output, including `predefined_units.dart` at
7233 lines.

### D2: The generator converts Markdown; Jekyll does not

GitHub Pages *is* running Jekyll on the deploy branch, so letting it convert
`PRIVACY.md` looked attractive.  It fails on three grounds.

Jekyll converts a Markdown file only when it carries YAML front matter;
without it the file is a *static file* and is copied byte-for-byte.  This was
confirmed on the live site: `GET /unitary/assets/LICENSE.md` returns `200`
with `content-type: text/markdown` and the raw source, unconverted.

Front matter would then be actively harmful, because a file that is both a
Flutter asset and a Jekyll source lands in `build/web` twice:

```
web/privacy.md ──┬── verbatim web/ copy ──▶ build/web/privacy.md
                 └── flutter asset bundle ─▶ build/web/assets/web/privacy.md

with front matter, Jekyll converts BOTH, and drops each source .md:
    privacy.md            → privacy.html            (wanted)
    assets/web/privacy.md → assets/web/privacy.html (breaks runtime loadString)
```

Jekyll cannot distinguish the asset copy from the page copy.  This change
does not bundle the policy as an asset (D4), so the conflict does not arise
here — but it is why "let Jekyll do it" does not generalise.

Finally, with no `_config.yml` and no `_layouts/`, Jekyll emits a bare
fragment: no `<html>`, no `<title>`, no `charset`, and no
`<meta name="viewport">`.  A Play reviewer opens the policy URL on a phone,
where that renders at desktop width.  Supplying a layout or theme would mean
adding Jekyll configuration that governs the whole site, and would give a
currently-inert build step real work that can fail — and a Jekyll failure
fails the Pages deployment, taking down the *app*, not just the document.

### D3: `web/.nojekyll` — a fix, not only a precaution

Jekyll is already deleting a deployed file.  `.last_build_id` is committed to
`gh-pages` (it is among the 42 files) yet returns `404` on the live site,
while `version.json` and `manifest.json` beside it return `200`.  Jekyll
excludes `.`- and `_`-prefixed paths from its output by default, silently and
with no error anywhere.

Harmless for `.last_build_id`, but it is the live form of a failure class
that would not be harmless: a future Flutter release or a package shipping
assets under an `_`-prefixed directory would vanish from the deployed site
with no signal.  `.nojekyll` also permanently defuses the `assets/LICENSE.md`
trap described in D2 — the web License screen works today only because that
file happens to carry no front matter, and nothing in the test suite would
catch it if someone added one.

The cost is foreclosing Jekyll processing, which D2 already declines to use.
The only observable change to the live site is that `.last_build_id` begins
returning `200`.

### D4: The app links out; it does not bundle the policy text

`LICENSE.md` is a Flutter asset rendered in-app by `LicenseScreen`, and
symmetry argues for a `PrivacyScreen` beside it.  The symmetry breaks on one
point: **the AGPL text never changes, and a privacy policy does.**  A policy
compiled into an APK is frozen at that release, while the hosted copy — the
one Play cross-checks against the Data safety declaration, and therefore the
authoritative one — moves on.  Two documents both claiming to be the privacy
policy, disagreeing, is worse than one that takes a tap to open.

Phase 10 task 4 asks only to "link it from the README and the in-app About
screen", so this is also the scoped reading.  The cost is that a user with no
connectivity cannot read the policy, which is a mild irony for an
offline-first app and is accepted: an offline user is, by construction, not
transmitting anything the policy would need to warn them about.

### D5: The generator is general; the document set is data

`tool/generate_web_docs.dart` + `_lib.dart`, following the established
`tool/` executable + library + `test/tool/` convention.  The document set is
a `const` list in the library — the same shape as `check_coverage_lib.dart`'s
`defaultExpectedAbsent` — so adding `doc/` pages later edits data, not logic.

Three consequences of generality that a privacy-only tool could have
hardcoded:

- **Titles come from the document's first H1.**  `PRIVACY.md`'s setext
  heading yields `<title>Privacy Policy — Unitary</title>`, and the H1
  remains in the rendered body as the page heading.  One less thing to keep
  in sync than a title carried per-document.
- **The back-link to the app is derived from output depth**, not specified
  per document.  `/unitary/privacy/` needs `../`; a future
  `/unitary/doc/architecture/` needs `../../`.  Hardcoding would ship a
  broken link on the first `doc/` page.  It must be relative: `/` would
  resolve to `wisnij.github.io`, not to the app, because the standalone page
  receives no `--base-href` substitution.
- **CSS is inlined in each page** rather than linked from a shared
  stylesheet, so there is no relative path to resolve across depths and each
  page remains self-contained inside the release zip.

The generator SHALL fail on a link to a `.md` file it is not converting.
`doc/` pages cross-link heavily (`[Terminology](doc/terminology.md)`), and
converted naively every such link 404s.  Link *rewriting* is deliberately not
built now — the right rule depends on a `doc/` layout not yet chosen — but
failing loudly turns that from a silent breakage into a build error on the
day it becomes relevant, and guards `PRIVACY.md` today against a stray
`[README](README.md)`.

### D6: `https://wisnij.github.io/unitary/privacy/`

Produced from `web/privacy/index.html`.  The extensionless directory form
survives a change of source format, which matters for a URL that is annoying
to change once registered with Play.

GitHub Pages 301-redirects directory paths lacking a trailing slash — verified
in two independent cases: `/unitary` → `/unitary/`, and `/unitary/icons` →
`/unitary/icons/` even though that directory has no `index.html`.  That is
server behaviour, not Jekyll, so it is unaffected by D3.  Prose links may
therefore be written `…/unitary/privacy`; the canonical trailing-slash form
is what gets registered with Play, so a reviewer never traverses a redirect.

### D7: `markdown` as a direct `dev_dependency`

Already present in `pubspec.lock` transitively via `flutter_markdown_plus`,
so nothing new is downloaded.  Declared as a dev dependency because `tool/`
code never ships in the app.  The alternative — hand-rolling a Markdown
subset — was rejected for a document whose formatting fidelity matters.

### D8: The hook names its inputs individually

```yaml
- id: generate-web-docs
  entry: dart run tool/generate_web_docs.dart
  pass_filenames: false
  files: |
    (?x)^(
      PRIVACY\.md |
      tool/generate_web_docs
    )
```

No new CI step is needed.  The `lint` job already runs
`pre-commit/action@v3.0.1`, which fails when a hook modifies a file, and
which defaults to `--all-files` — so in CI the hook runs against the whole
tree regardless of this pattern.  Adding a document later therefore requires
editing both the document set and this pattern, but forgetting the pattern
degrades to "not regenerated locally, caught by lint on the pull request"
rather than a stale published page.  Unlike `generate-icons`, this hook needs
no `SKIP` in CI: it runs `dart`, which that job already has.

### D9: Disclosures the policy must make

A bare "we collect nothing" would overclaim.  Two facts are true and belong
in the document:

- The exchange-rate request necessarily exposes the user's **IP address** to
  the Frankfurter API operator.  No identifier is sent, and the request is
  unauthenticated, but a network request is not invisible.
- The **web** build is served from GitHub Pages, which logs requests as any
  host does.  This distinguishes the hosted app from the APK and is not
  otherwise obvious.

Stating both is consistent with the project's no-tracking positioning rather
than in tension with it; a policy that survives scrutiny is worth more than
one that reads cleaner.

## Risks / Trade-offs

**The published policy is rolling, not versioned.**  `deploy-web` runs on
every push to `main`, so an edit goes live before the next release → this is
the intended consequence of D4 (one authoritative, current document), and it
is why nothing is bundled into the APK to contradict it.  If a future change
alters what the app transmits, the policy edit must land *with* that change
rather than ahead of it.

**The hook pattern and the document set can diverge as documents are added**
→ CI runs the hook with `--all-files`, so a missed pattern entry fails lint
rather than publishing a stale page (D8).

**`.nojekyll` starts serving `.last_build_id`** → harmless; it is a Flutter
build identifier already effectively public in the deployed bundle.

**The generated page is verified only as a string, never in a browser** →
the shell is small, static, and hand-reviewed once; a rendering regression
would require editing the shell, which is itself reviewed in a diff.
Accepted rather than engineered around.

**The URL is effectively permanent once registered with Play** → mitigated by
choosing the format-agnostic extensionless directory form now (D6) rather
than `privacy.html`.

**A `doc/` page added later with cross-links will fail the build** → that is
the designed behaviour (D5), and is preferable to silently publishing dead
links.

## Migration Plan

No migration in the data sense; nothing is stored, versioned, or read back.
The ordering that matters is external:

1. Land `PRIVACY.md`, the generator, the hook, `web/.nojekyll`, and the
   generated page together, so the repository is never in a state where the
   published page and the document disagree.
2. Merge to `main` and confirm the page is live at the canonical URL, that
   the no-trailing-slash form redirects to it, and that `.last_build_id` now
   returns `200` (the observable signal that `.nojekyll` took effect).
3. Only then register the URL with the Play Console (Phase 10 task 7), and
   keep the Data safety declaration consistent with D9's disclosures.

Rollback is reverting the commit: the next push to `main` force-pushes a
`gh-pages` tree without the page, and removing `web/.nojekyll` restores the
Jekyll build.  Neither affects the app.

## Open Questions

None blocking.  Two deferred by decision:

- **Publishing the `doc/` pages.**  The generator is built to accommodate
  them; doing it needs a `doc/` URL layout and a `.md`-link rewriting rule,
  at which point D5's fail-loud check becomes the to-do list.
- **A custom domain.**  Would change the policy URL, which is why it is worth
  noting now rather than discovering after Play registration.
