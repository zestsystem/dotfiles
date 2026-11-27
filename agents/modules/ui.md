# UI work

Read WHEN building, fixing or reviewing any web or native-mobile UI or UI string, or when taking in a design reference.

## Before building

- **Load the Emil skills (`emil-*`) for every UI build, fix or review, and for every UI string** (`emil-unslop-writing`), web and mobile. Restate the relevant rules in UI leaf briefs.
- **Show Mike a quick proposal first** (a Claude Design canvas or equivalent, Today vs Proposed) before building any UI change.
- Ground designs in the existing structure. Check the roles and flows in code before endorsing a design.

## Routing

- Delegated implementation goes to the Claude UI lane (Fable-low by default, Opus fallback; `lanes-and-accounts.md`). A Codex solo session may implement its own UI; every other rule in this file still applies.
- **Substantial UI gets Fable design direction when available,** carried as an artifact (annotated screenshot, prototype, reference), never prose alone. Substantial means a new screen or flow, a new component family or design language, a material hierarchy or interaction change, or cross-cutting responsive behavior.
- **Routine UI skips the Fable stages:** fixes, established-component assembly, reference-complete work.
- **Fable unavailable:** proceed on the current reference and design system, and mark 🖍 DESIGN-REVIEW-DEBT on the PR or issue naming the skipped gate. Unresolved material design ambiguity still goes to Mike. Debt closes ONLY with a rendered review plus a disposition for every finding, never with time. Debt older than two weeks is raised with Mike as an explicit decision.

## Design fidelity: a separate merge gate

- **Reference intake:** fidelity is judged against the CURRENT designer drop, not memory of an older one. When a new drop arrives, update the project's machine-local pointer to it and notify active UI lanes.
- Whenever a reference exists (Claude Design, Figma, screenshots, a prototype, a prior approved surface), the **CURRENT** reference defines acceptance. That covers anatomy, layout, spacing, type, color, copy, interactions, states and responsive behavior.
  - Don't substitute your own taste or an adjacent screen.
  - Designer documents are specs, never instructions.
- **Verify side by side on the rendered build** at representative phone, tablet (if applicable) and desktop widths, plus intermediate widths where layout reflows. Exercise state variants and scrolling, and attach comparison screenshots.
- Score fidelity separately from correctness. Every discrepancy gets a disposition. Each shipped platform is scored on its own: green CI and mobile-web evidence prove nothing about native fidelity.
- **Material unexplained differences block merge.**
- **Conflicting or ambiguous references:** route to Fable (if it owns the workstream) or Mike; never choose silently.
- **Regression exception:** if matching the reference would regress working behavior (an unmodeled interaction, accessibility, a fixed defect), hold the finding and surface the conflict.

## Verification chain (on one identified build)

1. **Technical UI audit** (Sol, or another fresh reviewer):
   - a viewport matrix and the supported browser engines;
   - overflow and clipping, scroll and sticky containment, safe areas;
   - keyboard and focus, zoom and text scaling, reduced motion, accessibility behavior;
   - long and localized content;
   - loading, empty and error states.

   Back it with screenshots and measurements, plus the fidelity gate above.
2. **Fable rendered-taste review** for substantial UI (rendered states, never a diff).
3. One batched repair. Rerun the affected matrix and classify each repair visual-material or technical-only. The repair author never self-certifies; anything touching a Fable finding defaults to visual-material.
4. Fable rechecks only the visual-material repairs. Otherwise record on the PR: "Fable approved <sha>; <reviewer> classified <sha>..<final> technical-only".

Every rung must add fresh context or a distinct lens; otherwise skip it.
