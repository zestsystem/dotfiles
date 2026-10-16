#!/usr/bin/env bash
# leaf-run account-guard tests — fake HOME, fake claude/codex CLIs, fake account homes, fake routing
# map; nothing billed, no real account touched. Run: bash claude-code/bin/tests/leaf-run-guard.sh
# Accounts are RFC 2606 example.test addresses; the fake access token must never reach any output.
set -uo pipefail
BIN=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
T=$(mktemp -d); T=$(cd -P "$T" && pwd)
trap 'rm -rf "$T"' EXIT
export HOME="$T/home" LEAF_REGISTRY="$T/reg.jsonl"
unset CLAUDE_CONFIG_DIR CODEX_HOME CODEX_API_KEY ANTHROPIC_API_KEY
mkdir -p "$HOME/.claude" "$T/bin" "$HOME"/projects/work/{utc,utc-wt,yapmoi,voidpet-poc,other}
export PATH="$T/bin:$BIN:/usr/bin:/bin"
U=utc@example.test MK=mk@example.test VP=vp@example.test SECRET=SECRET-ACCESS-TOKEN-do-not-print

# --- fake Claude slots: <home>/acct holds the logged-in account ---------------------------------
for s in .claude:$U .claude-mk:$MK .claude-voidpet:$VP; do
  mkdir -p "$HOME/${s%%:*}"; echo "${s#*:}" > "$HOME/${s%%:*}/acct"
done
cat > "$T/bin/claude" <<'EOF'
#!/bin/sh
d="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
if [ "$1 $2" = "auth status" ]; then
  m=claude.ai; [ -n "${ANTHROPIC_API_KEY:-}" ] && m=api_key
  printf '{"loggedIn":true,"authMethod":"%s","configDirectory":"%s","email":"%s"}\n' "$m" "$d" "$(cat "$d/acct")"
  exit 0
fi
echo "claude ran home=$d" >> "$HOME/ran.log"
EOF
printf '#!/bin/sh\nexport CLAUDE_CONFIG_DIR="$HOME/.claude-mk"\nexec claude "$@"\n' > "$T/bin/claude-mk"
printf '#!/bin/sh\nexport CLAUDE_CONFIG_DIR="$HOME/.claude-voidpet"\nexport CODEX_HOME="$HOME/.codex-voidpet"\nexec claude "$@"\n' > "$T/bin/claude-voidpet"
# A wrapper the guard can only see into by reading it (innocuous name), and an opaque one.
printf '#!/bin/sh\n# runs the voidpet slot\nexport CLAUDE_CONFIG_DIR="$HOME/.claude-voidpet"\nexec claude "$@"\n' > "$T/bin/myleaf"
printf '#!/bin/sh\nX=$(printf cod; printf ex)\nexec "$X" "$@"\n' > "$T/bin/opaque"
ln -s "$T/bin/claude-mk" "$T/bin/cl"   # symlinked alias of a slot wrapper
# k3's wrapper: an `exec claude` on a Kimi token — out of the guard's scope, must not be peeked.
printf '#!/bin/sh\nexport ANTHROPIC_AUTH_TOKEN="kimi"\nexport CLAUDE_CONFIG_DIR="$HOME/.claude-kimi"\nexec claude "$@"\n' > "$T/bin/kimi-claude"
mkdir -p "$HOME/.claude-kimi"; echo kimi@example.test > "$HOME/.claude-kimi/acct"

