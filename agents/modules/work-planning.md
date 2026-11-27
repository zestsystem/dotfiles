# Work planning: handoffs, epics, fan-in

Read WHEN writing any delegation brief, planning waves, picking up an epic of ~5+ units, deferring a verification, or collecting results from a fan-out.

## Briefs

- Every leaf brief starts with the full `~/.claude/delegation-preamble.md` (machine-local standing guards), then a role dossier if one exists (`~/.claude/roles/<role>.md`, created the 2nd time a role recurs, holding role facts only).
- State the outcome, constraints, authority boundary, write-set, runnable verification, hard stop and return shape. Leave open what the leaf should investigate; don't prescribe it.
- **Rules the local gates reward breaking go INLINE.** If the wrong answer passes local typecheck and tests (prod-only migration behavior, CI-only env flags), restate the rule in the brief. Also inline every entry of the repo's `docs/agents/env-deltas.md` whose surfaces intersect the write-set, and use the CI-shaped invocation of each gate.
- **Diagnoses are hypotheses.** Debug and redo briefs state your diagnosis AS a hypothesis, with permission to refute it. A refutation is the system working.
- **Keep in the director:** decomposition, architecture and design decisions, security judgment, user conversation, review of returns, and verify≈solve work (if you can't judge the diff without re-deriving it, don't delegate it).

## Sequencing

- **Fake-edge test:** does step B actually consume step A's output? If not, run them concurrently.
- **Same-worktree writers run sequentially.** Parallel writers need isolated worktrees or explicitly disjoint write-sets. Parallel readers are fine.
- **Pre-flight shared constraints** before wave 1:
  - resource ceilings (dev slots, DB locks, CI concurrency, host headroom);
  - files every wave touches (fix the hot spot first if a cheap restructure removes it);
  - serial costs (rebases onto a moving main, your own review attention).

  These, not lane capacity, set the real concurrency ceiling.
- **Wave size follows Mike's review bandwidth.** The merge gate is the throughput ceiling.

## Epics (~5+ units): compile, don't author

Below about 5 units, skip all of this.

- **Compile at pickup,** against the repo as it stands. Never in bulk: manifests rot. `/compile-epic` (Claude Code) runs the pipeline.
- The epic keeps the human layer: a paragraph of why plus hard constraints. Each leaf issue opens with an `AGENT SPEC` yaml block:
  - `job:` one bounded job with a stop point.
  - `in:` everything needed, spec-complete.
  - `out:` the deliverable shape.
  - `writes:` the declared write-set. Overlap forces an edge or a merge of the two units.
  - `verify:` runnable anchors that travel into the PR.
  - `lane:` routed at compile time.
  - `deps:` real edges only, each with `edge-data`, typed `contract` or `behavior`.
- **Interface-first:** a contract edge (enum/ID names, i18n keys, types, schema stubs) of under about 100 lines gets its own early node. A human gate blocks the smallest swappable unit.
- **Hot spots** that 2+ units touch get a wave-0 refactor to one-file-per-entity plus auto-discovery.
- **Decision bundle:** one epic comment lists every human gate (what it blocks, the decision needed, when it goes critical-path).
- **Frontier loop:** claim an unclaimed node whose deps have all been released, execute it, release it. Re-check the frontier right before EACH claim.
  - Notion computes it live (`Runnable` formula / Frontier view).
  - On Linear the manifest is authoritative.
- **Release semantics:** a contract edge releases at merge. A behavior edge with environment-bound anchors gets its own VERIFY node blocking its dependents, and any irreversible step sits downstream of it.
- **Post-merge defects are append-only.** Add a new small node; never reopen a released one. A contract-breaking fix is a REPLAN that inserts a repair node as a new dependency of the affected dependents, and notifies their holders on the bus.
- **Replan:** post `🔄 REPLAN <agent> · <date>` FIRST (it's a claim on the manifest, and the earliest wins), then recompile only the untouched downstream nodes.

## Deferred verification

- Defer only environment-bound anchors (a deployed env, a simulator, a seeded DB). Anything runnable locally runs before merge, and the money/auth/migration pre-merge rule still applies.
- Every verification deferred past merge gets a queue entry AT DEFERRAL with `defer-verify`: cwd, a precheck, the runnable anchor wrapped in `heavy-gate run`, and the issue.
- `drain-verify` runs nightly and opportunistically, and failures surface in the next report.
- A deferral without a queue entry is a protocol violation.

## Fan-in

- After any fan-out, count returns against launches before synthesizing. Subagents can die silently in any lane, and a report built from partial returns looks complete.
- For wide fan-outs, summarize per batch, then combine.
- **Bash-launched leaves go through `~/.config/claude-code/bin/leaf-run`,** which ledgers launch and completion.
  - `leaf-run` doesn't forward stdin: read the prompt inside the command (`stdin-from prompt.md codex exec … -`).
  - Run `leaf-sweep` at session start, before logout or shutdown, and after bash fan-outs. A dead PID with no completion is an 🚧 INTERRUPTED candidate.
  - Agent-tool children are ledgered by the harness.
- Wait for completion notifications. Never kill a working leaf because it looks slow.
