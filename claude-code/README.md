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

## Weekly delegation report

`bin/delegation-report.sh` produces a weekly economics/quality digest —
ccusage per-model spend (incl. Codex), delegation-log quality aggregates,
merged-PR throughput — synthesized by `claude -p` into
`~/.claude/delegation-reports/`. Scheduled Mondays 9:23am by a launchd agent
declared in `system/shared/claude-code.nix`; it activates on any machine
after `darwin-rebuild switch`. Run manually anytime; `DRY=1` prints raw data
without the Claude synthesis. Reports, delegation-log, and scorecard stay
machine-local (not in this repo) by design.
