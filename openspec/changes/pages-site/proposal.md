## Why

The project site lives at `https://wisnij.github.io/unitary/`, an address
tied to the current host, and its root is the web app itself, so there is no
page that introduces the project to someone who arrives cold.  The owner
already holds `wisnij.dev`; `unitary.wisnij.dev` currently 302-redirects
through Cloudflare to the GitHub repository rather than serving anything.
Now is the time to fix this: the Play Store submission (Phase 10 task 7)
has not yet registered a privacy-policy URL, so the policy's address can
still change without breaking an external registration.  Once registered,
it should be an address the project owns and can keep across any future
change of host.

## What Changes

- Serve the Pages site from the custom domain **`unitary.wisnij.dev`**.
  GitHub redirects every `wisnij.github.io/unitary/<path>` request to the
  same path on the custom domain, so existing links keep resolving.
- Restructure the site:
  - `/`: the repository `README.md`, rendered as a page, with the
    screenshots it references published alongside it.
  - `/app/`: the Flutter web app (**BREAKING** for bookmarks of the old app
    root: `wisnij.github.io/unitary/` now lands on the README, one link away
    from the app).
  - `/privacy`: the privacy policy, served extensionless from
    `privacy.html` (**BREAKING**: `/privacy/` with a trailing slash no longer
    resolves; nothing the project controls links to that form).
- Declare each page's canonical address (`<link rel="canonical">`) on the
  custom domain, so `https://unitary.wisnij.dev/privacy` is established as
  the policy's permanent address independent of the host.
- Publish through **GitHub Actions** (`actions/deploy-pages`) instead of
  force-pushing to a `gh-pages` branch.  The site is assembled on every push
  and pull request, so a generation error fails CI before merge; only pushes
  to `main` deploy.  The `gh-pages` branch is retired.
- Generate pages **in CI** instead of committing them.  The committed
  `web/privacy/index.html`, the `generate-web-docs` pre-commit hook, and
  `web/.nojekyll` (moot once Jekyll never runs) are removed.
- Build the web app with a **relative base href** (`./`), so a single build
  works at any mount point: `/app/` on the site, a subdirectory of any host
  for the release web zip, and a local preview.  Gated on a spike; the
  fallback is `--base-href /app/`.
- Extend the generator: rewrite relative links to files that are not
  published into GitHub `blob/main/` URLs (replacing the current hard failure
  on unconverted `.md` links), fail on links to files that do not exist, copy
  referenced local images into the site, and support per-page footers and an
  unsuffixed title for the site index.
- About screen: **"Project home"** now opens `https://unitary.wisnij.dev/`,
  and a new **"Source code"** entry opens the GitHub repository.
- Update `PRIVACY.md` (both URLs, new effective date), `README.md`, and the
  planning docs to the new addresses.
- Manual cutover: switch the Pages source to GitHub Actions, set the custom
  domain, replace the Cloudflare redirect with a **DNS-only** `CNAME`, enforce
  HTTPS, and delete `gh-pages`.  DNS-only is a requirement, not only a
  certificate-provisioning step: a proxied record would add Cloudflare as a
  second party logging requests, which the privacy policy does not disclose.

## Capabilities

### New Capabilities

- `pages-site`: the published project site: its domain, URL layout,
  canonical addresses, how it is assembled and deployed, and the constraints
  on the DNS configuration and any future host.

### Modified Capabilities

- `web-doc-generation`: output moves from `web/` into an assembled site
  directory generated in CI; extensionless page outputs; per-page footer links
  replace the depth-derived back-link to the app; unsuffixed title for the
  site index; canonical link tag; link rewriting to GitHub and missing-target
  failure replace the unconverted-`.md` failure; referenced images are
  published; the committed-page/pre-commit-hook and deploy-branch/`.nojekyll`
  requirements are removed.
- `privacy-policy`: the hosted URL becomes `https://unitary.wisnij.dev/privacy`;
  the trailing-slash scenario is replaced by the extensionless one.
- `about-menu`: "Project home" opens the project site; a new "Source code"
  entry opens the GitHub repository.

## Impact

- **CI**: `.github/workflows/ci.yml`: `deploy-web` replaced by `build-site`
  (all events) and `deploy-site` (main only, `pages: write`,
  `id-token: write`, `github-pages` environment); `build-web` additionally
  hands its build to `build-site`.  `.pre-commit-config.yaml` loses the
  `generate-web-docs` hook.
- **Web app**: `web/index.html` base element; `web/privacy/` and
  `web/.nojekyll` deleted.
- **Tooling**: `tool/generate_web_docs.dart`, `tool/generate_web_docs_lib.dart`
  and their tests.
- **App**: `lib/features/about/about_constants.dart`,
  `lib/features/about/presentation/about_screen.dart`, About screen and
  privacy screen tests.
- **Docs**: `PRIVACY.md`, `README.md`, `doc/implementation_plan.md`,
  `doc/design_progress.md`.
- **External configuration** (manual): repository Pages settings,
  Cloudflare DNS for `wisnij.dev`.  The `wisnij.dev` domain is already
  verified on the owner's GitHub account.
- **Web users**: moving to a new origin means browser-stored data (settings,
  history, worksheet values, fetched rates) does not carry over from
  `wisnij.github.io`.  Unavoidable with any domain change.
- No new dependencies.
