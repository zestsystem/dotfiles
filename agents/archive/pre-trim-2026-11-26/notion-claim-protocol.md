## Notion claim protocol (cross-director coordination)

For work that lives natively in company Notion. Same doctrine as the Linear
protocol — comments are the message bus, same seven-type comment format
(🔒 CLAIM / 📍 STATUS / 🚧 BLOCKED / 🤝 HANDOFF / ⚠️ TAKEOVER / ✅ RELEASE / 🚧 INTERRUPTED — "six-line" until 2026-09-05, an omission Astra caught) —
with Notion-specific mechanics. The canonical rules live on the "Agent Claim
Protocol" page next to the "Agent Tasks" database (under Docs) in company
Notion; this section is the summary directors carry between sessions.

- **Ownership signal:** the `Agent` single-select on the Agent Tasks database
  (`claude` / `codex` / `k3` / `human-only`). Empty = unclaimed. Single-select
  gives exclusivity for free. `human-only` = off-limits to ALL agents — Mike
  sets and clears it. All connectors currently act as Mike, so created_by
  canNOT distinguish directors — the Agent select + signed comment lines are
  the source of truth until per-agent integration tokens exist.
- **Claim race (no atomic claim in Notion):** set the Agent select + Status +
  Last Heartbeat, post the 🔒 CLAIM comment, then RE-READ the thread — if two
  CLAIMs landed concurrently, earliest server-side created_time wins; the
  loser clears the select and posts a yield.
- **Heartbeat:** `Last Heartbeat` date, set at claim and at every session end
  while holding a claim (post 📍 STATUS at the same time). A `Stale` formula
  flips at 3+ days.
- **Takeover tiers:** active work (Claimed/In Progress/In Review) follows the
  Linear rules — 3-day stale, or holder posted BLOCKED and you can unblock,
  or Mike directs it. Soft-reserved BACKLOG items (Agent set, Status still
  Backlog) are takeable after 1 day without a heartbeat — backlog
  reservations expire fast. Takeover procedure is identical to Linear's:
  read thread + branches first, swap the select, post ⚠️ TAKEOVER.
- **Epics:** claiming a parent task covers its unlabeled children (Epic
  self-relation); a child's own Agent value overrides.
- **Graph-as-data (2026-07-27):** compiled-epic deps live in the `Blocked by`
  / `Blocking` self-relation; human decision gates are ROWS (Agent =
  `human-only`, flipped to Done by Mike to release downstream); the `Runnable`
  formula + the "Frontier" view compute the claimable frontier live. Claim
  from the Frontier view and re-check `Runnable` immediately before claiming —
  this replaces manifest re-parsing on this substrate. `Lane` and `Wave` are
  properties set at compile time; the epic manifest keeps only edge-data
  labels, write-set globs, and shared constraints.
- **Substrate note (2026-07-28):** same rule as Linear — an unattended
  remote/cloud runner states it in its 🔒 CLAIM / 📍 STATUS comments with the
  run handle; the Agent select stays lane-only.
- **Leaves never touch the database** — claims are director-level judgment;
  enforced by never giving leaf prompts Notion access.
- **Scope (widened 2026-07-27, Mike-directed):** ALL voidpet-poc work — every
  employee and every agent — is tracked on the Agent Tasks board; GitHub
  Issues is legacy there (work existing issues to closure, open no new ones).
  The board's value is universal adoption: an untracked task is invisible
  verification debt, and an undeclared writer breaks write-set disjointness.
  Humans claim by setting Agent = `human-only` plus themselves in the `Owner`
  people property — the standing human-only rule then protects their rows
  from every agent. Enforcement for agents is repo-level: voidpet-poc's
  AGENTS.md carries the board rule, so every session in that repo loads it
  regardless of whose machine it runs on. UTC work, plus Mike-owned sibling
  projects in the local `project_routing` map (2026-09-25), stays on Linear
  with its own claim protocol. Claims scope ownership, not authority: Mike remains
  final approver on merges.

