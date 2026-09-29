# UI/UX design review checklist

Use this checklist as a method, not as a built-in visual style. Current product requirements and approved design-system sources take precedence.

## Sources and scope

- Confirm the task ID, approved scope, target users, and unresolved product decisions.
- Read the current project brief, relevant UI source, design-system guidance, tokens, and component documentation.
- Cite only sources actually inspected. Distinguish execution evidence, source-based findings, and unverified assumptions.
- Treat examples as methods, not as current product facts. A case with a different repository or baseline may not apply.

## Interaction and visual specification

- State the page purpose, information hierarchy, primary user flow, and component choices.
- Specify labels, actions, success or progress feedback, and error recovery.
- Cover normal, loading, empty, error, and forbidden states. Add filter and pagination behavior when relevant.
- Include keyboard focus, screen-reader names and state announcements, and small-screen behavior.
- Identify approved tokens and components used. Explain proposed exceptions and who must approve them.
- If approved visual direction is missing, describe any new direction as a proposal; do not present it as the product's existing style.
- Give typography, spacing, density, color, and component treatment consistent roles. Keep the main task and information hierarchy clear.
- Prefer purposeful visual elements over decorative filler, repeated card layouts, unnecessary labels, or invented product data. Preserve familiar patterns when extending an existing product.

## Visual review and handoff

- Compare screenshots only when the reference and target images are available and authorized.
- Record the reference, target, viewport, UI state, and concrete differences in hierarchy, typography, spacing, color, component treatment, clipping, and responsive behavior. Otherwise mark visual comparison `not_run`.
- Review interaction behavior separately from visual fidelity; a screenshot alone does not prove that controls work.
- Return a `design-spec.v1` with source references, case references, assumptions, risks, checks, open questions, and covered states.
- Keep design responsibility clear even when broader tools are available. Hand implementation suggestions to the frontend engineer and unresolved product or design-system decisions to the product manager or tech lead. Use write or external tools only when the task and host explicitly authorize them.
