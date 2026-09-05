## Context

Unitary ships through two channels that must stay compatible: APKs attached to
GitHub releases (automated today, and continuing after the Play launch) and, from
1.0.0, the Play Store.  Both are built by the same tag-driven pipeline in
`.github/workflows/ci.yml` (`prepare` → `build-android-apk` + `build-web` →
`release`, as the jobs were named before this change).

Current state, verified rather than assumed:

- `android/app/build.gradle.kts` signs the `release` build type with the debug
  key; `apksigner verify --print-certs` on the built APK reports `C=US,
  O=Android, CN=Android Debug`.
- The debug keystore actually used by the build is
  `~/.config/.android/debug.keystore` — RSA 2048, SHA256withRSA, valid to 2056,
  protected by the standard password `android`.  Note there is a second, older
  keystore at `~/.android/debug.keystore` (valid to 2053) that is **not** what
  signs builds on this machine; modern Android tooling resolves the
  `ANDROID_USER_HOME` location, which lands under `~/.config` here.  The
  distinction cost a detour once and is recorded so it does not cost another:
  when checking which key signed an artifact, compare fingerprints rather than
  assuming a path.
- No keystore, `key.properties`, or CI secret exists in the project; `.gitignore`
  has no keystore patterns.
- The APK is signed with the v2 scheme only (no v1, no v3 — so no rotation
  lineage exists).
- 27 APK downloads across all 38 releases, zero on recent ones.

Play Console state: the developer account is verified, `dev.wisnij.unitary` is
registered, the app is in **Draft**, and nothing has been uploaded — so the
app signing key has not yet been assigned and remains a free choice.  Play's
12-tester closed-test requirement applies to this account, which puts the store
launch weeks out and makes the signing work comfortably non-urgent in schedule
terms, but strictly ordered before the first upload.

The constraint that drives the whole design: **Play App Signing is mandatory for
new apps**, and under it Google re-signs delivered artifacts with an *app signing
key* while developers authenticate uploads with a separate *upload key*.  If the
app signing key is one Google generates, the GitHub APK (signed locally) and the
Play install (signed by Google) carry different certificates, and Android refuses
to install either over the other.  The two channels would become mutually
exclusive per user.

## Goals / Non-Goals

**Goals:**

- Release artifacts are signed with a real, durable key under the maintainer's
  control, never the debug key.
- A GitHub-downloaded APK and a Play-delivered install of the same version share
  one certificate, so users can move between channels.
- Releases stay fully automated — no per-release manual signing step.
- A leaked upload key is recoverable without abandoning the app identity.
- The build cannot leak key material into logs, artifacts, or the repository.
- Using the wrong key is caught mechanically, not by eyeballing a build log.

**Non-Goals:**

- The version-code scheme (separate change; a hard prerequisite for the first
  Play upload, since Play rejects duplicate version codes and every build
  currently reports `versionCode=1`).
- Building the AAB, Play listing assets, the privacy policy, and the store
  submission itself.
- Automating the *first* Play upload.  It is deliberately manual so the Console
  surfaces enrolment choices, policy warnings, and the pre-launch report.
- Any migration path for existing debug-signed installs (see Risks).
- iOS signing (Phase 13).

## Decisions

### D1: Upload our own app signing key to Play (Option A)

Three ways to reach one certificate across both channels were considered:

|                  | A: own the app key | B: Google generates | C: Google generates, republish Play APK |
|------------------|--------------------|---------------------|-----------------------------------------|
| Signatures match | Yes                | **No**              | Yes                                     |
| App key held by  | Maintainer + CI    | Google only         | Google only                             |
| GitHub APK build | Automated          | Automated           | **Manual per release**                  |
| Key can be lost  | Yes                | No                  | No                                      |
| Key can leak     | Yes                | No                  | No                                      |

**Chosen: A.**  B is disqualified outright — it splits users across two
incompatible channels for the life of the app.  C is genuinely attractive on
security (the app signing key never exists outside Google), and works by
downloading the Play-signed universal APK from App Bundle Explorer and attaching
it to the GitHub release; it was rejected because it puts a manual step in every
release, and no supported API appears to expose that download for automation.

A's cost is that the app signing key must be reachable by CI.  That is accepted
knowingly; see D3 and Risks.

