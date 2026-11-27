# Host, substrates, CI

Read WHEN choosing where work runs, starting any heavy local phase, handling a `heavy-gate` refusal, logging out with work running, booting local resources, or touching CI.

## Cost rule (Mike, 2026-11-16 and 11-18)

- **Local Mac first, always.** Verification, CI-shaped jobs and deploys run on the local Mac first, through `heavy-gate`. A local `rc=0 @<sha>` line is first-class evidence.
- GitHub CI is the fallback: on release, when a check can't run locally, or when Mike explicitly asks.
- **Never increase CI cost** without Mike: no bigger runner tiers, no extra shards, no new paid services.
- Never add a dispatch loop, per-item fan-out or `workflow_run` chain without showing Mike a runs-per-day and minutes estimate.
- Cut runner-minutes; don't add them. Project-specific runner facts (self-hosted pools, which project owns them) live in machine-local memory.

## Heavy local phases: `heavy-gate`

- **Every heavy phase goes through `heavy-gate run --label "<unit> <what>" -- <cmd>`,** by any director or leaf, in any project. That covers DB or browser suites, full typecheck or build, e2e and docker stacks, and simulators.
  - Wrap the phase, not the whole leaf.
  - It admits only when the gauge passes (memory, load per core, disk) and a lease slot is free.
  - Slot count and limits live in `agents/heavy-gate.conf`; don't restate them.
  - `check` is advisory only. Exit 75 plus a `HEAVY_GATE=` line means it was gated: the command never started.
- A detached resource (`docker compose up -d`, a booted simulator) outlives the lease. Run it through a foreground command that also tears it down.
- **Gated: never busy-wait.** The director routes the phase off the host, in this order:
  1. **Claude cloud agent:** the project's template routine via `RemoteTrigger` (`runtime-claude.md`). Use it for node/pnpm repo work. It has no secrets, docker or DB, and the nix devshell won't build there.
  2. **CI,** within the cost rule above: the pinned toolchain, real DB or browser infrastructure, macOS simulators the project already defines.
  3. **Codex Cloud.**

  A leaf never dispatches. It returns `GATED: <phase> <reason> <exact command>`.
- **No cloud path** (simulators, local stacks, Keychain, a rendered local preview): `defer-verify` with `--run` wrapping `heavy-gate run`. `drain-verify` refuses ungated heavy anchors. Keep working on other units meanwhile.
- **Free your own first:** before concluding the host is full, tear down your own dead stacks and booted devices whose worktree or claim is gone.
- The machine-local inventory of runners and local-only workflows is `~/.claude/cloud-runners.md`.

## Substrates

- **Local is the default.** Remote cloud (Claude cloud agents, Codex Cloud) and the self-hosted box are the alternatives. A substrate changes machine economics, not the meter: remote isn't a new quota pool.
- **Route remote** for repo-plus-toolchain-only work that is heavy, would exceed a local ceiling, or must survive the laptop sleeping.
- **Never remote:** simulators and emulators, KVM, Keychain, env-scoped local stacks, warm pools, or anything whose `verify:` anchors need this machine.
- **Fingerprint every "remote" run inside the leaf** (uname, hostname, pwd, whoami). An OK round-trip proves nothing about where it ran. The Agent tool's `isolation: "remote"` has silently run locally in the desktop app.
- **Remote briefs** state the required environment. Gates whose deliverable is "gates pass" run under the repo's pinned toolchain, remotely via the flake or re-verified locally or in CI.
- **Logout kills local leaves:** before logging out, run `leaf-sweep` and wait, or accept the kill and post 🚧 INTERRUPTED.

## Local resources

- Whoever boots a heavy resource (emulator, simulator, dev stack, watcher) tears it down.
- QA-created devices follow create-implies-delete (named shared pools excepted; those are age-swept).
- Sweep orphans at session start: kill by PID only, and exclude human-terminal stacks.
- **Container engine health:** time a bare `docker info`. More than about 10 seconds means hung. Don't wrap it in `timeout`: macOS has no `timeout`, and the "command not found" reads as a false hang. Restart a hung engine before queueing DB-locked runs.
