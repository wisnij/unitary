## ADDED Requirements

### Requirement: The project publishes a privacy policy
The project SHALL maintain a privacy policy at `PRIVACY.md` in the repository
root as its single source of truth, and SHALL publish it as an HTML page
alongside the deployed web app.  The published page SHALL be generated from
`PRIVACY.md` rather than maintained separately, so the two cannot diverge.

#### Scenario: Policy is readable in the repository
- **WHEN** the repository is browsed
- **THEN** `PRIVACY.md` is present at the root alongside `LICENSE.md` and `CONTRIBUTING.md`

#### Scenario: Policy is reachable at a stable hosted URL
- **WHEN** the hosted policy URL is requested
- **THEN** the generated policy page is served

#### Scenario: Path without a trailing slash reaches the same page
- **WHEN** the hosted policy URL is requested without its trailing slash
- **THEN** the request resolves to the same page

### Requirement: The policy discloses the app's actual data behaviour
The policy SHALL state truthfully that the app collects no personal data,
contains no analytics, advertising, or tracking, and stores all user data
locally on the device.  It SHALL describe the app's only outbound network
request — the unauthenticated exchange-rate fetch — and SHALL disclose that
this request necessarily exposes the requester's IP address to the API
operator even though no user identifier is sent.  It SHALL note that the
web build is served by a third-party host that logs requests as any host
does, distinguishing the hosted app from the installed app.  It SHALL provide
a contact address.

#### Scenario: Local-only storage is stated
- **WHEN** the policy is read
- **THEN** it states that settings, worksheet values, and history are stored only on the user's device

#### Scenario: The single network request is described
- **WHEN** the policy is read
- **THEN** it identifies the exchange-rate API as the only service the app contacts, and states that the request carries no user identifier

#### Scenario: IP exposure is disclosed rather than glossed
- **WHEN** the policy describes the exchange-rate request
- **THEN** it discloses that the request reveals the requester's IP address to the API operator

#### Scenario: Web hosting is distinguished from the installed app
- **WHEN** the policy is read
- **THEN** it notes that using the app in a browser involves a third-party host that logs requests, which does not apply to the installed app

#### Scenario: A contact route is provided
- **WHEN** the policy is read
- **THEN** it provides an address for privacy enquiries

### Requirement: The app bundles and displays the policy
The app SHALL bundle `PRIVACY.md` as an asset and SHALL render it on a
dedicated screen reached from the About screen, so the policy describing a
given build travels with that build and is readable without a network
connection.  Links within the rendered document SHALL be tappable and open in
the system browser, and a failure to launch a link SHALL NOT crash the app.

#### Scenario: Policy is bundled with the app
- **WHEN** the app's bundled assets are inspected
- **THEN** `PRIVACY.md` is among them

#### Scenario: Policy renders from the bundled asset
- **WHEN** the user opens the privacy policy screen
- **THEN** the bundled document is rendered as formatted text with an app bar and back navigation

#### Scenario: Policy is readable offline
- **WHEN** the device has no network connection
- **THEN** the policy screen still renders the full document

#### Scenario: Asset fails to load
- **WHEN** the bundled document cannot be read
- **THEN** the screen shows an error message rather than crashing

#### Scenario: Links in the document are tappable
- **WHEN** the user taps a link in the rendered policy
- **THEN** the system browser opens that link, and a launch failure does not crash the app

### Requirement: The bundled copy identifies its version and the current one
The policy SHALL state an effective date and SHALL name the canonical hosted
URL, so a reader of a bundled copy can tell which version of the document
they are seeing and reach the current one.  A bundled copy describes the
behaviour of the build that carries it and is not required to match a later
hosted revision.

#### Scenario: Effective date is present
- **WHEN** the policy is read, in the app or on the hosted page
- **THEN** it states the date from which it takes effect

#### Scenario: Canonical URL is reachable from the bundled copy
- **WHEN** the policy is read inside the app
- **THEN** it names the hosted URL as the location of the current version, as a tappable link

### Requirement: The policy is discoverable from the app and the README
The About screen SHALL offer an entry that opens the bundled policy screen,
and the README SHALL link to the hosted policy.

#### Scenario: About screen opens the policy
- **WHEN** the user selects the privacy policy entry on the About screen
- **THEN** the policy screen is pushed onto the navigation stack

#### Scenario: README links to the policy
- **WHEN** the README's statement about ads, tracking, and data harvesting is read
- **THEN** it links to the hosted policy

### Requirement: Published policy changes accompany the behaviour they describe
A change to what the app collects or transmits SHALL be published together
with the policy edit that describes it, and never in advance of it.  The
published policy tracks the default branch and goes live ahead of the next
release, so an edit made early would describe behaviour that shipped
software does not yet have.

#### Scenario: Policy edit accompanies a behaviour change
- **WHEN** a change alters what the app collects or transmits
- **THEN** the corresponding policy edit lands with that change rather than before it
