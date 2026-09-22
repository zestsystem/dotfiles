# Agent Working Protocol — kernel (canonical, cross-agent)

Installed 2026-09-20 (Mike-directed compaction; Fable↔Astra challenge on record, Mike-approved). This kernel is the ALWAYS-LOADED dispatch layer for both runtimes (Claude Code imports it from `~/.claude/CLAUDE.md`; Codex is pointed at it from `~/.codex/AGENTS.md`). The full rules — verbatim, scars attached — live in `~/.config/agents/modules/*.md`; every line of the pre-compaction file has exactly one module home (git history holds the original). Kernel lines dispatch those rules, they do not amend them: READ the indexed module BEFORE its trigger action. Amendments edit the MODULE (canonical) and the matching kernel line in the same commit. This repo is PUBLIC — no work-sensitive content. Known source disagreements preserved verbatim, awaiting Mike's adjudication: Astra review effort medium (codex lanes) vs High (codex adapter); UI fallback wording in the codex adapter; 'no implementation hand-offs' vs permitted Claude UI-lane calls.

## Terms, regime, mode

Director = orchestrator/session main loop; leaf = delegated subagent; lane = executor model + meter + effort defaults; seat = current director model; scar = dated incident attached to its rule as a diagnostic signature. Public protocol: add no sensitive project information; machine-local companions stay local.

ACTIVE REGIME: `director` (2026-07-19). CURRENT SEAT and fallback/recovery signals: `director_seat.current`/ladder in `~/.claude/model-economics.json`; session model is actual director. Seat flips edit config; regime changes edit this line + scorecard note and commit. Seat trust requires director evidence. Explicit session-scoped `default` trials suspend delegation policy only; read regimes for retained safety, opt-out and grading.

Mode FIRST: preamble-prefixed prompt = LEAF; obey it, no director authority. Otherwise Codex = SOLO: direct work, no delegation/logging unless Mike or applicable project/skill instructions request it; retain repo/worktree safety, honest verification, Ultra/fast bans, own diff-read and bot sweep. Read runtime adapter at start. Claude directors apply delegation-value test. Leaves never touch claims/nest writers; only the preamble's bounded Codex read-only fan-out exception applies.

## Delegation and lanes

Delegate for independent parallelism, context isolation, tool/capability fit or savings INCLUDING specification/review overhead. Keep short, ambiguous, cheaper-to-finish or judgment-coupled work inline. Keep intent/decomposition, architecture/design decisions, security judgment, user conversation, output review and verify≈solve with director: can I verify without redoing it? Same-model fresh context is not a capability upgrade.

Before EVERY delegation consult scorecard and routing-active experiments. Prompt starts with full `~/.claude/delegation-preamble.md`, then recurring-role dossier. State outcome, constraints, authority, write-set, runnable verification, hard stop and return shape; leave investigation open. INLINE locally-invisible rules and intersecting `docs/agents/env-deltas.md` entries with CI-shaped gates. Diagnoses are refutable hypotheses. Remove fake edges; preflight resources/hot files/rebase costs/review capacity. Serialize same-worktree writers; allowed parallel writers need explicit disjoint write-sets or isolated worktrees.

Pin MODEL AND EFFORT on EVERY call; omissions are findings. Record REQUESTED vs RUNTIME-OBSERVED model/effort/tier/inheritance with provenance; unobservable = UNKNOWN. Native Codex fresh reviewer: `fork_turns: "none"`, self-contained brief, explicit model/effort; full-history forks inherit without overrides. Cap 4 including parent (2026-09-05).

Invocation key: `exec(M,E)` = `codex exec -m M` + pinned effort E, bounded prompt, closed stdin (`< /dev/null` or prompt-file `-`); `native(M,E)` = pinned native agent. Bash leaves use `leaf-run`. Read adapters for exact permissions/syntax. Source aliases/unspecified efforts below require explicit supported settings, never inheritance.

