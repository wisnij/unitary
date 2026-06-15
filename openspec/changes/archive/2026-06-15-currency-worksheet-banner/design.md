## Context

Worksheet mode renders a `WorksheetTemplate` (id, name, rows, ordering) as a
table of labeled numeric fields in `WorksheetScreen`.  The Currency worksheet
converts between live exchange rates that are fetched on launch and can be
refreshed manually.  The freshness of those rates is currently surfaced only in
the Settings "Currency rates" section, via `CurrencySettingsSection`, which
watches `currencyStatusProvider` and formats `status.lastUpdatedAt` with a
private `_formatDateTime` helper (date + time), falling back to
"Using built-in rates" when `lastUpdatedAt` is null.

A user on the Currency worksheet has no in-place indication of rate freshness.
The request is to show that timestamp on the worksheet — but implemented as a
general worksheet banner facility, not a Currency-specific hack — and to keep it
small and unobtrusive.

Relevant existing pieces:

- `WorksheetTemplate` / `WorksheetRowKind` (sealed class) in
  `lib/features/worksheet/models/worksheet.dart` — const data models.
- `WorksheetScreen` in
  `lib/features/worksheet/presentation/worksheet_screen.dart` — `Scaffold` whose
  `body` is a `LayoutBuilder` → `SingleChildScrollView` → `Table`.
- `currencyStatusProvider` (`CurrencyStatus { lastUpdatedAt, isFetching, … }`).
- `formatShortDate` in `lib/shared/utils/date_formatter.dart` (date only) and
  the richer private `_formatDateTime` (date + time) in
  `currency_settings_section.dart`.

## Goals / Non-Goals

**Goals:**

- A general, reusable way for any worksheet template to declare a banner of
  contextual information.
- Render the banner small and unobtrusive, above the worksheet rows.
- Show the currency last-sync timestamp on the Currency worksheet, identical to
  the value in Settings.
- Reuse existing currency state; no new providers, no new dependencies.

- Offer a rate-refresh action in the currency worksheet AppBar that behaves
  identically to the Settings refresh button, by reusing the same control.

**Non-Goals:**

- Making the *banner* interactive.  The banner is display-only; the refresh
  affordance lives in the AppBar, not the banner.
- Banners for any worksheet other than Currency in this change.
- Persisting or configuring banners; they are static properties of predefined
  templates.
- A general "any free-text string" banner — banner content is typed, so dynamic
  values (like a live timestamp) are resolved at render time.

## Decisions

### Decision 1: Banner is a typed sealed type, not a string

Add `WorksheetBanner` as a sealed class with one initial variant,
`CurrencyRatesBanner`, mirroring the existing `WorksheetRowKind` pattern.
`WorksheetTemplate` gains an optional `final WorksheetBanner? banner` (default
`null`).

- **Why not a `String`?**  The currency banner's content is dynamic (a live
  timestamp / built-in-rates state) and must be resolved from providers at
  render time.  A plain string can't express that, and a `Widget` on a model
  would put presentation in the data layer.
- **Why a sealed type?**  It keeps templates as compile-time `const` data
  (`CurrencyRatesBanner()` is const), matches the project's existing
  `WorksheetRowKind` idiom, and lets the UI dispatch exhaustively with a
  `switch`.  New banner types are added as new variants plus a render branch.

### Decision 2: Rendering lives in a dedicated banner widget, dispatched by the screen

`WorksheetScreen.build` inserts the banner above the existing
`SingleChildScrollView`/`Table` when `template.banner != null`.  A
`WorksheetBannerWidget` (in `presentation/widgets/`) takes the `WorksheetBanner`
and `switch`es on its variant, returning the appropriate banner content widget.
The `CurrencyRatesBanner` branch is a small `ConsumerWidget` that watches
`currencyStatusProvider`.

