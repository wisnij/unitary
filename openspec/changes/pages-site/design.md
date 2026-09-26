## Context

**Current publishing path.**  `ci.yml`'s `deploy-web` job runs on pushes to
`main`, builds the app with `flutter build web --base-href /unitary/ --release
--wasm`, commits `build/web` onto an orphaned history and force-pushes it to
`gh-pages`.  GitHub Pages serves that branch at
`https://wisnij.github.io/unitary/`, so the app is the site root.  The one
other page, the privacy policy, reaches the site only because
`tool/generate_web_docs.dart` writes it to `web/privacy/index.html`, which is
committed, and Flutter copies `web/` verbatim into `build/web`.  A
`generate-web-docs` pre-commit hook keeps it in step with `PRIVACY.md`, and
`web/.nojekyll` stops the Pages Jekyll build from dropping dotfiles.

**Separately**, the `build-web` job builds the same app (default base `/`) on
every push and pull request, and zips `build/web` as the release web asset.
Two Flutter web builds happen on every push to `main`.

**Domain state, verified September 25, 2026.**
- `unitary.wisnij.dev` resolves to Cloudflare proxy addresses and answers
  with a 302 to `https://github.com/wisnij/unitary/`, the repository, not
  the Pages site.
- `wisnij.github.io` has no user site (its root returns 404), so no
  user-level custom domain interacts with the project site.
- `wisnij.dev` is already a verified domain on the owner's GitHub account,
  which prevents another account from claiming the subdomain.
- `.dev` is on the HSTS preload list: browsers never fall back to plain
  HTTP, so the site is unreachable at the new address until GitHub has
  issued its certificate.

**Pages server behaviour, verified against the live site.**  The site
already runs without Jekyll, and the Pages server itself resolves
extensionless paths to `.html` files: `/unitary/index` and
`/unitary/privacy/index` return 200, while `/unitary/manifest` returns 404
even though `manifest.json` exists.  Only `.html` is tried.  A path naming a
directory without its trailing slash is 301-redirected to add one.

**The app's routing.**  Nothing in `lib/` calls `usePathUrlStrategy`, so the
app uses Flutter's default hash URL strategy: navigation changes only the
fragment, and the document path is always the directory `index.html` was
served from.

**Flutter's service worker** is now a self-unregistering stub
(`flutter_service_worker.js` unregisters itself and reloads its clients), so
no client holds a cached copy of the old app that could outlive the move.

## Goals / Non-Goals

**Goals:**
- Serve the site from `https://unitary.wisnij.dev` with `/` (README),
  `/app/` (web app) and `/privacy` (policy).
- Make `https://unitary.wisnij.dev/privacy` the policy's permanent,
  declared address before it is registered with the Play Store.
- Catch site-generation errors in pull-request CI, not in the deploy.
- Build the web app once per workflow run, and have that build work at any
  mount point.
- Keep every existing `wisnij.github.io/unitary/...` link resolving
  somewhere sensible.

**Non-Goals:**
- Publishing `doc/` on the site.  Links to it are rewritten to GitHub; the
  generator stays a data change away from publishing it later.
- Any change to the README's content beyond its URLs.  The home page is a
  straight rendering; an "open the app" call to action, if wanted, is README
  content added separately.
- Path-based URLs inside the app.
- Keeping `/privacy/` (trailing slash) working.
- A site-wide navigation bar or shared layout beyond the per-page footer.

## Decisions

### D1: Publish through GitHub Actions, not a deploy branch

The Pages source changes from the `gh-pages` branch to "GitHub Actions".  A
`build-site` job runs on every push and pull request, assembles the site and
uploads it with `actions/upload-pages-artifact`.  A `deploy-site` job, only
for pushes to `main`, runs `actions/deploy-pages` with `pages: write` and
`id-token: write` in the `github-pages` environment, under a
non-cancelling concurrency group as `deploy-web` had.

