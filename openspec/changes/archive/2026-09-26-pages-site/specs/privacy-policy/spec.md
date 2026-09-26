## MODIFIED Requirements

### Requirement: The project publishes a privacy policy
The project SHALL maintain a privacy policy at `PRIVACY.md` in the repository
root as its single source of truth, and SHALL publish it as an HTML page on
the project site at `https://unitary.wisnij.dev/privacy`.  The published page
SHALL be generated from `PRIVACY.md` rather than maintained separately, so the
two cannot diverge.

#### Scenario: Policy is readable in the repository
- **WHEN** the repository is browsed
- **THEN** `PRIVACY.md` is present at the root alongside `LICENSE.md` and `CONTRIBUTING.md`

#### Scenario: Policy is reachable at a stable hosted URL
- **WHEN** `https://unitary.wisnij.dev/privacy` is requested
- **THEN** the generated policy page is served directly, with no redirect

#### Scenario: Previous hosted URL still reaches the policy
- **WHEN** `https://wisnij.github.io/unitary/privacy`, the address named by previously released builds, is requested
- **THEN** the request redirects to the current policy page

### Requirement: The bundled copy identifies its version and the current one
The policy SHALL state an effective date and SHALL name the canonical hosted
URL, `https://unitary.wisnij.dev/privacy`, so a reader of a bundled copy can
tell which version of the document they are seeing and reach the current
one.  A bundled copy describes the behaviour of the build that carries it and
is not required to match a later hosted revision.  Any change to the policy's
text SHALL come with a new effective date, so that two differing texts never
share one.

#### Scenario: Effective date is present
- **WHEN** the policy is read, in the app or on the hosted page
- **THEN** it states the date from which it takes effect

#### Scenario: Canonical URL is reachable from the bundled copy
- **WHEN** the policy is read inside the app
- **THEN** it names `https://unitary.wisnij.dev/privacy` as the location of the current version, as a tappable link

#### Scenario: Text changes bump the effective date
- **WHEN** the policy's text is edited
- **THEN** its effective date is updated in the same change
