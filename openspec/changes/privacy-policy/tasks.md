## 1. Dependency and scaffolding

- [x] 1.1 Add `markdown` to `dev_dependencies` in `pubspec.yaml` and run `flutter pub get`; confirm `pubspec.lock` records no version change (it is already resolved transitively via `flutter_markdown_plus`)
- [x] 1.2 Create `tool/generate_web_docs_lib.dart` and `tool/generate_web_docs.dart` stubs following the existing executable/library split used by `import_gnu_units`, `generate_predefined_units`, and `check_coverage`

## 2. Generator — tests first

- [x] 2.1 Write `test/tool/generate_web_docs_lib_test.dart` covering title derivation: `<title>` taken from the first setext H1, the H1 retained in the rendered body, and a missing H1 failing with an error naming the document
- [x] 2.2 Add tests for the page shell: charset declaration, `viewport` meta tag, `<title>`, inlined styling with no external stylesheet reference, and a light/dark colour-scheme rule
- [x] 2.3 Add tests for back-link derivation: one level up at depth 1, two levels up at depth 2, and never root-absolute
- [x] 2.4 Add tests for the unresolved-link check: a link to a `.md` file outside the document set fails and names both the source and the offending target; a link to a document inside the set succeeds; `http`/`https` links are unaffected
- [x] 2.5 Add a test that a generated page carries its generated-file marker naming the Markdown source
- [x] 2.6 Add a test that regenerating byte-identical output leaves the file untouched

## 3. Generator — implementation

- [x] 3.1 Implement the document set as a `const` list of source/output pairs in `generate_web_docs_lib.dart`, seeded with `PRIVACY.md` → `web/privacy/index.html`
- [x] 3.2 Implement Markdown→HTML conversion, H1 title derivation, and the self-contained page shell (charset, viewport, title, inlined light/dark CSS, generated-file marker)
- [x] 3.3 Implement depth-derived relative back-link to the app root
- [x] 3.4 Implement the unresolved `.md` link check as a hard failure
- [x] 3.5 Implement write-only-if-changed, and wire the executable to iterate the document set
- [x] 3.6 Confirm all tests from group 2 pass

## 4. The policy document

- [x] 4.1 Write `PRIVACY.md`: no collection, no analytics/ads/tracking, all data stored locally on device
- [x] 4.2 Document the exchange-rate request as the app's only outbound network call, stating that it is unauthenticated and carries no user identifier, and disclosing that it necessarily exposes the requester's IP address to the API operator
- [x] 4.3 Note that the browser-hosted build is served by GitHub Pages, which logs requests as any host does, and that this does not apply to the installed app
- [x] 4.4 State the declared Android permission (`INTERNET`); verify against a release APK with `aapt2 dump badging` before claiming the full permission set, and omit Flutter-injected internal permissions if they cannot be confirmed
- [x] 4.5 Add `wisnij@gmail.com` as the contact address and an effective date
- [x] 4.6 Name the canonical hosted URL in the document as the location of the current version, so the bundled copy self-identifies and links out (rendered as a tappable link in-app by `flutter_markdown_plus`)
- [x] 4.7 Confirm `markdownlint-cli2` passes on the new file, using setext headings per the project's Markdown convention
- [x] 4.8 Add `PRIVACY.md` to the Flutter `assets:` list in `pubspec.yaml`, beside `LICENSE.md`

## 5. Generated page and hook

- [x] 5.1 Run `dart run tool/generate_web_docs.dart` and commit the generated `web/privacy/index.html`
- [x] 5.2 Add the `generate-web-docs` hook to `.pre-commit-config.yaml` with `pass_filenames: false`, naming `PRIVACY\.md` and `tool/generate_web_docs` individually; confirm it needs no `SKIP` in CI (unlike `generate-icons`, it only runs `dart`)
- [x] 5.3 Verify drift is caught: edit `PRIVACY.md` without regenerating, confirm `pre-commit run --all-files` fails, then regenerate and confirm it passes
- [x] 5.4 Review the rendered page in a browser at phone and desktop widths, in both light and dark colour schemes

