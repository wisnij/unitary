## Context

The worksheet selector in the AppBar is built from a list of `WorksheetTemplate`
objects returned by `predefinedWorksheetTemplates`.  Currently the list is in
definition order (Length, Mass, Time, …).  The change simply sorts that list
alphabetically before rendering the dropdown.

## Goals / Non-Goals

**Goals:**

- Dropdown items appear in case-insensitive alphabetical order by template name.

**Non-Goals:**

- Changing the ordering of rows *within* a worksheet template.
- Persisting a user-selected sort order or allowing user-configurable ordering.
- Changing the default (initially-selected) template.

## Decisions

**Sort at the widget level, not the data level.**  The predefined template list
is ordered by physical magnitude within each template (spec requirement).
Sorting at the widget level (inside `WorksheetScreen`) keeps the data model
untouched and avoids any ambiguity about what "ordered" means in the template
registry.  The sort is a one-liner (`..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()))`)
applied when building the dropdown items.

## Risks / Trade-offs

- None.  The change is a trivial, local sort with no behavioral side-effects
  outside the dropdown display order.
