# Director lifecycle, compaction, grants

Read WHEN starting a session, at every heartbeat, before holding for a wait, after a compaction, before a fresh-session handoff or shift end, and whenever Mike grants continuous or overnight work.

## Every session start and heartbeat

- `director-preflight`: checks codex, the Claude slots, the nix shell, the container engine and `gh`. It always exits 0. On WARN, tell Mike what's degraded in your next message and keep working. A codex WARN moves Codex lanes to Claude (`lanes-and-accounts.md`).
- `director-context` (or `--self <session-id>`) is telemetry. Exit 3 means the window isn't in force for that session. It is not an order to recycle.
- Run `leaf-sweep`, the claims sweep (`claims.md`), active QA intake threads (`qa-intake.md`), and the orphan/host sweep (`host-and-ci.md`).

## Context resets are compaction

- The harness auto-compacts at `CLAUDE_CODE_AUTO_COMPACT_WINDOW` (settings.json). This is still a PILOT, started 2026-09-29; its review was due 2026-10-06 and hasn't happened. Mike decides whether it becomes standing. Compaction keeps the process: waiters, crons and the conversation survive it. A fresh session drops all of them.
- **Start a fresh session ONLY** at a completed epic or authority boundary, on unrecoverable state, on a seat change, or when you need independent review. A live-grant session ends only after its successor has acknowledged and owns the wakes. Never self-`/clear`.
- Keep the HANDOFF checkpoint (the six fields, `claims.md`) current at milestones.
- After any compaction, reconcile the checkpoint, the summary and live state (git/gh/ps/cron) before consequential writes. Revalidate mutable IDs (PR, run, SHA, worktree) from source before acting on them. Slips cluster right after resets.

## Ending a shift

- When the program has genuinely landed: post STATUS, queue or hand off the remaining watches, then terminate. Don't idle-hold: every full-context heartbeat costs real money.
- If you must hold, use a cadence of 20–30 minutes or longer, and queue long waits (`defer-verify`, scheduled re-entry) rather than babysitting them.
- Under meter pressure, run at most 2–3 Fable directors at a time and favor Codex execution.

## Continuous-work and overnight grants

- A grant is session-scoped and given by Mike explicitly ("keep working overnight"), never a standing default.
- **Under a grant:**
  - **Don't end the shift while claimable work exists anywhere.** Zones are defaults, not fences; pull from the global frontier.
  - **Arm the next wake at EVERY turn end.** A turn that ends with nothing scheduled has silently ended the shift.
  - **Reconcile fan-in at every wake.**
- **Declare the queue up front:** claim each item with its resume mechanism named. Unclaimed work is out of scope unless the frontier releases it.
- **Host survival is a precondition:** keep the machine awake, and remember local leaves die with the login session. Route remote if the host can't stay up.
- **Authority doesn't change:** review per handoff, the money/auth/migration final read, and human gates, releases, deploys and anything irreversible all WAIT for Mike.
- **Only external waits left:** park them in queues and arm a scheduled re-entry in a FRESH session that re-checks the frontier. The grant survives the session.
- **Morning report:** landed / in-PR / blocked, plus a STATUS on every touched issue. A grant that ends without its report is a violation.
- **Usage limit = pause, not stop:** wait for the reset and resume.

### Parallel directors under a grant

- Peer director sessions coordinate ONLY through claims. No hierarchy.
- One director holds the release checkpoint at a time (`orchestrator-hygiene.md`).
- Each director delegates its own leaves.
- About 3–4 directors with 1–3 leaves each is the local ceiling; go wider on remote substrates.
- Native subagents are children, never persistent peers. Don't report them as peers.
- **Peer death is detected by transcript probe, not `lastActivityAt`:** queued deliveries bump it. A peer with unprocessed queued messages and no assistant turn for more than 30 minutes is DEAD.
  - Take over its claims immediately from its on-disk state.
  - Notify Mike once.
  - After a host or app restart, sweep ALL peers' claims.
- With 2+ claimable items with disjoint write-sets, keep 2+ leaves in flight.