`actions/upload-pages-artifact` v4 and later leave dotfiles out of the
artifact unless `include-hidden-files: true` is set, and
`actions/upload-artifact` has the same default.  Both uploads set it, so the
deployed tree matches the assembled one, `app/.last_build_id` included.

- **Custom domain** lives in repository settings.  With a branch deploy it
  would also need a `CNAME` file in every force-push, or the push would clear
  the setting.
- **Jekyll** never runs on an Actions deployment, so `.nojekyll` and the
  failure mode it guarded against (silently dropped `.`/`_` paths, converted
  front-matter Markdown) disappear rather than needing a guard.
- **Permissions** narrow: the deploy no longer needs `contents: write`.
- **Cost**: the deployed tree can no longer be browsed as a branch.  The
  uploaded artifact is downloadable from each run, which covers the same
  debugging need.

*Alternative considered*: keep the branch deploy and add `CNAME` to the
assembled tree.  Rejected: it keeps Jekyll and the `.nojekyll` guard in play,
and needs `contents: write`.

### D2: Relative base href, one build shared by the site and the release zip

`web/index.html`'s `<base href="$FLUTTER_BASE_HREF">` becomes
`<base href="./">`, and no job passes `--base-href`.  `./` resolves against
the directory `index.html` was loaded from, so one build works at `/app/` on
the custom domain, at `wisnij.github.io/unitary/app/` before the domain is
switched, from a subdirectory in the release web zip (which today works only
at a server root), and in a local preview.

This is sound only because of the hash URL strategy: with path-based URLs,
`./` would resolve against a route path and break asset loading.  Whether the
engine's asset loading and `flutter build web` itself accept a relative base
is not known, so **the first implementation task is a spike**: build with
`./`, serve the output from a nested directory, and exercise startup, fonts,
and both Markdown-asset screens (License terms, Privacy policy).  If it fails,
fall back to `--base-href /app/` for the site build, leave the release zip
built as today, and accept that the deploy and the custom-domain switch must
happen together (see Migration Plan).

**Spike result (September 25, 2026): the relative base works.**
`flutter build web --release --wasm` accepts an `index.html` with no
`$FLUTTER_BASE_HREF` placeholder, with no warning.  The build was served from
`/app/` under a local server and driven in headless Chromium over the DevTools
protocol, using real mouse input on Flutter's semantics nodes.  Every request
resolved under `/app/` with status 200, including the fonts, the asset
manifests, and `assets/LICENSE.md` and `assets/PRIVACY.md` when their screens
were opened.  Both screens rendered their documents.  The identical build
served from a server root also booted and loaded `assets/PRIVACY.md`.  The
fallback is not needed.

Headless Chromium's `--screenshot` and `--dump-dom` are useless for this kind
of check: they capture before the Flutter view mounts and show a blank page,
even for the live site.  Waiting in real time and driving the page over the
DevTools protocol is what worked.

With a mount-agnostic build, `build-site` does not build the app itself: it
`needs: build-web` and unpacks that job's output into `app/`.  One Flutter web
build per workflow run instead of two, and the site and the release asset are
byte-identical builds.  `build-web` uploads `build/web` as an artifact for
this in addition to the zip.

*Alternative considered*: keep separate builds with different base hrefs.
Rejected: it doubles build time and lets the two diverge.

### D3: The Dart tool assembles the site; the workflow adds the app

`tool/generate_web_docs.dart` gains an output directory argument (default
`build/site`), replaces that directory's contents on each run, and writes
every page plus every local image the pages reference.  The workflow then
places the app build at `app/` inside it and uploads the result:

```
build/site/
├── index.html            ← README.md
├── privacy.html          ← PRIVACY.md
├── doc/screenshots/*.png ← copied because README.md references them
└── app/                  ← build/web, added by the workflow
```

