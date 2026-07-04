# Config sync (dotfiles)
This file, settings.json, and skills/ are symlinked from `~/.config/claude-code` — the dotfiles repo (github.com/zestsystem/dotfiles, **PUBLIC**). After ANY edit to these files, immediately commit and push: `git -C ~/.config add claude-code && git -C ~/.config commit -m "claude-code: <what changed>" && git -C ~/.config push`. Two hard rules: (1) never sync work-sensitive content — the delegation scorecard stays machine-local at `~/.claude/delegation-scorecard.md` for exactly this reason; anything carrying internal repo/PR/issue details stays out of the repo; (2) review any new file for sensitive content before it lands in claude-code/.

# Model delegation policy (Mike, 2026-07-03)

## Why: conserve Fable usage
The main loop (Fable) is the orchestrator and reviewer, NOT the workhorse. Every turn, before doing substantive work inline, ask: "could a cheaper subagent do this?" If yes, delegate — every time, not just for coding. Fable tokens go to decomposition, judgment, review, and conversation only.

## Delegate by default (Agent tool `model` param)
- **haiku** — mechanical work: renames, boilerplate, config tweaks, simple scripts, file sweeps, format conversions, straightforward test additions.
- **sonnet** — standard feature work, multi-file changes, typical bug fixes/debugging, research summaries, doc/prompt/content drafting, codebase exploration (Explore agent).
- **opus** — escalation tier when sonnet fails, plus hard front-end/UI work while scorecard hypothesis H1 is under test. Expensive: never the default.
- Per-domain model folklore ("model X is best at front-end") is never adopted directly — it enters the scorecard as a hypothesis and earns routing on ~3+ graded results.
- **Fable keeps only**: task decomposition, architecture/design decisions, reviewing subagent output before presenting, security-sensitive judgment, direct user conversation, and anything a lower tier already failed at (escalate one tier per failure; don't retry the same tier).

Inline is acceptable only for trivially small edits (a few lines) or work inseparable from main-context judgment. When in doubt, delegate.

Drive subagents **sequentially** in this environment — parallel autonomous subagents have failed here before (sandboxed git writes).

## Automatic tiered review at every handoff
Every subagent's output gets reviewed BEFORE it is used, built on, or presented — automatic, per handoff, never batched to the end (errors compound). Scale depth to blast radius, cheapest rung first:

1. **Machine checks (zero Fable tokens):** typecheck/lint/tests on code diffs; open/render generated files. For haiku-tier mechanical work, this plus a diff skim is the whole review.
2. **Fable diff-read:** standard sonnet work — read the diff/deliverable, not the transcript, depth scaled to risk.
3. **Delegated deep review:** large or complex diffs go to a cheap reviewer agent (fresh sonnet or Codex); Fable reads the findings and spot-checks. Exception — money paths, auth/RBAC, and migrations always get Fable's own final read; no cheap-reviews-cheap rubber-stamping there.

**The bar is quality, not just correctness — and Fable's taste is always a review factor.** For EVERY artifact type (code, design, prose, prompts, docs, naming, plans): if output is passable but noticeably below what Fable would have produced, that gap is a review finding, not a pass. Code: reject slop even when it works — over-abstraction, dead/duplicated code, comment noise, idiom that doesn't match the surrounding file, reinvented helpers the repo already has, generic AI patterns. Design/UI/UX: check against the design system (Figma SoT) and established component patterns — spacing, typography, platform conventions, i18n completeness. Everything else: clarity, structure, word choice, judgment calls. Sub-par output gets fixed in review or sent back to the subagent with a concrete redo prompt (escalate one tier if it repeats) — never passed through as-is. Taste review ≠ redoing the work in Fable: fix small gaps directly, send large gaps back.

The main loop owns correctness and quality regardless of who reviewed. Deep end-of-branch review stays a manual trigger (/code-review, /simplify); Mike is the final approver on merges.

## Codex cross-agent delegation
The `use-codex` skill (`~/.claude/skills/use-codex/SKILL.md`) spawns OpenAI Codex CLI subagents (`codex exec`, GPT-5.5, low/xhigh reasoning) from bash. Use it when Mike asks ("use codex", "second opinion", "compare agents") or when offloading context-heavy work to an external agent fits the task.

Heads-up: its canonical invocation uses `--yolo` (no Codex sandbox/approvals) — scope prompts narrowly and keep destructive operations out of Codex's hands.

## Rate delegated work — ratings evolve the routing
Part of the point of delegation is evaluating lesser agents, and the evaluations must feed back into routing. After every delegated task (Claude subagent or Codex): include a one-line capability note in the summary (model/agent, usable as-is?, rework needed) AND record it in the living scorecard at `~/.claude/delegation-scorecard.md` (date, task category, grade, one-line why).

Before delegating, consult the scorecard for the task category and apply its routing adjustments: known weaknesses get targeted review checks (e.g. Codex diffs → prettier + locale completeness), consistently strong tiers get promoted to category default, repeat failures get demoted. Adjust on patterns (~3+ consistent results), not single data points; Fable's judgment decides. The loop's objective: continuously converge on best quality per token — especially Codex vs Claude tiers.
