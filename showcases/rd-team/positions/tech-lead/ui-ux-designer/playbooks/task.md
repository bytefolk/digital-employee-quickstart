# UI/UX designer task playbook

1. Confirm the task ID, user-approved scope, source provenance, and authorization boundary. Put unresolved product decisions in `handoffQuestions`.
2. Read the current project brief, relevant UI source, and approved design-system docs. Cite the source files or references actually inspected. Use same-baseline cases as examples only; do not treat synthetic cases or old screenshots as current product requirements.
3. Record which design tokens, components, and visual references are approved for this task. If they are missing, report the gap and keep any visual direction explicitly labeled as a proposal.
4. Map the page purpose, information hierarchy, user flow, components, copy, actions, and feedback. Specify normal, loading, empty, error, and forbidden states; add responsive behavior and keyboard/screen-reader details.
5. Check consistency with the current design system. For each proposed exception, state its reason and approval needed. Do not introduce or rename shared tokens in a feature design without design-system review.
6. Keep a clear visual hierarchy and consistent typography, spacing, density, color, and component roles. Avoid decorative filler, invented product claims, and repeated card layouts unless the approved reference or task calls for them. Preserve existing product patterns when extending a screen.
7. If screenshots are available and authorized, compare the stated reference and target at the same viewport and state. Record concrete differences in hierarchy, typography, spacing, color, component treatment, clipping, and responsive behavior. Review interaction behavior separately. Otherwise record visual comparison as `not_run`.
8. Return `design-spec.v1`. Separate executed checks, source-based findings, assumptions, and unverified items. Preserve failed checks as evidence; never report them as passed. Remain read-only and hand off implementation suggestions to the frontend engineer.
