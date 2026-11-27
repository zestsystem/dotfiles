# Runtime: Codex CLI / ChatGPT app

Read WHEN a Codex session starts, or before native, exec, cloud or Claude-consult routing.

- **Mode check first.** A prompt that BEGINS with the delegation preamble means you are a LEAF: obey it. Otherwise this is a Mike-started session in **solo mode**.
- **Solo mode (the default):** do the work directly. No delegation, unless Mike asks for multi-agent work or a project or skill instruction requires it.
  - Still binding: the repo's AGENTS.md and worktree rules, honest verification (real exit codes), the Ultra/fast bans, your own diff read, and the review rung (`review.md`; on UTC, `just review`/`just land`).
- **Codex-director mode (opt-in):** when Mike asks for multi-agent work. The Codex main loop owns intent, decomposition, fan-in and final review. Every leaf gets the preamble and the handoff contract, pinned model and effort, and tiered review.
- **Native subagents:**
  - Pin full model IDs and effort.
  - An omitted model or effort inherits the parent, and full-history forks (`fork_turns` omitted or `"all"`) inherit AND can't take overrides. An independent reviewer needs `fork_turns: "none"`, a self-contained brief, and explicit model and effort.
  - The cap is 4 agents including the parent.
  - Parallel writers need separate worktrees or disjoint write-sets.
  - Wait for every child before synthesizing.
  - Record each child's model, effort, status and usage provenance; never invent numbers.
- **`codex exec`:** for a detached process, an exact usage footer, or a separate cwd. Pin `-m` and effort (`lanes-and-accounts.md`), and close stdin (`< /dev/null` or `-` from a file) or it hangs. Write leaves pass `-s danger-full-access`.
- **Codex Cloud** (`codex cloud exec --env <ID>`, then `status`/`diff`/`apply`): needs the repo's cloud environment and the account preflight. Fingerprint the run.
- **Claude calls from this runtime:** only Claude UI-lane implementation workers (`ui.md`; Fable-low, Opus fallback), plus an optional single-turn, read-only, diff-scoped Fable taste consult when Mike asks or a concrete taste question could change the result. Both go through a verified subscription path only. No other Claude calls, and no multi-turn Claude sessions.
- When attempts keep failing, or an orthogonal architecture or taste view would materially cut risk, recommend that Mike take the specific question to a Fable session. Don't chain consults.

## Session rules carried from `~/.codex/AGENTS.md`

`~/.codex/AGENTS.md` still holds Codex's worktree, Linear and Voidpet rules (a `codex/` branch prefix, UTC worktrees in `utc/codex/<name>`, a Linear issue before UTC implementation, Voidpet `doppler setup`). Moving them here is a pending, separately approved step. Until then that file stays authoritative for them.