# --- fake Codex homes: auth.json with an id_token whose claims carry the account ----------------
b64url() { printf '%s' "$1" | base64 | tr -d '=\n' | tr '+/' '-_'; }
mkcodex() {  # home email plan auth_mode
  mkdir -p "$HOME/$1"
  local claims; claims=$(printf '{"email":"%s","https://api.openai.com/auth":{"chatgpt_plan_type":"%s"}}' "$2" "$3")
  printf '{"auth_mode":"%s","OPENAI_API_KEY":null,"tokens":{"id_token":"%s.%s.sig","access_token":"%s","refresh_token":"%s"}}\n' \
    "$4" "$(b64url '{"alg":"none"}')" "$(b64url "$claims")" "$SECRET" "$SECRET" > "$HOME/$1/auth.json"
}
mkcodex .codex "$U" pro chatgpt
mkcodex .codex-yapmoi "$MK" free chatgpt
mkcodex .codex-voidpet "$VP" pro chatgpt
mkcodex .codex-apikey "$U" pro apikey
cat > "$T/bin/codex" <<'EOF'
#!/bin/sh
echo "codex ran home=${CODEX_HOME:-$HOME/.codex}" >> "$HOME/ran.log"
EOF
chmod +x "$T"/bin/*
echo "prompt" > "$T/prompt.md"
: > "$HOME/ran.log"

# --- fake routing map, same shape as the real machine-local one ---------------------------------
cat > "$HOME/.claude/model-economics.json" <<EOF
{"project_routing": {
   "_guard": "test",
   "UTC": {"paths": ["~/projects/work/utc"], "claude_slots": ["default"], "codex_homes": ["default"]},
   "yapmoi": {"paths": ["~/projects/work/yapmoi"], "claude_slots": ["claude-mk", "default"], "codex_homes": ["default"]},
   "voidpet-poc": {"paths": ["~/projects/work/voidpet-poc"], "claude_slots": ["voidpet"], "codex_homes": ["voidpet"]}},
 "claude_slots": {
   "default": {"config_home": "~/.claude", "account_last_verified": "$U"},
   "claude-mk": {"config_home": "~/.claude-mk", "account_last_verified": "$MK"},
   "voidpet": {"config_home": "~/.claude-voidpet", "account_last_verified": "$VP"}},
 "codex_homes": {
   "default": {"home": "~/.codex", "account": "$U"},
   "mk": {"home": "~/.codex-yapmoi", "account": "$MK"},
   "voidpet": {"home": "~/.codex-voidpet", "account": "$VP"}}}
EOF

pass=0 fail=0 ALL="$T/all.out"
# t NAME EXPECT(ok|BLOCK) PROJECTDIR LANE -- CMD...
t() {
  local name=$1 want=$2 dir=$3 lane=$4 rc got out before after; shift 5
  before=$(wc -l < "$HOME/ran.log" 2>/dev/null || echo 0)
  out=$(cd "$HOME/projects/work/$dir" && "$BIN/leaf-run" --issue TEST --lane "$lane" -- "$@" 2>&1); rc=$?
  after=$(wc -l < "$HOME/ran.log" 2>/dev/null || echo 0)
  printf '%s\n' "$out" >> "$ALL"
  case $rc in 0) got=ok ;; 3) got=BLOCK ;; *) got="rc=$rc" ;; esac
  # A block must stop the launch; a pass must actually run it.
  if [ "$got" = BLOCK ] && [ "$before" != "$after" ]; then got="BLOCK-but-ran"; fi
  if [ "$got" = ok ] && [ "$before" = "$after" ] && [ "${NO_RUN_OK:-}" != 1 ]; then got="ok-but-not-run"; fi
  if [ "$got" = "$want" ]; then pass=$((pass + 1)); printf "PASS  %-6s %-48s %s\n" "$want" "$name" "$(printf "%s" "$out" | grep -m1 "BLOCKED" | sed "s/.*BLOCKED — //" | cut -c1-95)"
  else fail=$((fail + 1)); printf 'FAIL  want %s got %s: %s\n%s\n' "$want" "$got" "$name" "$out" | sed 's/^/      /'; fi
}

echo "== UTC (default Claude slot + default Codex home only)"
t "claude direct, default slot"                     ok    utc    opus-5  -- claude -p hi
t "claude-mk wrapper (no longer UTC overflow)"      BLOCK utc    opus-5  -- claude-mk -p hi
t "absolute path to claude-mk"                      BLOCK utc    opus-5  -- "$T/bin/claude-mk" -p hi
t "symlinked alias of claude-mk"                    BLOCK utc    opus-5  -- cl -p hi
t "env CLAUDE_CONFIG_DIR=mk claude"                 BLOCK utc    opus-5  -- env CLAUDE_CONFIG_DIR="$HOME/.claude-mk" claude -p hi
t "env -u CLAUDE_CONFIG_DIR claude (back to default)" ok  utc    opus-5  -- env -u CLAUDE_CONFIG_DIR claude -p hi
t "bash -c with prefix assignment to mk"            BLOCK utc    opus-5  -- bash -c 'CLAUDE_CONFIG_DIR=$HOME/.claude-mk claude -p hi'
t "bash -lc export voidpet; claude"                 BLOCK utc    opus-5  -- bash -lc 'export CLAUDE_CONFIG_DIR="$HOME/.claude-voidpet"; claude -p hi'
t "bash -c nested sh -c into claude-mk"             BLOCK utc    opus-5  -- bash -c "sh -c 'claude-mk -p hi'"
t "bash -c unresolvable CLAUDE_CONFIG_DIR"          BLOCK utc    opus-5  -- bash -c 'CLAUDE_CONFIG_DIR=$(cat /x) claude -p hi'
t "shebang wrapper with innocuous name (peeked)"    BLOCK utc    opus-5  -- myleaf -p hi
t "codex lane, launch hidden behind computed name"  BLOCK utc    codex   -- opaque exec -
t "missing --lane"                                  BLOCK utc    ""      -- claude -p hi
t "ANTHROPIC_API_KEY assignment in env prefix"      BLOCK utc    opus-5  -- env ANTHROPIC_API_KEY=x claude -p hi
t "codex default home"                              ok    utc    codex   -- codex exec -
t "codex via stdin-from (prompt read inside)"       ok    utc    codex   -- stdin-from "$T/prompt.md" codex exec -
t "bash -c codex reading prompt file"               ok    utc    codex   -- bash -c "codex exec - < '$T/prompt.md'"
t "env CODEX_HOME=voidpet codex"                    BLOCK utc    codex   -- env CODEX_HOME="$HOME/.codex-voidpet" codex exec -
t "stdin-from + env CODEX_HOME=yapmoi codex"        BLOCK utc    codex   -- env CODEX_HOME="$HOME/.codex-yapmoi" stdin-from "$T/prompt.md" codex exec -
t "codex -C into voidpet tree"                      BLOCK utc    codex   -- codex exec -C "$HOME/projects/work/voidpet-poc" -
t "k3 wrapper kimi-claude (Kimi quota, unguarded)"  ok    utc    k3      -- kimi-claude -p hi
t "utc* worktree dir, claude-mk"                   BLOCK utc-wt opus-5  -- claude-mk -p hi
t "utc* worktree dir, default claude"               ok    utc-wt opus-5  -- claude -p hi
out=$(cd "$HOME/projects/work/utc" && ANTHROPIC_API_KEY=x "$BIN/leaf-run" --issue T --lane opus-5 -- claude -p hi 2>&1); rc=$?
printf '%s\n' "$out" >> "$ALL"
if [ $rc = 3 ]; then pass=$((pass + 1)); echo "PASS  BLOCK  process-env API key -> authMethod not claude.ai"; else fail=$((fail + 1)); echo "FAIL  process-env API key: rc=$rc $out"; fi
out=$(cd "$HOME/projects/work/utc" && CODEX_HOME="$HOME/.codex-apikey" "$BIN/leaf-run" --issue T --lane codex -- codex exec - 2>&1); rc=$?
printf '%s\n' "$out" >> "$ALL"
if [ $rc = 3 ] && printf '%s' "$out" | grep -q auth_mode; then pass=$((pass + 1)); echo "PASS  BLOCK  codex home in apikey auth_mode"; else fail=$((fail + 1)); echo "FAIL  codex apikey: rc=$rc $out"; fi

echo "== yapmoi (claude-mk primary, default Claude fallback, default Codex until mk is upgraded)"
t "claude-mk primary"                               ok    yapmoi opus-5  -- claude-mk -p hi
t "default claude fallback"                         ok    yapmoi opus-5  -- claude -p hi
t "claude-voidpet"                                  BLOCK yapmoi opus-5  -- claude-voidpet -p hi
t "codex default home"                              ok    yapmoi codex   -- codex exec -
t "codex yapmoi home (free plan, not yet allowed)"  BLOCK yapmoi codex   -- env CODEX_HOME="$HOME/.codex-yapmoi" codex exec -

echo "== voidpet-poc (voidpet Claude slot + ~/.codex-voidpet only)"
t "claude-voidpet"                                  ok    voidpet-poc opus-5 -- claude-voidpet -p hi
t "shebang wrapper into voidpet slot (peeked)"      ok    voidpet-poc opus-5 -- myleaf -p hi
t "default claude"                                  BLOCK voidpet-poc opus-5 -- claude -p hi
t "claude-mk"                                       BLOCK voidpet-poc opus-5 -- claude-mk -p hi
t "codex default home"                              BLOCK voidpet-poc codex  -- codex exec -
t "env CODEX_HOME=voidpet codex"                    ok    voidpet-poc codex  -- env CODEX_HOME="$HOME/.codex-voidpet" codex exec -
t "bash -c CODEX_HOME=voidpet codex < prompt"       ok    voidpet-poc codex  -- bash -c "CODEX_HOME=\$HOME/.codex-voidpet codex exec - < '$T/prompt.md'"
t "bash -c export then unset CODEX_HOME"            BLOCK voidpet-poc codex  -- bash -c 'export CODEX_HOME=$HOME/.codex-voidpet; unset CODEX_HOME; codex exec -'
echo "$U" > "$HOME/.claude-voidpet/acct"
t "voidpet slot re-logged into the UTC account"     BLOCK voidpet-poc opus-5 -- claude-voidpet -p hi
echo "$VP" > "$HOME/.claude-voidpet/acct"

echo "== outside designated projects / cross-project cd / missing map"
t "claude-mk from an undesignated dir"              ok    other  opus-5  -- claude-mk -p hi
t "bash -c cd into voidpet tree, default claude"    BLOCK other  opus-5  -- bash -c 'cd ~/projects/work/voidpet-poc && claude -p hi'
t "bash -c cd into voidpet tree, voidpet slot"      ok    other  opus-5  -- bash -c 'cd ~/projects/work/voidpet-poc && claude-voidpet -p hi'
t "cd to an unresolvable dir"                       BLOCK other  opus-5  -- bash -c 'cd "$PROJ" && claude -p hi'
mv "$HOME/.claude/model-economics.json" "$T/econ.bak"
t "map missing: billed launch fails closed"         BLOCK other  opus-5  -- claude -p hi
NO_RUN_OK=1 t "map missing: non-billed command passes" ok other gate  -- true
mv "$T/econ.bak" "$HOME/.claude/model-economics.json"

if grep -q "$SECRET" "$ALL"; then fail=$((fail + 1)); echo "FAIL  a Codex token reached leaf-run output"; else pass=$((pass + 1)); echo "PASS  no Codex token in any output"; fi
echo "-- $pass passed, $fail failed"
[ $fail = 0 ]
