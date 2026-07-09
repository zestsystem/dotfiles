# Config sync (dotfiles)
This file, settings.json, skills/, and the shared agent protocol at `~/.config/agents/PROTOCOL.md` live in the dotfiles repo (github.com/zestsystem/dotfiles, **PUBLIC**; this file and settings.json/skills/ are symlinked into `~/.claude/`). After ANY edit to these files, immediately commit and push: `git -C ~/.config add claude-code agents && git -C ~/.config commit -m "claude-code: <what changed>" && git -C ~/.config push`. Two hard rules: (1) never sync work-sensitive content — the delegation scorecard, log, preamble, and model-economics.json stay machine-local in `~/.claude/` for exactly this reason; anything carrying internal repo/PR/issue details stays out of the repo; (2) review any new file for sensitive content before it lands in the repo.

# Agent working protocol (canonical, shared with Codex)
The routing/delegation/review/grading protocol is maintained in ONE runtime-neutral file consumed by both Claude Code (imported below) and Codex (`~/.codex/AGENTS.md` points to it). Protocol changes go there — never fork Claude-only or Codex-only copies of shared rules; runtime-specific mechanics belong in its adapters section.

@~/.config/agents/PROTOCOL.md
