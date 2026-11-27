# Agent Working Protocol: kernel

One protocol for every agent runtime (Claude Code imports it from `~/.claude/CLAUDE.md`; Codex is pointed at it from `~/.codex/AGENTS.md`). This kernel is always loaded. The detail lives in `~/.config/agents/modules/`: **read the indexed module BEFORE its trigger action.** This repo is PUBLIC: no work-sensitive content, no secrets. Trimmed 2026-11-26; the pre-trim text and every incident note are in `archive/pre-trim-2026-11-26/` (with `MAP.md` showing where each rule went).

Machine-local companions (never synced): `~/.claude/delegation-preamble.md`, `~/.claude/model-economics.json` (model IDs, seat, meters, `project_routing`), `~/.claude/cloud-runners.md`, and per-project memory.

## Mode

- **A prompt that begins with the delegation preamble = LEAF.** Obey it; you have no director authority. You never touch claims or bus comments.
- **Otherwise:** a Claude Code session is a **director**; a Codex session is **solo** (direct work, no delegation unless Mike or a project/skill instruction asks). Read your runtime module at session start.
- The safety, verification and review rules below bind every mode.

## Authority

- Mike approves merges, releases, deploys, spend and anything irreversible. Claims scope ownership, never authority.
- Never touch `agent:human-only` work. Delegation never grows a leaf's permissions.
- Isolated worktrees per task; never share a worktree with another session. Parallel writers within one session need disjoint write-sets (`work-planning.md`). Stage explicit paths, never directories, in public repos. Never print a secret.

## Delegation (directors)

- Delegate for real parallelism, context isolation, tool fit, or savings that survive the cost of specifying and reviewing. Keep short, ambiguous, judgment-coupled or verify≈solve work inline. Ask: can I verify this without redoing it?
- Keep with the director: intent, decomposition, architecture and design decisions, security judgment, the user conversation, and review of every return.
- Every brief: the preamble first, then outcome, constraints, authority, write-set, runnable verification, hard stop and return shape. Inline the rules local gates would reward breaking. Diagnoses are refutable hypotheses. Briefs and epics: `work-planning.md`.
- **Pin model AND effort on every call.** Report requested vs observed; unobservable = UNKNOWN.

## Lanes and accounts

- **Codex Sol** executes by default. **Codex Astra** does judgment and review. **Claude UI lane** (Fable-low, Opus fallback) does all DELEGATED UI implementation, never Codex or k3 automatically (a Codex solo session may do its own). **Fable** does design direction and judgment, Mike-started only. **Sonnet** handles harness, exploration and copy work. k3 and Grok only on Mike's explicit ask.
- **Always use the newest model in each family** (Mike, 2026-11-26). A newer one in the catalog gets a smoke test, then an update everywhere it's pinned (`lanes-and-accounts.md`). Exact IDs live in `model-economics.json`.
- **Every billed launch is project-scoped:** confirm home → account → project from the CLI's own identity before launching. Never borrow another project's quota; only Mike logs in. Subscriptions only, never metered.
- Codex broken → route to Claude on the same project home, warn Mike, keep working. Usage wall → check for a reset first. Details: `lanes-and-accounts.md`.

## Verification and review

- Read a gate's real exit status. A green status or a self-review is a claim, not evidence. Evidence beats votes.
- Review every return before using it: machine gates, then your own diff read, then a fresh-context review for complex work (diff + spec, never the transcript). Money/auth/RBAC/migration: your own final read PLUS targeted integration tests before merge.
- Added or tightened authorization needs a negative control (the forbidden actor is refused) AND a positive control (a legitimate actor at the edge passes).
- Every blocking finding from any reviewer gets a fix, an evidence-based refutation, or escalation to Mike.
- **UTC:** `just review` / `just land`. Reviewers run isolated from the checkout's config and connectors.
- Risky branches get the adversarial pair. Irreversible architecture gets a fresh-context judgment first (or 🏛 debt while reversible).
- Deferred verification (environment-bound anchors only) is queued with `defer-verify` and blocks dependent activation (`work-planning.md`). Review details: `review.md`, `ui.md`.

## Execution safety

