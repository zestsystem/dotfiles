#!/usr/bin/env bash
# Tests for drain-verify's heavy-gate guard: a queued anchor whose run names a heavy command but
# not `heavy-gate run` is refused (UNGATED) before its precheck or run, is never fail-counted, and
# is listed in ESCALATIONS.md. Gated, light and MANUAL entries keep their existing handling.
set -uo pipefail
DV="$(cd "$(dirname "$0")/.." && pwd)/drain-verify"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/cwd" "$TMP/reports"
printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/osascript"; chmod +x "$TMP/bin/osascript"   # no desktop notifications
export PATH="$TMP/bin:$PATH" VERIFY_DEBT="$TMP/q.jsonl" VERIFY_DEBT_REPORTS="$TMP/reports" VERIFY_DEBT_HEAVY_PATTERNS="$TMP/patterns"
printf '# local recipe names\nmy-local-heavy-recipe\n' > "$TMP/patterns"
fail=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
entry() {  # id run precheck
  jq -cn --arg id "$1" --arg run "$2" --arg pre "$3" --arg cwd "$TMP/cwd" --arg ts "$(date +%FT%T%z)" \
    '{id:$id,ts:$ts,note:("t " + $id),cwd:$cwd,run:$run,precheck:$pre,status:"pending",fails:0}' >> "$VERIFY_DEBT"
}
status_of() { jq -r --arg id "$1" 'select(.id==$id) | "\(.status) fails=\(.fails)"' "$VERIFY_DEBT"; }

# Real drain: only refused/MANUAL entries, so no settle sleeps.
entry ungated "touch $TMP/ran-ungated; just e2e-isolated e2e" "touch $TMP/precheck-ran"
entry local-pattern "my-local-heavy-recipe up; touch $TMP/ran-local" ""
entry manual "echo 'MANUAL: run just e2e-isolated by hand' && false" ""
out="$("$DV" 2>&1)"; rc=$?
[[ $rc -eq 0 ]] && ok "a drain with only refused entries exits 0" || bad "drain exit (rc=$rc: $out)"
[[ ! -e "$TMP/ran-ungated" && ! -e "$TMP/precheck-ran" ]] && ok "an ungated heavy run and its precheck never start" || bad "ungated entry started"
[[ "$out" == *"UNGATED ungated"* ]] && ok "the refusal is logged as UNGATED" || bad "UNGATED log line ($out)"
[[ ! -e "$TMP/ran-local" && "$out" == *"UNGATED local-pattern"* ]] && ok "machine-local patterns extend the heavy list" || bad "local pattern ($out)"
[[ "$out" == *"MANUAL  manual"* && "$out" != *"UNGATED manual"* ]] && ok "a MANUAL entry that names a heavy command stays MANUAL" || bad "MANUAL handling ($out)"
[[ "$(status_of ungated)" == "pending fails=0" ]] && ok "a refused entry stays pending and is not fail-counted" || bad "status after refusal: $(status_of ungated)"
[[ "$out" == *"ungated=2"* ]] && ok "SUMMARY counts refusals" || bad "SUMMARY ($out)"
grep -q '^## UNGATED' "$TMP/reports/ESCALATIONS.md" 2>/dev/null && grep -q '\[ungated\]' "$TMP/reports/ESCALATIONS.md" \
  && ok "ESCALATIONS.md lists refused entries" || bad "ESCALATIONS.md ($(cat "$TMP/reports/ESCALATIONS.md" 2>/dev/null))"

# Dry run: gated and light entries still reach the normal path.
: > "$VERIFY_DEBT"
entry gated "$TMP/bin/fake-heavy-gate run --label 't maestro' -- true" ""
entry light "gh run list --limit 1" ""
entry ungated2 "nix develop -c just dev-e2e-mobile & sleep 90; just apps/mobile/e2e-run 205" ""
out="$("$DV" --dry-run 2>&1)"
[[ "$out" == *"DRY     gated"* ]] && ok "a heavy run inside heavy-gate run is not refused" || bad "gated entry ($out)"
[[ "$out" == *"DRY     light"* ]] && ok "a light run is not refused" || bad "light entry ($out)"
[[ "$out" == *"UNGATED ungated2"* ]] && ok "the guard applies in --dry-run too" || bad "dry-run guard ($out)"

exit $fail
