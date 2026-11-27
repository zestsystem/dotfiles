---
name: design-duel
description: Iterate a design against the best real-world example of the same thing until it wins, using a design canvas, rendered captures and rounds of fresh-context judges. Platform agnostic — marketing pages, web app screens, iOS/Android flows, onboarding, pricing, dashboards. Use when someone wants a surface to be "better than X", "best in class", "beat the competition", a redesign that needs real depth, or when one or two design passes have plateaued. Triggers on: beat competitor, better than, best in class, benchmark design, design duel, iterate until it wins, judge the design, compare against Mobbin, redesign landing page, redesign onboarding, redesign app screen.
---

# Design duel

One or two design passes produce a competent page. Depth comes from many rounds against a real opponent: put the design next to the best existing example of the same surface, have fresh judges score both blind, fix what they find, and repeat. Fifteen rounds is normal. Each round costs little; the result is a design no single pass reaches.

The loop: **requirements ledger → pick the opponent → audit → canvas → capture → judge → fix → repeat**, then hand the winning board to the build as the acceptance spec.

The opponent is a source of craft, not of scope. Copying a better-looking flow that drops a state, a rule or a pathway is a regression, however well it scores.

## 0. Requirements ledger (before any design)

Build the list of what the surface must keep, from the code, specs, tests and the owner's decisions, not from the current board:

- **Pathways**: every way into, through and out of the surface (signed in/out, first time/returning, each role, each platform, deep links, back/cancel, errors and retries).
- **States**: every state the code can render (loading, empty, partial, error, closed, sold out, pending, done) and what triggers each.
- **Rules**: product and copy rules the owner set (what may be called done, what blocks, what must never appear), each with where it lives in the code.
- **Data and edge cases**: limits, counts, permissions, locales, long names.