## 6. Publish verbatim

- [x] 6.1 Add an empty `web/.nojekyll`
- [x] 6.2 Confirm it survives the build: run `flutter build web` and check `build/web/.nojekyll` exists (Flutter's copy loop uses `listSync`, which includes dotfiles)

## 7. In-app policy screen — tests first

- [x] 7.1 Write `test/features/about/presentation/privacy_screen_test.dart` mirroring `license_screen_test.dart`: the bundled document renders as formatted text under an "Privacy policy" app bar with back navigation
- [x] 7.2 Add a test for the asset-failure path — a load error shows a message rather than crashing
- [x] 7.3 Add a test that tapping a link in the rendered document launches it via the existing `FakeUrlLauncher`, and that a launch failure does not crash
- [x] 7.4 Add tests to `about_screen_test.dart` mirroring the existing "License terms" pair: tapping "Privacy policy" pushes `PrivacyScreen`, and entry order places it after License terms and before Project home
- [x] 7.5 Implement `lib/features/about/presentation/privacy_screen.dart` mirroring `LicenseScreen` (`DefaultAssetBundle.loadString('PRIVACY.md')`, `flutter_markdown_plus`, `onTapLink` → `url_launcher` with silent failure handling)
- [x] 7.6 Add the Privacy policy `ListTile` to `AboutScreen`, navigating like the License terms tile
- [x] 7.7 Confirm `about_constants.dart` is unchanged, so its `defaultExpectedAbsent` entry in `check_coverage_lib.dart` still describes it correctly
- [x] 7.8 Confirm `privacy_screen.dart` is covered well enough to keep the aggregate above the 90% floor (`dart run tool/check_coverage.dart`)

## 8. README

- [x] 8.1 Link the hosted policy from the README's "ads, paywalls, subscriptions … data harvesting" paragraph, written in the no-trailing-slash form

## 9. Verification

- [x] 9.1 `flutter test --reporter failures-only` — full suite passes
- [x] 9.2 `flutter analyze` — no issues
- [x] 9.3 `pre-commit run --all-files` — clean
- [x] 9.4 Confirm `unitary-<version>-web.zip` produced by a local `flutter build web` contains `privacy/index.html`, `.nojekyll`, and `assets/PRIVACY.md`
- [x] 9.5 Verify the in-app screen on a real device: the policy renders, its hosted-URL link opens a browser, and it still renders with the network disabled

## 10. Post-merge verification (requires deployment from `main`)

- [ ] 10.1 Confirm `https://wisnij.github.io/unitary/privacy/` returns 200 and renders correctly
- [ ] 10.2 Confirm `https://wisnij.github.io/unitary/privacy` 301-redirects to the canonical trailing-slash form
- [ ] 10.3 Confirm `https://wisnij.github.io/unitary/.last_build_id` now returns 200 — the observable signal that `.nojekyll` took effect (it returns 404 today)
- [ ] 10.4 Confirm `https://wisnij.github.io/unitary/assets/LICENSE.md` and `.../assets/PRIVACY.md` both return 200 as `text/markdown`, and that the web app's License terms and Privacy policy screens both render
- [ ] 10.5 Confirm the deployed web app itself is unaffected (loads and evaluates an expression)

## 11. Documentation

- [x] 11.1 Mark Phase 10 task 4 complete in `doc/implementation_plan.md`, recording the hosted URL, the generated-and-committed approach, and the `.nojekyll` finding
- [x] 11.2 Add a dated entry to `doc/design_progress.md` covering the generator, the Jekyll findings (front-matter conversion, silent dotfile omission), and the decision to bundle the policy per-build rather than link out
- [x] 11.3 Note in Phase 10 task 7 that the Play Console Data safety declaration must stay consistent with the policy's disclosures, and that the canonical trailing-slash URL is the one to register