**This decision is irreversible and time-sensitive.**  The app signing key is
fixed at first release creation, and Play's *default* is to generate one.  If an
AAB is uploaded without deliberately choosing "use your own signing key", the
choice is silently made and cannot be undone.

### D2: Two keys, in two separate keystore files

An app signing key (permanent identity) and an upload key (authenticates uploads;
rotatable through Play Console if compromised).

They live in **separate keystore files**, not two aliases in one.  A single file
means anything holding the store password holds both keys, which would quietly
undo the separation the upload key exists to provide.  Two files let the two CI
secrets be scoped independently, and let the app signing key be withdrawn from CI
later by deleting one secret rather than restructuring.

Parameters, chosen once and permanent:

| Parameter           | Value                                          | Rationale                                                                                                                                                                                                                                                                                                                                                                                                                      |
|---------------------|------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Algorithm           | RSA                                            | Play's upload-your-own-key path expects RSA; EC has ragged support in the older v1/JAR scheme                                                                                                                                                                                                                                                                                                                                  |
| Key size            | 2048                                           | What Play itself generates, so never the odd case in a compatibility question                                                                                                                                                                                                                                                                                                                                                  |
| Signature algorithm | SHA256withRSA, passed explicitly via `-sigalg` | **Not** the default — JDK 21's keytool defaults RSA 2048 to SHA384withRSA (verified).  Either is strong and nothing validates a self-signed certificate's signature, but SHA256withRSA is the Android convention and matches the existing debug key, so it is chosen deliberately rather than inherited                                                                                                                        |
| Validity            | 30 years (`-validity 10950`)                   | An expired signing certificate freezes the app — no updates can be published.  Play enforces a minimum expiry; 30 years clears it with margin, and matches the debug key's own horizon                                                                                                                                                                                                                                         |
| Store format        | PKCS12                                         | JKS is the deprecated proprietary format.  Play's docs describe the *upload* key as "stored in a Java keystore (.jks or .keystore)", but Play never sees the container — it verifies a signature and a certificate — and conversion is lossless if a tool insists (verified: an imported copy reports an identical certificate fingerprint).  This is the one chosen parameter that is reversible without generating a new key |
| Aliases             | `unitary-app`, `unitary-upload`                | Referenced from `key.properties` and CI secrets                                                                                                                                                                                                                                                                                                                                                                                |

The certificate's distinguished name is **permanent and publicly visible** to
anyone who runs `apksigner verify --print-certs`, and it appears on Play
Console's app signing page.  Both keys use:

```
CN=Unitary, O=wisnij.dev, C=US
```

`CN` names the product rather than the maintainer, and `O` matches the
`dev.wisnij` application-ID namespace.  Product identity is preferred over
personal identity precisely because the field is permanent: a personal name or
country is a claim that can become untrue over a 30-year certificate lifetime and
can never be corrected, whereas the project's identity is stable.  It also
discloses nothing beyond what the application ID already broadcasts.  `L`
(locality) and `ST` (state) are **omitted entirely** rather than left blank —
they would be new personal disclosure that cannot be retracted, and an empty
value such as `L=` bakes a permanent empty component into the certificate rather
than leaving it out (verified).

Nothing validates any of this.  Android compares public keys, not names; the
certificate is self-signed with no CA in the picture.  keytool does not even
enforce that `C` is a two-letter code — `C=USA` is accepted without complaint
(verified) — so the values must be got right by inspection, not by tooling.
For the same reason the exact string above is worth re-reading once before the
key is generated: a typo is permanent, and `-dname` should be passed explicitly
so that keytool never drops into its interactive prompt sequence.

A PKCS12 consequence to expect rather than debug: Java's PKCS12 implementation
does not support a per-entry key password distinct from the store password, so
`key.properties`' `storePassword` and `keyPassword` will hold the same value.

### D3: CI signs both artifacts; `key.properties` is rewritten between builds

`flutter build apk` and `flutter build appbundle` both use the Gradle `release`
build type, so signing them with different keys needs a mechanism.  Two were
considered:

1. **Two signing configs selected by a Gradle property**, driven from CI via an
   `ORG_GRADLE_PROJECT_*` environment variable.
