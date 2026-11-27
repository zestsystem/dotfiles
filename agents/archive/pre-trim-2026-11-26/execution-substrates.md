## Execution substrates — WHERE delegated work runs (opened 2026-07-28)

The lane table picks WHO runs a task (model + meter); the substrate picks WHERE it executes. Three substrates: **local** (the director's machine — the default), **remote cloud** (vendor-hosted sandboxes: Anthropic remote agents / Claude Code web / scheduled cloud routines; Codex Cloud tasks), and the **self-hosted always-on box** (machine-local notes; the home for device/KVM-bound automation). Substrate changes MACHINE economics only — a remote worker bills the same meter as its lane (remote Claude = the Anthropic plan; Codex Cloud = the ChatGPT Pro meter), so lane routing and off-meter weighting are unchanged; never treat remote as a new quota pool.

- **Route remote when the task is repo+toolchain-only AND any of:**
  - heavy resource footprint — parallel test/build/browser verifiers that would contend for local RAM/CPU: the serialize-heavy-runs rule (one heavy verifier at a time, capped jest workers) is a LOCAL-substrate rule, and remote verifiers may run genuinely in parallel, each on its own machine;
  - the fan-out would exceed a local ceiling found by the pre-flight shared-constraints check — dev-server slots, simulator pool, worktree disk: a ceiling that binds only locally is a remote-routing signal, and routing waves remote is usually cheaper than serializing them;
  - long-running work that should survive the laptop sleeping or the session ending.
- **Never remote:** environment-bound work — device simulators/emulators, KVM, local secret stores (Keychain), env-scoped local stacks and warm pools, anything whose `verify:` anchors need the local machine. That class stays local or goes to the self-hosted box; the remote lanes and the self-hosted box are complements, not substitutes.
- **Login-session mortality (2026-07-28):** local leaves are child processes of the login session — logging out or rebooting SIGTERMs them mid-run (field case: three leaves killed mid-wave by a logout). Before logging out, check for in-flight leaf processes and either wait or accept the kill and post 🚧 INTERRUPTED per the claim protocol; work that must survive the laptop routes remote or to the self-hosted box from the start.
- **Remote-leaf spec discipline:** the cloud sandbox has the git repo and a standard toolchain, NOT local secrets, running stacks, or files outside the repo — a spec that silently assumes any of those fails remotely; state required env explicitly in the spec or keep the task local. **Nix/direnv-provisioned repos:** the devshell is a setup cost, not a blocker — mirror CI's provisioning (nix installer + `nix develop -c`) in the remote environment's setup phase, where network is available and the result may be cached; a CI that already runs the flake on Linux is the existence proof and the recipe. Running gates on a sandbox's own toolchain instead of the flake's is a fidelity trade — acceptable for exploration/drafting, but anything whose deliverable is "gates pass" runs under the repo's pinned toolchain (remotely via the flake, or re-verified locally/CI before merge). Everything else is unchanged: same preamble, same model+effort pinning, same tiered review, same logging with the substrate noted on the log line (e.g. `"substrate":"remote"`). Remote runs are background-by-default, so the fan-in guard applies with extra force.
- **Status: provisional — and verify the SUBSTRATE, not the round-trip (2026-07-28 scar).** A first "remote" Claude probe returned OK, but a follow-up recon proved the agent ran LOCALLY — local hostname, home directory, user, gh identity — i.e. the remote gate can silently fall back to local execution with no error. An OK round-trip proves nothing about WHERE it ran: before treating any run as remote, fingerprint the environment inside the leaf (uname/hostname/pwd/whoami) — a "remote" leaf that fingerprints local invalidates every machine-economics assumption the routing was based on (it contends for local RAM after all). Codex Cloud requires a per-repo environment configured in ChatGPT (`codex cloud exec --env <ID>`) plus the account pre-flight — the ACTIVE Codex account determines which org's repos a cloud task may legitimately touch, so check it before routing, not after. Grade substrate-routed tasks like any new lane config — ~3+ graded results before critical-path reliance; results land as normal lane grades with the substrate noted, never as a separate executor name.

## T3 Code host (2026-10-16, bundle 0.0.42 — Opus 5.5 draft, GPT-6 Astra challenge adopt-with-changes, Mike-approved)

- T3 Code is a Mike-operated host running the same Claude/Codex CLIs per configured instance. It is not a lane, meter or quota pool; grade under the underlying executor. The preamble discriminator, mode, claim and review rules apply unchanged — a T3 thread is a Mike-started session, nothing more.
- Instances map to account homes (Claude `CLAUDE_CONFIG_DIR`; Codex `CODEX_HOME`, optionally a "shadow home" that keeps its own `auth.json`). The instance→home→account→project map is machine-local. Project default models are preferences — T3 falls back to environment defaults when the chosen provider is disabled — so confirm the effective instance before billed work.
- Codex shadow homes share everything except auth (sessions, sqlite, logs, config, skills, cache): share one `CODEX_HOME` root only among accounts of ONE project; a project that must stay isolated gets its own root. This is state separation, not a security sandbox.
- Moving a thread between accounts is allowed only within one project (cross-project moves are cross-billing and carry one project's context into another's account). Continuation compatibility follows configured home paths — always set explicit homes rather than relying on defaults.
- T3 usage bars are reset telemetry with the usual freshness caveat; `probeFailed` is not a wall. T3 "load balancing" spreads threads across machines (environments), not accounts — there is no automatic account failover.
- `leaf-run` account guard (landed 2026-10-16, closing the Astra follow-up): every Claude/Codex launch from a designated project tree must match one of that project's allowed (home, account) pairs in the machine-local routing map. It is a positive allowlist, fails closed, and the public script names no account. It walks `env` prefixes, `bash -c` strings, `cd`/`-C` targets, `claude-*` slot wrappers and shebang scripts; asks identity live (`claude auth status` must say `claude.ai`; Codex `auth.json` claims via the redacting `codex-whoami`, `auth_mode` must be `chatgpt`); and blocks a claude/codex `--lane` whose launch it cannot see. Tests: `claude-code/bin/tests/leaf-run-guard.sh` (fake homes). Scope: `leaf-run` launches only — T3 threads and hand-typed launches still need the manual preflight above.

## Headroom gate: cloud first when the host is full (Mike, 2026-10-27; Opus 5.5 draft, GPT-6 Astra challenge adopt-with-changes)

Mike: "can you create a system wide rule that the account should use cloud runner and coordinate it when local machine runs out of headroom". This is the canonical headroom policy; qa-resource-lifecycle rule (4) defers to it.

- **Scope.** Every heavy LOCAL phase, by any director or leaf, in any project on the host:
  - test suites against a DB or a browser;
  - a full-monorepo typecheck or build;
  - e2e and docker-stack runs;
  - simulator or emulator sessions.
- **Admission.** Wrap the heavy phase itself, not a whole leaf: `heavy-gate run --label "<unit> <what>" -- <cmd>`.
  - It admits only when two things hold:
    - the gauge passes: memory free, load per core and disk free, against the one host-wide `agents/heavy-gate.conf`, with no per-process overrides;
    - a host-wide lease slot is free (default: one heavy phase at a time across all sessions and projects).
  - The lease is a kernel flock inherited by the command and its children. It frees when they exit or are killed.
  - A detached resource outlives the lease (`docker compose up -d`, a booted simulator). Run it through a foreground command that also tears it down.
  - Nested calls inside an admitted run inherit the lease.
  - `heavy-gate check` is advisory only and reserves nothing.
  - Every decision prints a `HEAVY_GATE=` line, so "gated" (exit 75, command never started) cannot be confused with a command that exits 75.
- **Gated: never busy-wait.** A director routes the phase off the host, in this priority order (Mike: "claude cloud agent should be most priority since it doesnt cost me much"):
  1. **Claude cloud agents.** The project's cloud-leaf template routine, launched through `RemoteTrigger` (runtime-claude, "Remote substrate"). Use it for repo-plus-node/pnpm work: implementation leaves, unit tests, package typecheck, lint.
     - It bills the project's own Anthropic plan, which is already paid for, so it is the default overflow.
     - The Agent tool's remote isolation is NOT this path: in the desktop app it silently ran locally (2026-10-27).
     - Fingerprint the substrate on every launch.
     - Its sandbox has no secrets, docker, DB stacks or simulators, and the nix devshell does not build there.
     - Network goes through a per-environment allowlist. A private package registry outside it blocks installs entirely: such a project's cloud leaves edit and push, and CI verifies, until the human allowlists the host.
  2. **CI runners.** Push, then PR checks or the project's dispatchable workflows. Use CI for checks that need what the cloud agent lacks:
     - the repo's pinned toolchain (the nix flake): CI is the merge gate anyway;
     - real DB or browser infrastructure, e2e evidence, parity runs;
     - macOS simulators, available only in workflows the project already defines.

     CI minutes cost money, and macOS runners cost the most, so prefer a Claude cloud agent whenever it can do the job.
  3. **Codex Cloud.** A per-repo environment on the ChatGPT meter: slow overflow capacity, used only when both of the above are unavailable.

  Every route keeps the existing substrate rules: never-remote, account preflight, fingerprint, and the pinned-toolchain merge gate.
  **A leaf** does not dispatch. It stops that phase and returns a structured `GATED: <phase> <reason> <exact command>` result; the director owns dispatch and queue registration.
- **No cloud path** (environment-bound work such as simulators, local stacks or Keychain, or cloud capacity unavailable): register a durable deferral with `defer-verify`.
  - Its `--run` wraps the real command in `heavy-gate run`; `check` may be the precheck, but never the reservation.
  - `drain-verify` enforces it: an entry whose run names a known heavy command without `heavy-gate run` is refused and logged UNGATED, never run or fail-counted, and listed in `ESCALATIONS.md` until rewrapped. Project-specific heavy recipe names go in the machine-local `~/.claude/verify-heavy-patterns` (2026-10-28: the nightly drain had started 28 ungated heavy anchors on the shared host).
  - The heartbeat drains it with `drain-verify`, oldest first. Two drain-time refusals in a row are reported to Mike instead of retried silently.
  - Meanwhile, keep working on other units.
- **Local-only workflows** (Mike: "some workflows cannot use cloud runners"):
  - simulator, emulator or device QA;
  - KVM or self-hosted-box work;
  - anything that needs local secrets (Keychain), a local or env-scoped stack, a warm pool, or a rendered local preview;
  - any project whose repo has no CI or cloud environment for that check.

  These are never forced through a gated host and never faked with a cloud substitute that tests something else. When gated, they take the deferral path below.
- **All projects.** The gate and this policy apply to every project on the host, and the lease is shared across all of them. A project's cloud runners authenticate and bill only under that project's own accounts (project account preflight); never route one project's work through another project's runner.
- **The human outranks agents.** Agents yield through the gate. They never stop, renice or kill processes they did not start.
- **Free your own first.** At session start and on every heartbeat, tear down your own resources whose worktree or claim is gone (dead test stacks, booted devices) before concluding the host is full. Scar 2026-10-27: dead stacks of removed worktrees held about 10% of RAM.
- **Inventory.** Each project's cloud runners and its local-only workflows (environment ids, workflow names, dispatch commands) live in the machine-local `~/.claude/cloud-runners.md`, never in this public file. A director working in a project with no entry adds one before routing.
- **Tests:** `claude-code/bin/tests/heavy-gate.sh` covers:
  - exclusivity;
  - release on exit and on kill;
  - inherited children;
  - nesting, and refusal of a forged token;
  - exit and signal semantics;
  - gauge refusal before start;
  - invalid configuration.
