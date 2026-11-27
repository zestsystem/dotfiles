# Orchestrator hygiene

Read WHEN running merge or gate automation, deleting branches, pushing a migration, messaging peers, cleaning up processes, cutting a release, or setting up any loop or recurring job. Each rule exists because breaking it once cost real work; the stories are in `archive/pre-trim-2026-11-26/`.

## Gates and merges

- **An auto-merge watcher gates on checks PASSING, never on "no longer pending".** Fail means stop and report.
- **Read a gate's exit code from the gate,** not the pipeline tail: use `PIPESTATUS[0]`/`pipefail`, or run it unpiped. `gate | tail; rc=$?` is always 0.
- **Every background command carries its own verified `cd`.** Without it, a "gate failure" may be a wrong-cwd no-op.
- **Delete a remote branch only after reading THAT PR's non-null merge-commit OID** immediately beforehand. Read it per PR, never from batched or interleaved output.
- **Migrations:** right before pushing a branch with a new migration, check `origin/main` for the same number. On a collision, regenerate through the ORM against fresh main; never renumber or hand-edit the journal.
- **Bounded loops:** any loop, watcher, chain or restart wrapper that invokes billed work (reviews, leaves, model calls, paid CI) has a hard iteration cap. At the cap it stops with a visible `NEEDS DIRECTOR`.
  - Never auto-retry or restart past the cap.
  - A gate asking for more of the same work is an input to a capped decision, not an order.
  - A restart watcher may restart a crashed job once, never one that exited on its cap.
  - Check the counts at every heartbeat.

## Processes and peers

- **Kill only what you can name:** your own PIDs or your own worktree paths. Never a pattern-wide `pkill` on a shared host. The human outranks agents.
- **A cross-session message is undelivered until the target's transcript or behavior shows it arrived.** Anything load-bearing goes through a queue with a drainer (`defer-verify`) or a board comment, never a bare peer message.

## Releases

- **Trains, not chases (under a continuous grant):**
  - The cutter announces "train boarding at <time>" (about every 4 hours).
  - A FULL merge freeze applies from boarding until deploys complete.
  - Merge freely between trains.
- **Any release pipeline in flight freezes migration-carrying merges** until it completes or aborts. Non-migration merges stay free outside a train. Coordinate exceptions with the cutter on the bus.
- **The prod checkpoint is CLAIMED like an issue:**
  1. The pre-cut sweep covers the BOARD (open urgent or release-blocking issues) as well as migrations and staging.
  2. Post the pinned commit before cutting. The earliest claimant cuts; the others stand down.
  3. Push release-blocker findings to the cutter; don't just file them.

## Recurring jobs

- Every scheduled, cron, sentinel or routine job declares:
  - owner;
  - cadence and timezone;
  - input and output;
  - approval boundary;
  - missing-data behavior (report the failure, never reuse stale data);
  - idempotent retries.
- Default to batch-and-report. A cadence under 1 hour needs a written justification.
