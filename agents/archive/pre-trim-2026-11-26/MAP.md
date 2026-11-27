# Trim map: 2026-11-26

Every rule in the pre-trim protocol, and where it went. Mike's decisions: T3 Code retired; Notion still used (Voidpet); delegation grading dropped; no hosted review bots on any repo. A GPT-6 Astra (high) challenge of the plan came back adopt-with-changes, and its changes are applied here.

The original files sit next to this one, verbatim. Incident notes (scars) live there and in git history. The new modules keep each rule, not its story.

**Status key**
- **K**: kept (the rule, minus the story)
- **M**: merged into the named module
- **R**: rewritten to match current fact
- **A**: archived (dead, or retired by Mike)

| Old module / kernel section | Rule | → New home | Status |
|---|---|---|---|
| kernel: terms, regime, mode | leaf/solo discriminator, director vs leaf | PROTOCOL.md §Mode | K |
| kernel: ACTIVE REGIME `director`, seats, `default` regime | regime/seat machinery | PROTOCOL.md §Mode (one line); archive | A (seat config stays in model-economics.json) |
| kernel: PRIMARY INTERFACE T3 | T3 detection, settle rule | none | A (Mike: no T3) |
| kernel: delegation-value test | when to delegate vs keep inline | PROTOCOL.md §Delegation | K |
| kernel: consult scorecard + experiments before every delegation | | none | A (grading dropped) |
| kernel: preamble + handoff contract + inline env-deltas | | PROTOCOL.md §Delegation; work-planning | K |
| kernel: pin model AND effort; requested vs observed | | PROTOCOL.md §Delegation; lanes-and-accounts | K (pinning). Requested-vs-observed kept as an honesty rule, without the logging |
| kernel: lane table | 10 rows | PROTOCOL.md §Lanes (5 families); lanes-and-accounts | R (k3/Grok/haiku/opus-4.8 rows → one line each; IDs → model-economics.json) |
| kernel: project account preflight | | PROTOCOL.md §Accounts; lanes-and-accounts | K (T3 mention dropped) |
| kernel: UI routing | | PROTOCOL.md §Lanes; ui | K |
| kernel: Codex down → Claude | | lanes-and-accounts | K |
| kernel: Ultra/fast ban, priority-tier mismatch, cache bomb, escalate one tier | | lanes-and-accounts | K |
| kernel: review ladder, evidence beats votes, blocker dispositions, arch debt | | PROTOCOL.md §Review; review | K |
| kernel: review bots / CodeRabbit wait/escape/defer-review | | review (one generic line) | A (no hosted bots). `just review`/`just land` kept |
| kernel: fan-in, leaf-run, leaf-sweep | | PROTOCOL.md §Execution; work-planning | K |
| kernel: orchestrator hygiene bullets | | PROTOCOL.md §Execution (index); orchestrator-hygiene | K |
| kernel: "Log/grade every delegation… challenge before adopting" | | review (challenge kept) | A (grading) / K (challenge) |
| kernel: director shift, compaction, six-field handoff | | lifecycle | K (still a PILOT: its review is overdue and it's listed under Open for Mike) |
| kernel: claims | | PROTOCOL.md §Claims; claims | K |
| kernel: standing grants G1–G5 | | PROTOCOL.md §Grants | R (G4 drops runner upsizing: the 11-16 no-CI-cost rule) |
| kernel: connector auth notice scar | | lanes-and-accounts | K |
| protocol-origin | public-repo rule, machine-local companions, terms | PROTOCOL.md header | K (scorecard/log listed as optional) |
| regimes-and-seats | delegation-value test, handoff contract | PROTOCOL.md §Delegation | K |
| regimes-and-seats | off-meter weighting, codex default executor, UI carve-out | lanes-and-accounts | K |
| regimes-and-seats | Fable judgment/design-direction lane | lanes-and-accounts; ui | K |
| regimes-and-seats | **architecture judgment rung + 🏛 debt** | review | K (Astra blocker: must not be lost) |
| regimes-and-seats | "independent is a procedure" | review | K |
| regimes-and-seats | seat ladder, occupant notes, `default`/dormant regimes, seat grading strata | none | A |
| regimes-and-seats | weekly Fable adversarial slot, ultrareview retired | review (ultrareview ban kept; weekly slot marked pending) | Pending Mike (a post-merge safety function, not grading) |
| multi-director-and-grok | peer-director formation | lifecycle (grants: 3 lines) | M (shrunk) |
| multi-director-and-grok | Grok formation | none | A (one run in August; Mike-only consult) |
| codex-lanes-and-weekly-limits | Sol executor scope, effort per task class | lanes-and-accounts | K |
| codex-lanes-and-weekly-limits | catalog facts ("no gpt-6-sol/luna", 5.5 retirement) | lanes-and-accounts → "check ~/.codex/models_cache.json" | R (catalog now lists gpt-6.1-sol, gpt-6-sol, gpt-6-luna) |
| codex-lanes-and-weekly-limits | lane-generation screen data, Astra multiplier estimates | none | A (grading evidence) |
| codex-lanes-and-weekly-limits | account homes; weekly-limit playbook; codex-down; Astra effort; Astra severity flattening | lanes-and-accounts; review | K |
| codex-lanes-and-weekly-limits | stop-point handoff contract; leaf nesting limits; Ultra/fast ban; priority-tier mismatch | lanes-and-accounts; work-planning | K |
| codex-lanes-and-weekly-limits | k3 lane | lanes-and-accounts (one line) | M |
| claude-lanes-and-economics | fable-low default UI, opus fallback, account scoping, persistent homes, `-p` cache-write bomb | lanes-and-accounts | K (calibration and evidence numbers archived) |
| claude-lanes-and-economics | sonnet/haiku/opus/fable roles, escalate one tier, folklore rule | lanes-and-accounts | K |
| claude-lanes-and-economics | new-model screening battery | lanes-and-accounts (one line) | K |
| runtime-k3-wrapper | k3 wrapper mechanics | lanes-and-accounts (in-session model-pin no-op warning + pointer) | A (except the warning) |
| runtime-k3-wrapper | **AUTH_TOKEN vs API_KEY trap; scrub inherited CLAUDE_*/ANTHROPIC_* env; interactive path ≠ headless probe** | lanes-and-accounts §Vendor wrappers | K (Astra: generic to any wrapper) |
| runtime-t3 | everything | none | A |
| execution-substrates | local/remote/box, route-remote criteria, never-remote, login mortality, remote spec discipline, fingerprint | host-and-ci | K |
| execution-substrates | T3 host section | none | A (the leaf-run account-guard facts move to lanes-and-accounts) |
| execution-substrates | headroom gate / heavy-gate | host-and-ci | R ("one at a time" → "slots per heavy-gate.conf"; CI overflow limited by local-first) |
| qa-resource-lifecycle | teardown duty, orphan sweep, create-implies-delete, docker health probe (no `timeout`) | host-and-ci | K |
| (memory 11-16, 11-18) | local Mac first; no CI cost increase; deploys local first | host-and-ci | NEW (promoted from memory) |
| handoff-and-decomposition | pin, keep-in-director list, fake-edge, pre-flight constraints, preamble, inline-rules, diagnosis-as-hypothesis, env-deltas, sequential writers | work-planning | K |
| handoff-and-decomposition | role dossiers | work-planning (one line) | K |
| work-compilation | the whole compile pipeline | work-planning §Epics (condensed) | K (scorecard/experiment routing clause removed) |
| fan-in-and-ledger | fan-in guard, leaf ledger, leaf-run stdin | work-planning | K |
| review-ladder-and-automation | 4 rungs, money/auth exception, dual controls, panel, evidence beats votes, blocker dispositions, scar-to-gate, surgical e2e, green-to-skill, bounded loop, recurring jobs | review; orchestrator-hygiene | K |
| adversarial-pair | the pair, selection bar, verification reviewer | review | R ("iterate until clean" → "repair and re-verify within the loop cap": Astra blocker) |
| review-bots | `just review` mechanism + reviewer isolation | review | K (Astra: isolation is an explicit requirement) |
| review-bots | CodeRabbit mechanics, defer-review/drain-review, grandfather window | none | A |
| review-bots | never-ignored dispositions | review (any reviewer) | K |
| ui-fidelity-and-verification | quality bar, fidelity gate, UI verification chain, 🖍 debt | ui | K (weekly-slot debt routing simplified) |
| (memory) | Emil skills for every UI task; Today-vs-Proposed first | ui | NEW (promoted from memory) |
| linear-claim-protocol | labels, claim, write-set, race, main-breakage, tracker-down markers, bus, takeover, sweep, stall prevention, grant liveness | claims | K |
| notion-claim-protocol | everything | claims §Notion | K |
| qa-intake | everything | qa-intake | K |
| overnight-mode | grant scope, global frontier, wake chain, host survival, authority unchanged, morning report | lifecycle | K ("delegation-log + scorecard entries" removed from the morning report) |
| director-lifecycle | shift end, compaction, preflight, context telemetry, grant precedence | lifecycle | K |
| orchestrator-hygiene | all bullets + release trains/freeze/checkpoint | orchestrator-hygiene | K |
| grading-experiments-and-rule-challenge | grading, scorecard, experiments, director grading, review rubric | none | A (Mike: drop grading) |
| grading-experiments-and-rule-challenge | **fresh-context challenge before significant protocol/routing/authority/review changes** | review §Changing this protocol | K |
| grading-experiments-and-rule-challenge | rule-challenge ritual | PROTOCOL.md §Keeping it short | R (quarterly review with Mike; no auto-archive) |
| runtime-claude | Agent pinning, use-codex, codex stdin, cloud-agent mechanics | runtime-claude | K |
| runtime-codex | modes, native agents, exec, cloud, permitted Claude calls, fork inheritance | runtime-codex | K (the "no implementation hand-offs" vs UI-worker contradiction resolved; grading lines removed) |

## Open for Mike (added by the trim, not decided)
1. The `director_seat.current` in model-economics.json says `opus-5`, but sessions run on Opus 5.5.
2. The Codex catalog now has `gpt-6.1-sol`, `gpt-6-sol`, `gpt-6.1-terra` and `gpt-6-luna`. Should the executor lane move off `gpt-5.6-sol`?
3. The compaction pilot (600K window) was due for review on 10-06. Is it now standing policy, or should it be re-reviewed?
4. Codex `service_tier = "priority"` vs the fast-mode ban: still unresolved since 09-05.
5. The Linear token location (Doppler project `linear`) after the Doppler removal.
6. The weekly post-merge Fable adversarial review: it continues as before until you decide whether to keep or retire it.
7. The standing grants G1–G5 stay in the kernel (Astra nit: move their conditions to a module and keep a pointer). Left in place because they are authority.
