## 1. Spike: relative base href

- [ ] 1.1 Replace `<base href="$FLUTTER_BASE_HREF">` in `web/index.html` with `<base href="./">` (updating the explanatory comment above it) and run `flutter build web --release --wasm` with no `--base-href`; record whether the build warns or fails
- [ ] 1.2 Serve `build/web` from a nested directory (e.g. copy it to `<scratch>/site/app/` and serve `<scratch>/site`), then load `/app/` and confirm startup, fonts, the License terms and Privacy policy screens (both load Markdown assets), and navigation between pages
- [ ] 1.3 Confirm the same build also runs when served from a server root, and that requesting `/app` without the slash is handled by the hosting redirect rather than the app (check behaviour under the local server used)
- [ ] 1.4 Record the outcome in `design.md` D2.  If the spike fails, switch the plan to the fallback: revert 1.1, build the site with `--base-href /app/`, leave `build-web` unchanged, and amend tasks 5 and 9 accordingly

## 2. Generator: tests first

- [ ] 2.1 Update `test/tool/generate_web_docs_lib_test.dart` for the new document model: entries carry an output path at the site root and a footer link (label and href); remove tests for depth-derived back-links, write-if-changed, and the unconverted-`.md` failure
- [ ] 2.2 Add title tests: index page (`index.html`) uses its heading alone; other pages append " — Unitary"
- [ ] 2.3 Add canonical-tag tests: `index.html` → `https://unitary.wisnij.dev/`, `privacy.html` → `https://unitary.wisnij.dev/privacy`
- [ ] 2.4 Add footer tests: each page renders its declared footer label and href; home page footer targets the GitHub repository, privacy footer targets `./`
- [ ] 2.5 Add link-resolution tests against a temporary repository root: converted document → relative extensionless page link; existing unpublished file → `blob/main/<path>`; existing directory → `tree/main/<path>`; fragment and query preserved; missing target fails naming source and link; absolute and fragment-only links unchanged; links resolved relative to a source document in a subdirectory
- [ ] 2.6 Add image tests: local `<img src>` copied to the same relative path in the output; missing image fails naming source and path; absolute-URL images neither rewritten nor copied
- [ ] 2.7 Add output-directory tests: contents replaced on each run (stale file from a removed document is gone); an output directory inside `web/` or `lib/` is refused before anything is deleted or written
- [ ] 2.8 Add a stylesheet test that images are constrained to the content width (`max-width: 100%`)
- [ ] 2.9 Add a test that the README's in-page anchors (`#development`, `#documentation`) match heading ids emitted for the README's headings, or document why a mismatch is acceptable

## 3. Generator: implementation

- [ ] 3.1 Add `siteBaseUrl` (`https://unitary.wisnij.dev`) and `repoUrl` (`https://github.com/wisnij/unitary`) constants to `tool/generate_web_docs_lib.dart`
- [ ] 3.2 Extend `WebDoc` with a footer link; change `defaultWebDocs` to `README.md` → `index.html` (footer: GitHub repository) and `PRIVACY.md` → `privacy.html` (footer: "← Unitary" → `./`); outputs are relative to the output directory rather than under `web/`
- [ ] 3.3 Implement the index title rule and the canonical `<link>` in `renderPage`
- [ ] 3.4 Replace `checkLinks` and `backLinkFor` with link resolution per design D5, returning the rewritten HTML
- [ ] 3.5 Implement image discovery and copying for local `<img src>` references
- [ ] 3.6 Replace `writeIfChanged`/`generateWebDocs` output handling with output-directory replacement and the source-tree guard
- [ ] 3.7 Add `img { max-width: 100%; height: auto; }` to `pageStyle`
- [ ] 3.8 Update `tool/generate_web_docs.dart`: accept an optional output directory argument (default `build/site`), update usage text and the doc comment (no more committed pages or pre-commit hook)
- [ ] 3.9 Update the library doc comment to describe CI generation and the site layout
- [ ] 3.10 Run the generator locally and inspect `build/site/`: both pages render in light and dark, screenshots display and fit a 390 px viewport, rewritten `doc/` links point to GitHub, footers and canonical tags are correct

## 4. Remove committed output and Jekyll guard

- [ ] 4.1 Delete `web/privacy/index.html` and `web/.nojekyll`
- [ ] 4.2 Remove the `generate-web-docs` hook from `.pre-commit-config.yaml`
- [ ] 4.3 Add `build/site/` to `.gitignore` if `build/` is not already ignored as a whole

