---
name: model-eval
description: Run the frozen new-model eval battery (screen a newly released model against the incumbent lanes) the same way every time, in any repo. Use when Mike says a new model dropped and asks to test, compare, benchmark, bake off or screen it ("test Neon vs Opus", "is model X better", "run the battery"), or asks to rerun or extend an earlier model screen.
---

# Model eval battery

The battery is reproducible because it lives on disk, not in a chat. Everything that defines a run (pinned SHAs, briefs,
answer keys, harness scripts, judge rubric, results) lives machine-local in `~/.claude/model-eval/`. This skill is procedure
only. Never copy task content, answer keys or results into this file: it syncs to a public repo.

## Before anything else
1. Read `~/.claude/model-eval/BATTERY.md` (axes, task classes, history), then the newest round's `SPEC.md`
   (e.g. `neon-v2/`) and the `opus55-exec/` scripts it reuses.
2. **Conflict of interest.** Check whether your own model is ANY arm, the baseline included (Fable is an arm whenever
   the baseline runs). If it is, DRAFT the spec only and tell Mike a model that is not an arm must direct. Every director
   runs blind: a launcher writes the arms under random labels and the mapping stays sealed until all judging is saved.
   An arm's model never grades.
3. A new model or a new repo means a new round directory with its own `SPEC.md`, written and sha256-recorded BEFORE arm 1.
   Never edit a frozen spec. Put deviations in that round's `RESULTS.md` with a reason.

## Judges come from vendors with no arm in the round
Check which vendors' subscriptions are live at run time; don't assume a lane still exists. Pick neutral judges from the
remaining vendors with no arm in the round, and use judges from an arm's vendor only as a measured bias probe. If just one
neutral judge is available, say the headline is weaker. Tag every grade with the panel that produced it, and never blend
grades across panels.

## Decisions only Mike makes (ask once, up front)
Which vendor/model is meant. Whether each repo's code may go to that vendor, and on which account. How the model gets
installed and signed in (Mike does every login). Whether the fixed Fable baseline arm runs. Any budget beyond the stopping
thresholds.

## Non-negotiables every round
- Identical brief bytes per unit across arms. Pinned effort per arm, with the pairing rule written down.
- Instruction parity probe: each arm lists the instruction files it loaded. Report results as LANE (model + harness)
  comparisons.
- Contamination control: sanitized clones at the base SHA, with no remote and no later refs, outside the agent-memory
  paths. Grep every transcript for answer-key, memory or log reads.
- Units are selected mechanically from merged work, and every candidate is recorded with its reason.
- Account preflight before every billed launch, using the CLI's own identity. Stop on a wrong identity.
- Blind multi-judge panel: vendor-neutral judges set the headline score. Home-vendor judges run as a measured bias probe.
  Where judges disagree by >1 grade, adjudicate on evidence. Mike's blind review board is the visual/UX taste score.
- Every run is a result: failed, refused, capped and contaminated runs are listed, never dropped.
- Screen ≠ adoption. Routing changes need ~3 graded production results plus the fresh-context challenge. Draft protocol
  changes, never apply them.

## Running it in another repo
Run each repo's round from a session in that repo, on that repo's account homes, against the same frozen SPEC.md. Results
from every repo go into the same round directory, split by repo.
