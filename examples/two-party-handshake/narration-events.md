# Narration events — two-party handshake example

The producer/consumer contract for the S0 film
(docs/04-sync.md applied to the worked example).

## Producer sites (one line per load-bearing decision)

```c
/* First site carries the consumer contract:
 * eaten by tools/merge_timeline.py (vocabulary: NARRATE-2) */
status_debug("NARRATE ev=round_accept round=%s mode=%s "
             "terms_ok=%d", ...);
```

Both participants emit the same vocabulary — the timeline merger
keys on `(participant, ts, ev)`.

## Sample merged timeline (R-20260916T1000Z, excerpt)

```jsonl
{"ts": "2026-09-16T10:00:03.112Z", "who": "requester", "ev": "quiesce_send", "round": "r7"}
{"ts": "2026-09-16T10:00:03.140Z", "who": "responder", "ev": "quiesce_recv", "round": "r7"}
{"ts": "2026-09-16T10:00:03.158Z", "who": "responder", "ev": "quiesce_send", "round": "r7"}
{"ts": "2026-09-16T10:00:03.161Z", "who": "requester", "ev": "round_open", "round": "r7", "mode": "append"}
{"ts": "2026-09-16T10:00:03.402Z", "who": "responder", "ev": "round_accept", "round": "r7", "terms_ok": 1}
{"ts": "2026-09-16T10:00:03.715Z", "who": "requester", "ev": "commit_send", "round": "r7", "store_ms": 14}
{"ts": "2026-09-16T10:00:03.980Z", "who": "responder", "ev": "commit_send", "round": "r7", "store_ms": 61}
{"ts": "2026-09-16T10:00:04.101Z", "who": "requester", "ev": "mutual_locked", "round": "r7"}
{"ts": "2026-09-16T10:00:04.104Z", "who": "responder", "ev": "mutual_locked", "round": "r7"}
{"ts": "2026-09-16T10:00:04.220Z", "who": "requester", "ev": "round_close", "round": "r7"}
{"ts": "2026-09-16T10:00:04.221Z", "who": "responder", "ev": "round_close", "round": "r7"}
```

The `store_ms` fields are the persistence-budget evidence the senior
layer cites (14–70 ms measured).

## Divergence classes (what the merger flags on this vocabulary)

| Class | Signature in this vocabulary |
|---|---|
| READER_KILL | responder aborts a round after a benign interleaved message (S4 shape) |
| MISATTRIBUTED_ABORT | `round_abort` with `reason=unknown` while `round` is still held open |
| DIVERGENT_VIEWS | `mutual_locked` on one side, `round_open` on the other, same `round` id |
| ORPHAN_WAIT | `quiesce_send` with no `quiesce_recv` within the bound |
| TOLERATED_STORM | repeated tolerate-path events for one round |
| NO_CONVERGENCE | neither `mutual_locked` nor `round_abort` within the bound |

Exit code = findings count; CI-gateable.

## Legacy parser note

Pre-narration logs (before the vocabulary existed) map onto the same
events: `"pausing for round"` → `quiesce_recv`,
`"terms accepted"` → `round_accept`, `"locked in"` → `mutual_locked`.
Banked historical evidence stays timeline-readable.
