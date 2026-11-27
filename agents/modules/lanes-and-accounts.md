# Lanes and accounts

Read WHEN choosing who runs a task, picking effort, launching any billed Claude or Codex call, or handling a quota wall or a broken tool. Exact model IDs, meters and the seat live in the machine-local `~/.claude/model-economics.json`; this file names families so a model release doesn't make it wrong. Before routing to a model name, check it against the live catalog (Codex: `~/.codex/models_cache.json`).

**Always the newest model in each family (Mike, 2026-11-26: "we should never use outdated models").** When a catalog lists a newer model in a family you use (Sol, Astra, Terra, Luna, Fable, Opus, Sonnet, Haiku), or a release note announces one:
1. Smoke-test it on the project's home: one pinned "reply OK" call, and confirm the observed model (Claude: `--output-format json` → `modelUsage`).
2. Update `model-economics.json`.
3. Update every pinned ID: `grep -rnE 'claude-(fable|opus|sonnet|haiku)-[0-9-]+|gpt-[0-9.]+-(sol|astra|terra|luna)'` across the dotfiles, `~/.claude/bin`, `~/.codex/AGENTS.md`, `~/.claude/settings.json`, and each repo's review gate. Review-gate pins change through that repo's normal PR.

This is a factual update, not a routing debate. Fallbacks also use the newest model one tier down, never an older generation.

## Routing

- **Codex Sol: default executor** for anything a written prompt can specify: backend, infra, non-UI mobile, services, research, mechanical sweeps, browser and simulator QA. It bills the ChatGPT plan, which spares the Anthropic plan, so weight it hardest.
  - Effort: low for mechanical work; medium for read-only investigation, attribution and verification runs; high for substantive work and any "make everything green" contract; xhigh only by explicit escalation.
- **Codex Astra: judgment and review.** Use it for skeptic reviews, architecture consults, spec drafting and root-causing. It is not the default delegated implementer (a Mike-started Astra solo session may implement).
  - Effort: medium by default; high for money/auth/migration skeptics.
  - It flattens severity: re-rank its findings yourself before acting.
- **Codex Terra / Luna:** read-heavy exploration (Terra, medium) and narrow repeatable work (Luna). "Read-only" doesn't mean low judgment, and Luna has never been measured as cheaper.
- **Delegated UI implementation: the Claude UI lane** (a Codex solo session may implement its own). Fable at low effort by default; Opus when Fable's weekly slice walls. Both run on the SAME project home. Never route UI to Codex or k3 automatically. If both are unavailable, surface it and wait. Design direction and review: `ui.md`.
- **Fable (full effort): judgment and design direction.** Planning, architecture, taste and escalation. Only via a Mike-started session or his explicit go-ahead; no agent-initiated metered spend.
- **Sonnet:** work that needs the Claude harness (session context, MCP, structured output, steering), codebase exploration and user-facing copy. **Haiku:** trivial mechanical work. **Opus (escalation):** after Sonnet fails.
- **k3 (Kimi):** only when Mike explicitly asks. Inside a k3-backed session (`kimi-claude`), Agent/Workflow `model` pins are a no-op: `sonnet`/`opus` silently run k3. Reach other lanes via bash (`codex exec`, plain `claude -p`). Wrapper details: `archive/pre-trim-2026-11-26/runtime-k3-wrapper.md`. **Grok:** a Mike-only consult; no agent path.
- Escalate one tier per failure; never retry the same tier. Model folklore ("X is best at frontend") is a hypothesis, never a routing rule.
- **New models:** screen with the machine-local battery (`~/.claude/model-eval/BATTERY.md`) on release day. Skip its scorecard/log grading steps (grading retired 2026-11-26). Its "pre-approved" Fable spend no longer stands: any metered arm needs Mike's go-ahead. Screening is not adoption; routing changes need Mike.

## Pinning and handoff mechanics

- Pin model AND effort on every delegated call. An unpinned child inherits the parent's model and runs at director prices. Report what was REQUESTED separately from what you OBSERVED actually ran; if you can't observe it, write UNKNOWN, never a guess.
- Every leaf has an explicit stop point ("stop after X and report"). Writers never nest. A Codex leaf may fan out to at most two pinned, read-only, hard-stopped investigators, one level deep. Claude leaves never nest.
- Never use Codex Ultra or fast mode, or `/code-review ultra`. Codex config carries `service_tier = "priority"`, which contradicts the fast-mode ban. Until Mike rules, launch at his configured tier and make no claims that it saves quota.
- `claude -p` fan-outs: each call is a new session and the user prompt isn't cache-shared. Check that the SECOND call's usage shows `cache_read`, not `cache_creation`, before fanning out (2026-09-02: a 5-hour window burned in 8 minutes).

## Accounts (project-scoped)

- Every billed lane belongs to one project. Each account lives in its own persistent config home (`CLAUDE_CONFIG_DIR`, `CODEX_HOME`). To switch accounts, pick the home; never log out and back in.
- Before ANY billed launch, confirm home → account → project against `project_routing` in `model-economics.json`, from the CLI's own identity and auth method. Claude: `claude auth status` (email AND `claude.ai` auth). Codex: `codex-whoami` (`auth_mode: chatgpt`). A GUI badge isn't verification.
- Never borrow another project's quota or state. A logged-out home is a lane failure to surface; only Mike logs in.
- `leaf-run` enforces this for its own launches (a positive allowlist that fails closed). Launches you type by hand still need the manual check.
- UTC Claude leaves launch through `~/.claude/bin/utc-leaf` (mk slot first; it falls back to the default slot only on a usage or rate limit). UTC reviews run through `utc-review` (the mk slot). If mk is limited, run plain `just review` with `UTC_REVIEW_CLAUDE_ACCOUNT` set to the default account; there's no automatic fallback. Codex leaves go through `leaf-run`. No in-process Agent leaves for UTC work: they bill the wrong slot.
- Never metered: subscription lanes only. Credits or plan upgrades are a recommendation to Mike, never agent-initiated.

## When a lane breaks

- **Usage wall:** check for a reset before abandoning the lane. Codex: read the latest `rate_limits` event (`used_percent`, `window_minutes`, `resets_at`), or send ONE pinned "reply OK" probe to that home. A 5-hour trip means hold briefly. A genuine weekly wall means falling back per the routing above, recording `resets_at`, and scheduling a recheck. Free resets are pre-authorized; credits aren't. A usage limit means pause and resume, not stop.
- **Codex broken (not a wall):** route Codex work to Claude on the same project home (executor → Opus high/low; read-only → Sonnet; judgment → Opus high). Warn Mike once and keep working. `just review` falls back on its own and labels the stamp. Re-probe at every heartbeat.
- **Connector "requires authentication" notices** naming a LOCAL server aren't claude.ai connector failures. Check the `claude.ai <Name>` rows of `claude mcp list` before asking Mike to re-auth.

## Vendor wrappers (any wrapped lane)

- A wrapper launched from inside an agent session inherits `CLAUDECODE`/`CLAUDE_*`/`ANTHROPIC_*`. Scrub all of them before the wrapper's own exports, or the child may use the parent's credentials and bill the wrong account.
- Use `ANTHROPIC_AUTH_TOKEN`, not `ANTHROPIC_API_KEY`. A rejected API-key prompt pins the key as rejected for interactive sessions only.
- A green headless `-p` probe doesn't prove the interactive path works. Test both.
