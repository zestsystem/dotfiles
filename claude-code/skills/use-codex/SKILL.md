---
name: use-codex
display_name: Use Codex
description: Spawn one or more OpenAI Codex CLI subagents from bash to offload context-heavy work from the parent Claude. Use when the user says "use codex", "build with codex", "ask codex", "get a codex second opinion", "compare codex vs claude", "have two agents try it", or otherwise asks to delegate or parallelize work to Codex. Also use whenever a user asks for a large coding task — research, multi-file refactors, large codebase analysis.
---

# Codex Subagent Skill

Spawn autonomous Codex CLI subagents to offload context-heavy work. Subagents burn their own tokens and return only their final message, so the parent's context stays clean.

**Golden Rule:** If task + intermediate work would add 3,000+ tokens to parent context → use a subagent.

## Instructions

When invoking this skill:

1. **Clarify intent.** Figure out what the user wants. If unclear, ask. Inline args ("use codex to review my auth plan") usually carry the intent — infer from them. Common buckets: second-opinion code review, refactor, plan validation, implementation of features, fresh perspective on a stuck bug, parallel comparison of approaches.
2. **Pick the right reasoning tier** Use GPT 5.6 Sol model (`gpt-5.6-sol`) with either low or xhigh reasoning
3. **Spawn the subagent** using the canonical invocation (Basic Usage). Pipe long prompts via stdin.
4. **Act autonomously while it runs.** Don't ask for permission mid-flight; the parent only sees the final result, so mid-task pauses waste tokens. Pause only for genuinely destructive operations (data loss, external impact, security).
5. **Monitor, don't fire-and-forget.** Check completion, verify quality, retry on failure, answer follow-ups if blocked. Feel free to run multiple sequential or parallel codex subagents.
6. **Present results, don't dump them.** Summarize what Codex said in your own words, surface concrete code changes or recommendations, and leave the next move to the user. Subagent output is *input* for your synthesis. Keep your response to the user concise and specific.

## Model + Reasoning Selection

Always use GPT 5.6 Sol (`gpt-5.6-sol`, latest — `gpt-5.5` is the fallback lane per the scorecard if Sol regresses or hits capacity errors), but choose from low or xhigh reasoning. You may use other reasoning but usually simple, short, or basic tasks are best done by low reasoning and hard, large, or long tasks are done by xhigh reasoning.

## Intelligent Prompting

Subagents only see what you give them. Be specific:

1. **Context** — what they're analyzing, where it lives.
2. **Objectives** — numbered, concrete.
3. **Constraints** — what to focus on, what to ignore.
4. **Output format** — exact shape the parent wants back.
5. **Success criteria** — when the task is done.

Template:

```
[TASK CONTEXT]
You are researching/analyzing/coding [TOPIC/EXPLANATION].

[OBJECTIVES]
1. ...
2. ...

[CONSTRAINTS]
- Focus on: ...
- Ignore: ...

[OUTPUT FORMAT]
Return: ...

[SUCCESS CRITERIA]
Complete when: ...
```

### Good vs. Bad Prompts

Vague prompts produce vague work; specific prompts produce useful work.

**Research**

❌ "Research authentication"

✅ "Research authentication in this Next.js codebase. Focus on: 1) Session management strategy (JWT vs session cookies), 2) Auth provider integration (NextAuth, Clerk, etc), 3) Protected route patterns. Check /app, /lib/auth, and middleware files. Return architecture summary with code examples."

**Web search / docs lookup**

❌ "Search for Codex SDK"

✅ "Find the most recent Codex SDK documentation using the web and summarize key updates. Focus on: 1) Installation/quickstart, 2) Core API methods and parameters, 3) Breaking changes or deprecations. Prioritize official OpenAI docs and release notes. Return a concise summary with citations."

**API discovery**

❌ "Find API endpoints"

✅ "Find all REST API endpoints in this Express.js app. Look in /routes, /api, and /controllers directories. For each endpoint document: method (GET/POST/etc), path, auth requirements, request/response schemas. Return as markdown table."

## Basic Usage

**Default: pipe the prompt via stdin using `-` as the positional argument.** Inline string prompts work for short ones, but anything with newlines, quotes, backticks, or `$` should be piped to avoid shell-escaping bugs.

Canonical invocation (capture output to file, GPT 5.6 Sol with xhigh reasoning):

