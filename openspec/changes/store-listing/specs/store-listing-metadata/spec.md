## ADDED Requirements

### Requirement: Store text is version-controlled in the fastlane layout

The Google Play listing text SHALL be kept in the repository under
`fastlane/metadata/android/en-US/`, as `title.txt`, `short_description.txt`,
and `full_description.txt`, in plain text.  These files SHALL be the source the
Play Console listing is copied from.

#### Scenario: The text files exist

- **WHEN** the repository is checked out
- **THEN** `fastlane/metadata/android/en-US/` contains `title.txt`,
  `short_description.txt`, and `full_description.txt`, each non-empty

### Requirement: Store text fits Play's limits

The title SHALL be at most 30 characters on one line, the short description at
most 80 characters on one line, and the full description at most 4,000
characters, counting Unicode characters rather than bytes.  A test SHALL check
the committed files against these limits, so that the test suite fails when
any of them is exceeded.

#### Scenario: Committed text within the limits

- **WHEN** the test suite runs against the committed text files
- **THEN** the store-text checks pass

#### Scenario: A description over its limit

- **WHEN** the short description is 81 characters long
- **THEN** the check reports it as over the 80-character limit and the test
  fails

#### Scenario: Non-ASCII characters count once each

- **WHEN** a text contains multi-byte characters such as `•` or `–`
- **THEN** each counts as one character toward its limit

### Requirement: The title names the app and what it does

The store title SHALL be `Unitary: Unit Converter`.

#### Scenario: The committed title

- **WHEN** `title.txt` is read, ignoring a trailing newline
- **THEN** its content is `Unitary: Unit Converter`

### Requirement: The description is written for a newcomer and matches the privacy policy

The full description SHALL open by saying what the app does, and SHALL state
early that the app has no ads, trackers, subscriptions, or in-app purchases and
works offline.  It SHALL NOT claim anything the privacy policy (`PRIVACY.md`)
does not support: it SHALL NOT say the app makes no network requests, and it
SHALL name the exchange-rate service the policy names.

#### Scenario: Opening of the description

- **WHEN** the first paragraph of `full_description.txt` is read
- **THEN** it describes what the app does, not how it is built

#### Scenario: Consistency with the privacy policy

- **WHEN** the description mentions currency rates
- **THEN** it names Frankfurter as their source, and nowhere does it say the
  app never connects to the network
