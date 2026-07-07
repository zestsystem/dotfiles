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
           taste_avg: ((map(.taste | select(. != null)) | if length > 0 then (add / length * 10 | round / 10) else null end)),
           taste_scored: (map(select(.taste != null)) | length),
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
  echo "## model economics config (meter semantics: subscription = utilization vs ceiling, metered = real dollars)"
  cat "$HOME/.claude/model-economics.json" 2>/dev/null || echo "(missing — treat all ccusage dollars as API-metered spend)"

  echo
  echo "## codex subscription utilization (live telemetry from the latest codex session)"
  local latest_codex
  latest_codex=$(ls -t "$HOME"/.codex/sessions/*/*/*/*.jsonl 2>/dev/null | head -1)
  if [ -n "${latest_codex:-}" ]; then
    jq -c '.. | objects | select(has("rate_limits")) | .rate_limits
           | {plan: .plan_type,
              five_hour_used_pct: .primary.used_percent,
              weekly_used_pct: .secondary.used_percent,
              weekly_resets: (.secondary.resets_at | todate)}' "$latest_codex" 2>/dev/null | tail -1 \
      || echo "(telemetry unparseable)"
  else
    echo "(no codex session telemetry found)"
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
    n=$(gh pr list -R "$slug" --state merged --search "merged:>=$SINCE_ISO" --limit 300 --json number --jq length 2>/dev/null) || continue
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

PROMPT='You are producing Mike'\''s weekly delegation-protocol digest from the raw data on stdin. Interpret dollars through the model-economics config: SUBSCRIPTION lanes (Claude plan models, Codex on ChatGPT Pro) have marginal cost ~0 — for those, report utilization vs the allotment (codex telemetry weekly_used_pct; note if approaching limits) and API-equivalent value captured vs the subscription price; METERED lanes (per the config, e.g. Fable after 2026-07-07) are real dollars. Apply any grade-correction / escaped-defect lines to the referenced task BEFORE aggregating. Write concise markdown: (1) value/spend by model incl. Codex, week-over-week direction if a previous digest is included, each labeled subscription-value or metered-spend; (2) two efficiency ratios: orchestrator-cost-per-merged-PR (main-loop model — Fable before 2026-07-07, Opus 4.8 after) AND all-in-per-merged-PR; (3) per-executor quality: correctness grades (substantive-fix rate, redo rate, escaped defects) AND taste_avg (1-5 craft score) — flag any lane with A-band correctness but taste_avg <= 3 as a demotion candidate, and note taste_scored coverage if most tasks lack the score; (4) Codex lane check: utilization headroom + flag if ext_tokens_missing shows per-task usage is not being recorded; (5) exactly ONE routing recommendation (promote/demote/keep testing) grounded in the scorecard anchors, taste, and cost-per-accepted-task on each lane'\''s own meter; (6) protocol-drift check: if the log is sparse relative to visible delegation activity, or a new model/price appears in ccusage that is missing from the economics config, say so plainly. Under 50 lines, no preamble.'

if command -v claude >/dev/null 2>&1; then
  printf '%s\n' "$DATA" | claude -p "$PROMPT" > "$OUT" 2>>"$OUT_DIR/launchd.err.log" \
    || printf '%s\n' "$DATA" > "$OUT"
else
  printf '%s\n' "$DATA" > "$OUT"
fi

osascript -e "display notification \"Weekly delegation digest ready: $OUT\" with title \"Delegation report\"" 2>/dev/null || true
printf 'report written: %s\n' "$OUT"