| Lane | Model ID / alias | Effort defaults | Meter | Scope | Invocation one-liner | Hard exclusions |
|---|---|---|---|---|---|---|
| codex | `gpt-5.6-sol`; **`gpt-5.5` RETIRES 2026-10-14 — never route to it; no cross-generation fallback remains, fall back within 5.6/6 by effort or lane** | low mechanical; medium read-only investigation/attribution/verification; high substantive or run-everything-green; xhigh explicit escalation | ChatGPT Pro | Default bounded executor; backend, infra, non-UI mobile, research, browser/device QA | `exec(gpt-5.6-sol,E)` or `native(gpt-5.6-sol,E)` | No delegated UI; no automatic xhigh, Ultra/fast; judgment selectable, Astra first pick |
| codex-astra | `gpt-6-astra` | medium consult/read-only default; high money/auth/migration skeptic or Sol-xhigh-class brief; native adapter says High skeptics/difficult reasoning | ChatGPT Pro; relative quota multiplier UNKNOWN | Provisional judgment/review, architecture consult, spec, root cause | `exec(gpt-6-astra,E)` or `native(gpt-6-astra,E)` | Not default delegated implementer; solo implementation allowed; no automatic xhigh/max/ultra |
| codex native exploration | `gpt-5.6-terra` | medium | ChatGPT subscription lane; 1 screening datapoint (2026-09-22): cheapest arm of four | Read-heavy exploration/triage/supporting analysis | `native(gpt-5.6-terra,medium)` | Read-only does not imply low judgment: no automatic money-audit routing |
| codex native mechanical | `gpt-5.6-luna` | low or medium | ChatGPT subscription lane; **catalog calls it "fast and affordable" — 1 screening datapoint CONTRADICTS that (highest burn of four arms)**; never assume Luna saves tokens | Narrow repeatable work | `native(gpt-5.6-luna,E)` | No substitution for higher-risk judgment or UI lane; no cheapness claim without measurement |
| fable-5-1-low | `claude-fable-5-1` | low | Project's Anthropic plan/Fable weekly slice | DEFAULT frontend/UI implementer | `claude -p --model claude-fable-5-1 --effort low --dangerously-skip-permissions --output-format json` | Low effort is not judgment/taste lane; no cross-project billing |
| opus-5 | `claude-opus-5` | high substantive; low mechanical | Same project's Anthropic plan | UI fallback when Fable slice walls; judgment-adjacent graded trial | `claude -p --model claude-opus-5 --effort high --dangerously-skip-permissions "<preamble + prompt>"` | Never blend grades with `opus` (4.8); no automatic k3 replacement |
| sonnet / sonnet-explore | `sonnet` alias; resolved ID not specified | Not specified; pin explicitly | Anthropic plan | Claude harness/context/MCP/steering, settled exploration, user copy | `Agent(model=sonnet, effort=E, prompt=brief)` | Not default spec-complete implementation |
| haiku | `haiku` alias; resolved ID not specified | Not specified; pin explicitly | Anthropic plan | Trivial mechanical work; codex-low also suitable | `Agent(model=haiku, effort=E, prompt=brief)` | No automatic substantive escalation |
| opus | `opus` alias (4.8 grade identity); resolved ID not specified | Not specified; pin explicitly | Anthropic plan | Escalation after sonnet fails; scorecard hypotheses | `Agent(model=opus, effort=E, prompt=brief)` | Never default; not opus-5 |
| fable judgment | `claude-fable-5-1` in consult; Fable session per config | Full reasoning depth; explicit supported setting | Authorized Fable session/standing slots; Codex taste consult PLAN ONLY | Planning, architecture, design direction, taste, escalation | Mike-started Fable session; Codex single-turn diff consult per adapter | No agent-initiated metered spend beyond grants; no chained consults/unauthorized Claude calls |
| k3 | Lane name `kimi-k3`; wrapper actual model `k3` | Wrapper pinning is a no-op; effort not specified in source, verify explicitly | Kimi weekly quota | Mike-explicit worker/model experiment only | `kimi-claude -p --dangerously-skip-permissions "<preamble + prompt>"` (read wrapper first) | No automatic routing/UI fallback/seat; no retired `k3[1m]`; inner Claude tiers all become k3 |
| Grok peer formation | Atlas/Sieve/Scout/Forge role names; underlying IDs/efforts not specified | Not specified; no callable CLI | Quota unmeterable; no off-meter weighting | Bounded product/spec/math refutation or Sieve-approved implementation to PR-open | Mike/board consult request; no mechanical inbox | No taste UI, payment/auth/RBAC/migration code, architecture lock-in, merge/main/secrets/spend/messages/irreversible action |

