# 03 — The manuscript

## What

One scenario, one page, four artifacts:
a rendered sequence diagram, a step table with believes-columns, the
audience-layer walkthroughs, and the narration vocabulary the scenario
emits.
The manuscript is the film's script; the run directory is its evidence.

## Why

A test proves a scenario happens.
A manuscript makes the scenario teachable, reviewable, and checkable:
teachable because the layered walkthroughs serve every depth;
reviewable because the diagram shows the shape at a glance;
checkable because a validator can confirm the page tells the truth
about the binary and the spec.

## Scenario grammar

Name scenarios `S<N>-<slug>.md`, deviating ONE variable per scenario
from the baseline:

```text
S0-happy-path.md          the baseline every other scenario deviates from
S1-crash-before-wire.md   deviation: crash at a specific step
S2-misabort.md            deviation: abort with wrong reason
S3-park-and-resume.md     deviation: state parked, later resumed
S4-message-race.md        deviation: benign interleaving lands mid-flow
S5-double-delivery.md     deviation: duplicate arrival
...
```

Rules:

- S0 exists and is filmed first.
  Every other scenario is defined by its delta from S0.
- One deviation per scenario.
  Two deviations in one page is two films stapled together; nobody
  learns either.
- The "can go wrong" column of S0's step table seeds the scenario
  list: each W-item pointing at a scenario is the review trail.

## Artifact 1: the sequence diagram (mermaid)

Mermaid `sequenceDiagram` renders natively on GitHub and every
mainstream Markdown surface — no build step, no images to keep in
sync.

Rules:

- One participant per system role (including "chain" or "time" when
  the outside world is a party).
- `Note over` blocks mark protocol PHASES — the state-machine
  superstructure a reader needs before any message detail.
- `alt` blocks show stock-vs-fixed behavior for bug films: the fixed
  arm inside the `alt`, the deviation made visual.
- The diagram is GENERATED from the merged timeline when a real run
  exists (see [04-sync.md](04-sync.md)), and hand-drawn only for
  planned scenarios not yet filmed.
  A generated diagram cannot disagree with the run; a hand-drawn one
  can.

## Artifact 2: the step table with believes-columns

| # | who→who | message/action | A believes | B believes | narration | can go wrong |
|---|---|---|---|---|---|---|

- `A believes` / `B believes` (one column per participant): the
  split-brain lens.
  After each step, what does each party now hold to be true?
- `narration`: which narration event the step emits (the closed
  vocabulary from [04-sync.md](04-sync.md)); `—` when the step is
  pure wire bookkeeping.
- `can go wrong`: pointer to the scenario page that films that
  failure (W-items).
  An empty cell is fine; a missing scenario for a named W-item is a
  backlog entry, not silence.

## Artifact 3: the audience layers

The layered-summary block (see [02-audiences.md](02-audiences.md))
sits in the manuscript:
junior walkthrough (no priors; tells the story of the table above),
senior notes (invariants, verbatim spec citations, order-of-operations
facts), and for bug films the ELI5 of the bug.

## Artifact 4: the narration vocabulary

The page lists the narration events each step emits, closing the loop
to live observability:
a reader can grep a live system log for the vocabulary and watch the
scenario happen in production-shaped form.
The vocabulary is closed and small (~10–13 events — phase entries,
dispatch branches, park/resume, tolerate/abort, terminal states);
a new event is a state-machine change and deserves review, not a
drive-by addition.

## Enumeration: prove the space, don't sample it

When the failure class is interleavings of benign messages at a
receiver, the input space is small and finite — enumerate it
exhaustively instead of writing one representative test:

```text
alphabet {A=announce, C=confirm}, all sequences ≤4, then the real
message: every ordering must converge; any foreign message anywhere
must still fail cleanly.
```

The law this enforces is **tolerance composition**:
`tolerate(x); tolerate(y)` is not `tolerate(x|y)*`.
Two sequential one-shot tolerances pass every sampled test and die on
the first real interleaving.
The enumerated suite plus its film is the proof that the space, not a
sample, was covered.

## Doc honesty: the manuscript checker

A script validates every manuscript page:

1. Every narration event named in the page exists in the built
   binary/manifest vocabulary.
2. Every spec citation resolves in the pinned spec corpus
   (see [10-spec-quotes.md](10-spec-quotes.md)).
3. Every W-item in a step table points at an existing scenario page
   or a tracked backlog entry.

The checker runs in CI next to the spec-quote gate.
A page that fails is a finding, never a warning to silence.

## Deriving manuscripts from an existing suite

1. Pick the test whose name tells the best story (or the bug whose
   fix deserves a record).
2. Run it with narration and capture on (see
   [06-footage.md](06-footage.md)).
3. Generate the sequence diagram and step-table skeleton from the
   timeline.
4. Write the layers by hand — the generation stops at facts; the
   walkthroughs are authorship.
5. Fill `can go wrong` from the failure scenarios you know; film the
   ones you do not.

## Pitfalls

- Diagrams that show messages but not phases.
  The phase `Note over` blocks are how a junior builds the state
  machine in their head; message lists alone are soup.
- Believes-columns filled with implementation detail
  ("parsed frame 47").
  Beliefs are protocol-level truths ("round open", "both quiesced").
- Scenario sprawl.
  If S12 exists and nobody can name its single deviation from S0,
  delete or merge it.
- Hand-editing a generated diagram.
  Fix the generator or the narration; otherwise the diagram drifts
  from every future run.

## References

- [templates/film-manuscript.md](../templates/film-manuscript.md)
- [examples/two-party-handshake/manuscript.md](../examples/two-party-handshake/manuscript.md)
- [04-sync.md](04-sync.md) — where the diagram source comes from.
