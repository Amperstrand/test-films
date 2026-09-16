# 02 — Audience levels: ELI5, ELI junior, ELI senior

## What

One manuscript, three depths.
Every film's summary block carries four layers, top to bottom:
TL;DR, ELI5, ELI-junior-developer, ELI-senior-developer.
A reader stops at their depth and still leaves with a correct,
useful understanding — the progressive-disclosure contract.

## Why

- A reader who knows nothing gets oriented before the questions.
- A junior developer learns the mechanism, not folklore.
- A senior reviewer gets invariants and verbatim spec citations,
  not a retelling.
- An AI agent consuming the film gets all three and can serve each
  audience on request.
- The author gets the real payoff: you cannot fake the shallow layer
  without the deep one being right.
  Comprehension is verified by explanation, not assumed by proximity.

This layering is also the standing gate for consequential actions in
AI-assisted workflows: the requester explains the issue back at ELI5
level (own words, zero jargon) before the action is approved.
The same record doubles as the film's summary block.

## The layer contracts

### Layer 1 — TL;DR

2–3 lines: what was verified, the verdict, the status.
Written last.
If the TL;DR cannot be stated, the film has no story yet.

### Layer 2 — ELI5

At most 5 sentences, zero jargon.
Must answer four things in plain language:

1. What goes wrong (or: what happens, for a happy-path film).
2. Who can trigger it.
3. What is at stake.
4. What the fix does (or: what the system guarantees).

Rules:

- No file names, no identifiers, no protocol message names.
- Analogies allowed; analogies that lie are not.
- Standalone: no "see section X" — a reader who stops here is done.

### Layer 3 — ELI junior developer, with context

Written for a developer who knows the platform basics but has never
read this code path.
Mandatory content:

| Element | Requirement |
|---|---|
| Mechanism chain | Cause → effect with `file:line` anchors |
| Affected class | The exact predicate (e.g., a bit-mask expression), not prose |
| Entry vs trigger asymmetry | What is accepted at entry vs what fires later, when they differ |
| Design tradeoffs | The fix's options INCLUDING rejected alternatives and why |
| Regression surface | What the fix must NOT change — the counter-rails |
| Operational consequences | What operators see, must do, or must stop doing |

Rules:

- Standalone text; pointers become structured evidence entries below
  the answer, not clauses inside it.
- One to four sentences per claim; the "host summary" register.
- Evidence entries carry a concrete result or citation
  (`cell`: a matrix result; `source`: file:line; `lineage`:
  build/test arm), never a bare path.

### Layer 4 — ELI senior developer / tradeoffs and nuances

Bullets, not prose:

- The invariant the behavior must uphold, with a verbatim spec
  citation where one exists (see
  [10-spec-quotes.md](10-spec-quotes.md)).
- Order-of-operations facts that remove deadlock or race classes.
- Cost, scope limits, adjacent behavior discovered, prior-art
  reconciliation.
- What was deliberately NOT traced — honesty about coverage beats
  the appearance of completeness.

## The distributed-systems lens: believes-columns

For multi-party scenarios, the step table in the manuscript carries
one column per participant: **what each participant BELIEVES after
this step**.
The believes-columns are the split-brain lens made visible: two
locally-sensible views that end in different places is the shape of
every hard distributed bug, and the table shows it as a readable row
instead of a log-archaeology session.
See [03-manuscript.md](03-manuscript.md).

## Retraction discipline (binding)

When a claim in any layer is refuted:

1. Retract it where it lives — same doc, same session.
2. Propagate the retraction to EVERY layer and summary carrying the
   claim, not only the correction site.
   The earned failure: a correction landed in an open-questions
   section while the ELI5 and junior summaries still carried the
   retracted sentence a day later — caught only in a pre-publication
   pass.
3. Before publishing or trusting any copy, grep it for every
   known-retracted claim.
4. In records with versioned answers, the refuted text stays visible,
   struck through, with a one-line "why it was wrong" and a
   `replaces:` pointer.
   Honest retractions stay visible; silent edits destroy trust and
   auditability.

## Progressive disclosure in the reel

The rendered film exposes layers in order; deeper layers and evidence
start collapsed.
The reader expands depth on demand; the default view is the layer the
film declares as its audience cut.

## Pitfalls

- ELI5 with jargon smuggled in ("the reconciler invalidates the
  view").
  If a noun is not everyday English, the sentence is not ELI5.
- Junior layer that retells the diff instead of the mechanism.
  The reader can read the diff; they cannot read the omitted context.
- Senior layer without anchors.
  Verbatim quotes and file:line cites are what separate the senior
  layer from an opinion.
- Writing layers out of order.
  Draft deep-first if needed, but FINALIZE shallow-first: if the ELI5
  does not parse cleanly, the understanding is incomplete — go back.

## References

- [templates/layered-summary.md](../templates/layered-summary.md) —
  the fill-in block.
- [03-manuscript.md](03-manuscript.md) — where the block sits in a
  manuscript.