- The banner is wrapped in a thin `Container`/`Material` bar using
  `colorScheme.surfaceContain[er]Highest`/`surfaceVariant`-style muted
  background, full width, with `bodySmall` text in `onSurfaceVariant`, an
  optional leading info icon, and modest padding.  This satisfies the
  "small and unobtrusive" requirement.
- Keeping render logic in the widget (not the model) preserves separation of
  concerns and keeps the model layer free of Flutter/Riverpod imports.

### Decision 3: Extract the date/time formatter into the shared helper

Move the date+time formatting currently in `_formatDateTime`
(`currency_settings_section.dart`) into `lib/shared/utils/date_formatter.dart`
as a public `formatDateTime(DateTime)` (alongside the existing
`formatShortDate`).  Update `CurrencySettingsSection` and the currency banner to
both call it.

- **Why:** the spec requires the banner and Settings to show an *identical*
  value.  A single shared function guarantees that and removes duplication.
- The existing `formatShortDate` (date only) is intentionally left as-is; the
  banner mirrors Settings, which shows date + time.

### Decision 4: Banner reads `currencyStatusProvider` directly

The currency banner watches the same provider Settings uses, so it reflects
`lastUpdatedAt` and updates reactively on refresh.  No plumbing through the
worksheet notifier/state is needed — the banner is a leaf `ConsumerWidget`.

### Decision 5: Reuse one refresh control in Settings and the worksheet AppBar

The Settings refresh affordance (refresh `IconButton`, in-progress
`CircularProgressIndicator`, disabled "Wait Ns" button during the 60-second
cooldown, and the `_RefreshErrorDialog` on failure) is extracted from
`CurrencySettingsSection` into a reusable `ConsumerWidget` — e.g.
`CurrencyRefreshButton` in
`lib/features/currency/presentation/currency_refresh_button.dart`.  It watches
`currencyStatusProvider`, calls `notifier.refresh()`, and shows the error dialog.
Both `CurrencySettingsSection` (as its `ListTile` trailing) and the worksheet
AppBar use this widget.

- **Why:** the requirement is that the worksheet refresh behaves *identically* to
  Settings — cooldown, spinner, and error feedback.  Sharing one widget
  guarantees that and avoids duplicating the cooldown/error logic.
- The error dialog (`_RefreshErrorDialog`) moves into the shared file alongside
  the button.

### Decision 6: The banner declaration also gates the refresh action

The worksheet AppBar shows the `CurrencyRefreshButton` when the active template's
`banner is CurrencyRatesBanner`.  Rather than introduce a second per-template
mechanism for "AppBar actions," the presence of the currency-rates banner marks a
worksheet as currency-aware, and the refresh action accompanies it.

- **Why not gate on `template.id == 'currency'`?**  Keying off the typed banner
  keeps the "this worksheet deals with currency rates" decision in one
  declarative place and avoids string-matching ids in the UI.
- **Why not a general `actions` list on the template?**  Over-engineered for a
  single action type; can be generalized later if a second case appears.
- The AppBar still renders the existing `WorksheetDropdown` as its title; the
  refresh button is added to `AppBar.actions`, so it sits at the trailing edge
  and is absent for non-currency worksheets.

## Risks / Trade-offs

- **Coupling the worksheet feature to the currency feature** → The
  `WorksheetBannerWidget`'s currency branch imports currency providers.  This is
  acceptable: the dependency is one-directional (worksheet UI → currency state)
  and confined to the banner widget; the worksheet model/engine stay
  currency-agnostic.  Alternative (injecting a builder callback) was rejected as
  over-engineered for a single banner type.
- **Layout shift between templates** → Switching to/from the Currency worksheet
  changes available vertical space because the banner appears/disappears.  This
  is expected and acceptable; the banner is small.
- **Formatter relocation** → Moving `_formatDateTime` is a pure refactor; tests
  that asserted Settings text continue to pass because output is unchanged.

## Open Questions

- None blocking.  (Possible future extension: make the banner tappable to jump
  to Settings or trigger a refresh — explicitly out of scope here.)