Keeping the logic in the Dart library makes it testable and means a new
screenshot in the README needs no workflow change.  Because output is no
longer committed, the "write only when changed" behaviour loses its reason and
is dropped; replacing the directory also guarantees that a page removed from
the document set does not linger in a local build.

The tool refuses an output directory that contains the repository, or that
lies inside the repository anywhere other than strictly within `build/`, so a
stray argument cannot delete sources or the Flutter build.  Everything is
rendered before anything is deleted, so a generation error also leaves the
previous output in place.

*Alternative considered*: shell steps in the workflow.  Rejected: untestable,
and image discovery would have to be hard-coded.

### D4: Extensionless pages via `.html` files at the site root

A document's output is `privacy.html`, not `privacy/index.html`.  The Pages
server answers `/privacy` with it directly (200, no redirect), matching the
behaviour GitHub documents for Jekyll's `about.md` → `/about`, which is a
property of the server rather than of Jekyll.  `/privacy.html` also serves
the page; the canonical tag (D6) says which address is meant.

`/privacy/` returns 404.  Adding a redirecting `privacy/index.html` stub was
considered and rejected: with both `privacy.html` and a `privacy/` directory
present, which one the server picks for `/privacy` is unverified, and nothing
the project controls links to the trailing-slash form.  Every released APK's
bundled policy, and the README, use the no-slash form.

`/app` still 301-redirects to `/app/`: the app is a directory of assets and
needs a trailing-slash base.  That is acceptable since it is reached by link.

### D5: Relative links resolve against the repository

Relative links are resolved against the source document's directory in the
repository, then handled in this order:

1. **A converted document** (a source in the document set): rewritten to
   that document's published page, as a relative extensionless path.
2. **An image referenced by `<img src>`**: kept as-is, and the file is
   copied into the site at the same relative path.
3. **Any other file or directory that exists**: rewritten to
   `https://github.com/wisnij/unitary/blob/main/<path>` (or `tree/main/` for a
   directory).  Pages deploy only from `main`, so `main` is always the
   matching revision.
4. **A target that does not exist**: generation fails, naming the source
   document and the link.

Fragments and queries are preserved.  Absolute URLs and fragment-only links
are untouched.  This replaces the current hard failure on unconverted `.md`
links: that failure existed to force this decision before `doc/` links
appeared, and the missing-target failure keeps its typo-catching value.

The README links to its own sections (`#development`, `#documentation`).  The
`gitHubWeb` extension set already emits heading ids; implementation confirms
they match GitHub's slugs for the README's headings.

### D6: Per-page footer, index title, canonical tag

`WebDoc` gains a footer link, and the index is identified by its output:
- **a footer link** (label and href), replacing the depth-derived back-link.
  The home page links to the GitHub repository ("Source code on GitHub"); the
  privacy page links to the home page (`./`, "← Unitary").  A later `doc/`
  page can choose its own.
- **no index flag**: the document whose output is `index.html` at the site
  root is the index by definition.  Its `<title>` is its heading alone
  ("Unitary"), where every other page is "Heading — Unitary", avoiding
  "Unitary — Unitary".

Every page carries `<link rel="canonical">` built from a site base URL
constant, `https://unitary.wisnij.dev`, and the page's extensionless path:
`/` for `index.html`, `/privacy` for `privacy.html`.  The constant lives in
the generator library; the app's About screen keeps its own URL constants in
`about_constants.dart`.  The duplication across the tool/app boundary is
accepted rather than having the tool import app code.

The stylesheet gains `img { max-width: 100%; height: auto; }` so the README's
480 px screenshots fit a phone.

### D7: About screen entries

"Project home" opens `https://unitary.wisnij.dev/`, with that URL as its
subtitle.  A new "Source code" entry, directly after it, opens
`https://github.com/wisnij/unitary` using the same `url_launcher` path and
failure handling.  The source offer that AGPL §13 requires for the hosted web
build becomes a clearly labelled entry of its own.

### D8: `PRIVACY.md` edits and the DNS-only requirement