2. **One signing config, with CI writing `key.properties` before each build
   step** — app keystore before the APK, upload keystore before the AAB.

**Chosen: 2.**  The Gradle configuration stays a single ordinary signing block
matching the stock Flutter convention, with no flavors, no extra build types, and
nothing for a future reader to decode.  The channel/key mapping lives in the
workflow, where the artifacts are already separate steps.

Keystores reach CI as base64-encoded secrets, decoded to files under
`RUNNER_TEMP` — outside the workspace, so they cannot be packaged or committed —
and referenced by the generated `key.properties`.  D6 settles where those secrets
live: on a `release` environment rather than at repository scope.

### D4: Local builds must keep working without any key

A developer clone has no `key.properties` and no keystore, and must still build.
The signing config therefore reads `key.properties` **only if present** and falls
back to the debug signing config otherwise — the standard Flutter pattern.

This creates a real hazard: a misconfigured *release* build would silently fall
back to debug signing rather than failing, which is exactly the bug this change
exists to remove.  Verification (D5) is what closes that hole, and is therefore
not optional polish.

### D5: Verification is mechanical, in CI

The release job asserts, after building, that the APK's signer certificate
SHA-256 fingerprint equals the expected app signing key fingerprint, and fails
otherwise.  Checking merely that the DN is not `CN=Android Debug` is too weak: it
would pass for any wrong-but-real key, and D4's silent fallback makes wrong-key
builds a plausible failure mode rather than a hypothetical one.

The expected fingerprint is recorded at key generation, stored as a
non-secret CI variable, and is also what confirms Play shows the same certificate
after enrolment.

One formatting detail matters for the comparison: `keytool -list -v` renders the
fingerprint as uppercase colon-separated (`SHA256: AA:BB:…`) while `apksigner
verify --print-certs` emits a lowercase contiguous digest.  They are the same
value — verified byte for byte against the existing debug key after
normalisation — so the check must strip colons and lowercase before comparing,
or it would never match.

### D6: Signing secrets are scoped to tag builds via a GitHub Actions environment

`build-android-apk` — as it stood before this change — carried no `if:`
condition, and only the final `release` step was tag-gated — so the APK is built on every push to `main`, every pull request, and
every tag.  That is deliberate (commit `7dd8b9d`, so the release path is
exercised before tagging), but it means repository-level secrets would decode the
keystore onto a runner dozens of times a month for builds that have no reason to
be signed.

Three options were compared:

|                                | Repo secrets        | Environment + reviewers    | Environment + tag policy |
|--------------------------------|---------------------|----------------------------|--------------------------|
| Key materialises on            | every push, PR, tag | tag builds, after approval | tag builds only          |
| Manual step per release        | none                | one approval               | none                     |
| Survives a rogue workflow edit | no                  | yes                        | yes                      |
| Audit trail                    | no                  | yes                        | yes                      |

**Chosen: environment with a `v*` deployment tag policy, no required reviewers.**
The decisive property is that the policy lives in *repository settings*, not in
the workflow file — so an edit to `.github/workflows/ci.yml` cannot grant a
branch access to the key, whereas with repository secrets the workflow file is
the only thing standing between any branch and the keystore.  Log masking is not
a defence here; `base64` defeats it trivially.

Required reviewers were rejected: `environment:` is job-level and cannot be
applied conditionally, so approvals would fire on ordinary `main` pushes as well
as releases, contradicting the unattended-release goal for what amounts to a
solo maintainer approving their own work.

**Consequence — the APK job splits in two.**  A job whose environment excludes
the current ref *fails* rather than skipping, so the signed build must be a
separate, tag-only job:

```
build-android-apk-test     non-tag pushes/PRs, no environment
                           → no key.properties, so debug signing via D4
                           → mirrors the release job step for step apart from
                             signing, so build, asset-naming and upload
                             failures surface before a tag; publishes nothing

build-android-apk-release  tags only, environment: release
                           → real key, fingerprint verified per D5
                           → this is what the release job attaches
```

This composes with D4 rather than fighting it: the keyless job needs no special
casing, because an absent `key.properties` already falls back to debug signing.
Debug-signed artifacts from that job are never published — only the `release`
job, which runs on tags, attaches anything.