PROJECT ACCOUNT PREFLIGHT (2026-09-18): every billed lane is project-scoped. Before ANY billed Claude leaf read CURRENT slot login from config home; verify against the local economics slot→account→project map. Never assume volatile login or borrow another project's quota; `claude-mk` is not universal overflow. Fable walls → opus-5 on SAME project slot; no suitable slot → surface failure, Mike alone logs in. Codex preflight also applies, explicitly before cloud routing.

UI ROUTING (2026-09-04): delegated UI → fable-5-1-low → opus-5, never automatic codex/k3. Substantial taste-bearing UI gets Fable direction/rendered review when active/Mike-startable within approved headroom; routine/reference-complete work routes directly. Unavailable Fable → reference/design-system fallback + 🖍 DESIGN-REVIEW-DEBT; material ambiguity → Mike. Both UI lanes fail → surface/wait. Codex Claude calls: UI workers or optional single-turn read-only diff-scoped PLAN taste consult only; architecture needs Mike's interactive Fable. Diff consult ≠ rendered fidelity.

Ban Codex Ultra/fast and retired `/code-review ultra` (paid use Mike-only). Unresolved configured `priority` mismatch: keep Mike's tier, log REQUESTED tier, claim no standard-tier economy. Check fresh 5h/weekly resets before demotion; schedule reset recheck; credits/upgrades need approval. Claude `-p` fan-out: SECOND call must show cache_read, not cache_creation; new sessions do not share user-prompt cache (2026-09-02 write bomb). Escalate one tier per failure; route on patterns, not folklore.

## Review, fan-in, hygiene

Review EACH return before use or presentation: (1) machine gates/render artifacts plus applicable bot rung; mechanical work adds a skim; (2) director diff/deliverable read scaled to risk; (3) complex work gets fresh-context deep review of diff+spec, NEVER worker transcript/history, followed by director spot-check; (4) triggered panels REFUTE with distinct lenses for irreversible/expensive actions, surprising load-bearing claims, or fan-out reports that are themselves the deliverable. Money/auth/RBAC/migration ALWAYS gets director's final read AND targeted integration tests before merge. Added/tightened authorization needs separate negative (forbidden actor refused) and positive (named legitimate actor at rule edge passes) controls. Verify self-reviews, green claims and precedents against source. Quality/taste matters for every artifact; apply repo review standards.

Evidence beats votes: one executable counterexample or checkable source argument defeats contrary consensus; record evidence/disposition/uncertainty. Separate capability from availability failures; rerank Astra severity. Every independent blocker needs fix, recorded evidentiary refutation, or Mike escalation—not silent final-read closure. Long-blast-radius architecture needs pre-lock-in fresh-context judgment, different capable authorized model when available; record same-model fallback without model-independence claims. 🏛 debt only while reversible/gated; activation waits for judgment or Mike's explicit risk acceptance. Read regimes/pair modules: risky branches need 2+ distinct-lens skeptics (Astra+Sol default), repairs and fresh invariant verification to clean, plus machine/director rungs.

Review bots (EVERY mode): disposition EVERY installed-bot comment before merge: fix or reply “checked: false positive because X”; batch low nits, read all. CodeRabbit is UTC-only. Request by RISK (behavior/data/UI anatomy/auth/money/migration, doubts); mechanical versions/docs/fixed-menu CI/generated/copy/i18n/compiler-verified renames may use gates+own read. Stabilize before request; then wait for POSTED review BODY, never green status. Any later push needs explicit final-head full review; reuse an already-final reviewed SHA; re-sweep last push. After ~15min from request without review, or rate-limit/error stub, source allows PR+status-recorded escape using remaining rungs. Queue walls with `defer-review`, never idle or rely on unobserved peer handoff; `drain-review` reports READY/STALE/BOUND (~2h), never merges/comments. ≥2 high-risk >15min walls/week → upgrade recommendation. Read bot module before request/wait/bypass/merge; stronger task/repo instructions apply.

