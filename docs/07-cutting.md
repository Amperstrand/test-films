# 07 — Cutting: segmentation and editing

## What

Cutting turns raw footage + timeline into scenes a viewer can sit
through.
A scene is a bounded segment of the run with one job: answer one
question, show one mechanism, or expose one divergence.

## Why

- Uncut footage is message soup — the exact failure mode cutting
  exists to fix.
- Scenes are the reuse unit: a film for one audience reuses another
  film's scenes with different narration and overlays.
- Cut points derived from the timeline are mechanical and
  reproducible; cut points chosen by hand in an editor are neither.

## Where cut points come from (in priority order)

1. **Narration events.**
   Every phase entry / dispatch branch / park/resume / abort in the
   merged timeline is a natural scene boundary (see
   [04-sync.md](04-sync.md)).
2. **Question anchors.**
   When the source is dialogue (a review workshop, a recorded design
   call), segment on the questions: detect the question list, anchor
   each scene to the span where that question is worked, then
   rebalance interleaved spans back to their owning question.
   The proven pattern for IRC/workshop-style logs:
   fingerprint-normalized text matching of question text against the
   log, host-speaker detection, and a rebalance pass that assigns
   interleaved fragments to the nearest preceding anchor.
3. **Divergence boundaries.**
   For bug films: the scene cuts at the first divergent event and at
   its resolution — the viewer watches the split-brain open and
   close.
4. **Static spans.**
   The prune from [06-footage.md](06-footage.md) at scene
   granularity: a static span inside an otherwise live scene becomes
   a time-compression, not a deletion (the viewer must trust that
   time passed).

## Scene grammar

```text
scene:
  id:           S0.4            # scenario.step
  span:         timeline events [ev-112 .. ev-127]
  footage:      footage/raw/<clip>.webm  (time-coded subrange)
  narration:    voice/s0.4.<voice>.<ext> (per-scene clip, see 05-voice.md)
  question:     one sentence this scene answers
  layers:       which manuscript lines it evidences
  overlays:     overlays/s0.4.*  (see 08-overlays.md)
```

Rules:

- One question per scene.
  If a scene answers two, it is two scenes.
- Every scene cites its timeline span.
  A scene that cannot cite its span is an animation, not footage —
  fine for teaching, but it must be LABELED as synthetic in the reel.
- Keep raw spans intact in the directory even when the cut drops
  them.
  The cut is a view; the footage is the record.

## Editing rules (earned)

1. **Regenerate, never hand-edit.**
   The cut list is generated from the timeline into a declarative
   scene list; the reel renders from the scene list.
   Hand-edited reels drift from runs and rot.
2. **Retraction propagates through cuts.**
   When a manuscript claim is retracted (see
   [02-audiences.md](02-audiences.md)), every scene whose
   `question` or `layers` cites it must be re-derived.
   Grep the scene list for retracted claim ids before publishing.
3. **The A/B cut for fix films.**
   Film the stock arm and the fix arm from the SAME scenario
   manuscript; cut them as parallel scenes with matching spans.
   Viewers compare behavior, not production values.
4. **Time-compression is labeled.**
   Any speed-up or elision carries an overlay badge
   ("7 min elapsed").
   Films that hide cuts lose the trust that makes them evidence.
5. **Junior cuts show the state machine; senior cuts show the
   invariants.**
   Same footage, different overlay emphasis and narration depth —
   the audience layers apply to cutting, not only to text.

## Reels

The reel (`index.html`) is generated from the scene list + overlays +
voice manifest:

- self-contained (local assets, inline SVG, no network);
- progressive disclosure on depth layers;
- per-scene citation footer: span, run manifest, spec-quote anchors;
- an "evidence mode" toggle that swaps narration for the raw
  timeline lane of the current span — the reviewer's view.

## Pitfalls

- Cutting before the manuscript exists — scenes without questions
  become highlight reels; the film stops teaching.
- Overlapping spans in one reel — parallel A/B scenes cite DIFFERENT
  runs (each with its own manifest); never overlap spans within one
  run's cut.
- Deleting "boring" raw spans — boring is evidence of the happy path;
  compress, cite, keep.
- Letting the editor become a dependency — everything the reel needs
  must regenerate from text (scene lists, mermaid sources, voice
  manifest) in CI.

## References

- [03-manuscript.md](03-manuscript.md) — scenes cite manuscript lines.
- [05-voice.md](05-voice.md) — per-scene narration clips.
- [08-overlays.md](08-overlays.md) — what renders on top of the cut.