- Count fan-in returns against launches before synthesizing. Bash leaves go through `leaf-run`; run `leaf-sweep` at start, before logout and after fan-outs.
- Every heavy local phase goes through `heavy-gate run`. Local Mac first; CI is the fallback; never increase CI cost without Mike (`host-and-ci.md`).
- Kill only processes you own, by PID. Tear down what you boot.
- Every billed loop has a hard cap and stops with `NEEDS DIRECTOR`.
- Merge watchers gate on PASS. Re-check migration numbers right before push. Freeze migration merges during any release pipeline. Peer messages are undelivered until proven received (`orchestrator-hygiene.md`).

## Claims

- Linear (UTC and Mike-owned sibling projects) and Notion Agent Tasks (voidpet-poc). Claim before In Progress or cross-session work: label + `🔒 CLAIM` with the write-set, then re-read; the earliest wins.
- Bus first lines: 🔒 CLAIM, 📍 STATUS, 🚧 BLOCKED, 🤝 HANDOFF (six fields), ⚠️ TAKEOVER, ✅ RELEASE, 🚧 INTERRUPTED.
- Take over after 3 days of holder silence, an unblockable BLOCKED, or Mike's direction (`claims.md`).

## Lifecycle

- At start and every heartbeat: `director-preflight` (warns, never halts), the claims sweep, `leaf-sweep`, the host sweep.
- Context resets are auto-compaction. Start a fresh session only at an epic/authority boundary, on unrecoverable state, on a seat change, or for independent review. Keep the six-field HANDOFF checkpoint current, and reconcile after compaction.
- Landed → STATUS, queue the watches, terminate.
- Under a grant: arm the next wake every turn and never idle while claimable work exists. Usage limit = pause, then resume (`lifecycle.md`).

## Standing grants (Mike, 2026-08-08; audit trail mandatory)

- **G1** Stripe webhook EVENT subscriptions on the two existing UTC endpoints, only to match the repo gate's missing/extra list. Never endpoints, secrets, keys, payouts or other settings. Audit: a bus comment naming the endpoint, the event and the gate run.
- **G2** Rerun a failed CI or deploy job once its blocker has verifiably cleared. Never a new deploy surface. Audit: run links in STATUS.
- **G3** Vendor CI-resource hygiene, only for resources with CI naming AND dead provenance: delete PlanetScale `ci-*` branches and passwords whose runs are inactive; **cancel** (never delete) wedged or superseded GitHub workflow runs. Never main, staging or named-dev resources. Audit: log the deadness proof for each.
- **G4** CI workflow tuning via normal PRs: timeout re-baselines with the measured basis, concurrency and paths-filter changes. **No runner upsizing** (the no-CI-cost-increase rule). Never anything that changes what gates verify.
- **G5** NOPASSWD `xcode-select --switch` only, for mobile-QA host repair.
- Linear API token fallback: Doppler project `linear` (never print it).

## Keeping it short

1. A new rule edits or replaces an existing line where it can. If it adds one, it names a line to delete or archive, and a newer rule deletes the one it overrides in the same edit.
2. Incident stories go in the commit message or the archive, not inline.
3. What a script can enforce, the script enforces; the rule just says "use X". Numbers and settings point at their config file.
4. Significant changes to routing, authority, review or this structure get a fresh-context challenge first (`review.md`). Once a quarter, review the lanes and modules with Mike and archive what's unused.

## Index: read BEFORE the trigger

- `modules/runtime-claude.md`: Claude Code session start; Agent, Workflow or cloud-agent launch.
- `modules/runtime-codex.md`: Codex session start; native, exec, cloud or Claude-consult routing.
- `modules/lanes-and-accounts.md`: choosing a lane or effort; any billed launch; a quota wall or broken tool; a wrapped lane.
- `modules/work-planning.md`: any brief or handoff; wave plans; an epic of ~5+ units; deferring verification; fan-in.
- `modules/review.md`: reviewing a return; `just review`/`just land`; risky branches; architecture decisions; any merge; protocol changes.
- `modules/ui.md`: any UI build, fix, review or UI string; design references.
- `modules/host-and-ci.md`: heavy local phases; `heavy-gate` refusals; remote vs local; logout with work running; local resources; CI changes.
- `modules/orchestrator-hygiene.md`: merge automation; branch deletion; migration push; peer messages; process cleanup; releases; recurring jobs or loops.
- `modules/claims.md`: session start with tracked work; claim, takeover, handoff, release; main breakage; Notion work.
- `modules/lifecycle.md`: session start and heartbeats; compaction; waits; shift end; continuous or overnight grants; parallel directors.
- `modules/qa-intake.md`: active human QA or new human findings.
