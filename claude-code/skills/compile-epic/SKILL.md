---
name: compile-epic
display_name: Compile Epic
description: Compile an epic's intent into agent-adaptive units of work — machine-first leaf issues with declared write-sets, real dependency edges, and runnable verification anchors, plus a graph manifest for frontier execution. Use when kicking off an epic/program of ~5+ units ("compile this epic", "plan this as a work graph", "break this down for the agents"), or to recompile a stale plan ("replan this epic" / "/compile-epic replan <epic-id>"). Not for single issues or small fixes.
---

# Compile Epic

Turn one paragraph of human intent into a compiled work graph: leaf issues optimized for autonomous parallel execution, and an epic-level manifest any director can schedule from. The doctrine lives in the "Work compilation" section of the agent working protocol (`~/.config/agents/PROTOCOL.md`) — this skill is the executable pipeline.

**Threshold check first:** below ~4–5 units of work, STOP — tell the user a normal issue is cheaper than this ceremony, and offer to just write the issue.

**This is judgment-lane work.** Run the compilation in the main loop (or a judgment-lane leaf per the protocol's lane table) — never delegate planning to a mechanical tier. Repo exploration to ground the plan MAY be delegated (read-only, explore-tier).

## Inputs

Collect before compiling (ask only for what's genuinely missing):
1. **Intent** — the epic's "why" + hard constraints, from the user or an existing epic description.
2. **Repo grounding** — explore the actual codebase for the surfaces involved: current structure, existing helpers, gates that apply, known landmines from project memory. A plan not grounded in the repo produces fiction specs.
3. **Substrate + target** — which board (Linear team/project, or Notion database) and where the epic lives or should be created.

## Pipeline

Run all eight steps, in order. Do not skip the audits — they are the point.

1. **Decompose** into candidate units. Each unit = one bounded job a single leaf session can complete spec-complete (a literal executor produces the right thing with zero inference). If a unit's `job:` can't be written unambiguously, the thinking isn't done — either resolve the ambiguity now or make resolving it its own upstream unit.
2. **Fake-edge test** every implied ordering: does unit B actually consume an artifact of unit A? No named artifact → no edge → same wave.
3. **Write-set audit**: declare `writes:` globs for every unit, then compute pairwise overlaps across the whole epic. Overlap → add a real edge between them or merge the units. Disjoint write-sets are what make in-wave parallelism safe by construction.
4. **Shared-constraints pre-flight** (protocol: "pre-flight shared constraints"): enumerate resource ceilings the batch will exhaust (dev-server slots, DB locks, CI concurrency), hot-spot files every wave must touch (consider a cheap restructure first as its own unit), and serial costs that scale with wave count (rebase cycles, review attention).
5. **Contract each node**: fill the full AGENT SPEC (template below) — inputs, output shape, stop point.
6. **Anchor each node**: `verify:` must be runnable commands (real gates, named test files) — never "should work". If no anchor exists for a unit, creating the anchor (a test, a checkable script) becomes part of the unit's job.
7. **Assign lanes** at plan time per the protocol's lane table (frontend/UI vs default executor vs harness-exception vs judgment).
8. **Emit the wave schedule**: topological layers of the dep graph, each wave capped at the merge gate's review bandwidth (~4–6 PRs), not lane capacity.

## AGENT SPEC template (top of every leaf issue description)

```yaml
## AGENT SPEC (v1)
job: >-
  <one bounded job>; stop after <explicit stop point, usually "PR opened">.
in:
  files: [<paths the leaf starts from>]
  context:
    - <decision already made, stated as fact>
    - <repo landmine or rule the local gates won't catch — restated INLINE>
out:
  pr: {base: main, title-prefix: "<ISSUE-ID>"}
writes:
  - <glob of files/surfaces this unit may touch>
verify:
  - <runnable command>
  - <named test file to run or add>
lane: <lane name from the protocol table>
deps:
  - id: <ISSUE-ID of upstream unit>
    edge-data: "<the artifact this unit consumes from it>"
```

A short human-readable paragraph MAY follow the block; the block is authoritative. The issue title stays a plain one-liner (humans scan boards by title).

## Graph manifest (in the epic description)

```
## GRAPH MANIFEST (v1) — recompiled <date>
WAVES:
  1: [A, B, C]        # disjoint write-sets, run in parallel
  2: [D(A), E(A,B)]   # parens = deps
  3: [F(D,E,C)]
EDGES:
  A -> D: "<artifact>"
  ...
CONSTRAINTS: <shared ceilings + hot spots from step 4>
```

**Frontier rule for executing directors:** frontier = unclaimed issues whose deps are all ✅ RELEASED. Claim via the substrate's claim protocol, execute, release. Never start a node whose deps aren't released, even if it "looks independent" — the manifest is the authority.

## Substrate mechanics

- **Linear:** create leaves as children of the epic (`parentId`); explicitly set state (issue creation defaults to Backlog); put the AGENT SPEC in each description and the manifest in the epic description. Claim protocol, `agent:*` labels, and the comment bus are unchanged by compilation.
- **Notion:** same content standard; use the Agent Tasks database conventions (Epic relation, Agent select).
- Leaves never touch claims or the manifest — claim/replan is director-level judgment (protocol rule).

## Replan mode (`/compile-epic replan <epic-id>`)

Trigger: reality diverged from a spec (wrong assumption, discovered constraint), or a director posted 🔄 REPLAN.
1. Read the epic manifest + all leaf states; identify the divergence point.
2. Recompile ONLY the downstream untouched subgraph — claimed/in-flight/released work is preserved as-is.
3. Rewrite affected unstarted leaf specs, update the manifest (bump the recompiled date), and post `🔄 REPLAN <agent> · <date>` on the epic with a one-line diff of what changed.

## Output to the user

End with: the wave schedule, the unit count per lane, any constraints found in step 4, and links to the created epic + issues. Creating/modifying board content is the deliverable — but show the compiled plan and get a yes BEFORE creating issues if the epic didn't already exist or the user hasn't seen the decomposition.