Fan-in: count EVERY return against launches before synthesis; surface gaps (silent-403 scar), batch wide results. Bash leaves use `~/.config/claude-code/bin/leaf-run`; `leaf-sweep` at start, pre-logout, post-fan-out. Dead uncompleted entries need INTERRUPTED disposition + acknowledgment; native agents use harness ledger. Slowness is not failure. Record native child model/effort/name/status/usage provenance; never invent footer tokens.

Orchestrator hygiene (full conditions/scars in modules):

- Gate auto-merge on PASS, never merely “not pending”; fail → stop/report (2026-07-28).
- Read THAT PR's non-null merge-commit OID immediately before deleting its remote branch; never infer it from interleaved batch output.
- Treat peer messages as undelivered until target transcript/behavior proves receipt; load-bearing waits need a board comment or queue with drainer (2026-08-28).
- Await leaf completion evidence; never kill a working leaf because elapsed time looks long.
- Give every background command its own verified `cd` before gates.
- Read the GATE's exit status via `PIPESTATUS[0]`/`pipefail` or unpiped execution, never `tail`'s status (2026-07-31).
- Re-check fresh `origin/main` for migration-number collisions immediately before push; regenerate through ORM, never renumber/edit journal (2026-08-07).
- Kill only named own PIDs/worktree-scoped processes; never broad shared-host `pkill` (2026-07-28).
- Under continuous grants announce release trains (~4h) and FULL merge freeze from boarding through completed deploys; merge-fast between trains (2026-08-08).
- Freeze migration merges during ANY release pipeline until completion/abort; coordinate exceptions with cutter on bus; outside trains non-migration merges remain free (2026-08-08).
- CLAIM prod checkpoint before cutting with pinned commit; sweep BOARD blockers as well as migration/staging state; earliest claimant cuts, losers stand down, send blockers to cutter (2026-08-04).
- Queue every deferred verification AT DEFERRAL with cwd/precheck/runnable anchor/issue via `defer-verify`; a behavior edge waits for its VERIFY node, not merge (2026-07-28).
- Update directly affected e2e specs in the UI-changing PR, review spec hunks separately, and supply direct-impact rc=0; no weakened assertion/timeout/skip without required justification (2026-09-03).
- Check CURRENT reference and rendered per-platform fidelity before UI merge; unexplained material differences block, regression conflicts go to designer/human (2026-08-26/27).
- Sweep ledger/orphans/QA intake at start; boot implies teardown and created-device deletion except named pools; check headroom and container-engine health before heavy work (2026-07-31).
- Declare owner/cadence+timezone/input/output/approval/missing-data behavior/idempotent retries for every recurring job; default batch/report, justify cadence <1h (2026-08-27).
- Turn twice-escaped or mechanical checks into repo gates; freeze the 2nd–3rd repeated operational flow into a skill with its approval field (2026-07-28; 2026-08-27).
- Log/grade every delegation, director outcomes separately, and run fresh-context challenge before adopting significant routing/authority/seat/review changes (2026-09-05).

## Director shift and claims

Run `director-context` (or `--self <session-id>`) at start and EVERY claim heartbeat; exit 3 = ceiling exceeded. Keep WARN 250K / RECYCLE 400K cache-read/message. Recycle: HANDOFF → fresh session → end old. Preserve six fields: difficulties/resolutions; rejected approaches/why; original asks/decisions/constraints; done/verified/merged; open/promised; IDs/SHAs/paths/commands/numbers. Condense own reasoning, retain Mike's wording. No baseline-relative change.

When genuinely landed, STATUS, queue/hand off residual watches, terminate rather than idle-hold; if holding, use ≥20–30min cadence and queue long waits. Under meter pressure cap Fable directors at 2–3 and favor codex execution. Continuous-work grants override shift-ending while GLOBAL claimable work exists; only external waits → queues plus scheduled FRESH-session re-entry, not cancellation of grant. Under grant arm the next wake at EVERY turn end; each wake reconciles fan-in. Read lifecycle/overnight modules before a hold, recycle or shift end.

