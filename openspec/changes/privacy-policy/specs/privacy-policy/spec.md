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

### Requirement: The policy is discoverable from the app and the README
The About screen and the README SHALL each link to the hosted policy.
Neither SHALL reproduce the policy text, so that a single document remains
authoritative and no installed release can present a contradicting copy.

#### Scenario: About screen links to the policy
- **WHEN** the About screen is displayed
- **THEN** it offers an entry that opens the hosted policy

#### Scenario: README links to the policy
- **WHEN** the README's statement about ads, tracking, and data harvesting is read
- **THEN** it links to the hosted policy

#### Scenario: No bundled copy of the policy text
- **WHEN** the app is inspected for bundled assets
- **THEN** the policy text is not among them

### Requirement: Published policy changes accompany the behaviour they describe
A change to what the app collects or transmits SHALL be published together
with the policy edit that describes it, and never in advance of it.  The
published policy tracks the default branch and goes live ahead of the next
release, so an edit made early would describe behaviour that shipped
software does not yet have.

#### Scenario: Policy edit accompanies a behaviour change
- **WHEN** a change alters what the app collects or transmits
- **THEN** the corresponding policy edit lands with that change rather than before it
