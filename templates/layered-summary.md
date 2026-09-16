# Layered summary block

<!-- The fill-in for the summary block of any film, record, or
     answer card. Follows docs/02-audiences.md. Layers finalize
     shallow-first. Delete this comment when done. -->

**TL;DR**: <<what was verified / what happens · verdict · status —
2–3 lines, written last>>

**ELI5**: <<≤5 sentences, zero jargon.

1. What goes wrong (or happens on the happy path).
2. Who can trigger it.
3. What is at stake.
4. What the fix does / the system guarantees.>>

**ELI junior developer, with context**:

- Mechanism: <<cause → effect chain with file:line anchors>>
- Affected class: <<exact predicate, e.g. a mask expression — not
  prose>>
- Entry vs trigger: <<accepted at entry but fires later? state the
  asymmetry; else "symmetric">>
- Tradeoffs: <<chosen design INCLUDING rejected alternatives and
  why>>
- Regression surface: <<what this must NOT change — the
  counter-rails>>
- Operations: <<what operators see / must do / must stop doing>>

**ELI senior developer / tradeoffs and nuances**:

- Invariant: <<…>> (quote: <<Q-id>>)
- Ordering: <<…>>
- Cost/scope: <<…>>
- Not traced: <<honest coverage limits>>

Evidence (structured, concrete results — never bare paths):

| Kind | Label | Locator |
|---|---|---|
| <<cell>> | <<result>> | <<run + path>> |
| <<source>> | <<claim>> | <<file:line>> |
| <<lineage>> | <<arm>> | <<build/test id>> |

Retractions: <<none | struck-through claim + replaces-pointer + why
it was wrong — visible, never silently edited>>
