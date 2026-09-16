# 06 — Footage: capture, storage, retention

## What

Raw footage is every artifact a run leaves behind — captured video,
screenshots, terminal/trace recordings, merged timelines, audio.
The run directory IS the footage store, and its layout is the
contract every downstream tool (cutting, overlays, publishing) reads.

## Why

- The decode window closes fast.
  Test frameworks and CI sweeps intermediate artifacts; the failure
  you want to film is only "steppable-through" while its evidence
  still exists.
- Films are re-rendered, not remembered.
  A film whose footage was pruned becomes a claim, not a record.
- Storage without policy is a cost incident.
  Video is the heaviest artifact class a CI produces; unbounded
  retention turns into a billed surprise.

## Capture: video from tests

Proven patterns, in order of effort:

1. **Framework video** (Playwright and siblings): record the
   browser/app under test; the fixture wires a video path per test.
2. **Client-harness recording**: the test's own client (a phone
   driver, a portal client) exposes a `record_portal_video(path)`
   method the fixture calls.
3. **Screen/session recording of the rig**: when the interesting
   surface is not one browser but the bench (devices, routers,
   boards), record the bench camera or the multiplexed terminal
   session.

Auto-capture policy (the earned default set):

| Trigger | Behavior |
|---|---|
| Test failed | Capture video automatically |
| Test passed | Capture only when opted in per run (env flag) or per test (marker) |
| Always | Screenshot on terminal state for every test (cheap, high value) |

## The static-scene prune

Most pass/fail videos of a calm UI are visually identical frame to
frame.
Before storing or embedding, run the static check:

```python
# scale to 160x90 grayscale-ish raw frames, diff consecutive frames,
# count pixels differing beyond a threshold; all-frames-below == static
extract = subprocess.run(
    ["ffmpeg", "-y", "-i", video_path,
     "-vf", "scale=160:90",
     "-f", "image2pipe", "-vcodec", "rawvideo", "-pix_fmt", "rgb24", "-"],
    capture_output=True, timeout=30,
)
```

- Frame-diff beyond thresholds ⇒ motion ⇒ keep.
- Static ⇒ delete and log the skip.
- Missing ffmpeg ⇒ assume static BUT never fail the test report over
  an optional dependency — reporting must be disruption-proof.

## Run directory layout

```text
films/<scenario-id>/<run-timestamp>/
├── manifest.json        # git SHAs of every system, tool versions, env fingerprint
├── timeline.jsonl       # merged narration (04-sync.md)
├── lanes/               # per-actor raw logs + event streams
├── footage/raw/         # <test>-<status>.webm / .mp4 / .png, sanitized names
├── voice/               # segments.json, gradepacks, per-scene clips
├── overlays/            # mermaid sources, step tables, SVG charts
└── index.html           # the reel
```

Naming: `re.sub(r'[^\w\-.]', '_', test_name)` + status suffix —
artifact consumers downstream sort and group on these names.

## Evidence banking rules (each earned by a lost debugging cycle)

1. **Save everything; truncate only the display.**
   Capture to file first; format at print time.
   Display-side truncation (piping a capture through `head`) destroys
   the settle verdict and forensics while the money moved fine.
2. **Bank failing-run evidence BEFORE anything else** — before
   cleanup, before the next run, before the write-up.
   The next gate (yours or another session's) destroys the logs.
3. **Long runs on ephemeral machines carry their own exfiltration.**
   A watcher (independent of the caller, fires on ANY exit including
   kill -9) packs the run dirs and ships them the moment the run
   exits.
   "Read it out later" on a machine that can vanish is a data-loss
   plan.
4. **Retention window, not immediate deletion.**
   Keep a 24h review window so failures stay steppable-through across
   runs; degrade (4h/1h) only on disk floors.
5. **Never edit a runner script while its process table shows an
   instance running** — incremental shell readers die mid-file.
6. **Re-run-safe drivers**: campaign drivers wipe every directory they
   own at start; a clone into an existing tree fails instantly and
   looks like a network error.

## Publishing and privacy

- A `can_publish` capability flag on the run environment, not a
  per-call decision.
  Ephemeral cloud environments with no real user data: publishable.
  Local/physical environments (real SSIDs, MACs, IPs, keys, numbers
  on whiteboards): never published — results stay in gitignored
  local dirs, and the publish script hard-gates on the flag.
- Content-addressed blob storage for everything published:
  sha256-addressed, mirrored to at least two independent servers,
  verifiable by gateway hash checks.
- A published run carries a structured index event (small,
  machine-readable: counts, file list with mime types and hashes) —
  messages and indexes in the message plane; blobs in the data plane.
  Shoving evidence blobs into index events is an anti-pattern that
  breaks every consumer.
- Every file entry in an index MUST carry an explicit MIME type:
  content-addressed URLs have no extensions, and without `mime` every
  player classifies footage as `application/octet-stream` and renders
  nothing.

## CI artifact economics

- Artifact storage is metered past a small free tier, even on plans
  where minutes are free.
  An unpaid storage overage can freeze org Actions entirely —
  symptom: workflows queue forever while every policy page reads
  "enabled".
  Set org retention ≤7 days AND per-workflow `retention-days` low.
- Videos are the multiplier.
  The static prune plus publish-not-store defaults keep a green CI
  from shipping gigabytes.
- Budget events, not vibes:
  estimated artifacts/month ≈ runs/month × videos-kept/run ×
  average video size — checked against the free tier before enabling
  capture-by-default anywhere.

## Pitfalls

- Embedding huge video into HTML reports without a size gate —
  base64 inflates by a third and the report stops loading; cap the
  embed size, link the rest.
- Screenshots without the state line: pair every image with the
  machine-readable state (the state-machine field from the UI) so the
  film's checker can validate what the eye sees.
- Treating CI's copy of artifacts as the archive — CI retention is a
  cache, not a library; published blobs are the library.

## References

- [04-sync.md](04-sync.md) — lanes and timelines.
- [08-overlays.md](08-overlays.md) — embedding rules.
- [09-make-and-ci.md](09-make-and-ci.md) — wiring capture into make
  and CI.
