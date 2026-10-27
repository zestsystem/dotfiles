#!/usr/bin/env bash
# Tests for heavy-gate: admission, the lease's exclusivity and lifetime, nesting, exit and signal semantics, and the gauge.
set -uo pipefail
HG="$(cd "$(dirname "$0")/.." && pwd)/heavy-gate"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
export HEAVY_GATE_STATE_DIR="$TMP/state"
open_conf() { printf 'min_mem_free_pct=0\nmax_load_per_core=100000\nmin_disk_free_pct=0\nslots=1\n' > "$TMP/conf"; }
export HEAVY_GATE_CONF="$TMP/conf"; open_conf
fail=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }

out="$("$HG" run --label t1 -- true 2>&1)"; rc=$?
[[ $rc -eq 0 && "$out" == *"HEAVY_GATE=admitted slot=0 label=t1"* ]] && ok "admits and runs" || bad "admits and runs (rc=$rc: $out)"

"$HG" run -- bash -c 'exit 7' 2>/dev/null; rc=$?
[[ $rc -eq 7 ]] && ok "exit status passes through" || bad "exit status passes through (rc=$rc)"

"$HG" run --label holder -- sleep 3 2>/dev/null & holder=$!
sleep 0.7
out="$("$HG" run -- true 2>&1)"; rc=$?
[[ $rc -eq 75 && "$out" == *"HEAVY_GATE=gated reason=lease_busy"* && "$out" == *"holder"* ]] && ok "second run is gated while the lease is held" || bad "second run gated (rc=$rc: $out)"
"$HG" check 2>/dev/null; rc=$?
[[ $rc -eq 75 ]] && ok "check reports busy" || bad "check reports busy (rc=$rc)"
wait $holder
out="$("$HG" run -- true 2>&1)"; rc=$?
[[ $rc -eq 0 ]] && ok "lease frees when the holder exits" || bad "lease frees on exit (rc=$rc: $out)"

out="$("$HG" run --label outer -- "$HG" run --label inner -- true 2>&1)"; rc=$?
[[ $rc -eq 0 && "$out" == *"HEAVY_GATE=inherited slot=0"* ]] && ok "a nested run inherits the lease" || bad "nested run inherits (rc=$rc: $out)"

HEAVY_GATE_HELD="0:$(printf '%032x' 7)" "$HG" run -- true 2>"$TMP/forged"; rc=$?
grep -q "HEAVY_GATE=admitted" "$TMP/forged" && [[ $rc -eq 0 ]] && ok "a forged inherited token is ignored" || bad "forged token ignored (rc=$rc: $(cat "$TMP/forged"))"

"$HG" run -- sleep 30 2>/dev/null & victim=$!
sleep 0.7; kill -TERM $victim; wait $victim; rc=$?
[[ $rc -eq 143 ]] && ok "signals reach the command (143)" || bad "signal semantics (rc=$rc)"
out="$("$HG" run -- true 2>&1)"; rc=$?
[[ $rc -eq 0 ]] && ok "lease frees when the holder is killed" || bad "lease frees on kill (rc=$rc: $out)"

"$HG" run -- bash -c 'sleep 2 & exit 0' 2>/dev/null; rc=$?
out="$("$HG" run -- true 2>&1)"; rc2=$?
[[ $rc -eq 0 && $rc2 -eq 75 ]] && ok "a child that keeps running keeps the lease" || bad "child keeps lease (rc=$rc rc2=$rc2: $out)"
sleep 2.5
"$HG" run -- true 2>/dev/null && ok "and frees it when that child exits" || bad "lease frees after child exits"

printf 'min_mem_free_pct=0\nmax_load_per_core=100000\nmin_disk_free_pct=100\nslots=1\n' > "$TMP/conf"
out="$("$HG" run -- touch "$TMP/should-not-exist" 2>&1)"; rc=$?
[[ $rc -eq 75 && "$out" == *"reason=disk_"* && ! -e "$TMP/should-not-exist" ]] && ok "the gauge gates before the command starts" || bad "gauge gates (rc=$rc: $out)"

printf 'max_load_per_core=abc\n' > "$TMP/conf"
"$HG" check >/dev/null 2>&1; rc=$?
[[ $rc -ne 0 && $rc -ne 75 ]] && ok "an invalid threshold is an error, not an admission" || bad "invalid threshold (rc=$rc)"
open_conf

printf 'min_mem_free_pct=0\nmax_load_per_core=100000\nmin_disk_free_pct=0\nslots=2\n' > "$TMP/conf"
"$HG" run -- sleep 2 2>/dev/null & a=$!; sleep 0.5
"$HG" run -- true 2>/dev/null; rc=$?
[[ $rc -eq 0 ]] && ok "two slots admit a second run" || bad "two slots (rc=$rc)"
wait $a

exit $fail
