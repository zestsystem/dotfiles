# Review

Read WHEN reviewing any delegated return, choosing review depth, requesting or dispositioning a reviewer, deciding architecture, or merging anything.

## The ladder (every handoff, before the output is used or shown)

Scale depth to blast radius, cheapest rung first. Never let it hit zero.

1. **Machine checks:** typecheck, lint, tests, rendered output. On UTC also `just review` (risk-based, below). For trivial mechanical work, this plus a diff skim is the whole review.
2. **Director diff-read:** read the diff or deliverable, never the transcript.
3. **Fresh-context deep review** for large or complex work. The reviewer gets the diff plus the spec, NEVER the worker's transcript. A Codex full-history fork inherits context (use `fork_turns: "none"`). The director spot-checks the findings.
   - **Money, auth/RBAC, migrations:** always the director's own final read, plus a pre-merge run of that surface's targeted integration tests.
   - **Added or tightened authorization:** a negative control (the forbidden actor is refused) AND a positive control (a named legitimate actor at the rule's edge still passes).
4. **Panel (triggered only):** several fresh skeptics with distinct lenses, each trying to REFUTE. Triggers: a finding would drive an irreversible or expensive action; a surprising claim is load-bearing; the fan-out report IS the deliverable.

- Self-reviews, green claims and cited precedents are claims. Check them against source.
- **Evidence beats votes.** One executable counterexample or checkable source argument defeats any consensus. Record the evidence, the disposition and what's still uncertain. Keep capability failures (bad output) separate from availability failures (quota, tool, harness).
- **Every blocking finding from any independent rung** gets a fix, a recorded evidence-based refutation, or escalation to Mike. The director's final read never silently closes one.
- Quality is part of correctness. Passable-but-sloppy output is a finding: over-abstraction, dead code, comment noise, reinvented helpers, generic AI patterns. Apply the repo's `/review-standards` where one exists.

## UTC review gate: `just review` / `just land`

- `just review <pr>` runs fresh-context Astra and Opus reviewers in parallel, read-only, on subscription slots. Each posts a stamped comment keyed to an exact diff fingerprint. Run one full pair, then deltas.
- `just land` refuses without both full reviews, an unbroken delta chain to the current diff, and a terminal disposition for every finding.
- Operator guide: `docs/agents/review-gate.md`.
- **Request by risk:** behavior, data, UI anatomy, auth, money, migration, or any doubt. Mechanical diffs (version bumps, docs, generated files, copy and i18n fills, compiler-verified renames) may skip `just review`. They then can't go through `just land`, and merge on machine gates plus your own read, with Mike's approval. Every reviewed PR lands through `just land`.
- **Reviewer isolation is a requirement, not a detail.** A reviewer runs in the PR's checkout, so it must never load that checkout's config or reach connectors.
  - Claude reviewers: `--restricted --strict-mcp-config --disable-slash-commands`, Read/Grep/Glob tools only, and NO shell.
  - Codex reviewers: an empty scratch cwd, `--ignore-user-config --ignore-rules`, and apps, plugins, hooks, browser and web search all off.
  - Read provider failures only from structured error events: stderr echoes the prompt, so PR content can forge it.
- No hosted review bots run on any repo now. If one is added: every comment gets a disposition before merge, read the posted body (a green status isn't a review), and re-sweep after the last push.
- After any push following a review, the final head needs coverage (a delta or a fresh pass) before merge. Mike approves every merge.

## Adversarial pair (deep correctness)

- **When:**
  1. money/auth/RBAC/migration and persisted-state formats;
  2. launch flips and first production exposure;
  3. wide-blast-radius branches and epic merge waves;
  4. surfaces whose real gates run after merge.
- **Shape:** 2+ fresh-context skeptics with DISTINCT lenses (default: one Astra + one Sol or Opus), each read-only with diff + spec. On UTC: `just review --deep`.
  - Then one batched fix pass on confirmed findings.
  - Then a verification reviewer on the fix delta. It checks the repaired invariant across callers and failure paths, not just that the patch landed.
- Repair and re-verify **within the bounded-loop cap**. If rounds keep raising findings past the cap, re-plan; don't run again. Findings are claims: confirm them against code before fixing.

## Architecture judgment rung

- Decisions with a long blast radius get ONE fresh-context judgment before implementation locks in. That covers new persisted formats, cross-service contracts, auth/money topology, migration strategy, net-new design language and anything irreversible.
- Use a different capable model where one is reachable on subscription. For new design language, the consult isn't the lane that will implement it.
- A same-model fresh-context consult is the recorded fallback; call it "fresh-context", not "independent".
- A skipped rung becomes 🏛 ARCHITECTURE-REVIEW-DEBT on the PR or issue, and only while the work stays reversible or gated. An irreversible activation stays blocked until the rung runs or Mike explicitly accepts the risk.
- "Independent" means a procedure: separate context, freedom to reject the brief, and the consult's own evidence gathering. It never means a claim of uncorrelated errors.

## Post-merge risk review (status pending Mike)

The pre-trim protocol ran a standing weekly Fable adversarial review of the riskiest merged surface, separate from pre-merge review. It wasn't a grading instrument. Whether it continues is open for Mike. Until he decides, it stays a standing function as before (within its pre-approved slots, never other metered spend). The trim doesn't retire it.

## Turning repeats into tools

- **Scar-to-gate:** a defect class that escapes twice, or a check a script could decide, becomes a repo gate (CI, lint, pre-merge script), not another prose rule.
- **Green-to-skill:** a multi-step flow driven by hand for the 2nd–3rd time becomes a skill or recipe. Its contract covers when to use it, inputs and access, the exact sequence, validation, what it returns, and what needs approval. The approval field is mandatory.
- **Surgical e2e:** a PR that changes a test id, copy or component anatomy updates every spec that references it in the SAME PR. That spec diff is reviewed separately.
  - Spec hunks touch selectors, copy and anatomy only. A removed assertion, an added skip, or a widened timeout or matcher needs a `spec-lint: <spec> — <why>` line.
  - The direct-impact set must show `rc=0` before merge.

## Changing this protocol

A significant change to routing, authority, review gates or this protocol's structure gets a fresh-context CHALLENGE before adoption: cross-vendor when reachable, a different model than the drafter. Record the proposal, evidence, disagreements, disposition and Mike's approval. Write "converged" or "Mike-approved" only when that literally happened. Routine factual corrections (a model ID, a path, a number) need no debate.
