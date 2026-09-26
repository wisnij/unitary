# pages-site Specification

## Purpose
The published project site at `unitary.wisnij.dev`: its domain, URL layout,
canonical addresses, how it is assembled and deployed, and the constraints on
its DNS configuration and any future host.

## Requirements
### Requirement: The project site is served from its own domain
The project site SHALL be served by GitHub Pages at
`https://unitary.wisnij.dev`, configured as the repository's custom domain
with HTTPS enforced.  The custom domain SHALL remain configured for as long
as the `wisnij.github.io/unitary/` addresses need to resolve, because GitHub
redirects them to the custom domain only while it is set, and released builds
bundle a privacy policy naming a `wisnij.github.io` address.

#### Scenario: Site is served over HTTPS at the custom domain
- **WHEN** `https://unitary.wisnij.dev/` is requested
- **THEN** the site's home page is served with a valid certificate

#### Scenario: Old addresses redirect with their path preserved
- **WHEN** `https://wisnij.github.io/unitary/privacy` is requested
- **THEN** the response redirects to `https://unitary.wisnij.dev/privacy`

### Requirement: The site has a fixed URL layout
The site SHALL serve the repository `README.md`, rendered as a page, at `/`;
the web app at `/app/`; and the privacy policy at `/privacy`.  Pages other
than the app SHALL be served at extensionless addresses.

#### Scenario: Home page is the rendered README
- **WHEN** `/` is requested
- **THEN** a page rendered from `README.md` is served, including the screenshots it references

#### Scenario: Web app is served under /app/
- **WHEN** `/app/` is requested
- **THEN** the Flutter web app loads and runs, including screens that load bundled Markdown assets

#### Scenario: App path without a trailing slash reaches the app
- **WHEN** `/app` is requested
- **THEN** the request redirects to `/app/`

#### Scenario: Privacy policy is served without an extension or redirect
- **WHEN** `/privacy` is requested
- **THEN** the privacy policy page is served directly, with no redirect

### Requirement: Canonical addresses are independent of the host
Each generated page SHALL declare its canonical address on the custom domain.
Any host that serves the site SHALL serve each page at that extensionless
canonical address, whether natively or through a rewrite rule, so that the
addresses the project publishes survive a change of host.

#### Scenario: Canonical address of the policy
- **WHEN** the privacy policy page is inspected
- **THEN** it declares `https://unitary.wisnij.dev/privacy` as its canonical address

#### Scenario: Canonical address of the home page
- **WHEN** the home page is inspected
- **THEN** it declares `https://unitary.wisnij.dev/` as its canonical address

### Requirement: The site is assembled in CI and deployed through GitHub Actions
The site SHALL be assembled by CI on every push and pull request, and SHALL
be deployed through GitHub Pages' Actions deployment only for pushes to
`main`.  Generated pages SHALL NOT be committed to the repository, and no
deploy branch SHALL be maintained.  The deployed site SHALL be exactly the
assembled tree, with no server-side build step applied to it.

#### Scenario: Pull-request CI catches generation errors
- **WHEN** a pull request introduces a link in a published document to a file that does not exist
- **THEN** the pull request's CI fails before merge

#### Scenario: Only main deploys
- **WHEN** CI runs for a pull request or a tag
- **THEN** the site is assembled but not deployed

#### Scenario: Assembled files are served unmodified
- **WHEN** a file, including one whose name begins with `.` or `_`, is part of the assembled site
- **THEN** it is served byte-for-byte at its path in the tree

### Requirement: One web build serves every mount point
The web app SHALL resolve its own URLs relative to the page it is loaded
from, with no absolute base href, so that a single build runs correctly at
`/app/` on the site, at any other directory it is served from, and from the
release web archive.  The site SHALL use the same build that is published as
the release web asset.  The Flutter development server (`flutter run` on a
web device) SHALL continue to serve the app.

#### Scenario: Release archive runs from a subdirectory
- **WHEN** the release web archive's contents are served from a subdirectory of a web server
- **THEN** the app loads and runs

#### Scenario: Development server still runs the app
- **WHEN** `flutter run -d chrome` or `flutter run -d web-server` is started
- **THEN** the app is served and loads its assets, with no base-href error

#### Scenario: Site and release asset share a build
- **WHEN** a workflow run produces both the site and the release web archive
- **THEN** both contain the same web build, produced once

### Requirement: The release web archive contains only the app
The release web archive SHALL contain the web app build only, not the site's
generated pages.

#### Scenario: No site pages in the archive
- **WHEN** the release web archive is inspected
- **THEN** it contains the app build and no generated README or privacy policy page

### Requirement: DNS for the site does not proxy requests
The DNS record for `unitary.wisnij.dev` SHALL resolve to GitHub Pages without
routing requests through a proxy or CDN.  The privacy policy names GitHub
Pages as the only party that serves and logs requests for the web app; a
proxy would add another, and SHALL NOT be introduced without a corresponding
policy change.

#### Scenario: Requests reach GitHub Pages directly
- **WHEN** `unitary.wisnij.dev` is resolved
- **THEN** it resolves to GitHub Pages rather than to a proxy's addresses
