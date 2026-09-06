## ADDED Requirements

### Requirement: Generated HTML documents are produced from Markdown sources
The project SHALL provide `tool/generate_web_docs.dart` and
`tool/generate_web_docs_lib.dart`, following the established tool
executable/library convention, which convert a declared set of Markdown
documents into standalone HTML pages under `web/`.  The document set SHALL be
data — a constant list of source/output pairs in the library — so that
publishing further documents requires no change to the conversion logic.  The
tool SHALL NOT be specific to any one document.

#### Scenario: Declared documents are converted
- **WHEN** `dart run tool/generate_web_docs.dart` is invoked
- **THEN** every document in the declared set is converted and written to its declared output path

#### Scenario: Adding a document requires only a data change
- **WHEN** a new source/output pair is added to the document set
- **THEN** it is converted on the next run with no change to the conversion logic

#### Scenario: Unchanged output is not rewritten
- **WHEN** a document's rendered output is byte-identical to the file already on disk
- **THEN** the file is left untouched

### Requirement: Page title derives from the document's first heading
The generator SHALL take each page's title from the first level-1 heading in
its Markdown source, and SHALL retain that heading in the rendered body as the
page heading.  Setext-style headings SHALL be recognised, since the project's
Markdown convention uses them for level-1 and level-2 headings.

#### Scenario: Title taken from a setext H1
- **WHEN** a source document begins with a setext level-1 heading
- **THEN** the generated page's `<title>` incorporates that heading text, and the heading is also present in the page body

#### Scenario: Missing H1 is an error
- **WHEN** a source document contains no level-1 heading
- **THEN** the generator fails with an error naming the document, rather than emitting an untitled page

### Requirement: Pages are self-contained and mobile-legible
Each generated page SHALL be a complete HTML document declaring a character
encoding, a `viewport` meta tag, and a `<title>`, with its styling inlined
rather than linked from a shared stylesheet.  Styling SHALL adapt to the
viewer's light or dark colour-scheme preference.

#### Scenario: Page carries the metadata a mobile browser needs
- **WHEN** a page is generated
- **THEN** it contains a charset declaration, a `viewport` meta tag, and a `<title>`

#### Scenario: Styling travels with the page
- **WHEN** a generated page is opened outside the deployed site, such as from the release web archive
- **THEN** it renders with its intended styling, with no external stylesheet request

### Requirement: The link back to the app is derived from output depth
Each generated page SHALL include a relative link back to the web app's root.
The link SHALL be computed from the page's depth below `web/` rather than
specified per document, and SHALL be relative.  A root-absolute link is
forbidden, because a standalone page receives no `--base-href` substitution
and `/` would resolve to the hosting domain rather than to the app.

#### Scenario: Link depth matches page location
- **WHEN** a page is generated one directory below `web/`
- **THEN** its back-link points one level up

#### Scenario: Deeper pages get correspondingly deeper links
- **WHEN** a page is generated two directories below `web/`
- **THEN** its back-link points two levels up

#### Scenario: No root-absolute back-link is emitted
- **WHEN** any page is generated
- **THEN** its back-link is relative, not beginning with `/`

### Requirement: Links to unconverted Markdown documents fail the build
The generator SHALL fail with an error when a source document links to a
`.md` file that is not itself in the document set.  Such a link would publish
as a dead link, and cross-document links are common in the project's
documentation, so the failure exists to surface them at generation time
rather than after publication.  Rewriting such links is out of scope.

#### Scenario: Link to an unconverted document is rejected
- **WHEN** a source document links to a `.md` file that is not in the document set
- **THEN** the generator fails with an error naming the source document and the offending link target

#### Scenario: Link to a converted document is accepted
- **WHEN** a source document links to a `.md` file that is in the document set
- **THEN** generation succeeds

#### Scenario: External links are unaffected
- **WHEN** a source document links to an absolute `http` or `https` URL
- **THEN** generation succeeds regardless of the target

### Requirement: Generated pages are committed and kept in sync by a pre-commit hook
Generated pages SHALL be committed to the repository, and a
`generate-web-docs` pre-commit hook with `pass_filenames: false` SHALL
regenerate them when a declared source or the generator itself changes.  Each
generated page SHALL carry a marker identifying it as generated and naming
the source to edit instead.  No new CI step is required: the lint job already
runs the pre-commit hooks over all files and fails when a hook modifies one.

#### Scenario: Editing a source regenerates its page
- **WHEN** a declared Markdown source is changed and committed
- **THEN** the hook regenerates the corresponding HTML page

#### Scenario: A stale committed page fails lint
- **WHEN** a declared source is changed without regenerating its page
- **THEN** the lint job fails because the hook modifies a tracked file

#### Scenario: Generated pages identify themselves
- **WHEN** a generated page is inspected
- **THEN** it carries a marker identifying it as generated and naming its Markdown source

### Requirement: The deploy branch is published verbatim
The web build output SHALL be published without server-side post-processing:
`web/.nojekyll` SHALL be present so that GitHub Pages publishes the deploy
branch as-is rather than running a Jekyll build over it.  Without it, Jekyll
silently omits `.`- and `_`-prefixed paths from the served site and converts
Markdown files carrying YAML front matter, either of which can remove a
deployed file with no error reported.

#### Scenario: Dotfiles present on the deploy branch are served
- **WHEN** a file whose name begins with `.` is part of the web build output
- **THEN** it is retrievable from the deployed site

#### Scenario: Markdown assets are served as-is
- **WHEN** a Markdown file is bundled as a Flutter asset and reaches the deployed site
- **THEN** it is served unconverted at its original path, so the app can load it at runtime regardless of whether it carries front matter

#### Scenario: Generated pages are published unmodified
- **WHEN** a generated HTML page reaches the deploy branch
- **THEN** it is served byte-for-byte as generated
