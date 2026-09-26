# web-doc-generation Specification

## Purpose
TBD - created by archiving change privacy-policy. Update Purpose after archive.
## Requirements
### Requirement: Generated HTML documents are produced from Markdown sources
The project SHALL provide `tool/generate_web_docs.dart` and
`tool/generate_web_docs_lib.dart`, following the established tool
executable/library convention, which convert a declared set of Markdown
documents into standalone HTML pages in a site output directory (by default
`build/site`).  The document set SHALL be data (a constant list of
source/output pairs with their per-page settings in the library) so that
publishing further documents requires no change to the conversion logic.  The
tool SHALL NOT be specific to any one document.  Each run SHALL replace the
output directory's contents, and the tool SHALL refuse an output directory
inside a tracked source tree.

#### Scenario: Declared documents are converted
- **WHEN** `dart run tool/generate_web_docs.dart` is invoked
- **THEN** every document in the declared set is converted and written to its declared output path under the output directory

#### Scenario: Adding a document requires only a data change
- **WHEN** a new document entry is added to the document set
- **THEN** it is converted on the next run with no change to the conversion logic

#### Scenario: Output directory is replaced
- **WHEN** the output directory contains a file from an earlier run whose document is no longer in the set
- **THEN** that file is absent after the next run

#### Scenario: Output inside a source tree is refused
- **WHEN** the tool is given an output directory inside `web/` or `lib/`
- **THEN** it fails without deleting or writing anything

### Requirement: Page title derives from the document's first heading
The generator SHALL take each page's title from the first level-1 heading in
its Markdown source, and SHALL retain that heading in the rendered body as the
page heading.  Setext-style headings SHALL be recognised, since the project's
Markdown convention uses them for level-1 and level-2 headings.  The site's
index page SHALL use the heading alone as its title; every other page SHALL
append the site name.

#### Scenario: Title taken from a setext H1
- **WHEN** a source document begins with a setext level-1 heading
- **THEN** the generated page's `<title>` incorporates that heading text, and the heading is also present in the page body

#### Scenario: Missing H1 is an error
- **WHEN** a source document contains no level-1 heading
- **THEN** the generator fails with an error naming the document, rather than emitting an untitled page

#### Scenario: Index page title is not suffixed
- **WHEN** the site's index page is generated from a document whose heading is "Unitary"
- **THEN** its `<title>` is "Unitary", not "Unitary — Unitary"

#### Scenario: Other page titles carry the site name
- **WHEN** a page other than the index is generated from a document whose heading is "Privacy Policy"
- **THEN** its `<title>` is "Privacy Policy — Unitary"

### Requirement: Pages are self-contained and mobile-legible
Each generated page SHALL be a complete HTML document declaring a character
encoding, a `viewport` meta tag, and a `<title>`, with its styling inlined
rather than linked from a shared stylesheet.  Styling SHALL adapt to the
viewer's light or dark colour-scheme preference, and images SHALL be scaled
down to fit narrow viewports.

#### Scenario: Page carries the metadata a mobile browser needs
- **WHEN** a page is generated
- **THEN** it contains a charset declaration, a `viewport` meta tag, and a `<title>`

#### Scenario: Styling travels with the page
- **WHEN** a generated page is opened from a local copy of the site
- **THEN** it renders with its intended styling, with no external stylesheet request

#### Scenario: Wide images fit a phone screen
- **WHEN** a page containing an image wider than the viewport is displayed
- **THEN** the image is scaled to the content width rather than overflowing it

### Requirement: Pages are published at extensionless addresses
A document's output SHALL be an `.html` file named for its address (for
example `privacy.html` for `/privacy`), or `index.html` for the site root,
rather than an `index.html` inside a directory of that name.

#### Scenario: Policy output is a root-level file
- **WHEN** the privacy policy is generated
- **THEN** it is written to `privacy.html` at the root of the output directory

### Requirement: Pages declare their canonical address
Each generated page SHALL include a `<link rel="canonical">` whose target is
the site base URL (`https://unitary.wisnij.dev`) followed by the page's
extensionless path: `/` for `index.html`, and the file name without `.html`
for any other page.

#### Scenario: Canonical tag for a named page
- **WHEN** `privacy.html` is generated
- **THEN** it declares `https://unitary.wisnij.dev/privacy` as canonical

#### Scenario: Canonical tag for the index
- **WHEN** `index.html` is generated
- **THEN** it declares `https://unitary.wisnij.dev/` as canonical

### Requirement: Each page declares its own footer link
Each document entry SHALL specify the footer link its page carries, as a
label and an href, instead of the footer being derived from the page's
location.  An href to another page on the site SHALL be relative.

#### Scenario: Home page footer links to the source repository
- **WHEN** the home page is generated
- **THEN** its footer links to the project's GitHub repository

#### Scenario: Privacy page footer links to the home page
- **WHEN** the privacy policy page is generated
- **THEN** its footer links to the site's home page with a relative href

### Requirement: Relative links are resolved against the repository
The generator SHALL resolve each relative link in a rendered document against
the source document's directory in the repository.  A link to a document in
the set SHALL be rewritten to that document's published page.  A link to any
other existing file SHALL be rewritten to the file's `blob/main` URL on
GitHub, and to any other existing directory to its `tree/main` URL.  A link
whose target does not exist SHALL fail generation.  Fragments and queries
SHALL be preserved; absolute URLs and fragment-only links SHALL be left
unchanged.  Images referenced by `<img src>` are handled by the image
publishing requirement instead.

#### Scenario: Link to a converted document is rewritten to its page
- **WHEN** a source document links to another document in the set
- **THEN** the link points to that document's published page

#### Scenario: Link to an unpublished file is rewritten to GitHub
- **WHEN** `README.md` links to `doc/architecture.md`, which is not in the document set
- **THEN** the link points to `https://github.com/wisnij/unitary/blob/main/doc/architecture.md`

#### Scenario: Fragment is preserved when rewriting
- **WHEN** a source document links to `doc/terminology.md#dimension`
- **THEN** the rewritten link ends with `#dimension`

#### Scenario: Link to a missing file fails
- **WHEN** a source document links to a relative path that does not exist in the repository
- **THEN** the generator fails with an error naming the source document and the link target

#### Scenario: External and fragment-only links are unaffected
- **WHEN** a source document links to an absolute `http` or `https` URL, or to `#development`
- **THEN** the link is emitted unchanged

### Requirement: Referenced images are published with the page
Each local image a page references through `<img src>` SHALL be copied into
the output directory at the same relative path, so the page's reference
resolves on the site.  A reference to an image that does not exist SHALL fail
generation.  Images with absolute URLs SHALL be left unchanged and not copied.

#### Scenario: README screenshots are published
- **WHEN** the home page is generated from `README.md`, which references `doc/screenshots/freeform.png`
- **THEN** that file is present at `doc/screenshots/freeform.png` in the output directory

#### Scenario: Missing image fails
- **WHEN** a source document references a local image that does not exist
- **THEN** the generator fails with an error naming the source document and the image path

#### Scenario: Remote images are not copied
- **WHEN** a source document references a badge image by absolute URL
- **THEN** the reference is unchanged and nothing is copied for it

### Requirement: Generated pages identify themselves
Each generated page SHALL carry a marker identifying it as generated and
naming the Markdown source to edit instead.

#### Scenario: Generated page names its source
- **WHEN** a generated page is inspected
- **THEN** it carries a marker identifying it as generated and naming its Markdown source
