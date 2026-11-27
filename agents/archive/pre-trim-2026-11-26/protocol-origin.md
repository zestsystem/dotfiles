# Agent Working Protocol (canonical, cross-agent)

This file is the single source of truth for session routing, delegation, review, and grading. It is consumed by BOTH runtimes: Claude Code imports it from `~/.claude/CLAUDE.md`; Codex is pointed at it from `~/.codex/AGENTS.md`. Write rules here runtime-neutrally; runtime-specific mechanics go in the adapters section at the bottom. This repo is PUBLIC — no work-sensitive content (internal repo/PR/issue details) may land here.

Machine-local companions (never synced, shared by both runtimes):
- `~/.claude/delegation-preamble.md` — standing guards pasted at the top of every leaf work delegation
- `~/.claude/delegation-scorecard.md` — living quality record + routing adjustments
- `~/.claude/delegation-log.jsonl` — one JSON line per delegated task (append via `~/.config/claude-code/bin/log-delegation`)
- `~/.claude/model-economics.json` — lane/meter economics; price changes and new models are edits to that one file

**Terms:** *director* = the session's main loop (used interchangeably with *orchestrator*); *leaf* = a delegated subagent; *lane* = a named executor (model + meter + effort defaults) from the lane table; *seat* = which model currently runs directors, read from `director_seat.current` in `~/.claude/model-economics.json`; *scar* = a dated field incident that produced a rule — scar parentheticals are diagnostic signatures for recognizing the same failure live, not history, and stay attached to their rules.

**Map — the decisions this file governs:** WHO executes → Delegation lanes. WHERE it runs → Execution substrates. HOW epics decompose → Work compilation. HOW output is checked → Tiered review. HOW routing evolves → Rate delegated work (grading, open experiments, the rule-challenge ritual). HOW directors coordinate → the claim protocols (Linear/Notion) + QA intake. Runtime-specific mechanics → adapters at the bottom.