## 5. CI

- [ ] 5.1 In `build-web`, after zipping, upload `build/web` as an additional artifact for `build-site`
- [ ] 5.2 Add a `build-site` job (all events, `needs: build-web`): check out, set up Dart/Flutter, run `dart run tool/generate_web_docs.dart build/site`, download the web build into `build/site/app/`, and upload with `actions/upload-pages-artifact`
- [ ] 5.3 Add a `deploy-site` job (`if: github.ref == 'refs/heads/main'` on push, `needs: build-site`) with `permissions: pages: write, id-token: write`, `environment: github-pages` (URL from the deploy step output), the existing non-cancelling concurrency group, and `actions/deploy-pages`
- [ ] 5.4 Delete the `deploy-web` job
- [ ] 5.5 Confirm on a pull request that `build-site` runs and `deploy-site` is skipped, and that deliberately adding a link to a missing file in `README.md` fails `build-site`

## 6. About screen: tests first

- [ ] 6.1 Update About screen tests: "Project home" subtitle is `https://unitary.wisnij.dev/` and tapping launches it; a "Source code" entry follows it with subtitle `https://github.com/wisnij/unitary`, launches that URL, and survives a launch failure; entry order matches the spec
- [ ] 6.2 In `lib/features/about/about_constants.dart`, point `projectHomeUrl` at `https://unitary.wisnij.dev/` and add `sourceCodeUrl`
- [ ] 6.3 Add the "Source code" `ListTile` after "Project home" in `about_screen.dart` (code icon, shared launch-and-ignore-failure behaviour)

## 7. Documents and URLs

- [ ] 7.1 `PRIVACY.md`: policy URL → `https://unitary.wisnij.dev/privacy`, web app URL → `https://unitary.wisnij.dev/app/`, bump the effective date; confirm the "Using Unitary in a web browser" section is still accurate with DNS-only Cloudflare
- [ ] 7.2 Update `test/features/about/presentation/privacy_screen_test.dart` fixtures and expectations to the new policy URL
- [ ] 7.3 `README.md`: privacy link → `https://unitary.wisnij.dev/privacy`; web app link → `https://unitary.wisnij.dev/app/`
- [ ] 7.4 Search the repository (excluding archived OpenSpec changes and dated history entries) for remaining `wisnij.github.io` references and update them
- [ ] 7.5 `doc/implementation_plan.md`: Phase 10 task 1 (web deployment description) and task 7 (register `https://unitary.wisnij.dev/privacy` with Play, no trailing slash)
- [ ] 7.6 `doc/design_progress.md`: add a dated entry for this change, including the origin change for web users and the DNS-only requirement

## 8. Verification

- [ ] 8.1 `flutter test --reporter failures-only` passes
- [ ] 8.2 `flutter analyze` is clean
- [ ] 8.3 `dart run tool/check_coverage.dart` still meets the threshold (after `flutter test --coverage`)
- [ ] 8.4 `pre-commit run --all-files` passes without the removed hook

## 9. Cutover (manual, after merge)

- [ ] 9.1 Repository Settings → Pages → Source: GitHub Actions
- [ ] 9.2 Re-run the workflow on `main`; check `/`, `/app/` and `/privacy` at `https://wisnij.github.io/unitary/` (skip `/app/` under the base-href fallback and proceed straight to 9.3–9.4)
- [ ] 9.3 Settings → Pages → Custom domain: `unitary.wisnij.dev`
- [ ] 9.4 Cloudflare: delete the `unitary` redirect rule; add `CNAME unitary → wisnij.github.io`, DNS-only
- [ ] 9.5 After GitHub's DNS check passes and the certificate is issued, enable Enforce HTTPS
- [ ] 9.6 Verify: `/`, `/app/`, `/app` → `/app/`, `/privacy` (200, no redirect), `/privacy/` (404, accepted), canonical tags, `wisnij.github.io/unitary/privacy` → `unitary.wisnij.dev/privacy`, and `unitary.wisnij.dev` resolving to GitHub Pages addresses rather than Cloudflare's
- [ ] 9.7 On a device build, confirm About → Project home and Source code open the right URLs, and the bundled policy's link opens the new address
- [ ] 9.8 Delete the `gh-pages` branch
