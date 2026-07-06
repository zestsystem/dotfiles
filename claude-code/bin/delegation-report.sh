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
      def exmap: {"codex-gpt-5.5":"codex-gpt-5.5-xhigh","codex-gpt5.5-xhigh":"codex-gpt-5.5-xhigh","codex-gpt5.5-low":"codex-gpt-5.5-low"};
      map(select(.executor) | select((.date // "") >= $since)
          | .executor = (exmap[.executor] // .executor)) |
      group_by(.executor) |
      map({executor: .[0].executor, tasks: length,
           claude_tokens: (map(.tokens // 0) | add),
           ext_tokens: (map(.ext_tokens // 0) | add),
           ext_tokens_missing: (map(select(.ext_tokens == null)) | length),
           redos: (map(.redos // 0) | add),
           substantive_fixes: (map(.substantive_fixes // 0) | add),
           taste_nits: (map(.taste_nits // 0) | add),
           gates_green: (map(select(.gates_green == true)) | length),
           grades: (map(.grade // "?") | join(","))})' "$log" 2>/dev/null \
      || echo "(log parse error)"

    echo
    echo "## grade corrections + escaped defects (apply to the aggregates above)"
    jq -c 'select(.executor | not)' "$log" 2>/dev/null || true
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

PROMPT='You are producing Mike'\''s weekly delegation-protocol digest from the raw data on stdin. Codex (gpt-5.5) spend is REAL spend on the OpenAI meter — treat it as a first-class cost lane alongside Claude models, never as free. Apply any grade-correction / escaped-defect lines to the referenced task BEFORE aggregating grades. Write concise markdown: (1) spend by model incl. Codex, week-over-week direction if a previous digest is included; (2) two efficiency ratios: orchestrator-cost-per-merged-PR (the main-loop model — Fable before 2026-07-07, Opus 4.8 after) AND all-in-cost-per-merged-PR (every model + Codex); (3) per-executor quality (grades, substantive-fix rate, redo rate, escaped defects) from the log aggregates; (4) cost-per-quality check on the Codex lane: ccusage gpt-5.5 dollars vs its grades — flag if ext_tokens_missing shows per-task Codex usage is not being recorded; (5) exactly ONE routing recommendation (promote/demote/keep testing a lane) grounded in the scorecard grade anchors AND cost per accepted task across both meters; (6) protocol-drift check: if the delegation log is missing or sparse relative to visible delegation activity, say so plainly. Under 45 lines, no preamble.'

if command -v claude >/dev/null 2>&1; then
  printf '%s\n' "$DATA" | claude -p "$PROMPT" > "$OUT" 2>>"$OUT_DIR/launchd.err.log" \
    || printf '%s\n' "$DATA" > "$OUT"
else
  printf '%s\n' "$DATA" > "$OUT"
fi

osascript -e "display notification \"Weekly delegation digest ready: $OUT\" with title \"Delegation report\"" 2>/dev/null || true
printf 'report written: %s\n' "$OUT"
