# 11 — Factory: film matrices from scenario enumeration

## What

A film factory turns one filmable system into a matrix of films.

It enumerates the scenario space (participant dimensions × outcomes ×
special flows), records each scenario once, renders an audience layer per
footage take, gates every film against the merged timeline, and publishes
a reel.

The moving parts:

| Part | Role |
|---|---|
| Scenario table | Every combination of dimensions, plus named special flows |
| Group configs | Per-group environment for the system under test (feature flags, timers) |
| Composite recorder | All lanes in one viewport, one recording |
| Narration builder | Lines anchored to the recorded timeline, per audience |
| Gate battery | Sequence, forbidden-event, container, audio, cross-system checks |
| Reel | Index page and manifest generated from the scenario table |

## Why

Hand-made films cover the happy path, because that is what a human
chooses to film.

The interesting cells are the failure paths — windows that lapse, retries
that give up, states that never converge — and they only film correctly
when the environment is deliberately configured against success.

Audience variants share footage.
Recording the same scenario three times for three audiences multiplies
cost and lets "identical" takes drift apart; multiplying at render time
keeps one footage truth per scenario.

A film without a gate is a claim.
The merged timeline already states what must happen and what must never
happen; asserting on it turns every render into a test.

## How

1. **Enumerate before filming.**
   Write the scenario table first: dimensions (two or three), a bounded
   outcome set (settled, lapsed), and the special flows (multi-step,
   persistence, mixed rails).
   Every cell is either filmable in one take or explicitly out of scope
   with a reason.
2. **Group by environment.**
   Failure-path cells need helpers disabled and windows shortened; paid
   cells need helpers on.
   Put cells that share an environment into one group; the orchestrator
   writes the group's config, restarts the whole stack, records the
   group, then restores.
3. **Compose the lanes; record once.**
   One page: the client under test in an iframe, one terminal pane per
   backend lane, a scene bar.
   A small server spawns the system, parses narration events, feeds the
   panes over a websocket, and appends every line to the merged timeline
   with arrival timestamps.
   One viewport recording yields footage that is synchronized by
   construction.
4. **Anchor narration to the recording, not the plan.**
   Scene transitions land in the timeline as they happen; narration lines
   attach to scene indexes plus offsets.
   Each line gets the window until the next line; synthesize per line,
   tempo-fit when a line outgrows its window, pad the mixed track to the
   footage length.
5. **Draw the protocol while it runs.**
   The same narration events that feed the log feed a live sequence
   diagram: one lifeline per participant, one arrow per mapped event,
   self-messages for local decisions, and a `T+ss.mmm` stamp on every
   arrow and log line.
   The diagram is the merged timeline drawn instead of printed — a
   viewer sees causality at speaking speed, where a text log only
   supports it after study.
6. **Render voice over clean footage.**
   Narration audio lands on the composite recording; captions and
   scene titles live in the artifacts beside the film (subtitle file,
   manuscript), never burned into the pixels.
   Burned text duplicates the voice track, dates the footage, and
   fights the composition for attention.
7. **Gate every film.**
   The gate battery per film:
   sequence asserts (the events the scenario promises, in order),
   forbidden-event asserts (failure paths must contain no success
   events),
   container probes (codec, resolution, duration band),
   audio measurement inside a cue span,
   and a cross-system check (the durable registry state the footage
   claims to produce).
8. **Make the pipeline resumable.**
   A take that exists is skipped; a film that exists is re-gated, not
   re-rendered.
   A multi-hour matrix survives interruption and gate fixes without
   re-recording.
9. **Generate the reel from the table.**
   The index page links films, manuscripts, and timelines from the same
   scenario table that drove the run — no hand-maintained lists.

## Pitfalls

- **Standing success-helpers race failure windows.**
  A daemon installed to make demos hands-free (an auto-settler paying
  every obligation) settles inside shortened failure windows; the
  failure cells only film correctly with the helper paused for that
  group.
  Pause per group, restore after, and verify restoration — the helper
  exists for a reason.
- **Kill the supervisor tree between groups.**
  Restarting only the listener leaves the supervisor alive, and the
  supervisor respawns the listener with the previous group's config.
  The next take silently runs the wrong environment.
  Stop the tree, wait for the port to be free, then start.
- **Two dev servers on one checkout can share state.**
  Separate ports do not mean separate systems when both point at the
  same state directory; alarms and background turns execute against
  shared data.
  Inventory the state directory before blaming an external actor.
- **When the log omits the event, diff the state.**
  A node whose log never mentions settlement still exposes settlement in
  list calls; a one-second poll-diff reconstructs the missing lane from
  real state.
- **Slide the window; never parse a failed fetch as empty.**
  Polling the tail of a growing list must re-anchor the window each
  poll; a failed initial fetch read as an empty list pins the window to
  the oldest items and the watcher dies silently.
- **Budget the viewport before filming.**
  Panels added after the layout was set steal pixels from the
  protagonist; a status bar under a full-height phone crops the
  composer out of every frame.
  Sum the chrome (padding, bars, gaps) against the viewport before
  the first take, and verify with a frame, not a mental model.
- **One visible actor per causal arrow.**
  An external auto-settler that pays obligations on a wall-clock
  schedule produces payments with no sender in the diagram — effects
  without causes.
  Pause standing success-helpers while recording so the visible
  participant performs every step of the story, then restore them.
- **Stamp merged logs in milliseconds.**
  Second-resolution stamps order events that a diagram must sequence;
  `T+ss.mmm` keeps the log and the arrows agreeing.
- **Namespace data-driven class names.**
  Lane or event identifiers become CSS classes in the composition page;
  one collision with a layout rule silently repaints a whole panel.
  Prefix generated classes (`l-guest`, `l-rail`) and gate on painted
  pixels, not DOM presence.
- **Dynamic viewport units misreport in cross-origin iframes.**
  `100dvh` computes short in headless embedding; size the bezel to the
  app's observed extent instead of trusting viewport units.
- **Probe audio at cue starts.**
  Cue-end timestamps measure the gaps between lines; a gate reading
  silence there fails films that are fine.
- **Adjacent systems speak adjacent units.**
  A system that reports millisatoshi gets read as satoshi by humans; the
  1000× phantom propagates into reports.
  Render the derived unit beside the raw unit on every human surface.

## References

- [04-sync.md](04-sync.md) — narration events, the merged timeline
- [05-voice.md](05-voice.md) — synthesized narration, word-level timing
- [06-footage.md](06-footage.md) — capture patterns, run directories
- [09-make-and-ci.md](09-make-and-ci.md) — gates in CI, publishing policy
