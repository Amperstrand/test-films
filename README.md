# test-films

Turn your tests into films.
A standalone, project-agnostic methodology for making short explainer films
out of test suites, protocol runs, and bug investigations — with a
manuscript, a voice track, synchronized multi-system footage, and text
overlays — rendered for three audiences: **ELI5**, **ELI junior
developer**, and **ELI senior developer**.

This repo is a knowledge base, not a service.
It collects the lessons we earned while building this capability across
many projects, distilled so any team (humans or AI agents) can adopt the
practice without re-earning them.

## Why films from tests

We do a lot of AI-assisted ("vibe") coding.
Agents write and change code faster than humans can read the diffs.
Three things keep that honest:

1. **Tests prove behavior.** The suite is the contract.
2. **Films explain behavior.** A film makes one test, one scenario, or
   one bug visible to any audience in minutes — a newcomer, a senior
   reviewer, or another agent.
3. **Layered narration keeps everyone honest.** Writing the ELI5 forces
   comprehension; writing the senior layer forces precision. The
   owner-approval loop for consequential actions runs on exactly this
   pattern: the requester explains it back at ELI5 level before it
   ships.

A test that only a CI dashboard can see is half a test.
A film is the test, explained.

## What a film is

A film is a **self-describing run directory** plus a rendered page.
Not necessarily an `.mp4` — the package is the unit:

| Film term | Engineering artifact |
|---|---|
| Manuscript | Scenario page: sequence diagram, step table, walkthrough layers |
| Voice over | Transcript (ASR) or synthesized narration, word-level timestamps |
| Footage | Captured video/recordings from the test run, plus raw traces |
| Sync | Multi-system narration merged into one timeline |
| Cutting | Segmentation: scenes anchored to questions or divergence events |
| Text overlay | Diagrams, step tables, captions rendered over/next to footage |
| The reel | Self-contained HTML page or dashboard entry embedding all of it |

An `.mp4` render is one possible final form.
The run directory is the durable one.

## Quickstart

1. Read [docs/01-manifesto.md](docs/01-manifesto.md) for the shape of
   the practice.
2. Pick your audience level contract:
   [docs/02-audiences.md](docs/02-audiences.md).
3. Copy [templates/film-manuscript.md](templates/film-manuscript.md)
   and write the manuscript for one scenario of one test.
4. Add narration events to the systems under test:
   [docs/04-sync.md](docs/04-sync.md).
5. Wire capture, storage, and CI:
   [docs/06-footage.md](docs/06-footage.md) and
   [docs/09-make-and-ci.md](docs/09-make-and-ci.md).
6. Use [prompts/film-from-test.md](prompts/film-from-test.md) to have
   an AI agent draft the film from a green run, then edit it.

The worked example in
[examples/two-party-handshake/](examples/two-party-handshake/) shows a
complete manuscript for a generic two-party protocol handshake.

## Repository map

| Path | What it gives you |
|---|---|
| `docs/01-manifesto.md` | Why test films; what the package contains |
| `docs/02-audiences.md` | ELI5 / junior / senior layer contracts and rules |
| `docs/03-manuscript.md` | How to write the scenario manuscript |
| `docs/04-sync.md` | Narration events; syncing client/server/distributed systems |
| `docs/05-voice.md` | Voice pipeline: ASR, transcripts, narration, subtitles |
| `docs/06-footage.md` | Capturing, storing, pruning raw footage |
| `docs/07-cutting.md` | Segmentation and editing rules |
| `docs/08-overlays.md` | Diagrams, captions, report pages, dashboards |
| `docs/09-make-and-ci.md` | Make targets, CI jobs, gates, publishing policy |
| `docs/10-spec-quotes.md` | Verbatim spec-quote anchoring and drift detection |
| `docs/lessons-learned.md` | The master list of earned lessons |
| `templates/` | Manuscript, layered-summary, Makefile skeletons, and the browser-recording chrome kit (`film-chrome.ts`) |
| `tools/narrate-film.sh` | Synthesize, rate-fit, align, and mix a voice-over onto a recorded film from its timeline |
| `tools/record-film.sh` | Run a recording lane on a beefier remote box; pull video, stills, and timeline back |
| `tools/frames.sh` | Extract stills at timestamps for frame-by-frame review |
| `prompts/` | AI-agent prompts: film-from-test, film-script (owner-reviewed), narration-lines, frame-review, film-live-demo |
| `examples/` | Sanitized worked examples |

## Conventions

- One sentence per line in Markdown source (semantic line breaks).
- Tables for structured data; code blocks always carry a language tag.
- Relative links only; never absolute paths or external URLs for
  internal navigation.
- Active voice, present tense.
- No filler words. The forbidden list lives in [AGENTS.md](AGENTS.md).

## License

MIT — see [LICENSE](LICENSE).