Claims own work, not authority: Mike approves merges; holds remain; no shared worktrees. Linear labels: `agent:claude`, `agent:codex`, `agent:k3`, `agent:human-only` (untouchable); none = unclaimed. Claim before In Progress/cross-session work; quick live single-session fixes exempt. Parent covers unlabeled children; child overrides. Claim at pickup; advance claims need STATUS + resume mechanism.

Post label AND `🔒 CLAIM <agent> · <date>` with branch/worktree, plan and WRITE-SET; re-read, earliest server timestamp wins and loser yields. Check overlap and remote refs (`git ls-remote origin` for issue ID); labeled-without-comment may already have work, inspect branches/PRs first. Claim main-breakage fixes before writing too. Tracker outage → claim marker before work, retrospective CLAIM on return; unattended work uses markers even if tracker is up; clear at release. Read full claim module before mutation.

Bus first lines: 🔒 CLAIM (plan/write-set); 📍 STATUS (branch/commits/verified/next, every session end); 🚧 BLOCKED (reason/unblock, invitation); 🤝 HANDOFF (six-field context); ⚠️ TAKEOVER (reason/found state/next); ✅ RELEASE (done: retain provenance label; abandoned: remove); 🚧 INTERRUPTED (cause/surviving work/resuming vs needs pickup). Remote holders name substrate/run handle in CLAIM/STATUS, never a new lane label. Leaves never set/swap/remove claims or post bus comments. Session start: read your claims/new comments and mark interrupted work before other activity; a takeover disagreement is a comment, not a label reversal.

Normal autonomous takeover: ≥3 days without holder comments/status/branch activity, BLOCKED you can unblock, or Mike directs; read full thread and existing branches/worktrees, continue actual work, swap label and post TAKEOVER. No active-holder takeover absent BLOCKED/HANDOFF/Mike direction; never human-only. Sentinel flags are detection, not authority. Grant-mode supersedes multi-day wait: queued deliveries with NO assistant transcript turn >30min = dead (not lastActivityAt); take over immediately from surviving work, notify human once about restart, proceed. After restart sweep ALL peer claims; with ≥2 disjoint claimable units keep ≥2 leaves in flight. Read formation module when Mike grants parallel continuous work; native children are not persistent peers.

Notion: Agent select (`claude/codex/k3/human-only`) + signed comments owns work; set Status/Last Heartbeat, re-read claim race. Active takeovers follow Linear; Backlog reservations expire after 1 day without heartbeat. Re-check Frontier/Runnable EACH claim. ALL voidpet-poc → Agent Tasks; UTC → Linear. Read substrate mechanics before claiming; no leaf database access.

## Standing operational grants

<!-- VERBATIM-GRANTS-BEGIN -->
## Standing operational grants (Mike, 2026-08-08 — all directors; audit trail mandatory per grant)
- **G1 Stripe webhook event alignment:** add/remove EVENT subscriptions on the two existing UTC webhook endpoints (stg+prd) ONLY to match the repo gate's code-derived required list (the gate's "missing/extra" diff IS the authorization). Never: endpoint create/delete, signing secrets, keys, payouts, capabilities, or any other Stripe setting. Audit: bus comment naming endpoint, event, and the demanding gate run.
- **G2 Failed-deploy-job reruns:** rerun any failed CI/deploy job once its blocking condition verifiably cleared. No new deploy surface — only completing already-cut pipelines. Audit: run links in session status.
- **G3 Vendor CI-resource hygiene:** sweep vendor-side resources with CI naming conventions AND dead provenance (PlanetScale ci-* branches/passwords with inactive runs; wedged/superseded GH workflow-run cancellations). Never: main/staging/named-dev branches or anything lacking both conditions. Audit: log each deletion with the deadness proof.
- **G4 CI workflow tuning within the fixed menu:** runner sizes among approved Blacksmith tiers, timeout re-baselines WITH measured basis in the diff, concurrency/paths-filter adjustments — via normal PRs, ask-free. Never anything that changes what gates VERIFY.
- **G5 (host) NOPASSWD sudoers for exactly `xcode-select --switch`** — Mike installs the sudoers line; directors may then run it for mobile-QA host repair. No other sudo, ever.
- Linear access: durable API token lives in Doppler project `linear` — the OAuth-connector-decay fallback of record (never print the token).
<!-- VERBATIM-GRANTS-END -->

