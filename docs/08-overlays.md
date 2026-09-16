# 08 — Overlays: diagrams, captions, report pages

## What

Overlays are every piece of rendered context that sits on top of or
next to the footage: sequence diagrams, step tables, state diagrams,
captions, charts, and the report page that embeds them all.

## Why

Footage shows WHAT happened; overlays explain WHY, in reading order,
at the viewer's depth.
They are also the cheapest surface to keep honest: text and generated
diagrams can be validated mechanically, pixels cannot.

## The overlay kit (proven set)

| Overlay | Renders where | Generated from |
|---|---|---|
| Sequence diagram | Native on GitHub-class Markdown (mermaid) | Merged timeline (`--mermaid`) |
| Step table with believes-columns | Markdown table | Timeline + manuscript authorship |
| State diagram | Mermaid `stateDiagram-v2` | The narration vocabulary itself |
| Captions/subtitles | Player (WebVTT/SRT) | Word-level transcript timestamps |
| Charts (distributions, box plots) | Inline SVG in a self-contained HTML page | Run metrics |
| Screenshots with state lines | Report page | Auto-capture + machine-readable UI state |
| The reel | `index.html`, offline-capable | Scene list + overlay manifest |

Rules:

- **Prefer native rendering.**
  Mermaid renders on the hosting surface with no build step; SVG
  inline in HTML needs no image pipeline; both survive repo moves.
  Binary overlay formats (PNG of a diagram) rot when the source
  rot is invisible.
- **Every chart carries its generator** (script + input data path in
  the run directory).
  A chart that cannot be regenerated is a decoration.
- **Pair screenshots with machine state.**
  Every captured image stores the state-machine value of the UI at
  capture time; the film checker validates image↔state agreement,
  and dashboards group on the state field.

## The report page (self-contained HTML)

For dashboards and standalone reels, the proven shape is a
single-file HTML page:

- Inline SVG for charts (no JS chart framework required).
- Assets embedded (base64) up to a size cap; beyond the cap, link
  to the content-addressed blob (see [06-footage.md](06-footage.md)).
- File entries labeled with MIME type — bare hash URLs carry no
  extension, and `video/webm` vs `application/octet-stream` is the
  difference between a playable film and a download button.
- A manifest line on the page: run id, commit, timestamp, tool
  versions.

## Injecting into existing dashboards

When a dashboard already exists, films integrate as data, not as
screens:

1. The run publishes its structured index (JSON) with:
   `run_id`, `timestamp`, `passed`/`failed`/`skipped`/`total`
   counts, and a `files` array where every entry has `path`, `url`,
   `sha256`, `mime`, `size`.
2. A `summary.json` entry provides per-test grouping (name, outcome,
   runner, duration) so the dashboard hierarchies group footage by
   test.
3. The dashboard fetches indexes and renders; the film never patches
   the dashboard binary.
   (The five hard requirements this implies — JSON content, MIME per
   file, counts present, summary uploaded, hierarchy data — are the
   difference between dashboards that render your films and ones
   that show nulls.)

## Caption discipline

- Captions are generated from the accurate (verbatim) gradepack;
  voice-over follows the audience layer text; both are labeled.
- Caption breaks land at sentence boundaries and natural pauses
  (from word timestamps), mid-cliffhanger breaks lose viewers.
- Caption overlays on compressed spans state the elision
  (see [07-cutting.md](07-cutting.md)).

## The honesty footer

Every scene in a reel ends with a citation footer:

```text
span: timeline events [ev-112..ev-127] · run: <run-id>@<commit>
quotes: [Q7, Q12] · generated: <tool versions>
```

The footer is generated; a scene without one is flagged by the film
checker as synthetic-teaching (allowed, but labeled).

## Pitfalls

- Diagrams as images — regenerate-ability dies; keep the mermaid
  source in the run directory.
- Overlays that assert what the footage does not show — the checker
  validates overlays against the timeline span they cite; overlays
  making claims beyond their span fail the build.
- Loading a JS framework per report — self-contained pages survive
  link rot and offline review; frameworks do not.
- Forgetting `mime` on published file entries (the classic broken
  dashboard).

## References

- [04-sync.md](04-sync.md) — diagram and table generation sources.
- [06-footage.md](06-footage.md) — publishing, MIME, size caps.
- [09-make-and-ci.md](09-make-and-ci.md) — the checker and its CI
  gates.
