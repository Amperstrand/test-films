# 01 — Manifesto: films from tests

## What

A test film is a short, self-describing package — manuscript, synced
timeline, footage, voice, overlays — that explains one scenario of a
system under test to a chosen audience depth, produced from a real run
with real evidence.

## Why

Three pressures created this practice:

1. **AI-assisted development changed the review bottleneck.**
   Agents produce changes at a rate where reading diffs is no longer
   the scaling surface. Tests carry the proof burden; films carry the
   comprehension burden. A senior reviewer watches a two-minute film of
   the scenario and knows the shape of the change; a newcomer watches
   the ELI5 cut and oriented themselves without a hand-holding session.
2. **Distributed systems fail between the logs.**
   Each participant's log looks healthy alone.
   The bug lives where two views of the same state machine diverge.
   A film that syncs all views onto one timeline makes the divergence
   visible — to juniors, seniors, and LLMs alike.
3. **Writing at multiple depths forces honesty.**
   You cannot write a correct ELI5 of a mechanism you do not
   understand, and you cannot write the senior layer without verbatim
   spec anchors.
   The discipline of producing all layers is itself a verification
   step — it catches incomplete mental models before they ship.

The pattern earns its keep in the highest-stakes workflow we run:
before any consequential external action, the requesting agent must
explain the issue back in its own words at ELI5 level, with the full
technical layer underneath.
Comprehension is verified, not assumed.
Films are that protocol, made durable.

## The unit: a self-describing run directory

A film is a directory that contains everything needed to re-render and
re-verify the story, with a manifest pinning provenance:

```text
films/<scenario-id>/<run-timestamp>/
├── manifest.json          # tool versions, git SHAs of every system under test,
│                          #   environment fingerprint, schema version
├── manuscript.md          # the scenario page (template: templates/film-manuscript.md)
├── timeline.jsonl         # merged, timestamped narration events from ALL systems
├── lanes/                 # per-actor raw logs and per-actor event streams
├── footage/               # captured video/recordings (retention policy applies)
├── voice/                 # transcript.json (word-level), narration audio if any
├── overlays/              # mermaid sources, step tables, captions, SVG charts
└── index.html             # the reel: self-contained page embedding all of it
```

Rules the directory enforces:

- **Self-describing**: the manifest carries the exact revisions of
  every system that produced the run.
  A film whose pointers float is not a film.
- **Re-renderable**: `index.html` renders from local files only; no
  network dependency, no session that must be replayed.
- **Honest**: every claim in the manuscript links to its evidence in
  `timeline.jsonl` or `footage/`; a checker validates that event names
  mentioned in docs exist in the binaries and that quote refs resolve
  (see 03-manuscript.md and 10-spec-quotes.md).
  Docs that lie are worse than no docs.

## The pipeline at a glance

```text
test suite ──run──▶ evidence (logs, videos, traces, artifacts)
                      │
                      ├─ narration events ──sync──▶ merged timeline ──▶ sequence diagram
                      ├─ footage ──static-prune──▶ kept scenes ──▶ embedded video
                      ├─ transcript (ASR) ──or──▶ synthesized voice ──▶ voice track
                      └─ spec quotes ──verify──▶ anchors
                      │
                   manuscript (3 audience layers)
                      │
                   reel (index.html) ──▶ dashboard / review / training
```

Each stage has a doc in this repo; each arrow has earned lessons
attached.

## What a film is NOT

- **Not a screen recording dump.** Raw footage without manuscript and
  timeline is "message soup" — the exact failure mode of DEBUG-log
  reading that this practice exists to escape.
- **Not a replacement for tests.** Films are downstream of the suite;
  a film can only be as honest as the run that produced it.
- **Not a one-off video file.** The durable artifact is the directory;
  an `.mp4` is a render target, produced when a human wants a
  shareable single file.

## Audience levels

Every film declares its audience cut: ELI5, ELI junior developer, or
ELI senior developer — and the layered-summary format means one
manuscript serves all three (the reader stops at their depth).
The contracts live in [02-audiences.md](02-audiences.md).

## Pitfalls

- Filming everything and cutting nothing.
  Storage and attention both die; the static-scene prune and the
  scenario-per-film rule exist for this.
- Letting the film drift from the run.
  Regenerate the film from the run directory, never hand-edit facts
  into it; the checker must fail on drift.
- Writing the senior layer without the ELI5 layer.
  The shallow layer is where misunderstanding surfaces; skipping it
  removes the practice's built-in comprehension check.

## References

- [02-audiences.md](02-audiences.md) — the layer contracts.
- [03-manuscript.md](03-manuscript.md) — the manuscript pattern.
- [examples/two-party-handshake/](../examples/two-party-handshake/) —
  a complete worked manuscript.
