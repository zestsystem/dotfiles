# Claims and the comment bus

Read WHEN starting a session that does tracked work, or before claiming, taking over, handing off, releasing, or fixing main. Claims scope ownership, not authority: Mike approves merges, money/auth/migration holds stay holds, and two directors never share a worktree. Leaves never set, swap or remove claims, and never post bus comments.

**Routing:** UTC and the Mike-owned sibling projects in the local `project_routing` map use Linear. All voidpet-poc work uses Notion Agent Tasks (that repo's AGENTS.md carries the rule).

## Linear

- **Labels** (one per issue): `agent:claude`, `agent:codex`, `agent:k3`, `agent:human-only`. No label means unclaimed. `agent:human-only` is untouchable: only Mike sets or clears it.
- **When:** before In Progress, or whenever work spans sessions. Quick live single-session fixes are exempt. A parent claim covers unlabeled children; a child's own label overrides.
- **How:**
  1. Run `git ls-remote origin | grep -i <issue-id>` first: a labeled issue with no comment may already have work in flight.
  2. Set the label AND post `🔒 CLAIM <agent> · <date>` with branch/worktree, a one-line plan and the WRITE-SET.
  3. Re-read the issue. The earliest server timestamp wins; the loser removes its label and posts a yield.

  A label without a CLAIM comment isn't a claim.
- **Check write-sets** of adjacent claims before picking work. Overlap found at claim time costs one comment.
- **Main breakage is claimed before it's fixed:** post on the tracking or nightly-red issue first.
- **Tracker down:** run `claim-marker set <issue-id>` (an empty `claim/<id>-<agent>` branch) before working. Post the CLAIM when the tracker returns, and run `claim-marker clear` at release. Unattended queues set markers even when the tracker is up.
- **Takeover (Mike's permission not needed):** the holder has been silent 3+ days (no comments, status or branch activity), OR posted BLOCKED and you can unblock, OR Mike directs it.
  1. Read the full thread and the holder's branches and worktrees.
  2. Continue from their actual state.
  3. Swap the label and post `⚠️ TAKEOVER`.

  Never take human-only work. Without a BLOCKED, a HANDOFF or Mike's direction, never take an issue with holder activity inside 3 days. If you disagree with being taken over, comment; don't revert the label.
- **Session-start sweep:** list issues with your label and read new comments. Any In Progress issue you aren't actively resuming gets 🚧 INTERRUPTED before anything else.
- **Stall prevention:**
  - Claim at pickup, not in advance; advance claims need a STATUS naming the resume mechanism.
  - Ending a turn with leaves still running needs a STATUS naming them.
  - A `stalled` label from the sentinel is a signal, not ownership.

## Bus first lines

The body below the first line is free-form.

- `🔒 CLAIM <agent> · <date>`: plan, branch/worktree, write-set. A remote runner names its run handle here; substrate never gets a label.
- `📍 STATUS`: branch, commits, what's verified, next step. At least at every session end while holding a claim.
- `🚧 BLOCKED`: why, what would unblock it. A standing invitation to take over.
- `🤝 HANDOFF <from> → <to>`: the six fields:
  1. difficulties and how they were resolved;
  2. approaches rejected, and why;
  3. asks, decisions and constraints, in the original words;
  4. what's done, verified and merged;
  5. what's open or promised;
  6. IDs, SHAs, paths, commands and numbers.

  Keep Mike's words near-verbatim; condense your own reasoning.
- `⚠️ TAKEOVER <new> ← <old>`: reason, the state you found, what's next.
- `✅ RELEASE`: done (keep the label as provenance) or abandoned (remove it).
- `🚧 INTERRUPTED`: cause, what survives, and `resuming` or `needs pickup`. Posted the moment you observe a death, or at the next session-start sweep.

## Notion (voidpet-poc Agent Tasks)

- **Ownership** is the `Agent` single-select (`claude`/`codex`/`k3`/`human-only`) plus signed comments. The same seven bus types apply.
- Humans claim with `human-only` plus themselves as `Owner`.
- **Claim:**
  1. Set Agent, Status and Last Heartbeat.
  2. Post 🔒 CLAIM.
  3. Re-read. The earliest `created_time` wins; the loser clears the Agent select and posts a yield.
- **Heartbeat:** set Last Heartbeat and post STATUS at every session end.
- **Takeover:** active rows follow the Linear rules. Backlog reservations expire after 1 day without a heartbeat.
- **Epics and graph:**
  - A parent claim covers unlabeled children.
  - Deps are `Blocked by` relations; human gates are rows with Agent = `human-only`.
  - Claim from the Frontier view and re-check `Runnable` right before claiming.
- Leaves never touch the database.
