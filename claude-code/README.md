# claude-code

Portable Claude Code config, wired into `~/.claude` by home-manager
(`system/shared/claude-code.nix`) as writable out-of-store symlinks:

- `CLAUDE.md` — standing model-delegation + review policy (loads in every session)
- `settings.json` — user-level Claude Code settings
- `skills/` — user-level skills (use-codex, frontend-design)

Claude sessions edit these files through the `~/.claude` symlinks; edits land
here, and sessions are instructed (see "Config sync" in CLAUDE.md) to commit
and push after every update.

Deliberately NOT synced: `~/.claude/delegation-scorecard.md`. This repo is
public and the scorecard accumulates work internals (issue IDs, PR numbers,
file/line references), so it stays machine-local. If the repo ever goes
private, move it here and add one more `link` entry in claude-code.nix. On a
fresh machine the scorecard starts empty and rebuilds from new ratings.

The use-codex skill additionally requires the Codex CLI to be installed on
the machine.
