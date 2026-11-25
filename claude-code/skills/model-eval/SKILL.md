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
2. **Impartiality (Mike's rule):** any model may direct or judge, including a model that's in the trial. Act as an
   impartial referee. Keep two cheap safeguards: run blind (a launcher writes arms under random labels; the mapping stays
   sealed until every judge's output is saved), and measure and report each judge's self-preference gap. If you are an
   arm, disclose that in the report.
3. A new model means a new round directory: copy `~/.claude/model-eval/TEMPLATE-SPEC.md` (the reusable formula) to
   `<round>/SPEC.md`, fill it from Mike's answers, and record its sha256 BEFORE arm 1.
   Never edit a frozen spec. Put deviations in that round's `RESULTS.md` with a reason.

## Judges: everyone in the try-out
Every model with an arm in the trial judges, plus any other model available at run time. One vote each, nobody sole. Check
what is actually available at run time; don't assume a lane still exists. Tag every grade with the panel that produced it,
and never blend grades across panels.

## Decisions only Mike makes (ask once, up front)
Which vendor/model is meant. Whether each repo's code may go to that vendor, and on which account. How the model gets
installed and signed in (Mike does every login). Which arms run (including any fixed baseline). Any budget beyond the stopping
thresholds.

## Non-negotiables every round
- Identical brief bytes per unit across arms. Pinned effort per arm, with the pairing rule written down.
- Instruction parity probe: each arm lists the instruction files it loaded. Report results as LANE (model + harness)
  comparisons.
- Contamination control: sanitized clones at the base SHA, with no remote and no later refs, outside the agent-memory
  paths. Grep every transcript for answer-key, memory or log reads.
- Units are selected mechanically from merged work, and every candidate is recorded with its reason.
- Account preflight before every billed launch, using the CLI's own identity. Stop on a wrong identity.
- Blind panel of all judges. The headline is the median of ALL judges. After unsealing, report each judge's
  self-preference gap (its grade for its own arm minus the others' median) and the headline with and without that judge.
  Where judges disagree by >1 grade, adjudicate on evidence. Mike's blind review board is the visual/UX taste score.
- Every run is a result: failed, refused, capped and contaminated runs are listed, never dropped.
- Screen ≠ adoption. Routing changes need ~3 graded production results plus the fresh-context challenge. Draft protocol
  changes, never apply them.

## Dual-director rounds
Mike may run the same round under more than one director. If units.lock already exists, read it
and never reselect units. Write only to your own runs/<director>/ directory, and don't read the other run until both are
complete. Consolidate afterwards: robust = both runs agree; resolve disagreements on evidence; report the director effect
and the run-to-run variance.

## Running it in another repo
Run each repo's round from a session in that repo, on that repo's account homes, against the same frozen SPEC.md. Results
from every repo go into the same round directory, split by repo.
