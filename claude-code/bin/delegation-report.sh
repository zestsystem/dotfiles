#!/usr/bin/env bash
# Weekly delegation-protocol digest: economics (ccusage, incl. Codex) + quality
# (~/.claude/delegation-log.jsonl) + merged-PR throughput, synthesized by `claude -p`.
# Scheduled by launchd via system/shared/claude-code.nix. DRY=1 prints raw data only.
set -uo pipefail
export PATH="$HOME/.local/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

SINCE_ISO=$(date -v-7d +%Y-%m-%d)
SINCE_CC=$(date -v-7d +%Y%m%d)
OUT_DIR="$HOME/.claude/delegation-reports"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/$(date +%Y-%m-%d).md"

gather() {
  echo "# Raw data: delegation digest, week ending $(date +%Y-%m-%d)"

  echo
  echo "## ccusage daily (last 7d, per-model incl. Codex; API-equivalent dollars)"
  npx -y ccusage@latest daily --since "$SINCE_CC" 2>/dev/null || echo "(ccusage unavailable)"

  echo
  echo "## delegation-log.jsonl aggregates (last 7d)"
  local log="$HOME/.claude/delegation-log.jsonl"
  if [ -f "$log" ]; then
    jq -s --arg since "$SINCE_ISO" '
      map(select((.date // "") >= $since)) |
      group_by(.executor // "unknown") |
      map({executor: .[0].executor, tasks: length,
           claude_tokens: (map(.tokens // 0) | add),
           ext_tokens: (map(.ext_tokens // 0) | add),
           redos: (map(.redos // 0) | add),
           substantive_fixes: (map(.substantive_fixes // 0) | add),
           taste_nits: (map(.taste_nits // 0) | add),
           gates_green: (map(select(.gates_green == true)) | length),
           grades: (map(.grade // "?") | join(","))})' "$log" 2>/dev/null \
      || echo "(log parse error)"
  else
    echo "(no delegation-log.jsonl yet — if delegation clearly happened this week, flag as protocol drift)"
  fi

  echo
  echo "## merged PRs last 7d (repos discovered under ~/projects/work at runtime)"
  local seen=" " total=0 d url slug n
  for d in "$HOME"/projects/work/*/ "$HOME"/projects/work/*/*/; do
    [ -e "$d/.git" ] || continue
    url=$(git -C "$d" remote get-url origin 2>/dev/null) || continue
    slug=$(printf '%s' "$url" | sed -E 's#^(git@github.com:|https://github.com/)##; s#\.git$##')
    case "$seen" in *" $slug "*) continue ;; esac
    seen="$seen$slug "
    n=$(gh pr list -R "$slug" --state merged --search "merged:>=$SINCE_ISO" --json number --jq length 2>/dev/null) || continue
    echo "$slug: $n"
    total=$((total + n))
  done
  echo "TOTAL merged PRs: $total"

  echo
  echo "## previous digest (week-over-week reference)"
  local prev
  prev=$(ls -1 "$OUT_DIR"/*.md 2>/dev/null | grep -v "$OUT" | tail -1 || true)
  if [ -n "${prev:-}" ]; then cat "$prev"; else echo "(none — first report)"; fi

  echo
  echo "## scorecard header + verdicts (context)"
  sed -n '1,40p' "$HOME/.claude/delegation-scorecard.md" 2>/dev/null || echo "(no scorecard)"
}

DATA=$(gather)

if [ "${DRY:-0}" = "1" ]; then
  printf '%s\n' "$DATA"
  exit 0
fi

PROMPT='You are producing Mike'\''s weekly delegation-protocol digest from the raw data on stdin. Write concise markdown: (1) Claude spend by model + Codex spend, week-over-week direction if a previous digest is included; (2) Fable-tokens-per-merged-PR ratio; (3) per-executor quality (grades, substantive-fix rate, redo rate) from the log aggregates; (4) exactly ONE routing recommendation (promote/demote/keep testing a lane) grounded in the scorecard grade anchors; (5) protocol-drift check: if the delegation log is missing or sparse relative to visible delegation activity, say so plainly. Under 40 lines, no preamble.'

if command -v claude >/dev/null 2>&1; then
  printf '%s\n' "$DATA" | claude -p "$PROMPT" > "$OUT" 2>>"$OUT_DIR/launchd.err.log" \
    || printf '%s\n' "$DATA" > "$OUT"
else
  printf '%s\n' "$DATA" > "$OUT"
fi

osascript -e "display notification \"Weekly delegation digest ready: $OUT\" with title \"Delegation report\"" 2>/dev/null || true
printf 'report written: %s\n' "$OUT"
