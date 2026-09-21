## Human QA intake threads (cross-substrate, 2026-07-29)

When a human is doing hands-on QA/review (release QA day, design review, exploratory testing), their findings flow through ONE intake thread — the comment thread of the gating issue itself (or a dedicated intake issue when no single gate exists), marked with the substrate's `qa-intake` label so directors and the sentinel can find active threads mechanically. Division of labor is asymmetric BY DESIGN — the human stays in flow, agents do all structuring:

- **Human side: one comment per finding, zero ceremony.** A sentence plus a pasted screenshot/recording is the ideal unit; no severity, formatting, or repro steps required. Annotated screenshots beat prose (attachments are agent-readable). Optional: cite a state/gallery ID when one exists for exact reproduction — never at the cost of flow.
- **Agent side: every human comment gets a DISPOSITION REPLY** from a director — `→ filed <ISSUE-ID>` (properly specced issue; fix PR linked back when it lands), `→ by design (reason)`, or `→ needs one detail: <question>`. Sweeping active intake threads is part of every session-start sweep, and the stall sentinel flags unswept comments (a few hours old) in its digest — an unswept finding is a protocol miss, same class as an unanswered BLOCKED.
- **Gating findings re-block append-only:** a finding serious enough to re-block a gated release is added as a NEW blocker of the gate issue — released nodes are never reopened (compilation release semantics apply).
- Money/auth findings fast-track per the review section; label hygiene: `qa-intake` comes OFF when the QA effort closes, so the sweep set stays small.