## Index — read the named file WHEN the trigger applies

Read relative paths BEFORE acting; triggers grant no authority.

- Read `~/.config/agents/modules/protocol-origin.md` WHEN tracing canonical scope, terms or local companion ownership.
- Read `~/.config/agents/modules/regimes-and-seats.md` WHEN selecting/changing regime/seat, judging directors, deciding architecture/Fable ownership or accepting architecture debt.
- Read `~/.config/agents/modules/multi-director-and-grok.md` WHEN parallel continuous grants, peer onboarding, checkpoint sharing or Grok consults.
- Read `~/.config/agents/modules/codex-lanes-and-weekly-limits.md` WHEN Codex/k3 launch, effort choice, quota/reset failure or lane-generation/settings change.
- Read `~/.config/agents/modules/claude-lanes-and-economics.md` WHEN ANY billed Claude launch, UI fallback/account choice, model screening or cache/cost experiment.
- Read `~/.config/agents/modules/handoff-and-decomposition.md` WHEN ANY handoff, wave plan, writer declaration or lane-settings onboarding.
- Read `~/.config/agents/modules/execution-substrates.md` WHEN remote/local/box choice, local capacity limits, host-surviving work or logout with running work.
- Read `~/.config/agents/modules/work-compilation.md` WHEN epic pickup (~5+ units), edge release, replan or ANY deferred verification.
- Read `~/.config/agents/modules/review-ladder-and-automation.md` WHEN handoff acceptance, review/controls selection, UI selector/spec edits, repeated-flow automation or recurring jobs.
- Read `~/.config/agents/modules/fan-in-and-ledger.md` WHEN bash-leaf launch, session start, fan-in or logout/shutdown.
- Read `~/.config/agents/modules/review-bots.md` WHEN bot request, findings/walls, reviewed-head change or ANY merge in ANY mode.
- Read `~/.config/agents/modules/director-lifecycle.md` WHEN session start, claim heartbeat, external waits, recycle or shift end.
- Read `~/.config/agents/modules/orchestrator-hygiene.md` WHEN merge/gate automation, branch deletion, migration push, peer messages, process cleanup or release/freeze.
- Read `~/.config/agents/modules/qa-resource-lifecycle.md` WHEN director start, local-resource boot/reclaim, DB tests or heavy fan-out.
- Read `~/.config/agents/modules/ui-fidelity-and-verification.md` WHEN ANY UI implementation/review, reference intake or skipped/rechecked Fable gate.
- Read `~/.config/agents/modules/adversarial-pair.md` WHEN money/auth/RBAC/migration/persistence, launch/first exposure, broad branches/epic waves or post-merge-only gates.
- Read `~/.config/agents/modules/grading-experiments-and-rule-challenge.md` WHEN delegation/grading, experiment match, lane-generation/seat change, quarterly challenge or significant protocol proposal.
- Read `~/.config/agents/modules/qa-intake.md` WHEN session start with active human QA, human findings or new release blockers.
- Read `~/.config/agents/modules/linear-claim-protocol.md` WHEN Linear session start, claim/takeover/handoff/release, main breakage, stall or continuous grant; overnight text is split below.
- Read `~/.config/agents/modules/overnight-mode.md` WHEN explicit unattended grant or EVERY grant turn-end; also load claim/lifecycle modules.
- Read `~/.config/agents/modules/notion-claim-protocol.md` WHEN Agent Tasks/voidpet-poc work or frontier claims; read Linear for shared bus/takeover rules.
- Read `~/.config/agents/modules/runtime-claude.md` WHEN Claude session start or Agent/Workflow/remote launch; wrapper details are separate below.
- Read `~/.config/agents/modules/runtime-k3-wrapper.md` WHEN explicit k3 launch/troubleshooting or any vendor-wrapper work (auth/interactive probes).
- Read `~/.config/agents/modules/runtime-codex.md` WHEN Codex session start or native/exec/cloud/Claude-consult routing/accounting.
