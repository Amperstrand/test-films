# 05 — Voice: transcripts, narration, subtitles

## What

The voice track of a film is either (a) a transcript of real audio
(review meetings, design calls, live narrated sessions) produced by
ASR, or (b) synthesized narration of the manuscript.
Both land in the run directory as structured, word-level-timestamped
data — never as a bare text blob.

## Why

- The transcript is a first-class manuscript SOURCE: the people who
  understand the system explain it out loud; ASR banks that
  explanation; the manuscript distills it.
- Word-level timestamps make subtitles and caption overlays
  mechanical instead of manual.
- A voice track turns a page somebody reads into a film somebody can
  watch while doing something else — which is the entire point for
  ELI5 audiences.

## The ASR pipeline (proven shape)

Self-hosted whisper-class ASR (faster-whisper / CTranslate2) in a
container, GPU-accelerated when a GPU exists, CPU-fine otherwise:

```text
audio in ──prefilter──▶ transcribe ──▶ gradepacks out
            (silence/      (model tier)     transcript.txt   plain, one line per segment
             voice-activity                 segments.json    timestamps + word-level data
             gate, saves                     report.md       run metadata, model, timings
             GPU-hours)
```

Rules and lessons:

- **Prefilter before transcribing.** A cheap voice-activity gate
  drops silence and near-silence; on long recordings this is the
  difference between minutes and hours of GPU time for identical
  output.
- **Emit gradepacks, not one output.** The same audio gets distinct
  renderings: an "accurate" pack (verbatim, timestamps, for
  archival/evidence) and an "llm-ready" pack (lightly normalized
  paragraphs, for model consumption).
  Consumers differ; one file serves none of them well.
- **Batch mode is a queue, not a loop.** A batch runner that claims
  jobs, processes, and writes completion markers survives
  interruption; an in-memory loop re-transcribes everything after a
  restart.
- **Local mode first, cloud mode optional.** The same container runs
  standalone (directory in, directory out) or behind an API + GPU
  worker (browser submits, worker claims, object storage holds
  audio/results, a small database holds the queue).
  Keep the core transcription step identical across both so results
  never depend on the deployment shape.
- **Cache by content hash.** The same audio submitted twice must not
  pay twice; key the cache on the file digest plus model tier.
- **Model tier is a declared film input.** Which model/size produced
  a transcript belongs in the manifest — a transcript's accuracy
  claims are meaningless without it.
- **Diarization is opt-in and separate.** Multi-speaker audio
  (meetings) gets speaker-attributed segments; single-voice
  narration does not pay the cost.

## From transcript to manuscript

1. Bank the recording and the gradepacks in the run directory.
2. Distill the llm-ready pack into manuscript layers — by an agent
   or by hand; the transcript is evidence, the manuscript is
   authorship (see 03-manuscript.md).
3. Cite the transcript in the manuscript's evidence block with the
   time range, the same way you cite a log line.

## Synthesized narration (voice-over)

When the film needs a voice that was never spoken:

1. Narrate FROM the manuscript layers — the ELI5 layer is the
   voice-over script for the ELI5 cut; verbatim reuse, no rewrites.
2. One voice per audience level, kept stable across the film series:
   audiences learn voices; changing the narrator mid-series is a
   re-orientation tax every viewer pays.
3. Generate per-scene audio keyed to the timeline (one clip per
   manuscript step), never one long take — per-scene clips make
   re-cutting a scene independent of every other scene.
4. Store the audio, the voice identifier, and the synthesizer
   settings in the manifest.
   A voice-over that cannot be regenerated identically is a
   maintenance liability, not an asset.
5. Local synthesizers keep the pipeline offline-capable and free;
   cloud voices sound better and cost per character.
   Decide per series, declare in the manifest, never mix voices
   within one film.

## Subtitles and captions

- Generate subtitle files (SRT/WebVTT) from `segments.json`
  word-level timestamps — splitting long segments on sentence
  boundaries at natural pauses.
- Every film gets captions by default.
  Accessibility is not an audience level you opt into.
- Caption text comes from the accurate gradepack (verbatim), while
  the voice-over may follow the ELI5 layer — do not silently swap
  one for the other; label which is which on the player.

## Voice during physical operations (a niche that pays)

When a long physical procedure runs hands-busy (flashing, recovery
modes, bench alignment), have the runner SPEAK its state transitions
through the OS speech facility (one-line shell calls; no new
dependency).
"Waiting for the recovery server", "upload started", "done,
rebooting" converts a 3-minute stare into an eyes-free procedure.
The same events that feed the timeline are the ones worth saying out
loud — emit narration, get voice for free.

## Synthesized narration that does not sound synthetic

Robotic narration is a choice, not a constraint.
A small local neural model turns a manuscript into speech that
reviewers stop noticing:

- **Model**: Kokoro-82M (public, ONNX, ~330 MB plus a voice pack).
  Loads in about a second, synthesizes faster than real time on CPU.
- **One process per line** keeps memory flat when rendering a matrix;
  the one-second load cost is cheaper than a resident server for
  short runs.
- **Declare the recipe** like any model input: voice id, speed factor,
  output gain — in the manifest, so the series stays consistent and
  regenerations do not drift.
- **GPU is optional**: the CUDA execution provider needs the matching
  system CUDA and cuDNN libraries; without them the model silently
  falls back to CPU, which is already real time.
  Do not spend an hour installing CUDA to save two minutes of render.
- Keep the deterministic robotic synthesizer around for one job:
  test fixtures that must sound identical on every machine.

## Pitfalls

- Transcribing everything "because storage is cheap" — GPU-hours are
  not; prefilter first.
- Trusting ASR punctuation/paragraphing as evidence — the accurate
  pack is verbatim WORDS; structure is added by the gradepack, not
  discovered by the model.
- One giant audio file per film — per-scene clips keep re-cuts
  local.
- Undeclared model/voice settings — regeneration drift makes the
  film series inconsistent over time.
- Gate audio at cue STARTS, not cue ends — the end timestamps of
  healthy narration measure the silence between lines.

## References

- [02-audiences.md](02-audiences.md) — which text becomes the
  voice-over for which cut.
- [07-cutting.md](07-cutting.md) — per-scene clips and cut points.
- [06-footage.md](06-footage.md) — retention applies to audio too.
