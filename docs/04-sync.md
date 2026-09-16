# 04 — Sync: filming client/server and distributed systems

## What

Make every system under test "think out loud" with structured
narration events, then merge each participant's event stream into ONE
cross-view timeline.
The merged timeline is the film's spine: it drives the sequence
diagram, the step table, the cut points, and the divergence findings.

## Why

Protocol bugs live where two participants take locally-sensible paths
through the same state machine and end up in different places
(split brain).
Post-mortem log reading fails three ways:

1. Wire-level logs are bookkeeping soup — hundreds of DEBUG lines per
   second; the decision is buried under transport noise.
2. Single-participant reading cannot see divergence — each log looks
   healthy alone.
3. Error messages lie — a bail-out path that clears state makes every
   downstream consumer inherit the lie.

Decision-level narration merged on one timeline fixes all three —
for juniors, seniors, AND LLMs.

## Layer 1: narration (the producer)

At every load-bearing decision, emit ONE structured line at debug
level:

```c
status_debug("NARRATE ev=resume_dispatch txid=%s "
             "send_cs=%d park=%d", ...);
```

Rules of thumb:

- Narrate **decisions and their inputs** (why this branch), not
  messages — the wire log already has the messages.
- The event vocabulary stays small and closed (~10–13 events): phase
  entries, dispatch branches, park/resume, tolerate/abort, terminal
  states.
- `key=value`, greppable with one pattern, timestamped by the existing
  logging pipeline.
  No new transport, no side channel — ordinary CI logs become
  self-documenting.
- Annotate the FIRST narration site in the code with the consumer
  contract: which tool eats these lines.
- A line that does not answer "why did it take/defer/abort this
  branch" gets cut.
  Narrating messages instead of decisions brings the soup back.

## Layer 2: the merger/detector (the consumer)

A small stdlib script (the proven shape is ~150 lines):

1. Parse N participant logs (plus a "driver" lane when a test harness
   is itself a participant).
2. Normalize events — including a **legacy parser** that maps
   pre-narration log lines onto the same events, so ALL banked
   evidence becomes machine-readable retroactively.
3. Merge on timestamps.
4. Flag divergence classes:

| Class | Signature |
|---|---|
| READER_KILL | a participant failed the peer on a benign message (race signature) |
| MISATTRIBUTED_ABORT | abort with a false reason while still holding the state |
| DIVERGENT_VIEWS | same object id, incompatible states across participants |
| ORPHAN_WAIT | one side waits forever for a step the other never emits |
| TOLERATED_STORM | tolerance path firing in a loop |
| NO_CONVERGENCE | neither terminal state reached within the bound |

5. Exit code = findings count → gate-able in CI.
   Any future occurrence of a known bug class self-identifies in
   ordinary logs.
6. `--mermaid` flag: emit the sequence-diagram source for the
   manuscript from the merged timeline.

## Layer 3: trace lanes for richer systems

When the systems emit structured traces (JSONL), the run directory
carries a merged multi-lane trace:

- One lane per actor (including harness/driver and any external
  observer).
- A schema version line and a manifest carrying the exact git
  revisions of every producing binary — traces without provenance are
  anecdotes.
- An LLM-rendered digest of the trace (a Markdown rendering tuned
  for model consumption) living next to the raw JSONL: agents read
  the digest, humans and checkers read the raw lanes, and the digest
  is generated, never hand-edited.
- A Perfetto-compatible export when you want a real timeline UI:
  the open trace viewer renders the same events with zoom, pans, and
  per-track filtering, at zero bespoke-tooling cost.

## Clocks and ordering (earned the hard way)

- **Merge on timestamps requires comparable clocks.** On one host or
  one VM: monotonic per-process stamps plus a wall-clock anchor per
  lane. Across hosts: anchor each lane with an exchange the runner
  performs at run start, and treat cross-host sub-second ordering as
  advisory, not verdict-bearing.
- **Multi-wait assertions consume logs chronologically.** Test
  frameworks keep a monotonic search cursor per log: each wait
  consumes lines forward only, so a line written before the current
  cursor position can never match.
  Sequence multi-wait assertions in the order the system logs them,
  or use one late catch-all check.
- **Attribute log output by mtime and process table, not content.**
  A stale shared log path (overwritten per run) and a stale compiler
  error both read like live evidence.
  `stat` the artifact before believing it describes the run you are
  watching.
- **Gate paths are shared and unserialized.** One gate at a time
  across concurrent sessions; bank a failing gate's evidence
  immediately — the next run destroys the logs.
- **Drivers read their own artifacts.** Never grep a shared symlink
  from a multi-run driver; capture the per-pid runlog.
- **A reap at bound B proves only "slower than B"** — never a stall
  verdict. Timeout exit codes under load or under-sized bounds are
  artifacts, not findings; verdict columns come from the test
  runner's own reported line.

## Regime incomplementarity (the testing doctrine that comes with sync)

A slow loaded box scrambles timing; a quiet fast box delivers
adjacent orderings.
NEITHER regime's coverage contains the other's.
Any "tested" claim on interleaving-sensitive code needs both — best
as an A/B at each isolated commit (stock vs fix), same hour, on both
regimes.

And: banked evidence stays readable.
The legacy parser means the detector runs on the historical corpus,
not just future logs — old bug evidence becomes timeline input
retroactively.

## Pitfalls

- Event vocabulary sprawl — keep it closed; a new event is a
  state-machine change and deserves review.
- Batch-edits with count-without-assert silently skip sites (earned:
  a missing narration line detected only because the healthy-run
  detector flagged a false NO_CONVERGENCE — the layer debugging
  itself; keep that detector on even when "nothing is wrong").
- Merging on wall-clock across hosts and treating the order as
  verdicts (see clocks above).
- Unbounded tolerance loops (surfaced by TOLERATED_STORM) are
  themselves a DoS surface — cap them or explicitly accept with
  rationale.

## References

- [06-footage.md](06-footage.md) — where run directories and lanes
  live on disk.
- [07-cutting.md](07-cutting.md) — cut points come from divergence
  boundaries in this timeline.
- Method lineage worth reading: TCP RFC 793 (state diagram =
  structure, sequence diagram = evolution); XState model-based
  testing (paths through the machine are enumerable); the "message
  soup" abstraction lesson (keep effects, abstract bookkeeping — for
  humans AND LLMs reading traces).
