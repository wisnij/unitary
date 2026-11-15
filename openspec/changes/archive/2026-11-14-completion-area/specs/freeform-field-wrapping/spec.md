## REMOVED Requirements

### Requirement: Completion overlay positions correctly against a multi-line field
**Reason**: The completion overlay is replaced by an in-flow completion area that is not anchored to a field.
**Migration**: A field that grows to several lines makes the content taller; the "Completion area layout" requirement in `predictive-completion` covers how the area responds.