Both URLs in `PRIVACY.md` change: the policy's own address to
`https://unitary.wisnij.dev/privacy`, and the web app's to
`https://unitary.wisnij.dev/app/`.  The **effective date is bumped**: the
privacy-policy spec makes the date the means by which a reader of a bundled
copy tells which version they have, and two texts sharing a date would defeat
that, even though the app's data behaviour is unchanged.

The Cloudflare `CNAME` for `unitary` **must be DNS-only**.  A proxied record
would route every request through Cloudflare, adding a second party that
sees and logs them, and the policy's "Using Unitary in a web browser" section
names only GitHub Pages.  With DNS-only, Cloudflare answers DNS queries and
nothing more, and the section stays accurate as written.  This is recorded as
a requirement of the `pages-site` spec so that a future DNS change is checked
against the policy.

## Risks / Trade-offs

- **Relative base href does not work** → The spike runs first; the fallback
  (`--base-href /app/` for the site, zip unchanged) is fully specified, at the
  cost of a combined, briefly broken cutover.
- **Gap during the cutover** → With a relative base the new layout goes live
  at `wisnij.github.io/unitary/` first and can be checked there; the only
  remaining gap is certificate issuance after the domain is set, typically
  minutes.  HSTS means that gap cannot be bridged with plain HTTP.
- **Old app bookmarks and installed PWAs land on the README** → One link from
  the app, and the README already links to it.  Accepted.
- **Web users lose browser-stored data** → Inherent in any origin change;
  noted in the design progress entry.  Settings and history are cheap to
  recreate; exchange rates refetch automatically.
- **GitHub's `github.io` → custom domain redirect holds only while the custom
  domain is configured** → Released APKs bundle a policy naming the
  `github.io` URL, so removing the custom domain later would break them.
  Recorded in the `pages-site` spec.
- **The canonical address depends on extensionless-URL support** → GitHub
  Pages, Netlify and Cloudflare Pages provide it; a host that does not needs a
  rewrite rule or a `privacy/index.html` fallback.  Recorded as a constraint
  on any future host.
- **`blob/main` links track `main`, not the deployed commit** → The site only
  deploys from `main`, so they agree except in the minutes between a push and
  its deploy.  Accepted.
- **PR CI runs the site assembly** → The app build is reused from
  `build-web`, so the added cost is generation and packaging only.

## Migration Plan

Code first, then settings, in this order:

1. Merge the change.  `build-site` and `deploy-site` exist; `deploy-site`'s
   first run fails or is skipped until the Pages source is switched, and
   `gh-pages` keeps serving the old layout meanwhile.
2. Repository settings → Pages → Source: **GitHub Actions**.  From here the
   `gh-pages` branch is no longer served.
3. Re-run the workflow on `main`.  The new layout goes live at
   `https://wisnij.github.io/unitary/`; check `/`, `/app/` and `/privacy`
   there.  (With the `--base-href /app/` fallback, skip the `/app/` check and
   do steps 4–5 immediately.)
4. Settings → Pages → Custom domain: `unitary.wisnij.dev`.
5. Cloudflare: delete the redirect rule; add `CNAME unitary →
   wisnij.github.io`, **DNS-only**.
6. Wait for GitHub's DNS check and certificate; enable **Enforce HTTPS**.
7. Verify the new URLs, the `github.io` redirects, canonical tags, and the
   About screen links on a real build.
8. Delete the `gh-pages` branch.

**Rollback**: until step 8, switching the Pages source back to the `gh-pages`
branch and clearing the custom domain restores the old site exactly (the
Cloudflare redirect can be restored alongside).  After step 8 the old tree can
be recreated from any pre-change commit with the old `deploy-web` steps.

## Open Questions

- Does `flutter build web` accept an `index.html` without the
  `$FLUTTER_BASE_HREF` placeholder, and does asset loading work under a
  relative base?  Answered by the spike (D2).
