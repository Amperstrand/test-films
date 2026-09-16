# Film manuscript — `<SCENARIO-ID>`

<!-- Copy to films/<scenario-id>/manuscript.md and fill every
     <<PLACEHOLDER>>. Delete this comment block when done. -->

## Layered summary

<!-- Follows docs/02-audiences.md. Layers finalize shallow-first. -->

**TL;DR**: <<2–3 lines: what the scenario shows, the verdict, the
status.>>

**ELI5**: <<≤5 sentences, zero jargon: what happens, who can trigger
it, what is at stake, what the system guarantees.>>

**ELI junior developer**: <<Mechanism chain with file:line anchors;
the exact affected class as a predicate; entry-vs-trigger asymmetry
if any; design tradeoffs including rejected alternatives; the
regression surface (what must NOT change); operational
consequences.>>

**ELI senior developer / tradeoffs**:

- Invariant: <<the behavior must uphold — with a verbatim quote id
  where one exists (Q-id from the quote pack)>>.
- Ordering fact: <<order-of-operations constraints that remove
  deadlock/race classes>>.
- <<Cost, scope limits, adjacent behavior, prior-art
  reconciliation>>.
- Not traced: <<what this film deliberately does not cover>>.

## Sequence diagram

<!-- GENERATED from the merged timeline when a run exists
     (04-sync.md); hand-drawn only for planned scenarios. Mark
     which. -->

Source: <<generated | hand-drawn>>

```mermaid
sequenceDiagram
    participant A as <<role A>>
    participant B as <<role B>>
    Note over A,B: <<PHASE>>
    A->>B: <<message/action>>
    Note over A,B: <<PHASE>>
    B-->>A: <<response>>
    alt <<deviation name>>
        <<stock arm>>
    else <<fixed arm>>
        <<behavior>>
    end
```

## Step table

| # | who→who | message/action | A believes | B believes | narration | can go wrong |
|---|---|---|---|---|---|---|
| 1 | <<A→B>> | <<action>> | <<belief>> | <<belief>> | <<event or —>> | <<W-item / scenario ref>> |
| 2 | <<…>> | | | | | |

## Narration vocabulary

| Event | Emitted at | Meaning |
|---|---|---|
| <<event_name>> | <<site>> | <<decision it narrates>> |

## Evidence

| Kind | Label | Locator |
|---|---|---|
| <<cell \| source \| lineage>> | <<concrete result>> | <<run + path / file:line>> |
| transcript | <<range>> | <<voice/segments.json @ mm:ss–mm:ss>> |

## Run manifest

- Run: <<run-id>@<timestamp>>
- Systems: <<component>> @ <<git SHA>>
- Tools: <<tool + version list>>
- Corpus pins: <<quote-pack pins>>