Each row cites its source (file:line, spec, or the owner's words). Publish it with the audit. The ledger is fixed for the duel; adding a row needs a source, and removing one needs the owner's yes.

## 1. Pick the opponent

The opponent is the strongest real example of the *same surface for the same buyer*, not the most famous product.

- **Mobbin first** when the Mobbin tools are available: search sections, screens and flows for the surface type (e.g. "pricing", "onboarding", "event ticketing landing") on the target platform (web, iOS, Android). Shortlist 3–5, pick the one a judge would call best in class.
- **Direct competitors**: capture their live page or app. A competitor that's winning in the market is often a better opponent than a beautiful but unrelated site.
- Capture the opponent once, at the same viewports you'll capture your design, and **never change the opponent's captures mid-duel**. Its score moving while its pixels didn't is your noise floor (see §6).

## 2. Audit

Score your current surface and the opponent on a weighted rubric before designing anything. A good default for marketing surfaces (weights sum to 100):

| Criterion | Weight |
|---|---|
| Clear positioning | 10 |
| Speaks to the buyer (the person who pays) | 10 |
| First screen | 10 |
| Proof and credibility | 15 |
| Shows the real product | 10 |
| Range of offering | 10 |
| Pricing clarity (clarity, not which fee is lower) | 10 |
| Distinct visual identity | 10 |
| Phone experience | 5 |
| Copy quality | 5 |
| Internal consistency | 5 |

The ledger is a separate pass/fail gate, never a weighted criterion: a round that drops or contradicts a ledger row fails, whatever it scores.

For app screens, swap in task-based criteria (time to first success, error recovery, density vs clarity, platform conventions, accessibility). Keep the rubric fixed for the whole duel. Publish the audit as a page the person can share, and add a row per round.

## 3. Build on a canvas

Work on a design canvas (a Claude Design artifact when available), with one artboard per platform/viewport: desktop 1440, phone 390, plus app screens at device size.

- **Real everything.** The product's live tokens and type, real screenshots or faithful recreations of real screens, real data, real names. Placeholder content teaches the judges nothing.
- **Faithful product UI.** Recreate app screens (brackets, checkouts, editors) at real fidelity, not simplified icons. Judges reward seeing the actual product.
- Load the house design and writing skills (unslop design and writing, marketing pages, UI polish) before each big change.

## 4. Capture

Judges score pixels, not markup. Render every artboard and capture it viewport by viewport:

- **Web / canvas boards**: `scripts/render-dc.mjs` turns a `.dc.html` artboard into static HTML (pass a JSON map of asset ids to local files). `scripts/scroll-shots.mjs <url> <prefix> <width> <height> [mobile]` takes one JPEG per viewport with headless Chrome (`CHROME_BIN` overrides the path).
- **Native app screens**: capture from the simulator/emulator, or render the canvas artboard at device size.
- Name captures `A-<platform>-NN.jpg` (opponent) and `B-<platform>-NN.jpg` (yours). Each round overwrites B; A never changes.

## 5. Judge

Use fresh-context judges, never the session that designed the board.

- **At least two judges per round.** One judge swings ±3–5 points on an unchanged page.
- Blind labels: "Page A" and "Page B". The brief describes what each page is for, the rubric, and the capture paths. It never says which one is ours or what we hope.
- Same brief every round. Ask for: the rubric table with scores and deciding evidence (capture file names), weighted totals, the top 6 fixes for B with the criterion each moves, and where B already wins.
- Start from `templates/judge-brief.md`.

## 6. Read the scores honestly

- **Noise floor**: the spread of the opponent's score across judges and rounds while its captures stayed fixed. Gaps inside it are ties. Say "tied" when it's a tie.
- **Brief changes need a control.** If you change the rubric or brief mid-duel (e.g. "score pricing on clarity, not on which fee is lower"), rerun the latest round under both briefs and report both. Otherwise the opponent's score moving looks like progress.
- Judges score relatively: as your page improves, the opponent may drop a little. That is not a reason to trust the drop.
- Track every round in the audit page: round, your score, opponent score, what changed.

## 7. Fix, with two filters

Apply the judges' fixes in priority order, but run each through two filters:

1. **True to the product.** Catch obvious mistakes: invented features, wrong role names, miscounted numbers, unconsented quotes or photos. Claim real capabilities at full strength even when usage is thin. A truth pass that only subtracts makes the product sound smaller than it is; the goal is credible *and* appealing.
2. **The owner's judgment wins.** Judges converge on safe, generic advice ("lead with the payer", "add a money number"). Hold a decision the owner made unless the evidence clearly says otherwise, and test risky structural changes as a separate artboard rather than replacing the approved one.

Lessons that recur:
- Never name or reference the opponent on your surface.
- Only show a number if it impresses. A small money total anchors you as small and leaks revenue; usage counts with no public baseline (passes scanned, battles run) read bigger.
- Combine thin proof points (one organizer's three events beats three tiny cards).
- Candid, on-topic photos can beat polished ones; ask each quoted person for consent and their preferred photo at the same time.
- Remove a qualifier that points out concentration ("including X" when X is most of the number).
- Real counts come from the production database with test, rehearsal and fraud rows excluded.

3. **The ledger holds.** Before applying a fix, check it against every ledger row. A fix borrowed from the opponent that removes a pathway, state or rule is rejected or redesigned to keep it. After each round, walk the ledger against the artboards and mark each row covered (with the artboard) or missing. A missing row blocks the next round.

## 8. Know when to stop

Stop when the last two rounds are inside the noise floor and the judges' remaining asks need things only people can supply (quotes, consent, real data, a product feature). More rounds won't separate the designs; the build will (real components render sharper than any board). Say so plainly, then:

## 9. Hand off to the build

Package a reference pack: the ledger with every row mapped to an artboard (and to a test in the build), the final artboards, their static renders, the captures, and every asset under a readable name. The board is the acceptance spec. Build in sections against it, compare rendered output side by side at every viewport, and keep a list of new copy for sign-off before translation.
