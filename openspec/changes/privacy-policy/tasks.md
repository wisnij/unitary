## 1. Dependency and scaffolding

- [ ] 1.1 Add `markdown` to `dev_dependencies` in `pubspec.yaml` and run `flutter pub get`; confirm `pubspec.lock` records no version change (it is already resolved transitively via `flutter_markdown_plus`)
- [ ] 1.2 Create `tool/generate_web_docs_lib.dart` and `tool/generate_web_docs.dart` stubs following the existing executable/library split used by `import_gnu_units`, `generate_predefined_units`, and `check_coverage`

## 2. Generator — tests first

- [ ] 2.1 Write `test/tool/generate_web_docs_lib_test.dart` covering title derivation: `<title>` taken from the first setext H1, the H1 retained in the rendered body, and a missing H1 failing with an error naming the document
- [ ] 2.2 Add tests for the page shell: charset declaration, `viewport` meta tag, `<title>`, inlined styling with no external stylesheet reference, and a light/dark colour-scheme rule
- [ ] 2.3 Add tests for back-link derivation: one level up at depth 1, two levels up at depth 2, and never root-absolute
- [ ] 2.4 Add tests for the unresolved-link check: a link to a `.md` file outside the document set fails and names both the source and the offending target; a link to a document inside the set succeeds; `http`/`https` links are unaffected
- [ ] 2.5 Add a test that a generated page carries its generated-file marker naming the Markdown source
- [ ] 2.6 Add a test that regenerating byte-identical output leaves the file untouched

## 3. Generator — implementation

- [ ] 3.1 Implement the document set as a `const` list of source/output pairs in `generate_web_docs_lib.dart`, seeded with `PRIVACY.md` → `web/privacy/index.html`
- [ ] 3.2 Implement Markdown→HTML conversion, H1 title derivation, and the self-contained page shell (charset, viewport, title, inlined light/dark CSS, generated-file marker)
- [ ] 3.3 Implement depth-derived relative back-link to the app root
- [ ] 3.4 Implement the unresolved `.md` link check as a hard failure
- [ ] 3.5 Implement write-only-if-changed, and wire the executable to iterate the document set
- [ ] 3.6 Confirm all tests from group 2 pass

## 4. The policy document

- [ ] 4.1 Write `PRIVACY.md`: no collection, no analytics/ads/tracking, all data stored locally on device
- [ ] 4.2 Document the exchange-rate request as the app's only outbound network call, stating that it is unauthenticated and carries no user identifier, and disclosing that it necessarily exposes the requester's IP address to the API operator
- [ ] 4.3 Note that the browser-hosted build is served by GitHub Pages, which logs requests as any host does, and that this does not apply to the installed app
- [ ] 4.4 State the declared Android permission (`INTERNET`); verify against a release APK with `aapt2 dump badging` before claiming the full permission set, and omit Flutter-injected internal permissions if they cannot be confirmed
- [ ] 4.5 Add `wisnij@gmail.com` as the contact address and an effective date
- [ ] 4.6 Confirm `markdownlint-cli2` passes on the new file, using setext headings per the project's Markdown convention

## 5. Generated page and hook

- [ ] 5.1 Run `dart run tool/generate_web_docs.dart` and commit the generated `web/privacy/index.html`
- [ ] 5.2 Add the `generate-web-docs` hook to `.pre-commit-config.yaml` with `pass_filenames: false`, naming `PRIVACY\.md` and `tool/generate_web_docs` individually; confirm it needs no `SKIP` in CI (unlike `generate-icons`, it only runs `dart`)
- [ ] 5.3 Verify drift is caught: edit `PRIVACY.md` without regenerating, confirm `pre-commit run --all-files` fails, then regenerate and confirm it passes
- [ ] 5.4 Review the rendered page in a browser at phone and desktop widths, in both light and dark colour schemes

## 6. Publish verbatim

- [ ] 6.1 Add an empty `web/.nojekyll`
- [ ] 6.2 Confirm it survives the build: run `flutter build web` and check `build/web/.nojekyll` exists (Flutter's copy loop uses `listSync`, which includes dotfiles)

## 7. App integration — tests first

- [ ] 7.1 Add two tests to `test/features/about/presentation/about_screen_test.dart` mirroring the existing "Project home" pair: the Privacy policy tile shows the URL as its subtitle, and tapping it records the hosted URL on the existing `FakeUrlLauncher`
- [ ] 7.2 Add a test pinning entry order: Privacy policy renders after License terms and before Project home
- [ ] 7.3 Add `privacyPolicyUrl` to `lib/features/about/about_constants.dart`
- [ ] 7.4 Add the Privacy policy `ListTile` to `AboutScreen`, mirroring the Project home tile including its silent launch-failure handling
- [ ] 7.5 Update the `about_constants.dart` comment in `check_coverage_lib.dart`'s `defaultExpectedAbsent` ("Two const declarations" → three) and confirm the file is still declaration-only

## 8. README

- [ ] 8.1 Link the hosted policy from the README's "ads, paywalls, subscriptions … data harvesting" paragraph, written in the no-trailing-slash form

## 9. Verification

- [ ] 9.1 `flutter test --reporter failures-only` — full suite passes
- [ ] 9.2 `flutter analyze` — no issues
- [ ] 9.3 `pre-commit run --all-files` — clean
- [ ] 9.4 Confirm `unitary-<version>-web.zip` produced by a local `flutter build web` contains `privacy/index.html` and `.nojekyll`

## 10. Post-merge verification (requires deployment from `main`)

- [ ] 10.1 Confirm `https://wisnij.github.io/unitary/privacy/` returns 200 and renders correctly
- [ ] 10.2 Confirm `https://wisnij.github.io/unitary/privacy` 301-redirects to the canonical trailing-slash form
- [ ] 10.3 Confirm `https://wisnij.github.io/unitary/.last_build_id` now returns 200 — the observable signal that `.nojekyll` took effect (it returns 404 today)
- [ ] 10.4 Confirm `https://wisnij.github.io/unitary/assets/LICENSE.md` still returns 200 as `text/markdown`, and that the web app's License terms screen still renders
- [ ] 10.5 Confirm the deployed web app itself is unaffected (loads and evaluates an expression)

## 11. Documentation

- [ ] 11.1 Mark Phase 10 task 4 complete in `doc/implementation_plan.md`, recording the hosted URL, the generated-and-committed approach, and the `.nojekyll` finding
- [ ] 11.2 Add a dated entry to `doc/design_progress.md` covering the generator, the Jekyll findings (front-matter conversion, silent dotfile omission), and the link-out decision
- [ ] 11.3 Note in Phase 10 task 7 that the Play Console Data safety declaration must stay consistent with the policy's disclosures, and that the canonical trailing-slash URL is the one to register