```bash
cat <<'EOF' | codex exec --yolo --skip-git-repo-check \
  -m gpt-5.6-sol -c 'model_reasoning_effort="xhigh"' \
  -o /tmp/codex-result.txt -
[TASK CONTEXT]
You are analyzing /path/to/repo.

[OBJECTIVES]
1. Do X
2. Do Y

[OUTPUT FORMAT]
Return: path - purpose
EOF

result=$(cat /tmp/codex-result.txt)
```

**Variants** (only what changes from the canonical form):

- **Low-effort task** (simple search, short fetch, basic lookup): swap `-c 'model_reasoning_effort="xhigh"'` → `-c 'model_reasoning_effort="low"'`. Model stays `gpt-5.6-sol`.
- **Machine-parsable output:** swap `-o /tmp/codex-result.txt` → `--json`, then pipe through `jq -r 'select(.event=="turn.completed") | .content'`. Prefer `-o` whenever possible — it skips JSON parsing and avoids terminal truncation on long outputs.

## Parallel Subagents

Spawn multiple subagents for independent tasks — research two topics in parallel, or compare two approaches to the same problem. Each writes to its own `-o` file; `wait` for all, then read:

```bash
cat <<'EOF' | codex exec --yolo --skip-git-repo-check \
  -m gpt-5.6-sol -c 'model_reasoning_effort="xhigh"' -o /tmp/agent-a.txt - &
Approach A: solve [problem] using [strategy A]. Return diff + rationale.
EOF

cat <<'EOF' | codex exec --yolo --skip-git-repo-check \
  -m gpt-5.6-sol -c 'model_reasoning_effort="xhigh"' -o /tmp/agent-b.txt - &
Approach B: solve [problem] using [strategy B]. Return diff + rationale.
EOF

wait
RESULT_A=$(cat /tmp/agent-a.txt)
RESULT_B=$(cat /tmp/agent-b.txt)
```

The canonical compare-two-approaches pattern: give both subagents the same problem under different framings, wait, then synthesize the better answer in the parent.

## Sequential Subagents

When the parent is driving a multi-step engagement — each next call is a *judgment* based on what just came back, not a mechanical retry. Spawn one subagent, read its output, decide what to do next (next slice of the work, a review pass, a redo, a different angle, a verification step), spawn the next one, repeat. The parent stays in the driver's seat the whole time:

```bash
# Step 1: dispatch the first subagent
cat <<'EOF' | codex exec --yolo --skip-git-repo-check \
  -m gpt-5.6-sol -c 'model_reasoning_effort="xhigh"' \
  -o /tmp/codex-step-1.txt -
Implement the auth middleware in src/middleware/auth.ts per the spec at docs/auth.md.
Return: summary of changes + files touched.
EOF

# Step 2: parent reads /tmp/codex-step-1.txt, decides what's needed next.
# Could be: next part of the task, a critique pass, a redo, a verification — whatever fits.
# Always use a quoted heredoc (<<'EOF') for the template and `cat` the prior
# output on stdin — never interpolate $STEP_N into an unquoted heredoc.
# Codex output frequently contains backticks and $() sequences (code blocks,
# command examples), and bash would execute those during expansion.
{
  cat <<'EOF'
Review the auth middleware changes summarized below for security holes
(token leakage, timing attacks, missing CSRF). Return: issues + line refs.

[PRIOR WORK]
EOF
  cat /tmp/codex-step-1.txt
} | codex exec --yolo --skip-git-repo-check \
  -m gpt-5.6-sol -c 'model_reasoning_effort="xhigh"' \
  -o /tmp/codex-step-2.txt -

# Step 3: parent reads /tmp/codex-step-2.txt, dispatches a fix pass — or moves
# on to the next slice of work entirely. Keep going until the parent decides done.
```

The shape: **call → read → decide → call → read → decide**. Each prompt is composed fresh in the parent based on what just landed. There's no fixed loop count and no shared template — every step can be a totally different task (implement, review, refactor, sanity-check, redo from scratch). Feed prior outputs into later prompts whenever the next subagent needs that context to do its job.

## Local environment notes (added at install, 2026-07-03)

- `codex` on this machine is a shell alias to `/Applications/Codex.app/Contents/Resources/codex` (codex-cli 0.142.5). If `codex` doesn't resolve in a non-interactive shell, use that full path.
- `--yolo` disables Codex's sandbox and approval prompts — the subagent can run arbitrary commands. Prefer scoping prompts to a specific worktree and avoid pointing it at destructive operations.
- Write `-o` output files to the session scratchpad directory rather than `/tmp` when one is available.
- Source: https://public.my-agent-04eee268.sandbox.dev/skills/use-codex.md
