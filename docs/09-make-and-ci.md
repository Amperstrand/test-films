# 09 — Make and CI integration

## What

Films are produced by the same machinery that runs tests:
a make layer for humans, CI jobs for gates, and publish steps that
respect privacy.
No bespoke film server, no second pipeline to keep in sync.

## Why

- A film capability that lives outside the build is a capability that
  rots when the build changes.
- Gates (quote checks, doc honesty, narration coverage) only work
  where failures block: CI.
- The make layer is the teaching surface: `make film-<scenario>` is
  how a newcomer produces their first film without reading this repo.

## The make layer

Make targets are thin, discoverable stubs over the real runner
(a pytest suite or script) — the proven migration pattern for test
rigs that outgrew raw Makefiles:

```makefile
# templates/Makefile — copy into your project and fill <<PLACEHOLDER>>s
SCENARIO   ?= S0-happy-path
FILM_DIR   ?= films/$(SCENARIO)
PUBLISH_OK ?= $(shell ./scripts/provider.sh can-publish)

.PHONY: film-record film-cut film-check film-publish film-clean

film-record:      ## Run the scenario with narration + capture on
	<<RUNNER>> --scenario $(SCENARIO) --film-dir $(FILM_DIR) \
	    --narration --video-on-failure

film-cut:         ## Generate scene list + reel from the latest run
	<<RENDERER>> --film-dir $(FILM_DIR)

film-check:       ## Validate films: quotes, honesty, narration coverage
	<<CHECKER>> --film-dir $(FILM_DIR)

film-publish: film-check    ## Publish run index + blobs (gated)
	@if [ "$(PUBLISH_OK)" != "0" ]; then echo "publish disabled for this env"; exit 1; fi
	<<PUBLISHER>> --film-dir $(FILM_DIR)

film-clean:       ## Drop generated reels, KEEP raw footage + manifests
	rm -f $(FILM_DIR)/*/index.html
```

Rules:

- **The mapping lives in a registry file**
  (`config/make-targets.yaml`-style): target → pytest
  node ids/flags.
  Make stays a menu; the registry is the source of truth the CI also
  reads.
- `film-clean` never deletes footage or manifests — only generated
  views.

## CI jobs

| Job | Runs on | Gate |
|---|---|---|
| tests (+narration) | every push | existing suite, now emitting events |
| spec-quotes | every push | verbatim quote verifier — fails on drift (see 10-spec-quotes.md) |
| film-check | every push | doc honesty + narration coverage + overlay validation |
| film-render | on demand / nightly | reels for declared flagship scenarios |
| film-publish | main, gated | blobs + index events, only when `can_publish` |

Lessons that shape these jobs:

1. **Timeouts wrap binaries, never shell functions.**
    A `timeout N` around a function call "fails" instantly and
    silently.
2. **Wedged tests FAIL, they do not hang.**
    A per-test timeout plugin (and a per-run wall clock with a
    terminal marker) converts silent CI hangs into red builds.
3. **Artifact retention is a budget line.**
    Per-workflow `retention-days` low; org-level cap ≤7 days;
    the heavy artifacts that matter publish to blob storage, not CI
    storage (see 06-footage.md — an unpaid storage overage can freeze
    org Actions outright).
4. **Expected-fail phases pass only when the failure shows the
    required signature** — and an expected-fail that PASSES dies
    loudly, because behavior changed.
5. **Flake policy is a ledger, not a re-run button.**
    Retry once on a named, documented signature; a retry that still
    fails is a real failure.

## Drift control for distilled modules

When this repo's templates (or vendored tools) are copied into a
project, the copy can drift from the source.

- A drift manifest pins each lifted file: origin path + pinned
  revision.
- A CI job compares each file's current state against its pin and
  fails on divergence.
- On failure a human decides: update the copy to match, or bump the
  pin because the change is accounted for.
  (In THIS repo the origin identity is stripped per the anonymity
  law; the pin lives in the vendoring project, not here.)

## The GATE-READY card (before any expensive film run)

Long capture runs and overnight campaigns are the expensive rung of
the ladder; everything cheaper passes first.
Before launching, WRITE this card — it is both self-review and the
triage record:

```text
GATE-READY
changed:    <files + one-line intent each>
hypothesis: <what this run proves on film>
unit proof: <test names that pin it — or why none exists>
if wrong:   <expected failure signature>
preflight:  <checklist result>
```

A card you cannot fill out honestly means the run is NOT ready —
that realization is the card doing its job.

## Publishing policy (the gate order)

1. `can_publish` on the environment (local/physical NEVER publishes).
2. `film-check` green (no failing honesty/quote gates).
3. Redaction pass: grep the reel + manuscript for retracted claims
   and private data (real identifiers, internal hostnames).
4. Blobs to content-addressed storage (mirrored ≥2).
5. Index event last — the index is the atomic "this film exists"
   pointer; blobs first, index second, never the reverse.

## Pitfalls

- Making `film-*` targets that bypass the test runner — two sources
  of truth for what ran; the registry pattern exists to prevent it.
- Publishing from CI without the environment gate — physical-lab
  identifiers leaking into public dashboards is the permanent
  failure mode; the gate is per-environment capability, not
  per-pipeline convenience.
- Nightly render jobs that keep old reels — reels are generated
  views; clean and regenerate, retain the run directories.

## References

- [templates/Makefile](../templates/Makefile) — the full skeleton.
- [10-spec-quotes.md](10-spec-quotes.md) — the quote gate this
  chapter wires in.
