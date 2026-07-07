# Semantic Labels (delta)

## ADDED Requirements

### Requirement: Idle example exposes button semantics

The tappable idle-example display on the freeform screen SHALL expose
`button: true` semantics along with its tap action, so assistive technology
reports it as an actionable control rather than static text.  The visual
appearance SHALL remain unchanged.

#### Scenario: Idle example reported as a button

- **WHEN** assistive technology inspects the idle-example display while the
  freeform screen is idle and an `onTap` handler is present
- **THEN** the semantics node has the button flag set and exposes a tap action

#### Scenario: Non-idle result is not a button

- **WHEN** the result display shows any non-idle evaluation state
- **THEN** its semantics node does not have the button flag set

### Requirement: Long-press copy gestures expose labeled custom actions

Each long-press-to-copy gesture outside the worksheet — the About screen's
copyable rows and the unit entry detail's copyable definition — SHALL expose
the copy action to assistive technology as a labeled `CustomSemanticsAction`
(e.g. "Copy version", "Copy definition"), so the action is discoverable in
TalkBack's actions menu and VoiceOver's rotor.  Invoking the custom action
SHALL have the same effect as the long press, including the confirmation
snackbar.  The long-press gesture itself SHALL remain unchanged.

(The worksheet value-cell copy action is specified in the `worksheet-ui`
capability.)

#### Scenario: About screen copy action discoverable

- **WHEN** assistive technology inspects a copyable About screen row
- **THEN** a labeled custom semantics action is exposed, and invoking it copies
  the row's value to the clipboard

#### Scenario: Unit detail copy action discoverable

- **WHEN** assistive technology inspects the copyable definition text on the
  unit entry detail page
- **THEN** a labeled custom semantics action is exposed, and invoking it copies
  the definition to the clipboard