The two APK jobs are mutually exclusive (`!= 'tag'` and `== 'tag'`), so exactly
one runs per event.  Letting the test job run on tags too would spend a full APK
build producing a second `unitary-<version>.apk` — debug-signed, identically
named, sitting beside the publishable one in the run's artifact list.

## Risks / Trade-offs

**The app signing key is readable by the release workflow, and a leak is
effectively unrecoverable.** → The upload key being separate means a CI
compromise cannot *publish* to Play, and is rotatable.  But the app signing key
is the one that cannot be un-leaked: Play can issue a key upgrade for new
installs, while every existing install stays updatable by whoever holds the
stolen key.  Mitigated, not eliminated, by D6 — which cuts the exposure window
from every push and pull request down to tag builds alone, and puts the rule
somewhere a workflow edit cannot reach — together with pinning third-party
actions by commit SHA and keeping the offline backup authoritative so rotation is
always possible.  Note that an attacker holding repository admin, or the
maintainer's GitHub account, can change the environment rules; this is defence in
depth, not a wall.  This is the accepted price of D1 plus unattended releases;
switching to C later remains possible and would remove the exposure at the cost
of a manual step.

**Key loss ends the app's upgrade path entirely.** → Offline backups in more than
one location, passwords in a password manager, and the certificate fingerprint
recorded outside the keystore.  Losing the key is worse than losing the
repository, and should be treated that way.

**The first signed build cannot install over any published debug-signed build.**
→ Accepted, not solved.  The installed base is 27 lifetime downloads with zero
recent, so the realistic affected population is the maintainer.  Users must
uninstall first and will lose locally stored data.  A v3 signing lineage
(`apksigner rotate`) could technically preserve continuity from the debug key,
but the current APKs are v2-only, the debug key is a poor lineage root, and the
complexity buys nothing at this user count.  Handled with a release note.

**Play's enrolment default silently forecloses D1.** → The enrolment step is
ordered explicitly before any upload in `tasks.md`, and the first submission is
manual precisely so this choice is made deliberately.

**Secrets can leak into logs or artifacts.** → Never echo the decoded keystore or
passwords; write `key.properties` without shell tracing; confirm the built APK
contains no keystore file and the workflow log contains no secret material.

**Play's flows change over time.** → PEPK export, the "use your own key" option,
and the current minimum-expiry requirement are all to be confirmed against the
Console at implementation time rather than trusted from this document.

## Migration Plan

1. Version-code change lands first (separate change) — required before any Play
   upload.
2. Add `.gitignore` patterns **before** generating keys.
3. Generate both keys offline; record fingerprints; back up.
4. Wire Gradle and CI; verify a signed APK from a real CI run against the
   expected fingerprint.
5. Enrol in Play App Signing with the uploaded app signing key, as part of the
   first manual submission; confirm Play reports the expected certificate.

Rollback: before enrolment, reverting the Gradle and CI changes restores the
previous behaviour with no lasting consequence.  After enrolment, the app signing
key is fixed for the life of the app and there is no rollback — which is why
verification precedes enrolment.

## Open Questions

- ~~DN field values~~ — **settled September 3, 2026**: `CN=Unitary,
  O=wisnij.dev, C=US`.  Play documents no distinguished-name requirements at
  all, only key type and size, so omitting `L`/`ST`/`OU` carries no known risk.
  Strictly this is absence of a documented constraint rather than positive
  confirmation; accepted as final on that basis.  The remaining act — re-reading
  the `-dname` before generating — lives in task 3.2.
- ~~Whether Play still offers "use your own signing key" at first release
  creation~~ — **confirmed September 3, 2026**: the Console's "Change app signing
  key" offers Export-and-upload options for a private key and its public
  certificate.  The exact PEPK invocation is still to be captured at enrolment.
- ~~Play's current minimum app-signing-key expiry date~~ — **confirmed September
  3, 2026**: validity must end after 22 October 2033, with 25 years or more
  recommended.  `-validity 10950` yields 2056, clearing both.
- ~~Whether to adopt a GitHub Actions environment for the release job, or rely on
  repository secrets alone~~ — **settled September 3, 2026**: environment with a
  `v*` tag policy and no required reviewers.  See D6.
